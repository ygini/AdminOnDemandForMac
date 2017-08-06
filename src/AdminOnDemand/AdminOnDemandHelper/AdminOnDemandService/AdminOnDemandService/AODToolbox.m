//
//  AODToolbox.m
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AODToolbox.h"
#import "AODQuery.h"
#import "Constants.h"

@interface AODToolbox ()

@property ODSession *odSession;
@property ODNode *odNode;

@end


@implementation AODToolbox

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSError *error = nil;
        
        self.odSession = [ODSession defaultSession];
        self.odNode = [ODNode nodeWithSession:self.odSession type:kODNodeTypeAuthentication error:&error];
        
        if (error) {
            NSLog(@"We are unable to get access to an Open Directory authentication node. This is bad. Reported error: %@", error);
            
            return nil;
        }
        
    }
    return self;
}

- (NSString*)listToString:(NSArray *)list {
    if ([list count] == 0) {
        return @"Empty List";
    } else if ([list count] == 1) {
        return [list firstObject];
    } else {
        NSMutableString *string = [NSMutableString new];
        
        for (NSInteger i = [list count] - 1; i >= 0; i--) {
            if ([string length] > 0) {
                [string insertString:@", " atIndex:0];
            }
            [string insertString:[list objectAtIndex:i] atIndex:0];
        }
        
        return string;
    }
}

- (NSArray*)arrayWithStringOrArray:(id)stringOrArray {
    if ([stringOrArray isKindOfClass:[NSString class]]) {
        if ([stringOrArray length] > 0) {
            return @[stringOrArray];
        } else {
            return nil;
        }
    } else if ([stringOrArray isKindOfClass:[NSArray class]]) {
        for (NSString *string in stringOrArray) {
            if ([string isKindOfClass:[NSString class]]) {
                if ([string length] == 0) {
                    return nil;
                }
            } else {
                return nil;
            }
        }
        
        return stringOrArray;
    }
    
    return nil;
}

- (void)recordForCurrentUser:(AODUserRecordRequestCompletionHandler)completionHandler {
    [self recordForUserWithRecordName:NSUserName() andCompletionHandler:completionHandler];
}

- (void)recordForUserWithRecordName:(NSString*)recordname andCompletionHandler:(AODUserRecordRequestCompletionHandler)completionHandler {
    [self singleRecordOfType:kODRecordTypeUsers
               matchingValue:recordname
                forAttribute:kODAttributeTypeRecordName
       withCompletionHandler:completionHandler];
}

- (void)recordForEUID:(uid_t)euid withCompletionHandler:(AODUserRecordRequestCompletionHandler)completionHandler {
    [self singleRecordOfType:kODRecordTypeUsers
               matchingValue:[NSString stringWithFormat:@"%d", euid]
                forAttribute:kODAttributeTypeUniqueID
       withCompletionHandler:completionHandler];
}

- (void)singleRecordOfType:(ODRecordType)recordType matchingValue:(id)values forAttribute:(ODAttributeType)attribute withCompletionHandler:(AODUserRecordRequestCompletionHandler)completionHandler {
    NSError *error = nil;
    AODQuery *requestedUserQuery = [AODQuery queryWithNode:self.odNode
                                            forRecordTypes:recordType
                                                 attribute:attribute
                                                 matchType:kODMatchEqualTo
                                               queryValues:values
                                          returnAttributes:kODAttributeTypeAllAttributes
                                            maximumResults:0
                                                     error:&error];
    
    if (error) {
        completionHandler(nil, error);
    } else {
        
        [requestedUserQuery runQueryWithCompletionHandler:^(AODQuery *query, NSArray *results, NSError *error) {
            if ([results count] == 1) {
                completionHandler([results firstObject], nil);
            } else {
                completionHandler(nil, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                           code:kAODErrorCodeTooManyResults
                                                       userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"We are unable to find a coherent result when querying Open Directory. This is bad."]}]);
            }
        }];
    }
}

- (void)preflightForScenarioWithName:(NSString*)scenarioName withDetails:(NSDictionary*)scenario byUserWithRecord:(ODRecord*)userRecord andUseCompletionHandler:(void (^)(BOOL authorized, NSError *error, NSDictionary* scenario))completionHandler {
    NSMutableDictionary *scenarioDetails = [scenario mutableCopy];
    NSArray *elevatedGroups = [self arrayWithStringOrArray:[scenarioDetails objectForKey:kAODScenarioElevatedGroups]];
    
    if ([elevatedGroups count] == 0) {
        completionHandler(NO, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                  code:kAODErrorCodeEmptyElevatedGroups
                                              userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"We've be requested to run scenario `%@`, however key `%@` for this scenario is empty, so we won't do anything.", scenarioName, kAODScenarioElevatedGroups]}], scenarioDetails);
    } else {
        
        NSArray *allowedRequester = [self arrayWithStringOrArray:[scenarioDetails objectForKey:kAODScenarioRequester]];
        
        if (!allowedRequester) {
            allowedRequester = @[@"everyone"];
            [scenarioDetails setObject:allowedRequester forKey:kAODScenarioRequester];
        }
        
        NSError *error = nil;
        AODQuery *allowedRequesterQuery = [AODQuery queryWithNode:self.odNode
                                                   forRecordTypes:kODRecordTypeGroups
                                                        attribute:kODAttributeTypeRecordName
                                                        matchType:kODMatchEqualTo
                                                      queryValues:allowedRequester
                                                 returnAttributes:kODAttributeTypeAllAttributes
                                                   maximumResults:0
                                                            error:&error];
        
        
        [allowedRequesterQuery runQueryWithCompletionHandler:^(AODQuery *query, NSArray *results, NSError *error) {
            
            if (error) {
                completionHandler(NO, error, scenarioDetails);
            } else if ([results count] > 0) {
                BOOL requestedUserIsMemberOfAtLeastOneAllowedRequester = NO;
                for (ODRecord *groupOfAllowedRequester in results) {
                    NSError *error = nil;
                    requestedUserIsMemberOfAtLeastOneAllowedRequester = [groupOfAllowedRequester isMemberRecord:userRecord error:&error];
                    if (requestedUserIsMemberOfAtLeastOneAllowedRequester) {
                        break;
                    }
                }
                
                if (requestedUserIsMemberOfAtLeastOneAllowedRequester) {
                    
                    NSNumber *timeInSeconds = [scenarioDetails objectForKey:kAODScenarioTimeInSeconds];
                    if (!timeInSeconds) {
                        [scenarioDetails setObject:[NSNumber numberWithInteger:30*60] forKey:kAODScenarioTimeInSeconds];
                    }
                    
                    completionHandler(YES, nil, scenarioDetails);
                } else {
                    completionHandler(NO, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                              code:kAODErrorCodeRequesterNotAllowed
                                                          userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"We've be requested to run scenario `%@`, however `%@` isn't allowed, so we won't do anything.", scenarioName, [self usernameForRecord:userRecord withError:nil]]}], scenarioDetails);
                }
            } else {
                completionHandler(NO, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                          code:kAODErrorCodeRequesterNotAllowed
                                                      userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"We've be requested to run scenario `%@`, however requester groups `%@` does not exist, so we won't do anything.", scenarioName, [self listToString:allowedRequester ]]}], scenarioDetails);
            }
        }];
    }
}

- (NSString*)usernameForRecord:(ODRecord *)record withError:(NSError**)error {
    NSArray *values = [record valuesForAttribute:kODAttributeTypeRecordName error:error];
    if ([values count] > 0) {
        return [values firstObject];
    }
    
    return nil;
}

@end

//
//  AdminOnDemandService.m
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AdminOnDemandService.h"
#import "AODToolbox.h"
#import "Constants.h"
#import "AdminOnDemandTracker.h"
#import <OpenDirectory/OpenDirectory.h>

@implementation AdminOnDemandService

- (void)requestingUserRecord:(void(^)(ODRecord *requestingRecord, NSError *error))completionHandler {
    
    [[AODToolbox sharedInstance] recordForEUID:self.relatedConnection.effectiveUserIdentifier
                         withCompletionHandler:completionHandler];
}

- (void)requestingUsername:(void(^)(NSString *username, NSError *error))completionHandler {
    
    [self requestingUserRecord:^(ODRecord *requestingRecord, NSError *error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            NSError *error = nil;
            NSString *username = [[AODToolbox sharedInstance] usernameForRecord:requestingRecord withError:&error];
            
            completionHandler(username, error);
        }
    }];
}

- (void)requestForScenarioWithName:(NSString*)scenarioName withCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    NSDictionary *scenario = nil;
    
    [self requestingUserRecord:^(ODRecord *requestingRecord, NSError *error) {
        if (error) {
            completionHandler(NO, error);
        } else if (requestingRecord) {
            [[AODToolbox sharedInstance] preflightForScenarioWithName:scenarioName withDetails:scenario byUserWithRecord:requestingRecord andUseCompletionHandler:^(BOOL authorized, NSError *error, NSDictionary* scenarioDetails) {
                if (error) {
                    completionHandler(NO, error);
                } else if (!authorized) {
                    completionHandler(NO, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                              code:kAODErrorCodeRequesterNotAllowed
                                                          userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"We've be requested to run scenario `%@`, however `%@` isn't allowed, so we won't do anything.", scenarioName, NSUserName()]}]);
                } else {
                    NSDate *startDate = [NSDate date];
                    NSTimeInterval timeInSeconds = [[scenarioDetails objectForKey:kAODScenarioTimeInSeconds] doubleValue];
                    NSDate *endDate = [startDate dateByAddingTimeInterval:timeInSeconds];
                    for (NSString *group in [scenarioDetails objectForKey:kAODScenarioRequester]) {
                        
                        [[AdminOnDemandTracker sharedInstance] authorizationGivenTo:group via:scenarioName at:startDate until:endDate by:[[AODToolbox sharedInstance] usernameForRecord:requestingRecord withError:nil]];
                    }
                    
                    completionHandler(YES, nil);
                }
            }];
        } else {
            completionHandler(NO, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                      code:kAODErrorCodeRequesterNotFound
                                                  userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"We've be requested to run scenario `%@`, we are unable to identify the requester.", scenarioName]}]);

        }
    }];
}

@end

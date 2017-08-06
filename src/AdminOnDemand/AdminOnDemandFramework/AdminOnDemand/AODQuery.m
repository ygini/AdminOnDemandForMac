//
//  AODQuery.m
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AODQuery.h"

@interface AODQuery () <ODQueryDelegate>
@property AODQueryCompletionHandler completionHandler;
@property NSMutableArray *results;
@property NSError *error;
@end

@implementation AODQuery

#pragma mark Overriding

+(instancetype)queryWithNode:(ODNode *)inNode
              forRecordTypes:(id)inRecordTypeOrList
                   attribute:(ODAttributeType)inAttribute
                   matchType:(ODMatchType)inMatchType
                 queryValues:(id)inQueryValueOrList
            returnAttributes:(id)inReturnAttributeOrList
              maximumResults:(NSInteger)inMaximumResults
                       error:(NSError **)outError
{
    return (AODQuery *)[super queryWithNode:inNode
                             forRecordTypes:inRecordTypeOrList
                                  attribute:inAttribute
                                  matchType:inMatchType
                                queryValues:inQueryValueOrList
                           returnAttributes:inReturnAttributeOrList
                             maximumResults:inMaximumResults
                                      error:outError];
}

#pragma mark Addons

- (void)runQueryWithCompletionHandler:(AODQueryCompletionHandler)completionHandler
{
    [self runQueryWithCompletionHandler:completionHandler onRunLoop:[NSRunLoop currentRunLoop] withMode:NSDefaultRunLoopMode];
}

- (void)runQueryWithCompletionHandler:(AODQueryCompletionHandler)completionHandler onRunLoop:(NSRunLoop*)runLoop withMode:(NSString*)runLoopMode
{
    if (!self.completionHandler) {
        self.completionHandler = [completionHandler copy];
        self.results = [NSMutableArray new];
        [self setDelegate:self];
        [self scheduleInRunLoop:runLoop forMode:runLoopMode];
    }
    else
    {
        [NSException raise:kAODQueryAlreadyUsedException format:@"Trying to run an already used query, behavior not supported"];
    }
}

#pragma mark self delegate

-(void)query:(AODQuery *)inQuery foundResults:(NSArray *)inResults error:(NSError *)inError
{
    // When using network account with mobility enabled, a record can be returned two time.
    // The same with someone still using augmented records.

    for (ODRecord *record in inResults) {
        NSError *error = nil;
        NSArray *GUIDs = [record valuesForAttribute:kODAttributeTypeGUID
                                              error:&error];
        
        if (error) {
            [NSException raise:kAODQueryImpossibleGUIDException format:@"Impossible to get GUID for a query result"];
        } else if ([GUIDs count] != 1) {
            [NSException raise:kAODQueryIncoherentGUIDException format:@"Incoherent GUID for a query result"];
        } else {
            NSString *GUID = [GUIDs firstObject];
            __block BOOL GUIDAlreadyExist = NO;
            [self.results enumerateObjectsUsingBlock:^(ODRecord *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSError *error = nil;
                NSArray *alreadyAddeddGUIDs = [record valuesForAttribute:kODAttributeTypeGUID
                                                                   error:&error];
                
                if (error) {
                    [NSException raise:kAODQueryImpossibleGUIDException format:@"Impossible to get GUID for a query result"];
                } else if ([alreadyAddeddGUIDs count] != 1) {
                    [NSException raise:kAODQueryIncoherentGUIDException format:@"Incoherent GUID for a query result"];
                } else {
                    NSString *alreadyAddeddGUID = [alreadyAddeddGUIDs firstObject];
                    if ([alreadyAddeddGUID isEqualToString:GUID]) {
                        GUIDAlreadyExist = YES;
                    }
                }
            }];
            
            if (!GUIDAlreadyExist) {
                [self.results addObject:record];
            }
        }
    }

    if (inError) {
        self.error = inError;
    }
    
    if (!inError && !inResults) {
        self.completionHandler(self, self.results, self.error);
    }
}


@end

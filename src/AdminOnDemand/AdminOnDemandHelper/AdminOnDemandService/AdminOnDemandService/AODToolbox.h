//
//  AODToolbox.h
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenDirectory/OpenDirectory.h>

typedef void(^AODUserRecordRequestCompletionHandler)(ODRecord *requestedUser, NSError* error);
typedef void(^AODScenarioCompletionHandler)(BOOL succeed, NSError* error);

@interface AODToolbox : NSObject

+ (instancetype)sharedInstance;

- (NSArray*)arrayWithStringOrArray:(id)stringOrArray;
- (void)recordForCurrentUser:(AODUserRecordRequestCompletionHandler)completionHandler;
- (void)recordForUserWithRecordName:(NSString*)recordname andCompletionHandler:(AODUserRecordRequestCompletionHandler)completionHandler;
- (void)recordForEUID:(uid_t)euid withCompletionHandler:(AODUserRecordRequestCompletionHandler)completionHandler;
- (void)singleRecordOfType:(ODRecordType)recordType matchingValue:(id)values forAttribute:(ODAttributeType)attribute withCompletionHandler:(AODUserRecordRequestCompletionHandler)completionHandler;
- (void)preflightForScenarioWithName:(NSString*)scenarioName withDetails:(NSDictionary*)scenario byUserWithRecord:(ODRecord*)userRecord andUseCompletionHandler:(void (^)(BOOL authorized, NSError *error, NSDictionary* scenario))completionHandler;
- (NSString*)usernameForRecord:(ODRecord *)record withError:(NSError**)error;
@end

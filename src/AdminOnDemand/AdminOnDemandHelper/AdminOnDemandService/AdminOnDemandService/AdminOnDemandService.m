//
//  AdminOnDemandService.m
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AdminOnDemandService.h"

#import <AdminOnDemand/AdminOnDemand.h>
#import "AdminOnDemandTracker.h"

@implementation AdminOnDemandService

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)requestForScenarioWithName:(NSString*)scenarioName details:(NSDictionary *)scenario byUser:(NSString*)username andCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    CFPropertyListRef prefs = CFPreferencesCopyValue((CFStringRef)scenarioName, (CFStringRef)@"com.github.ygini.AdminOnDemand", kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    NSLog(@"TEST %@", prefs);
    [[AODToolbox sharedInstance] preflightForScenarioWithName:scenarioName withDetails:scenario byUser:username andUseCompletionHandler:^(BOOL authorized, NSError *error, NSDictionary* scenarioDetails) {
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
                
                [[AdminOnDemandTracker sharedInstance] authorizationGivenTo:group via:scenarioName at:startDate until:endDate by:username];
            }
            
            completionHandler(YES, nil);
        }
    }];
}

@end

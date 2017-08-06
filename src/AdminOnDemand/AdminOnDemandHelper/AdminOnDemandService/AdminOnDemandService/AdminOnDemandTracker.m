//
//  AdminOnDemandTracker.m
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AdminOnDemandTracker.h"

#define kAODLogFile @"/Library/Logs/AdminOnDemand.log"
#define kAODTracker @"/Library/Application Support/com.github.ygini.AdminOnDemand/tracker.plist"

@interface AdminOnDemandTracker ()
@property NSLock* lock;
@end

@implementation AdminOnDemandTracker

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
        self.lock = [NSLock new];
    }
    return self;
}

- (void)authorizationGivenTo:(NSString*)groupName via:(NSString*)scenario at:(NSDate*)addTime until:(NSDate*)removalTime by:(NSString*)username {
    [self.lock lock];
    
    NSMutableString* logFile = [NSMutableString stringWithContentsOfFile:kAODLogFile encoding:NSUTF8StringEncoding error:nil];
    if (!logFile) {
        logFile = [NSMutableString new];
    }
    
    [logFile appendFormat:@"Scenario `%@` started by `%@` on `%@` gave admin rights to `%@`, will stand until `%@`", scenario, username, addTime, groupName, removalTime];
    [logFile appendString:@"\n"];
    
    [logFile writeToFile:kAODLogFile atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSMutableDictionary *tracker = [NSMutableDictionary dictionaryWithContentsOfFile:kAODTracker];

    [tracker setObject:removalTime forKey:groupName];
    
    [tracker writeToFile:kAODTracker atomically:YES];
    
    [self.lock unlock];
}

@end

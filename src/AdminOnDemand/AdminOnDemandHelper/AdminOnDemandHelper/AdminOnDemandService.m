//
//  AdminOnDemandService.m
//  AdminOnDemandHelper
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AdminOnDemandService.h"

#import "AdminOnDemandServiceProtocol.h"

@interface AdminOnDemandService () {
    NSXPCConnection *_connectionToService;
}

@end

@implementation AdminOnDemandService

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
        _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"com.github.ygini.AdminOnDemandService"];
        _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AdminOnDemandServiceProtocol)];
        [_connectionToService resume];
    }
    return self;
}

- (void)terminate {
    [_connectionToService invalidate];
}

- (void)requestingUsername:(void(^)(NSString *username, NSError *error))completionHandler {
    [[_connectionToService remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        completionHandler(nil, error);
    }] requestingUsername:completionHandler];
}

- (void)requestForScenarioWithName:(NSString*)scenarioName withCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    [[_connectionToService remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        completionHandler(NO, error);
    }] requestForScenarioWithName:scenarioName withCompletionHandler:completionHandler];
}

@end

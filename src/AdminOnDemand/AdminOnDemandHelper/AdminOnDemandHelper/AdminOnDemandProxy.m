//
//  AdminOnDemandService.m
//  AdminOnDemandHelper
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AdminOnDemandProxy.h"

#import "AdminOnDemandServiceProtocol.h"

@interface AdminOnDemandProxy ()
@end

@implementation AdminOnDemandProxy

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
        _xpcService = [[NSXPCConnection alloc] initWithServiceName:@"com.github.ygini.AdminOnDemandService"];
        _xpcService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AdminOnDemandServiceProtocol)];
        [_xpcService resume];
    }
    return self;
}

- (void)terminate {
    [self.xpcService invalidate];
}

- (void)requestingUsername:(void(^)(NSString *username, NSError *error))completionHandler {
    [[self.xpcService remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        completionHandler(nil, error);
    }] requestingUsername:completionHandler];
}

- (void)requestForScenarioWithName:(NSString*)scenarioName withCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    [[self.xpcService remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        completionHandler(NO, error);
    }] requestForScenarioWithName:scenarioName withCompletionHandler:completionHandler];
}

@end

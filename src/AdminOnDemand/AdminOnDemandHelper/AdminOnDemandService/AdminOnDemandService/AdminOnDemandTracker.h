//
//  AdminOnDemandTracker.h
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdminOnDemandTracker : NSObject

+ (instancetype)sharedInstance;

- (void)authorizationGivenTo:(NSString*)groupName via:(NSString*)scenario at:(NSDate*)addTime until:(NSDate*)removalTime by:(NSString*)username;

@end

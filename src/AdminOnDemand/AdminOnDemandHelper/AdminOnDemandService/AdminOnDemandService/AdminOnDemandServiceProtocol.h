//
//  AdminOnDemandServiceProtocol.h
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AdminOnDemandServiceProtocol

- (void)requestingUsername:(void(^)(NSString *username, NSError *error))completionHandler;
- (void)requestForScenarioWithName:(NSString*)scenarioName withCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
    
@end

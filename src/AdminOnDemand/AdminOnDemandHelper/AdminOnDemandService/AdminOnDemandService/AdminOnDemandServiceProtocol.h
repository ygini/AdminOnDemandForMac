//
//  AdminOnDemandServiceProtocol.h
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AdminOnDemandServiceProtocol

- (void)requestForScenarioWithName:(NSString*)scenarioName details:(NSDictionary *)scenario byUser:(NSString*)username andCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
    
@end

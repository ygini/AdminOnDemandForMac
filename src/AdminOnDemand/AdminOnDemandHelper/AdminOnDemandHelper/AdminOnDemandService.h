//
//  AdminOnDemandService.h
//  AdminOnDemandHelper
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdminOnDemandServiceProtocol.h"

@interface AdminOnDemandService : NSObject <AdminOnDemandServiceProtocol>

+ (instancetype)sharedInstance;

@end

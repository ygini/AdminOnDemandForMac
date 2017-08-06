//
//  AdminOnDemandService.h
//  AdminOnDemandService
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdminOnDemandServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface AdminOnDemandService : NSObject <AdminOnDemandServiceProtocol>

@property (assign) NSXPCConnection *relatedConnection;

@end

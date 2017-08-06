//
//  Constants.h
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kAODCommandLineSelector @"useScenario"

#define kAODScenarioRequester @"requester"
#define kAODScenarioElevatedGroups @"elevatedGroups"
#define kAODScenarioTimeInSeconds @"timeInSeconds"

typedef enum : NSUInteger {
    kAODErrorCodeEmptyElevatedGroups = 1789,
    kAODErrorCodeRequesterNotAllowed,
    kAODErrorCodeRequesterNotFound,
    kAODErrorCodeTooManyResults,
    kAODErrorCodeTooManyValues,
} kAODErrorCode;

#endif /* Constants_h */

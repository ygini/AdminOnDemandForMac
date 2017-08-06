//
//  AODQuery.h
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenDirectory/OpenDirectory.h>

@class AODQuery;

typedef void(^AODQueryCompletionHandler)(AODQuery *query, NSArray *results, NSError *error);
#define kAODQueryAlreadyUsedException           @"AODQueryAlreadyUsedException"
#define kAODQueryIncoherentGUIDException		@"AODQueryIncoherentGUIDException"
#define kAODQueryImpossibleGUIDException		@"AODQueryImpossibleGUIDException"

@interface AODQuery : ODQuery

+(instancetype)queryWithNode:(ODNode *)inNode
              forRecordTypes:(id)inRecordTypeOrList
                   attribute:(ODAttributeType)inAttribute
                   matchType:(ODMatchType)inMatchType
                 queryValues:(id)inQueryValueOrList
            returnAttributes:(id)inReturnAttributeOrList
              maximumResults:(NSInteger)inMaximumResults
                       error:(NSError **)outError;

- (void)runQueryWithCompletionHandler:(AODQueryCompletionHandler)completionHandler;
- (void)runQueryWithCompletionHandler:(AODQueryCompletionHandler)completionHandler onRunLoop:(NSRunLoop*)runLoop withMode:(NSString*)runLoopMode;

@end

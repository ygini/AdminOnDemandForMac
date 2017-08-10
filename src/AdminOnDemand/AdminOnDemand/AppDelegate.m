//
//  AppDelegate.m
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <AdminOnDemandHelper/AdminOnDemandHelper.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [AdminOnDemandProxy sharedInstance].xpcService.interruptionHandler = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSAlert alertWithMessageText:@"XPC got interrupted"
                        defaultButton:@"OK"
                      alternateButton:nil
                          otherButton:nil
                 informativeTextWithFormat:@""] runModal];
        });
    };
    
    [AdminOnDemandProxy sharedInstance].xpcService.invalidationHandler = ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [[NSAlert alertWithMessageText:@"XPC got invalided"
                         defaultButton:@"OK"
                       alternateButton:nil
                           otherButton:nil
                informativeTextWithFormat:@""] runModal];
       });

    };
    
    NSString *scenarioToUse = [[NSUserDefaults standardUserDefaults] stringForKey:kAODCommandLineSelector];
 
    [[AdminOnDemandProxy sharedInstance] requestForScenarioWithName:scenarioToUse withCompletionHandler:^(BOOL success, NSError *error) {
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
                [NSApplication.sharedApplication terminate:self];
            });
            
        } else {
            [NSApplication.sharedApplication terminate:self];
        }
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}




@end

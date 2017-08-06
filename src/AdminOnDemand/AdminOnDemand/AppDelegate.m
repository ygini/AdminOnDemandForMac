//
//  AppDelegate.m
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import "AppDelegate.h"
#import <AdminOnDemand/AdminOnDemand.h>
#import <AdminOnDemandHelper/AdminOnDemandHelper.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSString *scenarioToUse = [[NSUserDefaults standardUserDefaults] stringForKey:kAODCommandLineSelector];
    
    [[AODToolbox sharedInstance] preflightForScenarioWithName:scenarioToUse withDetails:[[NSUserDefaults standardUserDefaults] dictionaryForKey:scenarioToUse] byUser:NSUserName() andUseCompletionHandler:^(BOOL authorized, NSError *error, NSDictionary *scenario) {
        if (error) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
            [NSApplication.sharedApplication terminate:self];
        } else {
            
            [[AdminOnDemandService sharedInstance] requestForScenarioWithName:scenarioToUse details:scenario byUser:NSUserName() andCompletionHandler:^(BOOL success, NSError *error) {
                if (error) {
                    NSAlert *alert = [NSAlert alertWithError:error];
                    [alert runModal];
                    [NSApplication.sharedApplication terminate:self];
                } else {
                    [NSApplication.sharedApplication terminate:self];
                }
            }];
        }
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}




@end

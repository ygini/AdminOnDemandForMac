//
//  main.m
//  AdminOnDemand
//
//  Created by Yoann Gini on 06/08/2017.
//  Copyright © 2017 Yoann Gini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    AppDelegate *appDelegate = [AppDelegate new];
    NSApplication.sharedApplication.delegate = appDelegate;
    return NSApplicationMain(argc, argv);
}

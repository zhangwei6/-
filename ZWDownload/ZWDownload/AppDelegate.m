//
//  AppDelegate.m
//  ZWDownload
//
//  Created by Admin on 2020/5/29.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "AppDelegate.h"
#import "ZWMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // @available(iOS 13.0,*)表示iOS 13.0及以上的系统，后面的*表示所有平台
    if (@available(iOS 13.0,*)) {
        
    }else{
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = UIColor.whiteColor;
        [self.window makeKeyAndVisible];
        
        ZWMainViewController *vc = [ZWMainViewController new];
        
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
    }
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end

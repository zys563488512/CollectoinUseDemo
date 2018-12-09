//
//  AppDelegate.m
//  Push
//
//  Created by 张 永盛 on 2018/12/8.
//  Copyright © 2018 张 永盛. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificationController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.rootViewController = [[NotificationController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    // 设置Notification的代理对象
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    // 询问用户是否同意App的消息通知
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"用户同意发送通知");
        }
    }];
    [self addCategoryWithNotification];
    return YES;
}
/**
 添加Category
 */
- (void)addCategoryWithNotification {
    
    // 设置Notification的Action Button
    UNNotificationAction *cancel = [UNNotificationAction actionWithIdentifier:@"cancel" title:@"cancel" options:UNNotificationActionOptionForeground];
    
    // 设置Notification的Category
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"push" actions:@[cancel] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    NSSet *categorySet = [NSSet setWithObject:category];
    
    // 设置Notification的Categories
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categorySet];
}

#pragma mark - UserNotificationCenterDelegate方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    if ([response.actionIdentifier isEqual:@"cancel"]) {
        UNNotificationRequest * request = response.notification.request;
        NSLog(@"删除了通知identifier: %@",request.identifier);
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[request.identifier]];
    }
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

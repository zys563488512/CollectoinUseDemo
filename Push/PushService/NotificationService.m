//
//  NotificationService.m
//  PushService
//
//  Created by 张 永盛 on 2018/12/8.
//  Copyright © 2018 张 永盛. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    // 我们可以在此重写一些东西
    // 重写一些东西
    self.bestAttemptContent.title = @"我是标题";
    self.bestAttemptContent.subtitle = @"我是副标题";
    self.bestAttemptContent.body = @"信息内容";
    
    self.contentHandler(self.bestAttemptContent);
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end

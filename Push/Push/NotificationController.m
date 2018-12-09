//
//  NotificationController.m
//  Push
//
//  Created by 张 永盛 on 2018/12/8.
//  Copyright © 2018 张 永盛. All rights reserved.
//

#import "NotificationController.h"
#import "NotificationCell.h"
#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>
#define weakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self

#define NORMAL_IDENTIFIER @"Normal"
#define IMAGE_IDENTIFIER  @"Image"
#define VIDEO_IDENTIFIER  @"Video"
#define VOICE_IDENTIFIER  @"Voice"

typedef NS_ENUM(NSInteger, NotificationType) {
    NotificationNormalType = 0,
    NotificationImageType,
    NotificationVideoType,
    NotificationVoiceType
};

@interface NotificationController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation NotificationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSArray *)dataSource {
    
    NSDictionary *normalType = @{@"title":@"Normal Type",
                                 @"tag":@(NotificationNormalType),
                                 @"identifier":NORMAL_IDENTIFIER};
    
    NSDictionary *imageType = @{@"title":@"Image Type",
                                @"tag":@(NotificationImageType),
                                @"identifier":IMAGE_IDENTIFIER};
    
    NSDictionary *videoType = @{@"title":@"Video Type",
                                @"tag":@(NotificationVideoType),
                                @"identifier":VIDEO_IDENTIFIER};
    NSDictionary *voiceType = @{@"title":@"Voice Type",
                                @"tag":@(NotificationVoiceType),
                                @"identifier":VOICE_IDENTIFIER};
    
    return @[normalType, imageType, videoType,voiceType];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NotificationCell *notificationCell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    
    if (!notificationCell) {
        
        notificationCell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"NotificationCell"];
        
    }
    
    notificationCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [notificationCell configuraCellWithDictionary:self.dataSource[indexPath.row]];
    
    [notificationCell setNotificationTypeAction:^(UISwitch *sender){
        
        if (sender.on) {
            
            [self createReminderNotificationWithTag:sender.tag];
            
        } else {
            
            NSDictionary *dictionary = self.dataSource[indexPath.row];
            
            // 删除指定Identifier的Notification
            [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[dictionary[@"identifier"]]];
            
            NSLog(@"删除了%@通知", dictionary[@"identifier"]);
        }
    }];
    
    return notificationCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

/**
 根据不同的Cell类型添加通知
 @param tag NotificationType
 */
- (void)createReminderNotificationWithTag:(NotificationType)tag {
    
    // 实例化Notification Content
    UNMutableNotificationContent *notificatinoContent = [[UNMutableNotificationContent alloc] init];

    // 设置Notification Content
    notificatinoContent.title = @"UserNotifications";
    notificatinoContent.sound = [UNNotificationSound defaultSound];
    notificatinoContent.categoryIdentifier = @"push";
    
    NSString *identifier = @"";
    
    switch (tag) {
        case NotificationNormalType:
       
            notificatinoContent.title = @"noraml title";
            notificatinoContent.body = @"这是一条正常的通知.";

            identifier = NORMAL_IDENTIFIER;
            
            break;
        case NotificationImageType: {
            
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"01"
                                                                  ofType:@"jpg"];
            NSLog(@"imagePath ----- %@",imagePath);
            NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
            
            // 设置一个添加了图片的Notification Attachment
            UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"imageAttachment" URL:imageURL options:nil error:nil];
            notificatinoContent.attachments = @[att];
            notificatinoContent.body = @"这是一条带图片的通知";
            
            identifier = IMAGE_IDENTIFIER;
        }
            break;
        case NotificationVideoType: {
            NSString *str = [[NSBundle mainBundle] resourcePath];
            NSString *videoPath = [NSString stringWithFormat:@"%@%@",str,@"/video.mp4"];
            NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
            // 设置一个添加了视频的Notification Attachment
            UNNotificationAttachment * att = [UNNotificationAttachment attachmentWithIdentifier:@"videoAttachment" URL:videoURL options:nil error:nil];
                notificatinoContent.attachments = @[att];
            
            notificatinoContent.body = @"这是一条带视频的通知";
            
            identifier = VIDEO_IDENTIFIER;
        }
            break;
        case NotificationVoiceType: {
            notificatinoContent.title = @"voice title";
            notificatinoContent.subtitle = @"播放一段音频";
            NSString *str = [[NSBundle mainBundle] resourcePath];
            NSString *voicePath = [NSString stringWithFormat:@"%@%@",str,@"/ailis.m4a"];
            NSURL *voiceURL = [NSURL fileURLWithPath:voicePath];
            NSError * error;
            // 设置一个添加了音频的Notification Attachment
            UNNotificationAttachment * att = [UNNotificationAttachment attachmentWithIdentifier:@"voiceAttachment" URL:voiceURL options:nil error:&error];
            if (error) {
                NSLog(@"error ---- %@",error);
            }
            notificatinoContent.attachments = @[att];
            notificatinoContent.body = @"这是一条带音频的通知";
            NSError *error1;
            AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:&error1];
            if (error) {
                NSLog(@"[NCMusicEngine] AVAudioPlayer initial error: %@", error1);
            }
            [player play];
            identifier = VOICE_IDENTIFIER;
        }
            break;
        default:
            break;
    }
    
    NSLog(@"identifier: %@", identifier);
    
    [self retrieveNotification:^(UNNotificationRequest * notificationRequest) {
        
        if ([notificationRequest.identifier isEqualToString:identifier]) {
            
            NSLog(@"发现有相同的通知");
            
            return;
        }
        
        NSLog(@"没有相同的通知");
        
        // 设置通知的时间, 苹果限制最小是60秒提醒一次, 小于60秒都给你Crash掉
//        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:YES];
        
        // 创建Notification的请求
        UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:identifier content:notificatinoContent trigger:nil];
        
        // 添加Notification的请求
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"发送通知失败: %@",error.localizedDescription);
            }
        }];
    }];
}

/**
 判断通知的类型
 @param notificationRequest Block
 */
- (void)retrieveNotification:(void (^) (UNNotificationRequest *))notificationRequest {
    
    // 获取正在添加的Notification信息
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UNNotificationRequest *request = requests.firstObject;
            
            notificationRequest(request);
        });
    }];
}

@end

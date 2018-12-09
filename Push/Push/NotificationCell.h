//
//  NotificationCell.h
//  Push
//
//  Created by 张 永盛 on 2018/12/8.
//  Copyright © 2018 张 永盛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationCell : UITableViewCell
@property (nonatomic, copy) void(^NotificationTypeAction)(UISwitch *sender);

- (void)configuraCellWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END

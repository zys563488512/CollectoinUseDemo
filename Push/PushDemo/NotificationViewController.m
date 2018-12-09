//
//  NotificationViewController.m
//  PushDemo
//
//  Created by 张 永盛 on 2018/12/8.
//  Copyright © 2018 张 永盛. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <AVFoundation/AVFoundation.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) AVPlayer * myPlayer;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@property (nonatomic, strong) AVSpeechSynthesizer * voice;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    // 这个方法，可以给自己的控件赋值，调整frame等等.
    NSDictionary * dict = notification.request.content.userInfo;
    // 这里可以把打印的所有东西拿出来
    NSLog(@"%@",dict);
    UNNotificationContent * content = notification.request.content;
    
    if (content.attachments.count > 0) {
        UNNotificationAttachment * att = content.attachments[0];
        NSURL * url = att.URL;
        
        if ([content.body rangeOfString:@"图片"].location != NSNotFound) {
            NSLog(@"图片处理");
            NSData *data = [NSData dataWithContentsOfURL:url];
            [self.imageView setImage:[UIImage imageWithData:data]];
            
            AVSpeechSynthesizer *player  = [[AVSpeechSynthesizer alloc]init];
            
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"支付宝到账，100元"];//设置语音内容
            
            utterance.voice  = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置语言
            
            utterance.rate   = 0.5;  //设置语速
            
            utterance.volume = 1;  //设置音量（0.0~1.0）默认为1.0
            
            utterance.pitchMultiplier    = 1;  //设置语调 (0.5-2.0)
            
            utterance.postUtteranceDelay = 1; //目的是让语音合成器播放下一语句前有短暂的暂停
            
            [player speakUtterance:utterance];
        }else if ([content.body rangeOfString:@"视频"].location != NSNotFound) {
            NSLog(@"视频处理");
            //                _playerImageViewH.constant = 40;
            self.imageView.image = [UIImage imageNamed:@"02.jpg"];
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *image = [self firstFrameWithVideoURL:url size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width/2)];
            [self.imageView setImage:image];
            //                _imgConstraintH.constant = self.view.frame.size.width/2;
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
            self.myPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
            self.playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, image.size.height+20);
            self.playerLayer.backgroundColor = [UIColor grayColor].CGColor;
            //设置播放窗口和当前视图之间的比例显示内容
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            [self.view.layer addSublayer:self.playerLayer];
            self.myPlayer.volume = 1.0f;
            [self.myPlayer play];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.myPlayer.currentItem];
            [att.URL stopAccessingSecurityScopedResource];
        }else  if ([content.body rangeOfString:@"音频"].location != NSNotFound){
            AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
            AVPlayer * player = [[AVPlayer alloc]initWithPlayerItem:songItem];
//             创建播放器
//            NSError *error = nil;
//            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//            // 准备播放
////            [player prepareToPlay];
            // 播放歌曲
             [player play];
        }
    }else{
        if ([self.label.text rangeOfString:@"视频"].location != NSNotFound) {
            NSLog(@"视频处理");
            //                _playerImageViewH.constant = 40;
            //1.从mainBundle获取test.mp4的具体路径
            NSString * path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
            //2.文件的url
            NSURL * url = [NSURL fileURLWithPath:path];
            
            //3.根据url创建播放器(player本身不能显示视频)
            AVPlayer * player = [AVPlayer playerWithURL:url];
            
            //4.根据播放器创建一个视图播放的图层
            AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:player];
            
            //5.设置图层的大小
            layer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
            //6.添加到控制器的view的图层上面
            [self.view.layer addSublayer:layer];
            
            //7.开始播放
            [player play];
            
        }else {
            AVSpeechSynthesizer *player  = [[AVSpeechSynthesizer alloc]init];
            
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:self.label.text];//设置语音内容
            
            utterance.voice  = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置语言
            
            utterance.rate   = 0.4;  //设置语速
            
            utterance.volume = 1;  //设置音量（0.0~1.0）默认为1.0
            
            utterance.pitchMultiplier    = 1;  //设置语调 (0.5-2.0)
            
            utterance.postUtteranceDelay = 1; //目的是让语音合成器播放下一语句前有短暂的暂停
            
            [player speakUtterance:utterance];
        }
    }
}

- (void)playbackFinished:(NSNotification *)notifi {
    NSLog(@"播放完成");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.myPlayer = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
}

#pragma mark ---- 获取图片第一帧
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size
{
    // 获取视频第一帧
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    //    self.label.text = [NSString stringWithFormat:@"**%@  **%@", url, error];
    if (img) {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}

#pragma mark - 获取通知里的 Action 事件
- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    if ([response.actionIdentifier isEqualToString:@"cancel"]) {
        UNNotificationRequest *request = response.notification.request;
        NSArray *identifiers = @[request.identifier];
        // 根据标识符删除等待通知
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:identifiers];
        // 根据标识符删除发送通知
        [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:identifiers];
        self.label.text = @"点击了取消按钮";
        // 删除动画效果
//        [self removeShakeAnimation];
        // 不隐藏通知页面
        completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    } else {
        // 隐藏通知页面
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }
}





- (void) addShakeAnimation {
    CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animation];
    frameAnimation.keyPath= @"transform.translation.x";
    frameAnimation.duration = 1;
    frameAnimation.repeatCount= MAXFLOAT;
    frameAnimation.values = @[@-20.0, @20.0, @-20.0, @20.0, @-10.0, @10.0, @-5.0, @5.0, @0.0];
    frameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.view.layer addAnimation:frameAnimation forKey:@"shake"];
}
- (void)removeShakeAnimation {
    [self.view.layer removeAnimationForKey:@"shake"];
}



@end

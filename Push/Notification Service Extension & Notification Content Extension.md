#### Notification Service Extension & Notification Content Extension
* UNNotificationServiceExtension（通知服务扩展）是在收到通知后，展示通知前，做一些事情的。比如，增加附件，网络请求等。
* 想要给通知创建一个自定义的用户界面，需要 UNNotificationContentExtension（通知内容扩展）。

如果我们经常是用iMassage，就会发现一些信息，附带了一些照片或者视频，如果推送中也可以附带这些多媒体，那么用户不用打开app就可以快速浏览到内容。都知道推送通知中带了push payload，苹果已经把payload的size提升到了4k bites，但是这么小的容量也无法使用户能发送一张高清的图片，甚至把这张图的缩略图包含在推送通知里面，也不一定放的下去。在iOS X中，我们可以使用新特性来解决这个问题。我们可以通过新的service extensions来解决这个问题。

##### iOS10给通知添加附件有两种情况：本地通知和远程通知。
* 本地推送通知，只需给content.attachments设置UNNotificationAttachment附件对象
* 远程推送通知，需要实现 UNNotificationServiceExtension（通知服务扩展），在回调方法中处理 推送内容时设置 request.content.attachments（请求内容的附件） 属性，之后调用 contentHandler 方法即可。

##### UNNotificationServiceExtension 提供在远程推送将要被 push 出来前，处理推送显示内容的机会。此时可以对通知的 request.content 进行内容添加，如添加附件，userInfo 等

* 为了能在service extension 里面的attachment，必须给apns增加 "mutable-content":1 字段，使你的推送通知是动态可变的

```
{
 "aps":{
     "alert":"Testing.. (34)",
     "badge":1,
     "sound":"default",
     "mutable-content":1
  }
}
```
* 给项目新建一个Notification Service Extension的扩展。
* 在-didReceiveNotificationRequest:withContentHandler:方法中处理request.content，用来给通知的内容做修改。如面代码示例了收到通知后，给通知增加图片附件：

```
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    //1. 下载
    NSURL *url = [NSURL URLWithString:@"http://img1.gtimg.com/sports/pics/hv1/194/44/2136/138904814.jpg"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
        
            //2. 保存数据
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject
                              stringByAppendingPathComponent:@"download/image.jpg"];
            UIImage *image = [UIImage imageWithData:data];
            NSError *err = nil;
            [UIImageJPEGRepresentation(image, 1) writeToFile:path options:NSAtomicWrite error:&err];
            
            //3. 添加附件
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"remote-atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&err];
            if (attachment) {
                self.bestAttemptContent.attachments = @[attachment];
            }
        }
        
        //4. 返回新的通知内容
        self.contentHandler(self.bestAttemptContent);
    }];
    
    [task resume];
}
```
注意：使用UNNotificationServiceExtension，你有30秒的时间处理这个通知，可以同步下载图像和视频到本地，然后包装为一个UNNotificationAttachment扔给通知，这样就能展示用服务器获取的图像或者视频了。这里需要注意：如果数据处理失败，超时，extension会报一个崩溃信息，但是通知会用默认的形式展示出来，app不会崩溃。
附件通知所带的附件格式大小都是有限的，并不能做所有事情，视频的前几帧作为一个通知的附件是个不错的选择。




#### 通知附件-UNNotificationAttachment
---
##### 一、介绍
UNNotificationAttachment对象可以包含视频、音频、图片内容，附件内容和通知内容会显示在一起。附件需要你的应用来提供。对于本地通知，应用创建完通知主要内容后再附上附件。对于远程通知，如果要添加附件，必须使用UNNotificationServiceExtension类实现notification service extension。
使用 attachmentWithIdentifier:URL:options:error:
方法创建attachment。必须指定磁盘上的文件作为附件内容，而且文件类型必须是支持的。attachment实例创建完成后，将其赋值给notification对象的attachments
属性。（对于远程通知，这些步骤需要通过你自己实现的service extension来完成）。
系统会先验证附件，然后才将相应的通知加入到发送队列中。如果附件是损坏的、无效的，或者类型不支持，那么通知请求不会被列入发送计划中。附件一旦验证通过，它被移到attachment data store中以保证它们能够被相应的进程存取。如果附件位于应用bundle中，那么系统会使用复制代替移动。
要获取一个已经存在的Attachment对象的内容，必须使用UNUserNotificationCenter中的getDataForAttachment:withCompletionHandler: 和getReadFileHandleForAttachment:withCompletionHandler:方法。

##### 二、支持的文件类型

<table>
  <tr>
    <th width=10%>附件</th>
    <th width=50%>支持类型</th>
    <th width="40%"> 附件最大尺寸
</th>
  </tr>
  <tr>
    <td bgcolor=#eeeeee> Audio </td>
    <td> kUTTypeWaveformAudio</br>
		  kUTTypeMP3</br>
		  kUTTypeMPEG4Audio </br>         		  kUTTypeAudioInterchangeFileFormat  </td>
    <td align=center> 5MB  </td>
  </tr>
  <tr>
    <td> Image </td>
    <td> kUTTypeJPEG </br> 
			kUTTypeGIF </br>
kUTTypePNG </td>
    <td align=center> 10MB </td>
  <tr>
    <td > Movie </td>
    <td> kUTTypeMPEG</br>
		kUTTypeMPEG2Video </br>
		kUTTypeMPEG4 </br>
		kUTTypeAVIMovie </td>
    <td align=center>  50MB </td>
  </tr>
</table>



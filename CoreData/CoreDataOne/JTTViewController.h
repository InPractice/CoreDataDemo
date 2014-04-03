//
//  JTTViewController.h
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JTTViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;//播放视频
@property (nonatomic, retain) UIActivityIndicatorView *activityForVideo;//加载视频时进度圈
@end

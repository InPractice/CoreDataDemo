//
//  JTTViewController.m
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import "JTTViewController.h"
#import "JTTAppLogicCoreDataStorage.h"
#import "Student.h"
#import <MediaPlayer/MediaPlayer.h>

@interface JTTViewController ()
{
    NSMutableDictionary *_stuDic;
    UITextField *_stuNameLabel;
    UITextField *_stuIdLabel;
}
@end

@implementation JTTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    ///*百度地图
    
    
    
    
    
    /* 视频播放
    // Register observers for the various movie object notifications.
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.backgroundColor = [UIColor redColor];
    [playButton setFrame:CGRectMake(10, 80, 60, 20)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton.backgroundColor = [UIColor redColor];
    [pauseButton setFrame:CGRectMake(10, 400, 60, 20)];
    [pauseButton setTitle:@"停止" forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseButton];
//    http://video2s.soufun.com/2014/03/19/bj/mp4/7850a8eaf193439fa8c4ae2560d640fb.mp4
     视频播放*/
    
    /* coredata 应用
    _stuNameLabel = [[UITextField alloc]initWithFrame:CGRectMake(100, 40, 120, 44)];
    _stuNameLabel.placeholder = [NSString stringWithFormat:@"请输入学生名字"];
    _stuNameLabel.delegate = self;
    _stuIdLabel = [[UITextField alloc]initWithFrame:CGRectMake(100, 90, 120, 44)];
    _stuIdLabel.placeholder = [NSString stringWithFormat:@"请输入学生号码"];
    _stuIdLabel.delegate = self;
    UITextField *teaNameLabel = [[UITextField alloc]initWithFrame:CGRectMake(100, 140, 120, 44)];
    teaNameLabel.placeholder = [NSString stringWithFormat:@"请输入教师名字"];
    teaNameLabel.delegate = self;
    UITextField *teaIdLabel = [[UITextField alloc]initWithFrame:CGRectMake(100, 190, 120, 44)];
    teaIdLabel.placeholder = [NSString stringWithFormat:@"请输入教师号码"];
    teaIdLabel.delegate = self;
    [self.view addSubview:_stuNameLabel];
    [self.view addSubview:_stuIdLabel];
    [self.view addSubview:teaNameLabel];
    [self.view addSubview:teaIdLabel];
    
    UIButton *recordStuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordStuButton.backgroundColor = [UIColor redColor];
    [recordStuButton setFrame:CGRectMake(10, 40, 60, 20)];
    [recordStuButton setTitle:@"录入" forState:UIControlStateNormal];
    [recordStuButton addTarget:self action:@selector(recordStudentInFo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordStuButton];
    
    UIButton *readStuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    readStuButton.backgroundColor = [UIColor redColor];
    [readStuButton setFrame:CGRectMake(10, 80, 60, 20)];
    [readStuButton setTitle:@"读取" forState:UIControlStateNormal];
    [readStuButton addTarget:self action:@selector(readStudentInFo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readStuButton];
    
    UIButton *removeStuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    removeStuButton.backgroundColor = [UIColor redColor];
    [removeStuButton setFrame:CGRectMake(10, 120, 60, 20)];
    [removeStuButton setTitle:@"删除" forState:UIControlStateNormal];
    [removeStuButton addTarget:self action:@selector(removeStudentInFo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeStuButton];
     */
}

#pragma mark - play video
-(void)pause
{
    if (self.activityForVideo.isAnimating) {
        [self.activityForVideo stopAnimating];
    }
    
    [self.moviePlayerController stop];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
    
    [self.moviePlayerController setFullscreen:NO animated:YES];
    [self.moviePlayerController.view removeFromSuperview];
    
    self.moviePlayerController = nil;
    
}
- (void)play
{
    NSURL * fileUrl = [NSURL URLWithString:@"http://video2s.soufun.com/2014/03/19/bj/mp4/7850a8eaf193439fa8c4ae2560d640fb.mp4"];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:fileUrl];
    self.moviePlayerController = player;
    [self installMovieNotificationObservers];
    self.moviePlayerController.scalingMode = MPMovieScalingModeNone;//不对视频进行缩放
    [self.moviePlayerController setMovieSourceType:MPMovieSourceTypeFile];
    [self.moviePlayerController setMovieSourceType:MPMovieSourceTypeFile];
    
    [self.moviePlayerController setFullscreen:YES];
    
    [self.view addSubview: [self.moviePlayerController view]];
    self.moviePlayerController.controlStyle=MPMovieControlStyleEmbedded;
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(80, 0, 80, 80);
    
    self.activityForVideo=activityView;
    CGSize mainScreenSize = [[UIScreen mainScreen] bounds].size;
    [[self.moviePlayerController view] setFrame:CGRectMake(0,44, mainScreenSize.height,mainScreenSize.width-44)];
    [self.moviePlayerController.view addSubview:self.activityForVideo];
   
    [self.activityForVideo startAnimating];
    
    [self.moviePlayerController play];
}

-(void)installMovieNotificationObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayerController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.moviePlayerController];//设置视频开始播放的回调处
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayerController];//播放状态发生改变
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieExitFullscreenAction:) name:MPMoviePlayerScalingModeDidChangeNotification object:self.moviePlayerController];
    
}
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
   
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
            
		case MPMovieFinishReasonPlaybackEnded:
       		break;
            
		case MPMovieFinishReasonPlaybackError:
        {

            [self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
                                waitUntilDone:NO];
        }
            
            
			break;
            
		case MPMovieFinishReasonUserExited:
            
			
            break;
            
		default:
            
			break;
	}
    
    [self.moviePlayerController setFullscreen:NO animated:YES];
    
	[self.moviePlayerController.view removeFromSuperview];
    
}
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification{
    if (self.activityForVideo.isAnimating) {
        [self.activityForVideo stopAnimating];
    }
}

- (void)movieExitFullscreenAction:(NSNotification *)notification{
    [[self moviePlayerController]setFullscreen:NO animated:YES];
}

-(void)moviePlayBackStateDidChange:(NSNotification *)notification{
    
}
-(void)displayError:(id)error{
    
    
}
#pragma mark - coredata
- (void)removeStudentInFo
{
    JTTAppLogicCoreDataStorage *store = [JTTAppLogicCoreDataStorage sharedInstance];
    [store removeStudentItem:_stuIdLabel.text];
}

- (void)readStudentInFo
{
    
//    [_stuDic setObject:_stuNameLabel.text forKey:@"name"];
//    [_stuDic setObject:_stuIdLabel.text forKey:@"stu_id"];
    
    JTTAppLogicCoreDataStorage *store = [JTTAppLogicCoreDataStorage sharedInstance];
    [store readStudentInfoFromDataBase];
}

-(void)recordStudentInFo
{
    if (!_stuDic) {
        _stuDic = [[NSMutableDictionary alloc]init];
    }
    
    
    [_stuDic setObject:_stuNameLabel.text forKey:@"name"];
    [_stuDic setObject:_stuIdLabel.text forKey:@"stu_id"];
    
    JTTAppLogicCoreDataStorage *store = [JTTAppLogicCoreDataStorage sharedInstance];
    [store insertStudentItem:_stuDic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  PlayerViewController.m
//  FlMusic
//
//  Created by lanqy on 14-1-15.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//
#import "AppDelegate.h"
#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import "NSString+TimeToString.h"
#import "TipsViewController.h"
#define kAccelerationThreshold 1.5
#define kUpdateInterval (1.0f/10.0f)
@interface PlayerViewController ()<AVAudioSessionDelegate,UIAccelerometerDelegate>
@property (strong, nonatomic) AVPlayer *DetailAudioPlayer;
@property (nonatomic) MPMusicPlaybackState playbackState;
@property (nonatomic) MPMusicRepeatMode repeatMode; // note: MPMusicRepeatModeDefault is not supported
@property (nonatomic) MPMusicShuffleMode shuffleMode; // note: only MPMusicShuffleModeOff and MPMusicShuffleModeSongs are supported
@property (nonatomic) NSTimeInterval currentPlaybackTime; // 0.0 to 1.0
@property (nonatomic) NSTimeInterval currentPlaybackRate;

@property (strong, nonatomic, readwrite) MPMediaItem *nowPlayingItem;

@property (nonatomic) BOOL interrupted;
@property (nonatomic) BOOL tipsShowing; // 默认为NO
@property (nonatomic,strong) UIToolbar *toolbar;
@property (nonatomic,strong) CMMotionManager *motionManager;
@end

@interface NSArray (ShuffledArray)
- (NSArray *)shuffled;
@end

@implementation NSArray (ShuffledArray)

- (NSArray *)shuffled {
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];
    
	for (id anObject in self) {
		NSUInteger randomPos = arc4random()%([tmpArray count]+1);
		[tmpArray insertObject:anObject atIndex:randomPos];
	}
    
	return [NSArray arrayWithArray:tmpArray];
}

@end

@implementation PlayerViewController
@synthesize detailSongAlubmTitle = _detailSongAlubmTitle;
@synthesize detailSongArtist = _detailSongArtist;
@synthesize detaiSongArkwork = _detaiSongArkwork;
@synthesize detailSongTitle = _detailSongTitle;
@synthesize detailSongArkworkThumbnail = _detailSongArkworkThumbnail;
@synthesize spline = _spline;
@synthesize aplaLayer = _aplaLayer;
@synthesize detailProgressSlider = _detailProgressSlider;
@synthesize DetailTrackCurrentPlaybackTimeLabel = _DetailTrackCurrentPlaybackTimeLabel;
@synthesize DetailTrackLengthLabel = _DetailTrackLengthLabel;
@synthesize indexPlaying = _indexPlaying;
@synthesize currentPlaybackTime = _currentPlaybackTime;
@synthesize currentPlaybackRate = _currentPlaybackRate;
@synthesize repeatMode = _repeatMode;
@synthesize shuffleMode = _shuffleMode;
@synthesize toolbar = _toolbar;
@synthesize volumeSlider = _volumeSlider;
@synthesize volumeView = _volumeView;
@synthesize shuffeArr = _shuffeArr;
@synthesize motionManager = _motionManager;
@synthesize tipsViewController = _tipsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set defaults
    self.updateNowPlayingCenter = YES;
    
    self.tipsShowing = NO;
     [self initSession];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.DetailAudioPlayer = [[AVPlayer alloc] init];
    [self buildInterfaceForPlayer];
    NSLog(@"%d",self.indexPlaying);
    
    self.repeatMode = MPMusicRepeatModeNone;
    self.shuffleMode = MPMusicShuffleModeOff;
    [self setMusicPlayerAttribute:self.indexPlaying];
    
    
    // Listen for volume changes
    [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handle_VolumeChanged:)
                                                 name:MPMusicPlayerControllerVolumeDidChangeNotification
                                               object:[MPMusicPlayerController iPodMusicPlayer]];

    
    //响应程序从后台转为前台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PlayMusicByActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
   
    

    
    // 实现摇动
    /*
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error) {
         if (error) {
             [self.motionManager stopAccelerometerUpdates];
         }else{
             CMAcceleration acceleration = accelerometerData.acceleration;
             if (acceleration.x > kAccelerationThreshold
                 || acceleration.y > kAccelerationThreshold
                 || acceleration.z > kAccelerationThreshold) {
                 
                 NSLog(@"shake");
                // [self showTipsViewController];
             }
             
         }
     }];
     */
}

// 初始化session,用于在后台播放音乐
- (void)initSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:NULL];
    
    AVAudioSession *backgroundMusic = [AVAudioSession sharedInstance];
    
    [backgroundMusic setCategory:AVAudioSessionCategoryPlayback error:NULL];
}


- (void)handle_VolumeChanged:(NSNotification *)notification {
    self.DetailAudioPlayer.volume = [MPMusicPlayerController iPodMusicPlayer].volume;
}

-(void)PlayMusicByActive
{
   /* if (self.playbackState == MPMusicPlaybackStatePlaying) {
        return;
    }else{
         [self setMusicPlayerAttribute:self.indexPlaying];
    }
   */
}

-(void)showTipsViewController
{
    if (!self.tipsViewController) {
        self.tipsViewController = [[TipsViewController alloc] initWithNibName:@"TipsViewController" bundle:nil];
    }
    [self presentModalViewController:self.tipsViewController animated:YES];
}

- (void)setNowPlayingItem:(MPMediaItem *)nowPlayingItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
  //  MPMediaItem *previousTrack = _nowPlayingItem;
  //  _nowPlayingItem = nowPlayingItem;
    
    // Create a new player item
    NSURL *assetUrl = [self.playItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:assetUrl];
    
    // Either create a player or replace it
    if (self.DetailAudioPlayer) {
        [self.DetailAudioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    } else {
        self.DetailAudioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    }
    
    // Inform iOS now playing center
    [self doUpdateNowPlayingCenter];
}


- (void)doUpdateNowPlayingCenter {
    
    if (!self.updateNowPlayingCenter || !self.playItem) {
        return;
    }
    
    // Only available on iOS 5
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (!playingInfoCenter) {
        return;
    }
    
    MPMediaItemArtwork *artwork = [self.playItem valueForProperty:MPMediaItemPropertyArtwork];
    
    MPNowPlayingInfoCenter *center = [playingInfoCenter defaultCenter];
    NSDictionary *songInfo = @{
                               MPMediaItemPropertyArtist: [self.playItem valueForProperty:MPMediaItemPropertyArtist],
                               MPMediaItemPropertyTitle: [self.playItem valueForProperty:MPMediaItemPropertyTitle],
                               MPMediaItemPropertyAlbumTitle: [self.playItem valueForProperty:MPMediaItemPropertyAlbumTitle],
                               MPMediaItemPropertyArtwork: artwork,
                               MPMediaItemPropertyPlaybackDuration: [self.playItem valueForProperty:MPMediaItemPropertyPlaybackDuration]
                               };
    
   // NSLog(@"%@",songInfo);
    center.nowPlayingInfo = songInfo;
}

-(void)buildInterfaceForPlayer
{
   
    self.detailSongArtist = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 220, 22)];
    self.detailSongArtist.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.detailSongArtist.text = @"张学友";
    self.detailSongArtist.font = [UIFont fontWithName:@"Arial" size:17.0f];
    self.detailSongArtist.textAlignment = NSTextAlignmentLeft;
    
    [self.view addSubview:self.detailSongArtist];
    
    
    self.detailSongAlubmTitle = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(10, 45, 220,20)];
   // self.detailSongAlubmTitle.numberOfLines = 0;
    self.detailSongAlubmTitle.textColor = [UIColor grayColor];
    self.detailSongAlubmTitle.text = @"只愿一生爱一人";
    self.detailSongAlubmTitle.font = [UIFont fontWithName:@"Arial" size:13.0f];
    self.detailSongAlubmTitle.textAlignment = NSTextAlignmentLeft;
    
   // self.detailSongAlubmTitle.labelSpacing = 35; // distance between start and end labels
    self.detailSongAlubmTitle.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    self.detailSongAlubmTitle.scrollSpeed = 30; // pixels per second
    self.detailSongAlubmTitle.fadeLength = 5.0f;
    self.detailSongAlubmTitle.scrollDirection = CBAutoScrollDirectionLeft;
    [self.detailSongAlubmTitle observeApplicationNotifications];
    [self.view addSubview:self.detailSongAlubmTitle];
    
    self.spline = [[UIView alloc] initWithFrame:CGRectMake(0, 70, 320, 2)];
    [self.spline setBackgroundColor:[UIColor grayColor]];
    [self.spline setAlpha:0.3f];
    [self.view addSubview:self.spline];
    
    self.detaiSongArkwork = [[UIImageView alloc] initWithFrame:CGRectMake(0, 72, 320, [[UIScreen mainScreen] bounds].size.height - 35 - 43 - 72)];
    self.detaiSongArkwork.image = [UIImage imageNamed:@"albumart-cd"];
    
    [self.detaiSongArkwork setUserInteractionEnabled:YES]; // imageView 滑动事件默认是关闭的，设为YES表示打开，此时才可以用UISwipeGestureRecognizer
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    
    // 设置滑动方向.
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    // 设置滑动方向.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    
    
    // 滑动事件加到imageview
    
    [self.detaiSongArkwork addGestureRecognizer:swipeUp];
    [self.detaiSongArkwork addGestureRecognizer:swipeDown];
    [self.detaiSongArkwork addGestureRecognizer:swipeLeft];
    [self.detaiSongArkwork addGestureRecognizer:swipeRight];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0; //seconds
    longPress.delegate = self;
    [self.detaiSongArkwork addGestureRecognizer:longPress];
    
    
    // 参见 http://stackoverflow.com/questions/19127501/how-to-detect-tap-and-double-tap-at-same-time-using-uitapgesturerecognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.detaiSongArkwork addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.detaiSongArkwork addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.view addSubview:self.detaiSongArkwork];
    
    
    self.detailSongArkworkThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(245, 25, 65, 65)];
    self.detailSongArkworkThumbnail.image = [UIImage imageNamed:@"placeholder"];
    [self.detailSongArkworkThumbnail setBackgroundColor:[UIColor whiteColor]];
    [self.detailSongArkworkThumbnail.layer setBorderColor:[[UIColor colorWithRed:207 / 255 green:207 / 255 blue:207 / 255 alpha:0.2] CGColor]];
    [self.detailSongArkworkThumbnail.layer setBorderWidth:2.0f];
    self.detailSongArkworkThumbnail.layer.cornerRadius = 5;
    self.detailSongArkworkThumbnail.layer.masksToBounds = YES;
    
    [self.view addSubview:self.detailSongArkworkThumbnail];
    
    self.DetailTrackCurrentPlaybackTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 57 + 27, 45, 20)];
    self.DetailTrackCurrentPlaybackTimeLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.DetailTrackCurrentPlaybackTimeLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
    self.DetailTrackCurrentPlaybackTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.DetailTrackCurrentPlaybackTimeLabel];
    
    self.aplaLayer = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 33, [[UIScreen mainScreen] bounds].size.width,40)];
    
    self.aplaLayer.backgroundColor = [UIColor whiteColor];
    [self.aplaLayer setAlpha:0.8f];
    
    [self.view addSubview:self.aplaLayer];
    
    
    self.detailSongTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 43, [[UIScreen mainScreen] bounds].size.width, 20)];
    self.detailSongTitle.textColor = [UIColor blackColor];
    self.detailSongTitle.font = [UIFont fontWithName:@"Arial" size:17.0f];
    self.detailSongTitle.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.detailSongTitle];
    
    self.DetailTrackLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(265, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 57 + 27, 45, 20)];
    self.DetailTrackLengthLabel.textColor =  [UIColor grayColor];
    self.DetailTrackLengthLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
    self.DetailTrackLengthLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.DetailTrackLengthLabel];

    
    CGRect myFrame = CGRectMake(50.0f, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 57 + 27, 220.0f, 20.0f);
    self.detailProgressSlider = [[UISlider alloc] initWithFrame:myFrame];
    self.detailProgressSlider.minimumValue = 0.0f;
    self.detailProgressSlider.maximumValue = 100.0f;
    self.detailProgressSlider.value = 0.0f;
    [self.detailProgressSlider setContinuous:false];
    [self.detailProgressSlider addTarget:self action:@selector(getDetailSilderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: self.detailProgressSlider];
    
    
    self.volumeView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 50.0f)];
    self.volumeView.backgroundColor = [UIColor whiteColor];

    CGRect sliderFrame = CGRectMake(50.0f, 13, 220.0f, 20.0f);
    self.volumeSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    self.volumeSlider.minimumValue = 0.0f;
    self.volumeSlider.maximumValue = 1.0f;
    self.volumeSlider.value = 0.0f;
    
    [self.volumeSlider setContinuous:false];
    [self.volumeSlider addTarget:self action:@selector(getVolumeSilderValue:) forControlEvents:UIControlEventValueChanged];
    [self.volumeView addSubview:self.volumeSlider];
    [self.view addSubview:self.volumeView];
    
    self.volumeView.hidden = YES;
    self.shuffle = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 90, [[UIScreen mainScreen] bounds].size.height - 35, 80, 30)];
    [self.shuffle setImage:[UIImage imageNamed:@"Track_Shuffle_Off"] forState:UIButtonTypeCustom];
    [self.shuffle addTarget:self action:@selector(shufflePlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.shuffle setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    self.shuffle.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.shuffle.selected = (self.shuffleMode != MPMusicShuffleModeOff);
    [self.view addSubview:self.shuffle];
    
    self.loop = [[UIButton alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 35, 80, 30)];
    [self.loop setImage:[UIImage imageNamed:@"Track_Repeat_Off"] forState:UIButtonTypeCustom];
   // [self.loop setBackgroundColor:[UIColor clearColor]];
    [self.loop setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [self.loop addTarget:self action:@selector(loopPlay:) forControlEvents:UIControlEventTouchUpInside];
    self.loop.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:self.loop];
    
    
}

- (void)getVolumeSilderValue:(UISlider *)paramSender
{
  //  self.DetailAudioPlayer.volume = [MPMusicPlayerController iPodMusicPlayer].volume;
    [MPMusicPlayerController iPodMusicPlayer].volume = paramSender.value;
  //  NSLog(@"%f",paramSender.value);
}
// 长按操作出现菜单
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
      //      NSLog(@"UIGestureRecognizerStateEnded");
            [self animationWithAfterDelay];
            //Do Whatever You want on End of Gesture
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
       //     NSLog(@"UIGestureRecognizerStateBegan.");
           
            [self showVolumeViewSilderWithAnimation];
        }
}

// 8秒隐藏音量调节视图
-(void) animationWithAfterDelay {
    
    [self performSelector:@selector(hideVolumeViewSilderWithAnimation) withObject:nil afterDelay:8.0];
    
}

// 渐变显示音量调节视图
-(void)showVolumeViewSilderWithAnimation
{
    self.volumeView.alpha = 0;
    self.volumeView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.volumeView.alpha = 1;
        self.volumeSlider.value = [MPMusicPlayerController iPodMusicPlayer].volume;
    }];
}

// 隐藏音量调节视图
-(void)hideVolumeViewSilderWithAnimation
{
    [UIView transitionWithView:self.volumeView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.volumeView.hidden = YES;
    
}

- (NSTimeInterval)currentPlaybackTime {
#if !(TARGET_IPHONE_SIMULATOR)
    return self.DetailAudioPlayer.currentTime.value / self.DetailAudioPlayer.currentTime.timescale;
#else
    return 0;
#endif
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    CMTime t = CMTimeMake(currentPlaybackTime, 1);
    [self.DetailAudioPlayer seekToTime:t];
}

- (void) getDetailSilderValue:(UISlider *)paramSender{
    
    if ([paramSender isEqual:self.detailProgressSlider]) {
        float newValue = paramSender.value / 10;
        self.DetailTrackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:floor(newValue) * 10];
        [self setCurrentPlaybackTime:floor(newValue) * 10];
    }
}

-(void)loopPlay:(id)sender
{
    switch (self.repeatMode) {
        case MPMusicRepeatModeAll:
            // From all to one
            self.repeatMode = MPMusicRepeatModeOne;
            break;
            
        case MPMusicRepeatModeOne:
            // From one to none
            self.repeatMode = MPMusicRepeatModeNone;
            break;
            
        case MPMusicRepeatModeNone:
            // From none to all
            self.repeatMode = MPMusicRepeatModeAll;
            break;
            
        default:
            self.repeatMode = MPMusicRepeatModeAll;
            break;
    }
    
    [self setImageForUIbarItem];
    
}


- (void)setImageForUIbarItem
{
    
    NSString *imageName;
    switch (self.repeatMode) {
        case MPMusicRepeatModeAll:
            imageName = @"Track_Repeat_On";
            break;
            
        case MPMusicRepeatModeOne:
            imageName = @"Track_Repeat_On_Track";
            break;
            
        case MPMusicRepeatModeNone:
            imageName = @"Track_Repeat_Off";
            break;
            
        default:
            imageName = @"Track_Repeat_Off";
            break;
    }
    
     [self.loop setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

// 重置播放模式
-(void)resetPlayMode
{
    self.shuffleMode = MPMusicShuffleModeOff;
    self.repeatMode = MPMusicRepeatModeNone;
     [self setImageForUIbarItem];
     [self setImageForShuffle];
}

-(void)shufflePlay:(id)sender
{
    if (self.shuffleMode == MPMusicShuffleModeOff) {
        NSLog(@"no shuffle");
        self.shuffleMode = MPMusicShuffleModeSongs;
        [self shuffd];
        self.indexPlaying = 0;
        [self playSongByIndex:self.indexPlaying];
    }else{
        NSLog(@"shuffle");
        self.shuffleMode = MPMusicShuffleModeOff;
        self.shuffeArr = self.msList;
        self.indexPlaying = 0;
        [self playSongByIndex:self.indexPlaying];
    }
    
    [self setImageForShuffle];
}

-(void)shuffd
{
    self.shuffeArr = [self.msList shuffled];
}

-(void)setImageForShuffle
{
    NSString *imageName;
    if (self.shuffleMode == MPMusicShuffleModeSongs) {
        imageName = @"Track_Shuffle_On";
    }else{
        imageName = @"Track_Shuffle_Off";
    }
    
    [self.shuffle setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


-(void)volumePlay:(id)sender
{
    
}


-(void)listPlay:(id)sender
{
    
}

-(void)doSingleTap
{
    if (self.playbackState == MPMusicPlaybackStatePlaying) {
        [self pause];
        self.playbackState = MPMusicPlaybackStatePaused;
    }else{
        [self play];
        self.playbackState = MPMusicPlaybackStatePlaying;
    }
}

// 双击播放最后一首
-(void)doDoubleTap
{
    // NSLog(@"doDouble tap ....");
    if (self.indexPlaying == ([self.msList count] - 1)) {
        self.indexPlaying = 0;
        [self playSongByIndex:self.indexPlaying];
    }else{
        self.indexPlaying = ([self.msList count] - 1);
        [self playSongByIndex:self.indexPlaying];
    }
    
}

-(void)playSongByIndex:(NSInteger*)index{
    [self setMusicPlayerAttribute:index];
}

// 滑动切换歌曲
-(void)handleSwipeGesture:(UISwipeGestureRecognizer *) sender
{
    //判断滑动的方向
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self skipToNextItem];
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self skipToPrevItem];
    }else if(sender.direction == UISwipeGestureRecognizerDirectionUp){
      //  NSLog(@"uping");
         [self showTipsViewController];
    }else if(sender.direction ==UISwipeGestureRecognizerDirectionDown){
      //  NSLog(@"downing");
        [self.DetailAudioPlayer pause];
        [self resetPlayMode];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)skipToNextItem{
    if ((self.indexPlaying + 1) > ([self.msList count] - 1)) { // 索引从0开始,切记啊
        return;
    }else{
        self.indexPlaying++;
        [self playSongByIndex:self.indexPlaying];
    }
}

-(void)skipToPrevItem{
    
    if ((self.indexPlaying - 1) < 0) {
        return;
    }else{
        self.indexPlaying--;
        [self playSongByIndex:self.indexPlaying];
    }
}

-(void)setMusicPlayerAttribute:(int *)index{
    
    if (self.shuffleMode == MPMusicShuffleModeOff) {
        self.playItem = [self.msList objectAtIndex:index];
    }else{
        self.playItem = [self.shuffeArr objectAtIndex:index];
    }
    
    [self doUpdateNowPlayingCenter];
    AVPlayerItem * url = [AVPlayerItem playerItemWithURL:[self.playItem valueForProperty:MPMediaItemPropertyAssetURL]];
    NSString *songTitle = [self.playItem valueForProperty: MPMediaItemPropertyTitle];
    NSString *songAlbumTitle = [self.playItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *songArtist = [self.playItem valueForProperty:MPMediaItemPropertyArtist];
    if (self.DetailAudioPlayer) {
         [self.DetailAudioPlayer replaceCurrentItemWithPlayerItem:url];
       
    }else{
        self.DetailAudioPlayer = [AVPlayer playerWithPlayerItem:url];
    }

    [self configureDetailPlayer];
    [self play];
    
    self.playbackState = MPMusicPlaybackStatePlaying;
    // 歌曲播放完整通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DetailPlayerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:url];

    self.detailSongArtist.text = ([songArtist length] == 0 ? NSLocalizedString(@"未知歌手", @"Unknown Artist") : songArtist);
    self.detailSongAlubmTitle.text = ([songAlbumTitle length] == 0 ? NSLocalizedString(@"未知专辑", @"Unknown Album") : songAlbumTitle);
    self.detailSongTitle.text = songTitle;
    
    UIImage *albumArtworkImage = NULL;
    // Artwork
    MPMediaItemArtwork *nowPlayartwork = [self.playItem valueForProperty:MPMediaItemPropertyArtwork];
    if (nowPlayartwork != nil) {
        albumArtworkImage = [nowPlayartwork imageWithSize:CGSizeMake(65.0f, 65.0f)];
    }
    
    if (albumArtworkImage) {
        self.detailSongArkworkThumbnail.image = albumArtworkImage;
        self.detaiSongArkwork.image = albumArtworkImage;
    }else{
        self.detailSongArkworkThumbnail.image = [UIImage imageNamed:@"placeholder"];
        self.detaiSongArkwork.image = [UIImage imageNamed:@"placeholder"];
    }
    
    self.DetailTrackCurrentPlaybackTimeLabel.text = @"0:00";
    
    NSTimeInterval trackLength = [[self.playItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.DetailTrackLengthLabel.text = [NSString stringFromTime:trackLength];
    self.detailProgressSlider.value = 0;
    self.detailProgressSlider.maximumValue = trackLength;
    
}

#pragma mark - AVAudioSessionDelegate

- (void)beginInterruption {
    if (self.playbackState == MPMusicPlaybackStatePlaying) {
        self.interrupted = YES;
    }
    [self pause];
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    if (self.interrupted && (flags & AVAudioSessionInterruptionFlags_ShouldResume)) {
        [self play];
    }
    self.interrupted = NO;
}


#pragma mark - Other public methods

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type != UIEventTypeRemoteControl) {
        return;
    }
    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                [self pause];
            } else {
                [self play];
            }
            break;
        }
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self skipToNextItem];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self skipToPrevItem];
            break;
            
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
            
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
            
        case UIEventSubtypeRemoteControlStop:
            [self pause];
            break;
            
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            [self doDoubleTap];
            break;
            
        case UIEventSubtypeRemoteControlBeginSeekingForward:
            [self doDoubleTap];
            break;
            
        case UIEventSubtypeRemoteControlEndSeekingBackward:
        case UIEventSubtypeRemoteControlEndSeekingForward:
            [self endSeeking];
            break;
            
        default:
            break;
    }
}

#pragma mark - MPMediaPlayback

- (void)play {
    [self.DetailAudioPlayer play];
    self.playbackState = MPMusicPlaybackStatePlaying;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)pause {
    [self.DetailAudioPlayer pause];
    self.playbackState = MPMusicPlaybackStatePaused;
}

- (void)stop {
    [self.DetailAudioPlayer pause];
    self.playbackState = MPMusicPlaybackStateStopped;
}

- (void)prepareToPlay {
    NSLog(@"Not supported");
}

- (void)beginSeekingBackward {
    NSLog(@"Not supported");
}

- (void)beginSeekingForward {
    NSLog(@"Not supported");
}

- (void)endSeeking {
    NSLog(@"Not supported");
}

- (void)DetailPlayerItemDidReachEnd:(NSNotification *)notification
{
     self.playbackState = MPMusicPlaybackStatePaused;
        dispatch_async(dispatch_get_main_queue(), ^{
                if (self.repeatMode == MPMusicRepeatModeOne) {
                        [self playSongByIndex:self.indexPlaying];
                }else if(self.repeatMode == MPMusicRepeatModeNone){
                    if (self.indexPlaying < ([self.msList count] - 1)) {
                        self.indexPlaying++;
                        [self playSongByIndex:self.indexPlaying];
                    }else{
                        return;
                    }
                }else if(self.repeatMode == MPMusicRepeatModeAll){
                    self.indexPlaying == ([self.msList count] - 1) ? (self.indexPlaying = 0) : self.indexPlaying++;
                    [self playSongByIndex:self.indexPlaying];
                }else{
                    
                    self.indexPlaying = 0;
                    return;
                }
        });
}

-(void)configureDetailPlayer {

    [self.DetailAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time) {
                                                  if(!time.value) {
                                                      return;
                                                  }
                                                  int currentTime = (int)(self.currentPlaybackTime);
                                                  
                                                  NSString * durationLabel = [NSString stringFromTime:currentTime];
                                                  self.DetailTrackCurrentPlaybackTimeLabel.text = durationLabel;
                                                  self.detailProgressSlider.value = currentTime;
                                              }];
    
}



-(void)viewWillAppear:(BOOL)animated {
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];

    if (app.isPlaying == NO && app.isFromList == YES) {
        [self setMusicPlayerAttribute:self.indexPlaying];
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


// 禁止横竖屏

- (BOOL)shouldAutorotate
{
    //returns true if want to allow orientation change
    return FALSE;
    
}
- (NSUInteger)supportedInterfaceOrientations
{
    //decide number of origination tob supported by Viewcontroller.
    return UIInterfaceOrientationMaskAll;
    
}

@end

@implementation UINavigationController (RotationIn_IOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject]  preferredInterfaceOrientationForPresentation];
}

@end
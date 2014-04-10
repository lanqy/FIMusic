//
//  PlayerViewController.m
//  FlMusic
//
//  Created by lanqy on 14-1-15.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+TimeToString.h"
@interface PlayerViewController ()
@property (strong, nonatomic) AVPlayer *DetailAudioPlayer;
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
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
   // self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.DetailAudioPlayer = [[AVPlayer alloc] init];
    [self buildInterfaceForPlayer];
    NSLog(@"%d",self.indexPlaying);
    [self setMusicPlayerAttribute:self.indexPlaying];

}

-(void)buildInterfaceForPlayer
{
   
    self.detailSongArtist = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 220, 22)];
    self.detailSongArtist.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.detailSongArtist.text = @"张学友";
    self.detailSongArtist.font = [UIFont fontWithName:@"Arial" size:17.0f];
    self.detailSongArtist.textAlignment = NSTextAlignmentLeft;
    
    [self.view addSubview:self.detailSongArtist];
    
    
    self.detailSongAlubmTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 220,20)];
    self.detailSongAlubmTitle.numberOfLines = 0;
    self.detailSongAlubmTitle.textColor = [UIColor grayColor];
    self.detailSongAlubmTitle.text = @"只愿一生爱一人";
    self.detailSongAlubmTitle.font = [UIFont fontWithName:@"Arial" size:13.0f];
    self.detailSongAlubmTitle.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.detailSongAlubmTitle];
    
    self.spline = [[UIView alloc] initWithFrame:CGRectMake(0, 70, 320, 2)];
    [self.spline setBackgroundColor:[UIColor grayColor]];
    [self.spline setAlpha:0.3f];
    [self.view addSubview:self.spline];
    
    self.detaiSongArkwork = [[UIImageView alloc] initWithFrame:CGRectMake(0, 72, 320, [[UIScreen mainScreen] bounds].size.height - 35 - 43 - 72)];
    self.detaiSongArkwork.image = [UIImage imageNamed:@"albumart-cd"];
    
    [self.detaiSongArkwork setUserInteractionEnabled:YES]; // imageView 滑动事件默认是关闭的，设为YES表示打开，此时才可以用UISwipeGestureRecognizer
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    
    // 设置滑动方向.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // 滑动事件加到imageview
    [self.detaiSongArkwork addGestureRecognizer:swipeLeft];
    [self.detaiSongArkwork addGestureRecognizer:swipeRight];
    
    [self.view addSubview:self.detaiSongArkwork];
    
    
    self.detailSongArkworkThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(245, 25, 65, 65)];
    self.detailSongArkworkThumbnail.image = [UIImage imageNamed:@"albumart-cd"];
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
    [self.detailProgressSlider addTarget:self action:@selector(getSilderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: self.detailProgressSlider];
    
    
    // toolbar begin
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *loop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"loop"] style:UIBarButtonItemStylePlain target:self action:@selector(loopAction:)];
    UIBarButtonItem *shuffle = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shuffle"] style:UIBarButtonItemStylePlain target:self action:@selector(shuffleAction:)];
    UIBarButtonItem *volume = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"volume-high"] style:UIBarButtonItemStylePlain target:self action:@selector(volumeAction:)];
    UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(listAction:)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBackgroundImage:[UIImage new]
             forToolbarPosition:UIToolbarPositionAny
                     barMetrics:UIBarMetricsDefault];
    
    [toolbar setBackgroundColor:[UIColor clearColor]]; // 去掉背景
    [toolbar setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
    CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 43, [[UIScreen mainScreen] bounds].size.width, 43);
    [toolbar setFrame:frame];
    NSArray *items = [NSArray arrayWithObjects:shuffle, flexiableItem, loop,flexiableItem,volume,flexiableItem,list, nil];
    toolbar.items = items;
    toolbar.clipsToBounds = YES; // 去掉toolbar上边框
    [self.view addSubview:toolbar];

    
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
        if ((self.indexPlaying + 1) > ([self.msList count] - 1)) { // 索引从0开始,切记啊
            return;
        }else{
            self.indexPlaying++;
            [self playSongByIndex:self.indexPlaying];
        }
        
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if ((self.indexPlaying - 1) < 0) {
            return;
        }else{
            self.indexPlaying--;
            [self playSongByIndex:self.indexPlaying];
        }
    }
}


-(void)setMusicPlayerAttribute:(int *)index{
    
    self.playItem = [self.msList objectAtIndex:index];
    
    AVPlayerItem * url = [AVPlayerItem playerItemWithURL:[self.playItem valueForProperty:MPMediaItemPropertyAssetURL]];
    NSString *songTitle = [self.playItem valueForProperty: MPMediaItemPropertyTitle];
    NSString *songAlbumTitle = [self.playItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *songArtist = [self.playItem valueForProperty:MPMediaItemPropertyArtist];
    
    [self.DetailAudioPlayer replaceCurrentItemWithPlayerItem:url];
   // [self setSliderTimeAndValue:song];
    
    [self configureDetailPlayer];
    [self.DetailAudioPlayer play];
    
    self.detailSongArtist.text = songArtist;
    self.detailSongAlubmTitle.text = songAlbumTitle;
    self.detailSongTitle.text = songTitle;
    // Artwork
    MPMediaItemArtwork *nowPlayartwork = [self.playItem valueForProperty:MPMediaItemPropertyArtwork];
    if (nowPlayartwork != nil) {
        self.detailSongArkworkThumbnail.image = [nowPlayartwork imageWithSize:CGSizeMake(65.0f, 65.0f)];
        self.detaiSongArkwork.image = [nowPlayartwork imageWithSize:CGSizeMake(65.0f, 65.0f)];
    }
    
    self.DetailTrackCurrentPlaybackTimeLabel.text = @"0:00";
    
    NSTimeInterval trackLength = [[self.playItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.DetailTrackLengthLabel.text = [NSString stringFromTime:trackLength];
    self.detailProgressSlider.value = 0;
    self.detailProgressSlider.maximumValue = trackLength;
    
}


-(void)configureDetailPlayer {

    [self.DetailAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time) {
                                                  if(!time.value) {
                                                      return;
                                                  }
                                                  int currentTime = (int)((self.DetailAudioPlayer.currentTime.value)/self.DetailAudioPlayer.currentTime.timescale);
                                                  
                                                  NSString * durationLabel = [NSString stringFromTime:currentTime];
                                                  self.DetailTrackCurrentPlaybackTimeLabel.text = durationLabel;
                                                  self.detailProgressSlider.value = currentTime;
                                              }];
    
}



-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"aaa");
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self setMusicPlayerAttribute:self.indexPlaying];
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
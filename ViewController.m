//
//  ViewController.m
//  FlMusic
//
//  Created by lanqy on 14-1-15.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicCustomCell.h"
#import "NSString+TimeToString.h"
#import "PlayerViewController.h"
@interface ViewController ()
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic, readwrite) MPMediaItem *nowPlayingItem;
@property (nonatomic, readwrite) NSUInteger indexOfNowPlayingItem;
@property (nonatomic) MPMusicPlaybackState playbackState;

@end

@implementation ViewController
@synthesize rearTableView = _rearTableView;
@synthesize songLabel = _songLabel;
@synthesize artistLabel = _artistLabel;
@synthesize songAlbumLabel = _songAlbumLabel;
@synthesize imageView = _imageView;
@synthesize playPauseButton = _playPauseButton;
@synthesize progressSlider = _progressSlider;
@synthesize volumeSlider = _volumeSlider;
@synthesize trackCurrentPlaybackTimeLabel = _trackCurrentPlaybackTimeLabel;
@synthesize trackLengthLabel = _trackLengthLabel;
@synthesize repeatButton = _repeatButton;
@synthesize shuffleButton = _shuffleButton;
@synthesize timer = _timer;
@synthesize playerViewController = _playerViewController;

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
    [self setNeedsStatusBarAppearanceUpdate];
    [self initSession];
    
    // 修改Navigation Bar Title text color
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
   // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.textColor = [UIColor grayColor]; // change this color
    label.text = NSLocalizedString(@"音乐列表", @"");
    self.navigationItem.titleView = label;
    
    self.rearTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [[UIScreen mainScreen] bounds].size.height - 160) style:UITableViewStylePlain];
    self.rearTableView.dataSource =self;
    self.rearTableView.delegate = self;
   // [self.rearTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.rearTableView];
    
    //2
    self.audioPlayer = [[AVPlayer alloc] init];
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    self.songsList = [NSMutableArray arrayWithArray:itemsFromGenericQuery];
    self.musicList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.songsList count]; i++) { // 过滤类型
        MPMediaItem *song = [self.songsList objectAtIndex:i];
        NSInteger mediaType = [[song valueForProperty:MPMediaItemPropertyMediaType] intValue];
        
        /*
        参考 http://stackoverflow.com/questions/8420609/how-do-i-check-an-mpmediaitem-for-mpmediatype-of-just-audio
         MPMediaTypeMusic: 1
         MPMediaTypePodcast: 2
         MPMediaTypeAudioBook: 4
         MPMediaTypeAudioITunesU: 8 (iOS 5)
         MPMediaTypeAnyAudio: 255
         MPMediaTypeMovie: 256
         MPMediaTypeTVShow: 512
         MPMediaTypeVideoPodcast: 1024
         MPMediaTypeMusicVideo: 2048
         MPMediaTypeVideoITunesU: 4096
         MPMediaTypeAnyVideo: 65280
         */
        
        if (mediaType == 1) {
            [self.musicList addObject:[self.songsList objectAtIndex:i]];
        }
    
    }
    
    // 刷新列表
    [self.rearTableView reloadData];
    
    // 获取歌曲属性
    MPMediaItem *song = [self.musicList objectAtIndex:0];
    
    [self playingEndNotification:song];
    
    // 生成播放器ui界面
    [self buildMusicPlayer];
    
    self.indexOfNowPlayingItem = 0;
   
    [self selectTableCellByIndex:0];
    
    [self setSliderTimeAndValue:song];
    
    [self configurePlayer];
    
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)playingEndNotification:(id)song
{
    AVPlayerItem * currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];

    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self setSliderTimeAndValue:song];
    //[self.audioPlayer play];
    self.playbackState = MPMusicPlaybackStatePlaying;
    
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    self.songName.text = songTitle;
    
    // 歌曲播放完整通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:currentItem];
    
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    NSLog(@"ending");
    
    if (self.indexOfNowPlayingItem < ([self.musicList count])) {
        self.indexOfNowPlayingItem++;
        [self selectTableCellByIndex:self.indexOfNowPlayingItem];
        MPMediaItem *song = [self.musicList objectAtIndex:self.indexOfNowPlayingItem];
        [self playingEndNotification:song];
    }else{
        self.indexOfNowPlayingItem = 0;
        return;
    }
    
    
}

// 通过索引选中cell
-(void)selectTableCellByIndex:(int)index
{
    NSIndexPath* selected = [NSIndexPath indexPathForRow:index inSection:0];
    [self.rearTableView selectRowAtIndexPath:selected animated:false scrollPosition:UITableViewScrollPositionMiddle];
}

// 通过索引获取歌曲
- (void)getSongsByIndex:(NSInteger *)index
{
    
}

// 初始化session,用于在后台播放音乐
- (void)initSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:NULL];
    
    AVAudioSession *backgroundMusic = [AVAudioSession sharedInstance];
    
    [backgroundMusic setCategory:AVAudioSessionCategoryPlayback error:NULL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"MusicCell";
    MusicCustomCell *cell = (MusicCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MusicCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
     }

    MPMediaItem *song = [self.musicList objectAtIndex:indexPath.row];
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    NSString *albumTitle = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *Artist = [song valueForProperty:MPMediaItemPropertyArtist];
    
    // Artwork
    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork != nil) {
        cell.artWork.image = [artwork imageWithSize:CGSizeMake(50.0f, 50.0f)];
    }

    cell.songName.text = songTitle;
    cell.Artist.text = [NSString stringWithFormat:@"%@ - %@",([Artist length] == 0 ? @"未知歌手" : Artist),([albumTitle length] == 0 ? @"未知专辑" : albumTitle)];
    cell.songName.highlightedTextColor = [UIColor whiteColor];
    cell.Artist.highlightedTextColor = [UIColor whiteColor];
    
    // 选中高亮
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     MPMediaItem *song = [self.musicList objectAtIndex:indexPath.row];
   //  [self playSelectedCurrentSong:indexPath];
   // [self.audioPlayer pause];
    NSLog(@"%d",MPMusicPlaybackStatePlaying);
    /*
    if (self.playbackState == MPMusicPlaybackStatePlaying) {
        [self.audioPlayer pause];
        self.playbackState = MPMusicPlaybackStatePaused;
    }else{
        [self.audioPlayer play];
        self.playbackState = MPMusicPlaybackStatePlaying;
    }
    */
    if (!self.playerViewController) {
        self.playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    }
    self.playerViewController.playItem = song;
    self.playerViewController.indexPlaying = indexPath.row;
    self.playerViewController.msList = self.musicList;
    [self.navigationController pushViewController:self.playerViewController animated:YES];
}

-(void)playSelectedCurrentSong:(NSIndexPath *)indexPath
{
    [self.audioPlayer pause];
    MPMediaItem *song = [self.musicList objectAtIndex:indexPath.row];
    
    [self playingEndNotification:song];
    
    [self.togglePlayPause setSelected:YES];
    
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    self.songName.text = songTitle;
    self.indexOfNowPlayingItem = indexPath.row;
    [self setSliderTimeAndValue:song];
    
}


-(void)setSliderTimeAndValue:(MPMediaItem *)nowPlayingItem{
    
    NSTimeInterval trackLength = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.trackLengthLabel.text = [NSString stringFromTime:trackLength];
    self.progressSlider.value = 0;
    self.progressSlider.maximumValue = trackLength;
    NSString *nowPlaysongTitle = [nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
    NSString *nowPlayalbumTitle = [nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *nowPlayArtist = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    
    // Artwork
    MPMediaItemArtwork *nowPlayartwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (nowPlayartwork != nil) {
        self.imageView.image = [nowPlayartwork imageWithSize:CGSizeMake(50.0f, 50.0f)];
    }
    
    self.artistLabel.text = nowPlayArtist;
    
    self.songAlbumLabel.text = nowPlayalbumTitle;
    
    self.songLabel.text = nowPlaysongTitle;
}

-(void)buildMusicPlayer
{
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 160, 320, 2)];
    [line setBackgroundColor:[UIColor grayColor]];
    [line setAlpha:0.2f];
    [self.view addSubview:line];
    
    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 160 + 10, 225, 20)];
    self.artistLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.artistLabel.font = [UIFont fontWithName:@"Arial" size:17.0f];
    self.artistLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.artistLabel];
    
    self.songAlbumLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 24, 225, 20)];
    self.songAlbumLabel.textColor = [UIColor grayColor];
    self.songAlbumLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
    self.songAlbumLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.songAlbumLabel];
    
    
    self.songLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 47, 225, 20)];
    self.songLabel.textColor = [UIColor blackColor];
    self.songLabel.font = [UIFont fontWithName:@"Arial" size:17.0f];
    self.songLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.songLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(230, [[UIScreen mainScreen] bounds].size.height - 160 + 10, 80, 80)];
    self.imageView.image = [UIImage imageNamed:@"albumart-cd"];
    [self.view addSubview:self.imageView];


    self.trackCurrentPlaybackTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 57 + 27, 45, 20)];
    self.trackCurrentPlaybackTimeLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.trackCurrentPlaybackTimeLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
    self.trackCurrentPlaybackTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.trackCurrentPlaybackTimeLabel];
    
    
    self.trackLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(265, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 57 + 27, 45, 20)];
    self.trackLengthLabel.textColor =  [UIColor grayColor];
    self.trackLengthLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
    self.trackLengthLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.trackLengthLabel];
    
    CGRect myFrame = CGRectMake(50.0f, [[UIScreen mainScreen] bounds].size.height - 160 + 10 + 57 + 27, 220.0f, 20.0f);
    self.progressSlider = [[UISlider alloc] initWithFrame:myFrame];
    self.progressSlider.minimumValue = 0.0f;
    self.progressSlider.maximumValue = 100.0f;
    self.progressSlider.value = 0.0f;
    [self.progressSlider setContinuous:false];
    [self.progressSlider addTarget:self action:@selector(getSilderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: self.progressSlider];
    
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

- (void)loopAction:(id)sender{
    NSLog(@"looping");
}

- (void)shuffleAction:(id)sender{
    NSLog(@"shuffing");
}

- (void)volumeAction:(id)sender{
    NSLog(@"set volume");
}

- (void)listAction:(id)sender{
    NSLog(@"listing");
}


-(void)viewWillAppear:(BOOL)animated {
   [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void) getSilderValue:(UISlider *)paramSender{
    
    if ([paramSender isEqual:self.progressSlider]) {
        float newValue = paramSender.value / 10;
        self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:floor(newValue) * 10];
        
    }
}

-(void) configurePlayer {
    //7
    __block ViewController * weakSelf = self;
    //8
    [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time) {
                                                  if(!time.value) {
                                                      return;
                                                  }
                                                  int currentTime = (int)((weakSelf.audioPlayer.currentTime.value)/weakSelf.audioPlayer.currentTime.timescale);
                                                  
                                                  NSString * durationLabel = [NSString stringFromTime:currentTime];
                                                  self.trackCurrentPlaybackTimeLabel.text = durationLabel;
                                                  self.progressSlider.value = currentTime;
                                              }];
    
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

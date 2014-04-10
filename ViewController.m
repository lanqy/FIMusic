//
//  ViewController.m
//  FlMusic
//
//  Created by lanqy on 14-1-15.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//
#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicCustomCell.h"
#import "NSString+TimeToString.h"
#import "PlayerViewController.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize rearTableView = _rearTableView;
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
   // [self initSession];
    
    // 修改Navigation Bar Title text color
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
   // label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.textColor = [UIColor grayColor]; // change this color
    label.text = NSLocalizedString(@"音乐", @"Songs");
    self.navigationItem.titleView = label;
    
    self.rearTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
    self.rearTableView.dataSource =self;
    self.rearTableView.delegate = self;
   // [self.rearTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.rearTableView];
    
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
    
    // 一秒后自动调用播放器
    [self performSelector:@selector(presentPlayerViewControllerWithoutAnimation) withObject:nil afterDelay:1.0];
    
}

-(void)presentPlayerViewControllerWithoutAnimation
{
    [self selectSongByIndexFromList:0];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

// 通过索引选中cell
-(void)selectTableCellByIndex:(int)index
{
    NSIndexPath* selected = [NSIndexPath indexPathForRow:index inSection:0];
    [self.rearTableView selectRowAtIndexPath:selected animated:false scrollPosition:UITableViewScrollPositionMiddle];
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
    UIImage *ArtworkImage = NULL;
    // Artwork
    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork != nil) {
        ArtworkImage = [artwork imageWithSize:CGSizeMake(50.0f, 50.0f)];
        
    }
    
    
    if (ArtworkImage) {
        cell.artWork.image = ArtworkImage;
    }else{
        cell.artWork.image = [UIImage imageNamed:@"white"];
    }
    
    cell.songName.text = songTitle;
    cell.Artist.text = [NSString stringWithFormat:@"%@ - %@",([Artist length] == 0 ? NSLocalizedString(@"未知歌手", @"Unknown Artist") : Artist),([albumTitle length] == 0 ? NSLocalizedString(@"未知专辑", @"Unkown Album") : albumTitle)];
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
    [self selectSongByIndexFromList:indexPath.row];
}

-(void)selectSongByIndexFromList:(int *)index
{
    
    MPMediaItem *song = [self.musicList objectAtIndex:index];
    if (!self.playerViewController) {
        self.playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    }
    self.playerViewController.playItem = song;
    self.playerViewController.indexPlaying = index;
    self.playerViewController.msList = self.musicList;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.isFromList = YES;
    app.isPlaying = NO;
    
    [self presentModalViewController:self.playerViewController animated:YES];

}

-(void)viewWillAppear:(BOOL)animated {
   [[self navigationController] setNavigationBarHidden:NO animated:YES];
    // 取消选中高亮
    NSIndexPath *tableSelection = [self.rearTableView indexPathForSelectedRow];
    [self.rearTableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void) getSilderValue:(UISlider *)paramSender{
    
    if ([paramSender isEqual:self.progressSlider]) {
        float newValue = paramSender.value / 10;
        self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:floor(newValue) * 10];
    }
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

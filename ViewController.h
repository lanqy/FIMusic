//
//  ViewController.h
//  FlMusic
//
//  Created by lanqy on 14-1-15.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerViewController;
@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *rearTableView;
@property (strong, nonatomic) UIButton *togglePlayPause;
@property (strong, nonatomic) UILabel *songName;
@property (strong, nonatomic) UILabel *durationOutlet;
@property (strong, nonatomic) NSMutableArray *songsList;
@property (strong, nonatomic) NSMutableArray *musicList;
@property (strong, nonatomic) UILabel *songLabel;
@property (strong, nonatomic) UILabel *songAlbumLabel;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UISlider *volumeSlider;
@property (strong, nonatomic) UILabel *trackCurrentPlaybackTimeLabel;
@property (strong, nonatomic) UILabel *trackLengthLabel;
@property (strong, nonatomic) UIButton *repeatButton;
@property (strong, nonatomic) UIButton *shuffleButton;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property BOOL panningProgress;
@property BOOL panningVolume;
@end

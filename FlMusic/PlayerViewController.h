//
//  PlayerViewController.h
//  FlMusic
//
//  Created by lanqy on 14-1-15.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController

@property (nonatomic, strong) id playItem;
@property (nonatomic, readwrite) NSInteger indexPlaying;
@property (nonatomic, strong) NSMutableArray *msList;

@property (nonatomic,strong) UILabel *detailSongTitle;
@property (nonatomic,strong) UILabel *detailSongAlubmTitle;
@property (nonatomic,strong) UILabel *detailSongArtist;
@property (nonatomic,strong) UIImageView *detaiSongArkwork;
@property (nonatomic,strong) UIImageView *detailSongArkworkThumbnail;
@property (nonatomic,strong) UIView *spline;
@property (nonatomic,strong) UIView *aplaLayer;


@property (strong, nonatomic) UILabel *DetailTrackCurrentPlaybackTimeLabel;
@property (strong, nonatomic) UILabel *DetailTrackLengthLabel;
@property (strong, nonatomic) UISlider *detailProgressSlider;
@property (strong, nonatomic) UISlider *detailVolumeSlider;

@end

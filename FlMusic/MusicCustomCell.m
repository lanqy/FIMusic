//
//  MusicCustomCell.m
//  FlMusic
//
//  Created by lanqy on 14-1-19.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//

#import "MusicCustomCell.h"

@implementation MusicCustomCell
@synthesize songName = _songName;
@synthesize Artist = _Artist;
@synthesize AlbumTitle = _AlbumTitle;
@synthesize artWork = _artWork;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildTable];
    }
    return self;
}

-(void)buildTable
{
    self.artWork = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
    [self addSubview:self.artWork];
    
    self.songName = [[UILabel alloc] initWithFrame:CGRectMake(75, 6, 245, 20)];
    self.songName.textColor = [UIColor blackColor];
    self.songName.font = [UIFont fontWithName:@"Arial" size:17.0f];
    self.songName.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.songName];
    
    self.Artist = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 245, 30)];
    self.Artist.textColor = [UIColor grayColor];
    self.Artist.font = [UIFont fontWithName:@"Arial" size:13.0f];
    self.Artist.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.Artist];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

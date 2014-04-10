//
//  AppDelegate.h
//  FlMusic
//
//  Created by lanqy on 14-1-12.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@property (nonatomic) BOOL isPlaying; //默认为YES
@property (nonatomic) BOOL isFromList; // 默认为NO

@end

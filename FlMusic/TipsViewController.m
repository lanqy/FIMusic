//
//  TipsViewController.m
//  FlMusic
//
//  Created by lanqy on 14-2-5.
//  Copyright (c) 2014年 lanqy. All rights reserved.
//
#import "AppDelegate.h"
#import "TipsViewController.h"
#import "FTCoreTextView.h"
#import <CoreMotion/CoreMotion.h>
@interface TipsViewController () <FTCoreTextViewDelegate>

@end

@implementation TipsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect bounds = self.view.bounds;
    
    //  Create scroll view containing allowing to scroll the FTCoreText view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //  Create FTCoreTextView. Everything will be rendered within this view
    self.coreTextView = [[FTCoreTextView alloc] initWithFrame:CGRectInset(bounds, 20.0f, 0)];
	self.coreTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //  Add custom styles to the FTCoreTextView
    [self.coreTextView addStyles:[self coreTextStyle]];
    
    //  Set the custom-formatted text to the FTCoreTextView
  //  NSLog(@"%@",[self textForView]);
    
    self.coreTextView.text = [self textForView];
    
    //  If you want to get notified about users taps on the links,
    //  implement FTCoreTextView's delegate methods
    //  See example implementation below
    self.coreTextView.delegate = self;
    
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDismiss:)];

    // 设置滑动方向.
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    // 滑动事件加到coreTextView
    [self.coreTextView addGestureRecognizer:swipeDown];
    
    [self.scrollView addSubview:self.coreTextView];
    [self.view addSubview:self.scrollView];
}

-(void)swipeToDismiss:(UISwipeGestureRecognizer *) sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionDown) {
        [self setFromList];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)setFromList
{
    AppDelegate *ap=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    ap.isFromList = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //  We need to recalculate fit height on every layout because
    //  when the device orientation changes, the FTCoreText's width changes
    
    //  Make the FTCoreTextView to automatically adjust it's height
    //  so it fits all its rendered text using the actual width
	[self.coreTextView fitToSuggestedHeight];
    
    //  Adjust the scroll view's content size so it can scroll all
    //  the FTCoreTextView's content
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGRectGetMaxY(self.coreTextView.frame)+20.0f)];
}

#pragma mark Load Static Content

- (NSString *)textForView
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tips" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark Styling

- (NSArray *)coreTextStyle
{
    NSMutableArray *result = [NSMutableArray array];
    
    //  This will be default style of the text not closed in any tag
	FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.f];
	defaultStyle.textAlignment = FTCoreTextAlignementJustified;
	[result addObject:defaultStyle];
	
    //  Create style using convenience method
	FTCoreTextStyle *titleStyle = [FTCoreTextStyle styleWithName:@"title"];
	titleStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:20.f];
	titleStyle.paragraphInset = UIEdgeInsetsMake(20.f, 0, 25.f, 0);
	titleStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:titleStyle];
	
    //  Image will be centered
	FTCoreTextStyle *imageStyle = [FTCoreTextStyle new];
	imageStyle.name = FTCoreTextTagImage;
	imageStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:imageStyle];
	
	FTCoreTextStyle *firstLetterStyle = [FTCoreTextStyle new];
	firstLetterStyle.name = @"firstLetter";
	firstLetterStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:30.f];
	[result addObject:firstLetterStyle];
	
    //  This is the link style
    //  Notice that you can make copy of FTCoreTextStyle
    //  and just change any required properties
	FTCoreTextStyle *linkStyle = [defaultStyle copy];
	linkStyle.name = FTCoreTextTagLink;
	linkStyle.color = [UIColor blueColor];
	[result addObject:linkStyle];
	
	FTCoreTextStyle *subtitleStyle = [FTCoreTextStyle styleWithName:@"subtitle"];
	subtitleStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:18.f];
	subtitleStyle.color = [UIColor brownColor];
	subtitleStyle.paragraphInset = UIEdgeInsetsMake(10, 0, 10, 0);
	[result addObject:subtitleStyle];
	
    //  This will be list of items
    //  You can specify custom style for a bullet
	FTCoreTextStyle *bulletStyle = [defaultStyle copy];
	bulletStyle.name = FTCoreTextTagBullet;
	bulletStyle.bulletFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.f];
	bulletStyle.bulletColor = [UIColor blackColor];
	bulletStyle.bulletCharacter = @"❧";
	bulletStyle.paragraphInset = UIEdgeInsetsMake(0, 20.f, 0, 0);
	[result addObject:bulletStyle];
    
    FTCoreTextStyle *italicStyle = [defaultStyle copy];
	italicStyle.name = @"italic";
	italicStyle.underlined = YES;
    italicStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:16.f];
	[result addObject:italicStyle];
    
    FTCoreTextStyle *boldStyle = [defaultStyle copy];
	boldStyle.name = @"bold";
    boldStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:16.f];
	[result addObject:boldStyle];
    
    FTCoreTextStyle *coloredStyle = [defaultStyle copy];
    [coloredStyle setName:@"colored"];
    [coloredStyle setColor:[UIColor redColor]];
	[result addObject:coloredStyle];
    
    return  result;
}

#pragma mark FTCoreTextViewDelegate

- (void)coreTextView:(FTCoreTextView *)acoreTextView receivedTouchOnData:(NSDictionary *)data
{
    //  You can get detailed info about the touched links
    
    //  Name (type) of selected tag
    NSString *tagName = [data objectForKey:FTCoreTextDataName];
    
    //  URL if the touched data was link
    NSURL *url = [data objectForKey:FTCoreTextDataURL];
    
    //  Frame of the touched element
    //  Notice that frame is returned as a string returned by NSStringFromCGRect function
    CGRect touchedFrame = CGRectFromString([data objectForKey:FTCoreTextDataFrame]);
    
    //  You can get detailed CoreText information
    NSDictionary *coreTextAttributes = [data objectForKey:FTCoreTextDataAttributes];
    
    NSLog(@"Received touched on element:\n"
          @"Tag name: %@\n"
          @"URL: %@\n"
          @"Frame: %@\n"
          @"CoreText attributes: %@",
          tagName, url, NSStringFromCGRect(touchedFrame), coreTextAttributes
          );
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
//
//  SyncedVideoViewController.m
//  SyncedVideo
//
//  Created by Ben Gardella on 3/29/12.
//  Copyright (c) 2012 Emmett's Older Brother Prod. All rights reserved.
//

#import "SyncedVideoViewController.h"
#import "SyncedVideoAppDelegate.h"
#import "VideoPlayerViewController.h"


@implementation SyncedVideoViewController


static NSString *songPackPrefix     = @"com.sophieworld.sws.SP.";
static float PAD_SCROLL_IMG_WIDTH   = 1760;
static float PHONE_SCROLL_IMG_WIDTH = 890;
static float PAD_SCROLL_WIDTH       = 1024;
static float PHONE_SCROLL_WIDTH     = 480;
static float PAD_STICKY_SIZE        = 300;
static float PHONE_STICKY_SIZE      = 150;

-(IBAction)makePurchase:(id)sender{
    
    NSLog(@"MAKE PURCHASE!!!");
    
    //call manager singleton
    InAppPurchaseManager *inAppPurchaseManager = [InAppPurchaseManager getInstance];
    [inAppPurchaseManager requestProductData];
    
}
 
-(IBAction)flipToVideoView:(id)sender{
    
    SyncedVideoAppDelegate * myDel = 
    ( SyncedVideoAppDelegate * ) [ [ UIApplication sharedApplication ] delegate ];
    
    [myDel flipToVideoViewWithButtonId:sender];
    
}

//////////////////////////////////
//////////////////////////////////
//////////////////////////////////
// scrolling stuff

- (IBAction)changePage:(id)sender{
    
    int pgOffset = 480;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
        pgOffset = 1024;
    }
    
    NSLog(@"page change: %i", pageControl.currentPage);
    //page 0 : 0 offset
    //page 1 : 480 or 1024 offset
    CGPoint pt = scrollView.contentOffset;
    CGPoint newPt = CGPointMake(pageControl.currentPage*pgOffset, pt.y);
    [scrollView setContentOffset:newPt animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)passedScrollView {
    
    [self snapScroll];
    
    NSLog(@"SCROLL VIEW HERE!!!");
    CGFloat pageWidth = passedScrollView.frame.size.width;
    int xoff =  passedScrollView.contentOffset.x;
    float pageFloat = xoff/pageWidth;
    int page = (int)(pageFloat + 0.5f);
    
    NSLog(@"xoff:%i, width:%f, page:%i", xoff, pageWidth, page);
    
    
    pageControl.currentPage = page;
}

- (void) snapScroll;{
    int scrollWidth = PHONE_SCROLL_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
        scrollWidth = PAD_SCROLL_WIDTH;
    }
    
    int temp = (scrollView.contentOffset.x+(scrollWidth/2)) / scrollWidth;
    [scrollView setContentOffset:CGPointMake(temp*scrollWidth , 0) animated:YES];
    int xoff =  scrollView.contentOffset.x;
    NSLog(@"xoff after snap:%i", xoff);
}

//////////////////////////////////
//////////////////////////////////
//////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // turn off portrait support
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
        return NO;
    else
        return YES;
}



- (void)viewDidLoad {
	// Do any additional setup after loading the view, typically from a nib.
/*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
        [scrollView setContentSize:CGSizeMake(1483, 483)];
    }else {
        [scrollView setContentSize:CGSizeMake(700, 128)];
    }
  */  
    [self setupSongPackViews];
        
    [super viewDidLoad];
}

- (void)setupSongPackViews{
    
    // check for installed song packs
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"manifest" inDirectory:nil];
    NSLog(@"Number of song packs installed: %i", paths.count);
 
    for(NSString *path in paths){
        NSLog(@"pack path: %@", path);
    }
    
    if(paths.count > 1){
        //scrollable corkboard
        [scrollView setScrollEnabled:YES];
     
        pageControl.numberOfPages = paths.count;
        pageControl.currentPage = 0;
        
        //resize the width of the scroll view and background image   
        int bgImageHeight = scrollBackgroundImageView.bounds.size.height;
        int bgScrollHeight = scrollView.bounds.size.height;
        int imgWidthAdjusted = PHONE_SCROLL_IMG_WIDTH*paths.count;
        int widthAdjusted = PHONE_SCROLL_WIDTH*paths.count;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
            imgWidthAdjusted = PAD_SCROLL_IMG_WIDTH*paths.count;
            widthAdjusted = PAD_SCROLL_WIDTH*paths.count;
        }
        
        [scrollBackgroundImageView setBounds:CGRectMake(scrollBackgroundImageView.bounds.origin.x, 
                                                        scrollBackgroundImageView.bounds.origin.y, 
                                                        imgWidthAdjusted, bgImageHeight)];
        
        [scrollView setContentSize:CGSizeMake(widthAdjusted, bgScrollHeight)];
        
        scrollBackgroundImageView.backgroundColor = [UIColor colorWithPatternImage:
                                                     [UIImage imageNamed:@"cork_board_seemless.png"]];
        
        //NSLog(@"adjusted width:%i", widthAdjusted);
        
        [self addSongPackButtons:paths];
        
    }else {
        [scrollView setScrollEnabled:NO];
        pageControl.hidden = YES;
    }
    

}

- (void)addSongPackButtons:(NSArray *)songPackPaths{
    
    for(int i=0; i<songPackPaths.count; i++){
    //for (NSString *manifestFilePath in songPackPaths) {
        NSString *manifestFilePath = [songPackPaths objectAtIndex:i];
         NSLog(@"manifestFilePath: %@", manifestFilePath);
        
        NSData *fileContents = [NSData dataWithContentsOfFile:manifestFilePath];
        NSString *content = [NSString stringWithUTF8String:[fileContents bytes]];
        //[fileContents release];
        NSArray *values = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSString *buttonOne;
        NSString *btnOneTitle;
        NSString *buttonTwo;
        NSString *btnTwoTitle;
        NSString *packId;
        
        for(NSString *line in values){
            if([line hasPrefix:@"button_1_id"]){
                NSArray *arr = [line componentsSeparatedByString:@"="];
                buttonOne = [arr objectAtIndex:1];
            }
            if([line hasPrefix:@"button_1_title"]){
                NSArray *arr = [line componentsSeparatedByString:@"="];
                btnOneTitle = [arr objectAtIndex:1];
            }
            if([line hasPrefix:@"button_2_id"]){
                NSArray *arr = [line componentsSeparatedByString:@"="];
                buttonTwo = [arr objectAtIndex:1];
            }
            if([line hasPrefix:@"button_2_title"]){
                NSArray *arr = [line componentsSeparatedByString:@"="];
                btnTwoTitle = [arr objectAtIndex:1];
            }
            if([line hasPrefix:@"pack_id"]){
                NSArray *arr = [line componentsSeparatedByString:@"="];
                packId = [arr objectAtIndex:1];
            }
            
        }
                
        [self createSongPackButtons:buttonOne :btnOneTitle :buttonTwo :btnTwoTitle :packId];
    }
    
}

- (void)createSongPackButtons:  (NSString *)buttonId1 
                             :  (NSString *)btnOneTitle 
                             :  (NSString *)buttonId2
                             :  (NSString *)btnTwoTitle
                             :  (NSString *)packId{
    NSLog(@"CREATE button one: %@ button two: %@ pack id: %@", buttonId1, buttonId2, packId);
    
    if(packId.intValue > 0){

        NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"post_it_big" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
        
        int fontSize1 = 29;
        int fontSize2 = 29;
        int xbtn1 = 73+(PHONE_SCROLL_WIDTH*packId.intValue);
        int xbtn2 = 267+(PHONE_SCROLL_WIDTH*packId.intValue);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
            xbtn1 = 147+(PAD_SCROLL_WIDTH*packId.intValue);
            xbtn2 = 617+(PAD_SCROLL_WIDTH*packId.intValue);
            
            fontSize1 = 60;
            fontSize2 = 60;

            if(btnOneTitle.length > 10){
                fontSize1 = 45;
            }
            if(btnTwoTitle.length > 10){
                fontSize2 = 45;
            }
        }else {
            if(btnOneTitle.length > 10){
                fontSize1 = 20;
            }
            if(btnTwoTitle.length > 10){
                fontSize2 = 20;
            }
        }
        
        UIButton *songButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [songButton1 addTarget:self action:@selector(flipToVideoView:) 
                     forControlEvents:UIControlEventTouchUpInside];
        
        [songButton1 setTitle:buttonId1 forState:UIControlStateNormal];
        [songButton1 setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        CGRect labelRect;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
            [songButton1 setFrame:CGRectMake(xbtn1,82,PAD_STICKY_SIZE,PAD_STICKY_SIZE)];
            labelRect = CGRectMake(30,-20,250,300);
        }else{
            [songButton1 setFrame:CGRectMake(xbtn1,2,PHONE_STICKY_SIZE,PHONE_STICKY_SIZE)];
            labelRect = CGRectMake(15,-10,120,150);
        }
        UILabel *label1 = [[UILabel alloc] initWithFrame:labelRect];
        label1.font = [UIFont fontWithName:@"Noteworthy" size:fontSize1];
        label1.textColor = UIColor.blackColor;
        [label1 setText:btnOneTitle];
        label1.backgroundColor = [UIColor clearColor];
        [label1 setTextAlignment:UITextAlignmentCenter];
        label1.numberOfLines = 3;
        [songButton1 addSubview:label1];
        [songButton1 setBackgroundImage:image forState:UIControlStateNormal];
        [scrollView addSubview:songButton1];
        
        UIButton *songButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [songButton2 addTarget:self action:@selector(flipToVideoView:) 
                     forControlEvents:UIControlEventTouchUpInside];
        
        [songButton2 setTitle:buttonId2 forState:UIControlStateNormal];
        [songButton2 setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){ //ipad
            [songButton2 setFrame:CGRectMake(xbtn2,82,PAD_STICKY_SIZE,PAD_STICKY_SIZE)];
        }else{
            [songButton2 setFrame:CGRectMake(xbtn2,2,PHONE_STICKY_SIZE,PHONE_STICKY_SIZE)];
        }
        UILabel *label2 = [[UILabel alloc] initWithFrame:labelRect];
        label2.font = [UIFont fontWithName:@"Noteworthy" size:fontSize2];
        label2.textColor = UIColor.blackColor;
        [label2 setText:btnTwoTitle];
        label2.backgroundColor = [UIColor clearColor];
        [label2 setTextAlignment:UITextAlignmentCenter];
        label2.numberOfLines = 3;
        [songButton2 addSubview:label2];
        [songButton2 setBackgroundImage:image forState:UIControlStateNormal];
        [scrollView addSubview:songButton2];
        
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (void)dealloc {
    [super dealloc];
}
     
     
@end

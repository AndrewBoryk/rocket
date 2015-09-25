//
//  ViewController.h
//  SpaceX
//
//  Created by Andrew Boryk on 9/19/15.
//  Copyright © 2015 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ViewController : UIViewController <GKGameCenterControllerDelegate> {
    UIImageView *rocketView;
    NSTimer *updateRocketTimer;
    CGPoint touchLocation;
    UIView *platformView;
    BOOL userTouching;
    BOOL gameOver;
    BOOL outOfFuel;
    float rotation;
    float fallingVelocity;
    float fallingVariable;
    float sidewaysAcceleration;
    float fuelAmmount;
    int totalPlays;
    int totalWins;
    BOOL allTime;
    NSMutableArray *openThrusterImages;
    NSMutableArray *closeThrusterImages;
    UIImageView *offscreenView;
    NSUserDefaults *gameDefaults;
    int inARow;
    float platformOffset;
    UIFont *bolded;
    UIFont *normal;
    NSArray *explosionImages;
    UIImageView *explosionView;
    SystemSoundID audioEffect;
}

@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (strong, nonatomic) IBOutlet UILabel *fuelLabel;
@property (strong, nonatomic) IBOutlet UILabel *winLoseLabel;
@property (strong, nonatomic) IBOutlet UILabel *yAxisLabel;
@property (strong, nonatomic) IBOutlet UILabel *xAxisLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *xLabel;
- (IBAction)scoreSwitchAction:(id)sender;
- (IBAction)replayAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *firstTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *successTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *successCounter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *waterBottomOffset;
@property (weak, nonatomic) IBOutlet UIImageView *waterImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successNumberOffset;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
- (IBAction)leaderboardAction:(id)sender;
- (IBAction)socialAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaderboardOffset;
@property (weak, nonatomic) IBOutlet UIButton *socialButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialOffset;
@property (weak, nonatomic) IBOutlet UIImageView *shareRocket;
@property (weak, nonatomic) IBOutlet UILabel *shareLinuteLabel;
@property (weak, nonatomic) IBOutlet UIView *instructionView;
- (IBAction)playAction:(id)sender;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerAd;

@end


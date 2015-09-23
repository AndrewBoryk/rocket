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

@interface ViewController : UIViewController {
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
    
}

@property (strong, nonatomic) IBOutlet UILabel *fuelLabel;
@property (strong, nonatomic) IBOutlet UILabel *winLoseLabel;
@property (strong, nonatomic) IBOutlet UILabel *yAxisLabel;
@property (strong, nonatomic) IBOutlet UILabel *xAxisLabel;
- (IBAction)scoreSwitchAction:(id)sender;

@end


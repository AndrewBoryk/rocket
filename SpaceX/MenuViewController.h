//
//  MenuViewController.h
//  SpaceX
//
//  Created by Andrew Boryk on 9/21/15.
//  Copyright © 2015 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
@interface MenuViewController : UIViewController <GKGameCenterControllerDelegate> {
    UIImageView *rocketView;
    NSMutableArray *openThrusterImages;
    NSTimer *updateRocketTimer;
    float rotation;
    float direction;
    BOOL gameCenterEnabled;
    NSUserDefaults *menuDefaults;
}

@property (strong, nonatomic) IBOutlet UIView *outerEdge;
@property (strong, nonatomic) IBOutlet UIView *innerEdge;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *leaderboardButton;

- (IBAction)playAction:(id)sender;
- (IBAction)leaderboardAction:(id)sender;


@end

//
//  MenuViewController.m
//  SpaceX
//
//  Created by Andrew Boryk on 9/21/15.
//  Copyright © 2015 Andrew Boryk. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    menuDefaults = [NSUserDefaults standardUserDefaults];
    self.playButton.layer.cornerRadius = 3.0f;
    self.innerEdge.layer.cornerRadius = 3.0f;
    self.outerEdge.layer.cornerRadius = 3.0f;
    self.leaderboardButton.enabled = NO;
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship4"]];
    rocketView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship0"]];
    rocketView.frame = image.frame;
    rocketView.contentMode = UIViewContentModeCenter;
    rocketView.center = CGPointMake(self.view.center.x, self.view.center.y - 100.0f);
    [self.view addSubview:rocketView];
    
    openThrusterImages = [[NSMutableArray alloc] init];
    int animationImageCount = 5;
    for (int i = 0; i < animationImageCount; i++) {
        [openThrusterImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Spaceship%i", i]]];
    }
    rotation = 0;
    direction = -1;
    rocketView.animationImages = openThrusterImages;
    rocketView.animationDuration = 0.25f;
    rocketView.animationRepeatCount = 0;
    [rocketView startAnimating];
    
//    updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
    
    [self authenticateLocalPlayer:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateRocketPosition {
    if (direction == 1) {
        if (rocketView.center.x < self.view.center.x + 10.0f) {
            rotation += direction*0.01f;
        }
        else {
            direction = -direction;
            rotation += direction*0.01f;
        }
    }
    else if (direction == -1){
        if (rocketView.center.x > self.view.center.x - 10.0f) {
            rotation += direction*0.01f;
        }
        else {
            direction = -direction;
            rotation += direction*0.01f;
        }
    }
    
    [UIView animateWithDuration:0.01f animations:^{
        rocketView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotation));
        rocketView.center = CGPointMake(rocketView.center.x + (rotation), rocketView.center.y);
    }];
}

- (IBAction)playAction:(id)sender {
    self.playButton.enabled = NO;
    [UIView animateWithDuration:1.75f animations:^{
        rocketView.center = CGPointMake(rocketView.center.x, -rocketView.frame.size.height);
        self.playButton.alpha = 0;
        self.leaderboardButton.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self performSegueWithIdentifier:@"play" sender:self];
    }];
    
}

- (IBAction)leaderboardAction:(id)sender {
    if ([GKLocalPlayer localPlayer]) {
        [self showLeaderboardAndAchievements:YES];
    }
    else {
        self.leaderboardButton.enabled = NO;
        [self authenticateLocalPlayer: YES];
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)acceleration {
    //ACCELERATION
}

-(void)authenticateLocalPlayer: (BOOL)launchLogin{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            if (launchLogin) {
                [self presentViewController:viewController animated:YES completion:nil];
            }
            self.leaderboardButton.enabled = YES;
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                gameCenterEnabled = YES;
                self.leaderboardButton.enabled = YES;
                [menuDefaults setObject:@"com.linute.rocket.landings" forKey:@"landingLeaderboard"];
                [menuDefaults setObject:@"com.linute.rocket.failed" forKey:@"failedLeaderboard"];
                [menuDefaults synchronize];
            }
            
            else{
                self.leaderboardButton.enabled = YES;
                gameCenterEnabled = NO;
            }
        }
    };
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = [menuDefaults objectForKey:@"landingLeaderboard"];
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

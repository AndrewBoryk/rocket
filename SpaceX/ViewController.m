//
//  ViewController.m
//  SpaceX
//
//  Created by Andrew Boryk on 9/19/15.
//  Copyright © 2015 Andrew Boryk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    gameDefaults = [NSUserDefaults standardUserDefaults];
    gameOver = true;
    userTouching = false;
    self.view.userInteractionEnabled = YES;
    outOfFuel = false;
    totalPlays = 0;
    totalWins = 0;
    self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", totalWins, totalPlays];
    rotation = 0;
    fallingVelocity = 0.0211f;
    fallingVariable = 1;
    allTime = false;
    inARow = 0;
    self.instructionView.alpha = 0;
    self.shareRocket.hidden = YES;
    self.shareLinuteLabel.hidden = YES;
    explosionImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"Explosion1"], [UIImage imageNamed:@"Explosion2"],[UIImage imageNamed:@"Explosion3"],[UIImage imageNamed:@"Explosion4"],[UIImage imageNamed:@"Explosion5"],[UIImage imageNamed:@"Explosion6"],[UIImage imageNamed:@"Explosion7"], nil];
    self.replayButton.alpha = 0;
    self.firstTimeLabel.alpha = 0;
    self.successTitleLabel.alpha = 0;
    self.highScoreLabel.alpha = 0;
    self.successCounter.alpha = 0;
    self.xLabel.alpha = 0;
    self.yLabel.alpha = 0;
    
    
    self.socialOffset.constant = -75;
    self.leaderboardOffset.constant = -75;
    
    bolded = [UIFont fontWithName:@"ADAM.CG PRO" size:100];
    normal = [UIFont fontWithName:@"ADAM.CG PRO" size:45];
    
    self.successCounter.font = normal;
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship4"]];
    rocketView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship0"]];
    rocketView.frame = image.frame;
    rocketView.contentMode = UIViewContentModeCenter;
    rocketView.center = CGPointMake(self.view.center.x+50, -rocketView.frame.size.height);
    platformOffset = 50;
    [self.view addSubview:rocketView];
    platformView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Platform"]];
    platformView.center = CGPointMake(self.view.center.x-75, self.view.frame.size.height - 100);
    [self.view addSubview:platformView];
    openThrusterImages = [[NSMutableArray alloc] init];
    closeThrusterImages = [[NSMutableArray alloc] init];
    int animationImageCount = 5;
    for (int i = 1; i < animationImageCount; i++) {
        [openThrusterImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Spaceship%i", i]]];
    }
    for (int i = animationImageCount; i > 0; i--) {
        [closeThrusterImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Spaceship%i", (i-1)]]];
    }
    fuelAmmount = 5.0f;
    self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
    platformView.alpha = 0;
    self.winLoseLabel.alpha = 0;
    self.fuelLabel.alpha = 0;
    self.yAxisLabel.alpha = 0;
    self.xAxisLabel.alpha = 0;
    self.yAxisLabel.text = @"0.00";
    self.xAxisLabel.text = @"0.00";
    
    if ([gameDefaults objectForKey:@"failedLandingScore"] == nil) {
        [gameDefaults setObject:[NSNumber numberWithInt:0] forKey:@"failedLandingScore"];
        [gameDefaults synchronize];
    }
    if ([gameDefaults objectForKey:@"safeLandingScore"] == nil) {
        [gameDefaults setObject:[NSNumber numberWithInt:0] forKey:@"safeLandingScore"];
        [gameDefaults synchronize];
    }
    else if ([[gameDefaults objectForKey:@"safeLandingScore"] intValue] == 0){
        [self reportWin];
    }
    
    self.bannerAd.adUnitID = @"ca-app-pub-9793545057577851/7451045123";
    self.bannerAd.rootViewController = self;
    [self.bannerAd loadRequest:[GADRequest request]];
    [self.bannerAd setAlpha:0];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([gameDefaults boolForKey:@"scoreboardShown"]) {
        [UIView animateWithDuration:0.5f animations:^{
            platformView.alpha = 1;
            self.winLoseLabel.alpha = 1;
            self.fuelLabel.alpha = 1;
            self.yAxisLabel.alpha = 1;
            self.xAxisLabel.alpha = 1;
            self.xLabel.alpha = 1;
            self.yLabel.alpha = 1;
        } completion:^(BOOL finished) {
            updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
        }];
    }
    else {
        [UIView animateWithDuration:0.5f animations:^{
            self.instructionView.alpha = 1;
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    touchLocation = [touch locationInView:touch.view];
    userTouching = YES;
    rocketView.animationImages = openThrusterImages;
    rocketView.animationDuration = 0.25f;
    rocketView.animationRepeatCount = 0;
    [rocketView startAnimating];
    

}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    touchLocation = [touch locationInView:touch.view];
    userTouching = YES;
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    userTouching = NO;
    [rocketView stopAnimating];
    rocketView.image = [UIImage imageNamed:@"Spaceship0"];
}

-(void)updateRocketPosition {
    CGRect rocketCollision = rocketView.frame;
    rocketCollision.size = CGSizeMake(rocketView.frame.size.width, rocketView.frame.size.height - (rocketView.frame.size.height * 0.22f));
    CGRect platformCollision = platformView.frame;
    platformCollision.origin = CGPointMake(platformView.frame.origin.x+(platformView.frame.size.width * 0.1096f), platformView.frame.origin.y);
    platformCollision.size = CGSizeMake(platformView.frame.size.width * 0.78f, platformView.frame.size.height * 0.25f);
    CGRect intersection = CGRectIntersection(platformCollision, rocketCollision);
    self.yAxisLabel.text = [NSString stringWithFormat:@"%.02f", -(((platformCollision.origin.y - (rocketView.frame.origin.y + rocketCollision.size.height))/platformCollision.origin.y) * 4.0f)];
    
    float xAxis;
    if (fmodf(rotation, 360) > 0 && fmodf(rotation, 360) < 180) {
        xAxis = ((fmodf(fmodf(rotation, 360), 180)/180.0f));
    }
    else if (fmodf(rotation, 360) == 180){
        xAxis = 4.0f;
    }
    else if (fmodf(rotation, 360) > 180 && fmodf(rotation, 360) < 360) {
        xAxis = -(((180.0f - fmodf(fmodf(rotation, 360), 180))/180.0f));
    }
    else {
        xAxis = 0.0f;
    }
    self.xAxisLabel.text = [NSString stringWithFormat:@"%.02f", xAxis];
    if(CGRectIsNull(intersection)) {
        if([offscreenView isDescendantOfView:self.view]) {
            [offscreenView removeFromSuperview];
            [offscreenView stopAnimating];
        }
        if ((rocketView.frame.origin.y + rocketView.frame.size.height) < 0) {
//            offscreenView = [[UIImageView alloc] initWithImage:rocketView.image];
//            offscreenView.center = CGPointMake(rocketView.center.x, ((rocketView.frame.size.height / 2.0f) + 8.0f));
//            offscreenView.clipsToBounds = YES;
//            offscreenView.contentMode = UIViewContentModeScaleAspectFit;
//            CGRect frame = offscreenView.frame;
//            frame.size = CGSizeMake(40, 40);
//            offscreenView.frame = frame;
//            offscreenView.layer.cornerRadius = offscreenView.frame.size.height / 2.0f;
//            offscreenView.layer.borderWidth = 1.0f;
//            offscreenView.layer.borderColor = [UIColor colorWithRed:25.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:0.3f].CGColor;
//            [self.view addSubview:offscreenView];
            [UIView animateWithDuration:0.01f animations:^{
                rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(2.11));
            }];
            
        }
        else {
            if (rocketView.frame.origin.x+rocketView.frame.size.width < 0) {
                if (userTouching) {
                    offscreenView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship4"]];
                }
                else {
                    offscreenView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship0"]];
                }
                
                CGRect frame = offscreenView.frame;
                frame.size = CGSizeMake(40, 40);
                offscreenView.frame = frame;
                offscreenView.center = CGPointMake(((rocketView.frame.size.width / 2.0f) + 8.0f), rocketView.center.y);
                offscreenView.clipsToBounds = YES;
                offscreenView.contentMode = UIViewContentModeScaleAspectFit;
                offscreenView.layer.cornerRadius = offscreenView.frame.size.height / 2.0f;
                offscreenView.layer.borderWidth = 3.0f;
                offscreenView.layer.borderColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:0.4f].CGColor;
                offscreenView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotation));
                [self.view addSubview:offscreenView];
            }
            else if (rocketView.frame.origin.x > self.view.frame.size.width) {
                if (userTouching) {
                    offscreenView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship4"]];
                }
                else {
                    offscreenView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship0"]];
                }
                CGRect frame = offscreenView.frame;
                frame.size = CGSizeMake(40, 40);
                offscreenView.frame = frame;
                offscreenView.center = CGPointMake((self.view.frame.size.width - ((rocketView.frame.size.width / 2.0f) - 8.0f)), rocketView.center.y);
                offscreenView.clipsToBounds = YES;
                offscreenView.contentMode = UIViewContentModeScaleAspectFit;
                offscreenView.layer.cornerRadius = offscreenView.frame.size.height / 2.0f;
                offscreenView.layer.borderWidth = 3.0f;
                offscreenView.layer.borderColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:0.4f].CGColor;
                offscreenView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotation));
                [self.view addSubview:offscreenView];
            }
            else {
                offscreenView = nil;
            }
            if (userTouching) {
                if (fuelAmmount > 0) {
                    fuelAmmount -= 0.01f;
                    if (fuelAmmount< 0) {
                        if (offscreenView) {
                            offscreenView.image =[UIImage imageNamed:@"Spaceship0"];
                        }
                        self.fuelLabel.text = @"0.00 fuel";
                    }
                    else {
                        self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
                    }
                    
                    //            NSLog(@"Fuel Amount %f", fuelAmmount);
                    
                    if (touchLocation.x > self.view.center.x) {
                        float comparisonFloat = (touchLocation.x - (self.view.center.x))/(self.view.center.x);
//                        float rotateValue;
//                        
//                        if (rotation == 0){
//                            rotateValue = 0.211f;
//                        }
//                        else if (rotation > 0 && rotation < 10) {
//                            rotateValue = 0.211f;
//                        }
//                        else if (rotation >= 10 && rotation < 90) {
//                            rotateValue = 0.211f*1.05f;
//                        }
//                        else if (rotation >= 90 && rotation < 135) {
//                            rotateValue = 0.211*1.11f;
//                        }
//                        else if (rotation >= 135 && rotation < 180) {
//                            rotateValue = 0.211*1.05f;
//                        }
//                        else if (rotation >= 180 && rotation < 225) {
//                            rotateValue = 0.211;
//                        }
//                        else if (rotation >= 225 && rotation < 270) {
//                            rotateValue = 0.211*1.55f;
//                        }
//                        else if (rotation >= 270 && rotation < 335) {
//                            rotateValue = 0.211*1.25;
//                        }
//                        else if (rotation >= 335 && rotation < 360) {
//                            rotateValue = 0.211f;
//                        }
//                        
//                        rotation = rotation + (rotateValue);
                        
                        if (rotation >= 0 && rotation < 25) {
                            rotation = rotation + comparisonFloat;
                        }
                        else if (rotation >= 25 && rotation < 90) {
                            rotation = rotation + comparisonFloat*1.11f;
                        }
                        else if (rotation >= 90 && rotation < 135) {
                            rotation = rotation + comparisonFloat*1.25f;
                        }
                        else if (rotation >= 135 && rotation < 180) {
                            rotation = rotation + comparisonFloat*1.11f;
                        }
                        else if (rotation >= 180 && rotation < 225) {
                            rotation = rotation + comparisonFloat;
                        }
                        else if (rotation >= 225 && rotation < 270) {
                            rotation = rotation + comparisonFloat/1.11f;
                        }
                        else if (rotation >= 270 && rotation < 335) {
                            rotation = rotation + comparisonFloat/1.25f;
                        }
                        else if (rotation >= 335 && rotation < 360) {
                            rotation = rotation + comparisonFloat/1.11f;
                        }
                        
                        
                        if (rotation < 0) {
                            rotation = 360.0f + rotation;
                        }
                        else if (rotation > 360){
                            rotation = 0;
                        }
                        
//                        NSLog(@"Rotation right %f", rotation);
                        
                        [self velocity];
                        [self acceleration];
                        
                        [UIView animateWithDuration:0.01f animations:^{
                            rocketView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotation));
                            rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(fallingVelocity));
                        }];
                        
                    }
                    else if (touchLocation.x < self.view.center.x) {
                        float comparisonFloat = ((self.view.center.x)-touchLocation.x)/(self.view.center.x);
//                        float rotateValue;
//                        
//                        if (rotation == 0){
//                            rotateValue = 0.211f;
//                        }
//                        else if (rotation > 0 && rotation < 25) {
//                            rotateValue = 0.211;
//                        }
//                        else if (rotation >= 25 && rotation < 90) {
//                            rotateValue = 0.211*1.25f;
//                        }
//                        else if (rotation >= 90 && rotation < 135) {
//                            rotateValue = 0.211f*1.55f;
//                        }
//                        else if (rotation >= 135 && rotation < 180) {
//                            rotateValue = 0.211;
//                        }
//                        else if (rotation >= 180 && rotation < 225) {
//                            rotateValue = 0.211*1.05f;
//                        }
//                        else if (rotation >= 225 && rotation < 270) {
//                            rotateValue = 0.211*1.11f;
//                        }
//                        else if (rotation >= 270 && rotation < 350) {
//                            rotateValue = 0.211*1.05f;
//                        }
//                        else if (rotation >= 350 && rotation < 360) {
//                            rotateValue = 0.211f;
//                        }
//                        
//                        rotation = rotation - (rotateValue);
                        
                        if (rotation >= 0 && rotation < 45) {
                            rotation = rotation - comparisonFloat/1.11f;
                        }
                        else if (rotation >= 45 && rotation < 90) {
                            rotation = rotation - comparisonFloat/1.25f;
                        }
                        else if (rotation >= 90 && rotation < 135) {
                            rotation = rotation - comparisonFloat/1.11f;
                        }
                        else if (rotation >= 135 && rotation < 180) {
                            rotation = rotation - comparisonFloat;
                        }
                        else if (rotation >= 180 && rotation < 225) {
                            rotation = rotation - comparisonFloat*1.11f;
                        }
                        else if (rotation >= 225 && rotation < 270) {
                            rotation = rotation - comparisonFloat*1.25f;
                        }
                        else if (rotation >= 270 && rotation < 315) {
                            rotation = rotation - comparisonFloat*1.11f;
                        }
                        else if (rotation >= 315 && rotation < 360) {
                            rotation = rotation - comparisonFloat;
                        }
                        
                        if (rotation < 0) {
                            rotation = 360.0f + rotation;
                        }
                        else if (rotation > 360){
                            rotation = 0;
                        }
                        
//                        NSLog(@"Rotation left %f", rotation);
                        
                        [self velocity];
                        [self acceleration];
                        
                        [UIView animateWithDuration:0.01f animations:^{
                            rocketView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotation));
                            rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(fallingVelocity));
                        }];
                    }
                    else {
                        [self velocity];
                        [self acceleration];
                        
                        [UIView animateWithDuration:0.01f animations:^{
                            rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(fallingVelocity));
                        }];
                    }
                }
                else {
                    if (offscreenView) {
                        offscreenView.image =[UIImage imageNamed:@"Spaceship0"];
                    }
                    [rocketView stopAnimating];
                    rocketView.image = [UIImage imageNamed:@"Spaceship0"];
                    self.view.userInteractionEnabled = NO;
                    [self acceleration];
                    [self velocity];
                    [UIView animateWithDuration:0.01f animations:^{
                        rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(fallingVelocity));
                    }];
                }
            }
            else {
                if (rotation == 0){
                    rotation = 0;
                }
                else if (rotation > 0 && rotation < 180){
                    float comparisonFloat = (rotation - 180.0f)/180.0f;
                    if (rotation > 0 && rotation < 45) {
                        
                    }
                    else {
                        rotation = rotation + 0.211f * (1 + comparisonFloat);
                    }
                }
                else if (rotation == 180){
                    rotation = 180;
                }
                else if (rotation < 360 && rotation > 180) {
                    float comparisonFloat = (180.0f - (rotation - 180.0f))/180.0f;
                    if (rotation > 315 && rotation < 360) {
                        
                    }
                    else {
                        rotation = rotation - 0.211f * (1 + comparisonFloat);
                    }
                    
                }
                //            NSLog(@"Going down");
                [self acceleration];
                [self velocity];
                [UIView animateWithDuration:0.01f animations:^{
                    rocketView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotation));
                    rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(fallingVelocity));
                }];
            }
            // check if label is contained in self.view
            
            if ((rocketCollision.origin.y + rocketCollision.size.height) > platformCollision.origin.y) {
//                NSLog(@"Lose");
                [updateRocketTimer invalidate];
                rocketView.transform = CGAffineTransformMakeRotation(0);
                
                explosionView = [[UIImageView alloc] initWithFrame:rocketView.frame];
                CGRect eFrame = explosionView.frame;
                eFrame.origin = CGPointMake(eFrame.origin.x-eFrame.size.width, eFrame.origin.y-(eFrame.size.height * 0.22f));
                explosionView.frame = eFrame;
                
                offscreenView.transform = CGAffineTransformMakeRotation(0);
                offscreenView.image = [UIImage imageNamed:@"Explosion1"];
                [offscreenView stopAnimating];
                offscreenView.animationImages = explosionImages;
                offscreenView.animationDuration = 0.5f;
                offscreenView.animationRepeatCount = 1;
                [offscreenView startAnimating];
                
                explosionView.frame = eFrame;
                rocketView.alpha = 0;
                explosionView.image = [UIImage imageNamed:@"Explosion1"];
                [explosionView sizeToFit];
                [self.view addSubview:explosionView];
                
                [explosionView stopAnimating];
                explosionView.animationImages = explosionImages;
                explosionView.animationDuration = 0.5f;
                explosionView.animationRepeatCount = 1;
                [explosionView startAnimating];
                totalPlays++;
                self.yAxisLabel.text = @"0.00";
                self.xAxisLabel.text = @"0.00";
                [self addFail];
                [NSTimer scheduledTimerWithTimeInterval:0.45f target:self selector:@selector(endingOptions) userInfo:nil repeats:NO];
            }
        }
        
    } else {
        totalPlays++;
        if (rocketCollision.origin.x + rocketCollision.size.width*0.24 >= platformCollision.origin.x && rocketCollision.origin.x+rocketCollision.size.width*0.66 <= platformCollision.origin.x + platformCollision.size.width && rocketCollision.origin.y < platformCollision.origin.y+1) {
            if ((rotation < 10 || rotation > 350) && fallingVariable <= 40) {
                //            NSLog(@"Win");
                NSLog(@"Win velocity: %f", fallingVariable);
                NSLog(@"Win rotation: %f", rotation);
                totalWins++;
                self.yAxisLabel.text = @"0.00";
                self.xAxisLabel.text = @"0.00";
                [self addWin];
                inARow++;
                [updateRocketTimer invalidate];
                if ([gameDefaults boolForKey:@"scoreboardShown"]) {
                    [UIView animateWithDuration:0.5f animations:^{
                        rocketView.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
                    } completion:^(BOOL finished) {
                        self.successCounter.text = [NSString stringWithFormat:@"%i", inARow];
                        self.successCounter.alpha = 0.8f;
                        [UIView animateWithDuration:0.25f animations:^{
                            rocketView.alpha = 0;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.35f animations:^{
                                platformOffset = (arc4random() % 150) - 75.0f;
                                platformView.center = CGPointMake(self.view.center.x-platformOffset, self.view.frame.size.height - 100);
                            } completion:^(BOOL finished) {
                                [self finishGame];
                            }];
                            
                        }];
                        
                        
                    }];
                    
                }
                else {
                    [UIView animateWithDuration:0.5f animations:^{
                        rocketView.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.25f animations:^{
                            platformView.alpha = 0;
                            self.winLoseLabel.alpha = 0;
                            self.xAxisLabel.alpha = 0;
                            self.yAxisLabel.alpha = 0;
                            self.xLabel.alpha = 0;
                            self.yLabel.alpha = 0;
                            self.fuelLabel.alpha = 0;
                            rocketView.alpha = 0;
                        } completion:^(BOOL finished) {
                            [self.view layoutIfNeeded];
                            self.waterBottomOffset.constant = -self.waterImageView.frame.size.height;
                            [UIView animateWithDuration:0.5f animations:^{
                                [self.view layoutIfNeeded];
                            } completion:^(BOOL finished) {
                                [gameDefaults setBool:true forKey:@"scoreboardShown"];
                                [gameDefaults synchronize];
                                [UIView animateWithDuration:0.5f animations:^{
                                    self.bannerAd.alpha = 1;
                                    self.firstTimeLabel.alpha = 1;
                                    self.replayButton.alpha = 1;
                                    self.successTitleLabel.alpha = 1;
                                }];
                            }];
                        }];
                        
                        //
                        
                    }];
                }
                
            }
            else {
                [updateRocketTimer invalidate];
                NSLog(@"Lose velocity: %f", fallingVariable);
                NSLog(@"Lose rotation: %f", rotation);
                self.yAxisLabel.text = @"0.00";
                self.xAxisLabel.text = @"0.00";
                [self addFail];
                rocketView.transform = CGAffineTransformMakeRotation(0);
                explosionView = [[UIImageView alloc] initWithFrame:rocketView.frame];
                CGRect eFrame = explosionView.frame;
                eFrame.origin = CGPointMake(eFrame.origin.x-eFrame.size.width, eFrame.origin.y-(eFrame.size.height * 0.22f));
                explosionView.frame = eFrame;
                
                offscreenView.transform = CGAffineTransformMakeRotation(0);
                offscreenView.image = [UIImage imageNamed:@"Explosion1"];
                [offscreenView stopAnimating];
                offscreenView.animationImages = explosionImages;
                offscreenView.animationDuration = 0.5f;
                offscreenView.animationRepeatCount = 1;
                [offscreenView startAnimating];
                
                rocketView.alpha = 0;
                explosionView.transform = CGAffineTransformMakeRotation(0);
                explosionView.image = [UIImage imageNamed:@"Explosion1"];
                
                [explosionView sizeToFit];
                [self.view addSubview:explosionView];
                
                [explosionView stopAnimating];
                explosionView.animationImages = explosionImages;
                explosionView.animationDuration = 0.5f;
                explosionView.animationRepeatCount = 1;
                [explosionView startAnimating];
                
                [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(endingOptions) userInfo:nil repeats:NO];
            }
        }
        else {
            [updateRocketTimer invalidate];
            NSLog(@"Lose Range velocity: %f", fallingVariable);
            NSLog(@"Lose Range rotation: %f", rotation);
            //            NSLog(@"Lose");
            self.yAxisLabel.text = @"0.00";
            self.xAxisLabel.text = @"0.00";
            [self addFail];
            rocketView.transform = CGAffineTransformMakeRotation(0);
            explosionView = [[UIImageView alloc] initWithFrame:rocketView.frame];
            CGRect eFrame = explosionView.frame;
            eFrame.origin = CGPointMake(eFrame.origin.x-eFrame.size.width, eFrame.origin.y-(eFrame.size.height * 0.22f));
            explosionView.frame = eFrame;
            explosionView.transform = CGAffineTransformMakeRotation(0);
            rocketView.alpha = 0;
            
            offscreenView.transform = CGAffineTransformMakeRotation(0);
            offscreenView.image = [UIImage imageNamed:@"Explosion1"];
            [offscreenView stopAnimating];
            offscreenView.animationImages = explosionImages;
            offscreenView.animationDuration = 0.5f;
            offscreenView.animationRepeatCount = 1;
            [offscreenView startAnimating];
            
            explosionView.image = [UIImage imageNamed:@"Explosion1"];
            [explosionView sizeToFit];
            [self.view addSubview:explosionView];
            
            [explosionView stopAnimating];
            explosionView.animationImages = explosionImages;
            explosionView.animationDuration = 0.5f;
            explosionView.animationRepeatCount = 1;
            [explosionView startAnimating];
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(endingOptions) userInfo:nil repeats:NO];
            
        }
        
        
        // Touching! Do something here
    }
}

-(void)endingOptions {
    rocketView.alpha = 0;
    [explosionView removeFromSuperview];
    if (self.successCounter.alpha > 0) {
        [self showScoreboard];
    }
    else {
        [self finishGame];
    }
}
-(void)showScoreboard {
    [UIView animateWithDuration:0.5f animations:^{
        self.bannerAd.alpha = 1;
    }];
    self.view.userInteractionEnabled = YES;
    [updateRocketTimer invalidate];
    [self.replayButton setTitle:@"RELAUNCH" forState:UIControlStateNormal];
    self.replayButton.enabled = YES;
    self.successTitleLabel.text = @"";
    if ([gameDefaults objectForKey:@"HighScore"]){
        if (inARow > [[gameDefaults objectForKey:@"HighScore"] intValue]) {
            [gameDefaults setObject:[NSNumber numberWithInt:inARow] forKey:@"HighScore"];
            [gameDefaults synchronize];
            self.highScoreLabel.text = @"New Personal Best";
        }
        else {
            self.highScoreLabel.text = [NSString stringWithFormat:@"Best Score: %i", [[gameDefaults objectForKey:@"HighScore"] intValue]];
        }
    }
    else {
        [gameDefaults setObject:[NSNumber numberWithInt:inARow] forKey:@"HighScore"];
        [gameDefaults synchronize];
        self.highScoreLabel.text = @"New Personal Best";
    }
    if ([GKLocalPlayer localPlayer]) {
        [self reportHighScore];
    }
    [UIView animateWithDuration:0.25f animations:^{
        platformView.alpha = 0;
        self.winLoseLabel.alpha = 0;
        self.xAxisLabel.alpha = 0;
        self.yAxisLabel.alpha = 0;
        self.xLabel.alpha = 0;
        self.yLabel.alpha = 0;
        self.fuelLabel.alpha = 0;
        self.successCounter.alpha = 0;
    } completion:^(BOOL finished) {
        self.successCounter.font = bolded;
        [self.view layoutIfNeeded];
        self.successNumberOffset.constant = self.view.frame.size.height/2.0f - 48.0f;
        self.waterBottomOffset.constant = -self.waterImageView.frame.size.height;
        [UIView animateWithDuration:0.5f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
            [gameDefaults setBool:true forKey:@"scoreboardShown"];
            [gameDefaults synchronize];
            self.socialOffset.constant = 16;
            self.leaderboardOffset.constant = 16;
            [UIView animateWithDuration:0.5f animations:^{
                [self.view layoutIfNeeded];
                rocketView.alpha = 0;
                self.highScoreLabel.alpha = 1;
                self.replayButton.alpha = 1;
                self.successTitleLabel.alpha = 1;
                self.successCounter.alpha = 1;
            }];
        }];
    }];
}

-(void)finishGame {
    [updateRocketTimer invalidate];
    rotation = 0;
    rocketView.transform = CGAffineTransformMakeRotation(0);
    if (platformOffset < 0) {
        rocketView.center = CGPointMake(self.view.center.x-50, -100);
    }
    else {
        rocketView.center = CGPointMake(self.view.center.x+50, -100);
    }
    
    
    rocketView.alpha = 0;
    fallingVelocity = 0.0211f;
    fallingVariable = 1;
    sidewaysAcceleration = 0;
    fuelAmmount = 5.0f;
    self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
    
    rocketView.alpha = 1.0f;
    [rocketView sizeToFit];
    self.view.userInteractionEnabled = YES;
    
    updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
    
    
    
}


-(void)acceleration {
    //ACCELERATION
    if (fmodf(rotation, 360) < 90 && fmodf(rotation, 360) > 0) {
        if (sidewaysAcceleration < 1.5f) {
            sidewaysAcceleration += (0.1f * (fmodf(fmodf(rotation, 360), 180) / 180.0f));
        }
        else {
            sidewaysAcceleration = 1.5f;
        }
        
    }
    else if (fmodf(rotation, 360) < 180 && fmodf(rotation, 360) > 90) {
        if (sidewaysAcceleration < 1.5f) {
            sidewaysAcceleration += (0.2f * (fmodf(fmodf(rotation, 360), 180) / 180.0f));
        }
        else {
            sidewaysAcceleration = 1.5f;
        }
        
    }
    else if (fmodf(rotation, 360) < 270 && fmodf(rotation, 360) > 180) {
        if (sidewaysAcceleration > -1.5f) {
            sidewaysAcceleration -= (0.2f * ((180.0f - (fmodf(fmodf(rotation, 360), 180))) / 180.0f));
        }
        else {
            sidewaysAcceleration = -1.5f;
        }
        
    }
    else if (fmodf(rotation, 360) < 360 && fmodf(rotation, 360) > 270) {
        if (sidewaysAcceleration > -1.5f) {
            sidewaysAcceleration -= (0.1f * ((180.0f - fmodf(fmodf(rotation, 360), 180)) / 180.0f));
        }
        else {
            sidewaysAcceleration = -1.5f;
        }
        
    }
}
-(void)velocity{
    if (fallingVariable < 10) {
//        NSLog(@"Falling variable %f", fallingVariable);
    }
    
    if (userTouching && fuelAmmount > 0) {
        if (fmodf(rotation, 360) == 0) {
            if (fallingVariable > 5) {
                fallingVariable-= 1.31f;
                fallingVelocity = fallingVariable*0.0211;
            }
            else {
                fallingVariable = 4;
                fallingVelocity = fallingVariable*0.0211;
            }
            
        }
        else if (fmodf(rotation, 360) < 90 && fmodf(rotation, 360) > 0) {
            if (fallingVariable > 5) {
                fallingVariable += -1.31*(fmodf(rotation, 360) / 90.0f);
                fallingVelocity = fallingVariable*0.0211;
            }
            else {
                fallingVariable = 5;
                fallingVelocity = fallingVariable*0.0211;
            }
            
        }
        else if (fmodf(rotation, 360) < 180 && fmodf(rotation, 360) > 90) {
            fallingVariable += ((fmodf(rotation, 360) - 90.0f) / 90.0f);
            fallingVelocity = fallingVariable*0.0211;
        }
        else if (fmodf(rotation, 360) == 180) {
            fallingVariable++;
            fallingVelocity = fallingVariable*0.0211;
        }
        else if (fmodf(rotation, 360) > 180 && fmodf(rotation, 360) < 270) {
            fallingVariable += ((fmodf(rotation, 360) - 180.0f) / 90.0f);
            fallingVelocity = fallingVariable*0.0211;
        }
        else if (fmodf(rotation, 360) > 270 && fmodf(rotation, 360) < 360) {
            if (fallingVariable > 5.0f) {
                fallingVariable += -1.31*((fmodf(rotation, 360) - 270.0f) / 90.0f);
                fallingVelocity = fallingVariable*0.0211;
            }
            else {
                fallingVariable = 5;
                fallingVelocity = fallingVariable*0.0211;
            }
            
        }
    }
    else {
        fallingVariable++;
        fallingVelocity = fallingVariable*0.0211;
    }
    //VELOCITY
//    NSLog(@"Falling velocity %f", fallingVelocity);
    
}

-(void)addWin {
    int landingTemp = [[gameDefaults objectForKey:@"safeLandingScore"] intValue] + 1;
    [gameDefaults setObject:[NSNumber numberWithInt:landingTemp] forKey:@"safeLandingScore"];
    [gameDefaults synchronize];
    if ([GKLocalPlayer localPlayer]) {
        [self reportWin];
    }
    [self scoreSetter];
    
}

-(void)addFail {
    if (totalPlays%10 == 9) {
        self.bannerAd.adUnitID = @"ca-app-pub-9793545057577851/7451045123";
        self.bannerAd.rootViewController = self;
        [self.bannerAd loadRequest:[GADRequest request]];
    }
    else if (totalPlays%10 == 0) {
        [UIView animateWithDuration:0.5f animations:^{
            self.bannerAd.alpha = 1;
        }];
    }
    else if (totalPlays%10 >= 4) {
        [UIView animateWithDuration:0.5f animations:^{
            self.bannerAd.alpha = 0;
        }];
    }
    int landingTemp = [[gameDefaults objectForKey:@"failedLandingScore"] intValue] + 1;
    [gameDefaults setObject:[NSNumber numberWithInt:landingTemp] forKey:@"failedLandingScore"];
    [gameDefaults synchronize];
    if ([GKLocalPlayer localPlayer]) {
        [self reportFail];
    }
    [self scoreSetter];
}

-(void)scoreSetter {
    if (!allTime) {
        self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", totalWins, totalPlays];
    }
    else {
        self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", [[gameDefaults objectForKey:@"safeLandingScore"] intValue], [[gameDefaults objectForKey:@"failedLandingScore"] intValue]];
    }
}

-(void)reportWin {
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:[gameDefaults objectForKey:@"landingLeaderboard"]];
    score.value = [[gameDefaults objectForKey:@"safeLandingScore"] intValue];
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
//            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)reportFail {
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:[gameDefaults objectForKey:@"failedLeaderboard"]];
    score.value = [[gameDefaults objectForKey:@"failedLandingScore"] intValue];
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
//            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)reportHighScore {
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:[gameDefaults objectForKey:@"highScoreLeaderboard"]];
    score.value = [[gameDefaults objectForKey:@"HighScore"] intValue];
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            //            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)scoreSwitchAction:(id)sender {
    if (allTime) {
        allTime = false;
//        NSLog(@"New");
        self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", totalWins, totalPlays];
    }
    else {
//        NSLog(@"Old");
        allTime = true;
        self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", [[gameDefaults objectForKey:@"safeLandingScore"] intValue], [[gameDefaults objectForKey:@"failedLandingScore"] intValue]];
    }
}

- (IBAction)replayAction:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.bannerAd.alpha = 0;
    }];
    if (self.highScoreLabel.alpha > 0) {
        [UIView animateWithDuration:0.25f animations:^{
            self.successTitleLabel.alpha = 0;
            self.replayButton.alpha = 0;
            self.firstTimeLabel.alpha = 0;
            self.highScoreLabel.alpha = 0;
            self.successCounter.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
            self.waterBottomOffset.constant = 0;
            self.successNumberOffset.constant = 16;
            self.successCounter.font = normal;
            self.successCounter.text = @"1";
            self.socialOffset.constant = -75;
            self.leaderboardOffset.constant = -75;
            [UIView animateWithDuration:0.5f animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                rotation = 0;
                rocketView.transform = CGAffineTransformMakeRotation(0);
                
                if (platformOffset < 0) {
                    rocketView.center = CGPointMake(self.view.center.x-50, -100);
                }
                else {
                    rocketView.center = CGPointMake(self.view.center.x+50, -100);
                }
                
                inARow = 0;
                
                fallingVelocity = 0.0211f;
                fallingVariable = 1;
                sidewaysAcceleration = 0;
                fuelAmmount = 5.0f;
                self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
                
                rocketView.image = [UIImage imageNamed:@"Spaceship0"];
                [rocketView sizeToFit];
                
                [UIView animateWithDuration:0.25f animations:^{
                    platformView.alpha = 1;
                    self.winLoseLabel.alpha = 1;
                    self.xAxisLabel.alpha = 1;
                    self.yAxisLabel.alpha = 1;
                    self.xLabel.alpha = 1;
                    self.yLabel.alpha = 1;
                    self.fuelLabel.alpha = 1;
                    rocketView.alpha = 1;
                } completion:^(BOOL finished) {
                    self.view.userInteractionEnabled = YES;
                    updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
                }];
            }];
        }];

    }
    else {
        [UIView animateWithDuration:0.25f animations:^{
            self.successTitleLabel.alpha = 0;
            self.replayButton.alpha = 0;
            self.firstTimeLabel.alpha = 0;
            self.successCounter.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
            self.waterBottomOffset.constant = 0;
            self.successNumberOffset.constant = 16;
            self.successCounter.font = normal;
            self.successCounter.text = @"1";
            
            [UIView animateWithDuration:0.5f animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                rotation = 0;
                rocketView.transform = CGAffineTransformMakeRotation(0);
                if (platformOffset < 0) {
                    rocketView.center = CGPointMake(self.view.center.x-50, -100);
                }
                else {
                    rocketView.center = CGPointMake(self.view.center.x+50, -100);
                }
                
                fallingVelocity = 0.0211f;
                fallingVariable = 1;
                sidewaysAcceleration = 0;
                fuelAmmount = 5.0f;
                self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
                
                rocketView.image = [UIImage imageNamed:@"Spaceship0"];
                [rocketView sizeToFit];
                
                [UIView animateWithDuration:0.25f animations:^{
                    platformView.alpha = 1;
                    self.winLoseLabel.alpha = 1;
                    self.xAxisLabel.alpha = 1;
                    self.yAxisLabel.alpha = 1;
                    self.xLabel.alpha = 1;
                    self.yLabel.alpha = 1;
                    self.fuelLabel.alpha = 1;
                    rocketView.alpha = 1;
                } completion:^(BOOL finished) {
                    self.successCounter.text = [NSString stringWithFormat:@"%i", inARow];
                    self.successCounter.alpha = 0.8f;
                    self.view.userInteractionEnabled = YES;
                    updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
                }];
            }];
        }];

    }
    
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
                self.leaderboardButton.enabled = YES;
                [gameDefaults setObject:@"com.linute.rocket.landings" forKey:@"landingLeaderboard"];
                [gameDefaults setObject:@"com.linute.rocket.failed" forKey:@"failedLeaderboard"];
                [gameDefaults setObject:@"com.linute.rocket.highscore" forKey:@"highScoreLeaderboard"];
                [gameDefaults synchronize];
            }
            
            else{
                self.leaderboardButton.enabled = YES;
            }
        }
    };
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = [gameDefaults objectForKey:@"landingLeaderboard"];
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

- (IBAction)socialAction:(id)sender {
    self.socialButton.highlighted = NO;
    self.socialButton.hidden = YES;
    self.replayButton.hidden = YES;
    self.leaderboardButton.hidden = YES;
    self.shareRocket.hidden = NO;
    self.shareLinuteLabel.hidden = NO;
    self.successTitleLabel.text = @"Land that Rocket!";
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);}
    else{
        UIGraphicsBeginImageContext(self.view.bounds.size);}
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    UIImage *swag = [UIImage imageWithData:data];
    NSString *texttoshare = @"I'm a bonafide astronaut! @getlinute #SpaceSquad";
    NSArray *activityItems = @[texttoshare, swag];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeMail, UIActivityTypeCopyToPasteboard];
    self.socialButton.hidden = NO;
    self.replayButton.hidden = NO;
    self.leaderboardButton.hidden = NO;
    self.successTitleLabel.text = @"";
    self.shareRocket.hidden = YES;
    self.shareLinuteLabel.hidden = YES;
    [self presentViewController:activityVC animated:TRUE completion:nil];
}
- (IBAction)playAction:(id)sender {
    [UIView animateWithDuration:0.25f animations:^{
        self.instructionView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            platformView.alpha = 1;
            self.winLoseLabel.alpha = 1;
            self.fuelLabel.alpha = 1;
            self.yAxisLabel.alpha = 1;
            self.xAxisLabel.alpha = 1;
            self.xLabel.alpha = 1;
            self.yLabel.alpha = 1;
        } completion:^(BOOL finished) {
            updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
        }];
    }];
    
}
@end

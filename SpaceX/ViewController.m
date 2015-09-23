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
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship4"]];
    rocketView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spaceship0"]];
    rocketView.frame = image.frame;
    rocketView.contentMode = UIViewContentModeCenter;
    rocketView.center = CGPointMake(self.view.center.x, -rocketView.frame.size.height);
    [self.view addSubview:rocketView];
    platformView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Platform"]];
    platformView.center = CGPointMake(self.view.center.x-75, self.view.frame.size.height - 75);
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
    fuelAmmount = 4.0f;
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
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5f animations:^{
        platformView.alpha = 1;
        self.winLoseLabel.alpha = 1;
        self.fuelLabel.alpha = 1;
        self.yAxisLabel.alpha = 1;
        self.xAxisLabel.alpha = 1;
    } completion:^(BOOL finished) {
        updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
    }];
    
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
    platformCollision.origin = CGPointMake(platformView.frame.origin.x+(platformView.frame.size.width * 0.1096f), platformView.frame.origin.y + (platformView.frame.size.height * 0.5151f));
    platformCollision.size = CGSizeMake(platformView.frame.size.width * 0.4795f, platformView.frame.size.height * 0.1212f);
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
    self.xAxisLabel.text = [NSString stringWithFormat:@"%.02f", xAxis];
    if(CGRectIsNull(intersection)) {
        if([offscreenView isDescendantOfView:self.view]) {
            [offscreenView removeFromSuperview];
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
                offscreenView = [[UIImageView alloc] initWithImage:rocketView.image];
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
                        
                        if (rotation >= 0 && rotation < 45) {
                            rotation = rotation + comparisonFloat/1.5f;
                        }
                        else if (rotation >= 45 && rotation < 90) {
                            rotation = rotation + comparisonFloat;
                        }
                        else if (rotation >= 90 && rotation < 135) {
                            rotation = rotation + comparisonFloat*1.5f;
                        }
                        else if (rotation >= 135 && rotation < 180) {
                            rotation = rotation + comparisonFloat;
                        }
                        else if (rotation >= 180 && rotation < 225) {
                            rotation = rotation + comparisonFloat/1.5f;
                        }
                        else if (rotation >= 225 && rotation < 270) {
                            rotation = rotation + comparisonFloat;
                        }
                        else if (rotation >= 270 && rotation < 315) {
                            rotation = rotation + comparisonFloat*1.5f;
                        }
                        else if (rotation >= 315 && rotation < 360) {
                            rotation = rotation + comparisonFloat;
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
                        
                        if (rotation >= 0 && rotation < 45) {
                            rotation = rotation - comparisonFloat;
                        }
                        else if (rotation >= 45 && rotation < 90) {
                            rotation = rotation - comparisonFloat*1.5f;
                        }
                        else if (rotation >= 90 && rotation < 135) {
                            rotation = rotation - comparisonFloat;
                        }
                        else if (rotation >= 135 && rotation < 180) {
                            rotation = rotation - comparisonFloat/1.5f;
                        }
                        else if (rotation >= 180 && rotation < 225) {
                            rotation = rotation - comparisonFloat;
                        }
                        else if (rotation >= 225 && rotation < 270) {
                            rotation = rotation - comparisonFloat*1.5f;
                        }
                        else if (rotation >= 270 && rotation < 315) {
                            rotation = rotation - comparisonFloat;
                        }
                        else if (rotation >= 315 && rotation < 360) {
                            rotation = rotation - comparisonFloat/1.5f;
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
                //            NSLog(@"Going down");
                [self acceleration];
                [self velocity];
                [UIView animateWithDuration:0.01f animations:^{
                    rocketView.center = CGPointMake(rocketView.center.x + sidewaysAcceleration, rocketView.center.y+(fallingVelocity));
                }];
            }
            // check if label is contained in self.view
            
            if ((rocketCollision.origin.y + rocketCollision.size.height) > platformCollision.origin.y) {
                [updateRocketTimer invalidate];
                
                rotation = 0;
                rocketView.transform = CGAffineTransformMakeRotation(0);
                rocketView.center = CGPointMake(self.view.center.x, -100);
                
                fallingVelocity = 0.0211f;
                fallingVariable = 1;
                sidewaysAcceleration = 0;
                fuelAmmount = 4.0f;
                self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
                rocketView.image = [UIImage imageNamed:@"Spaceship0"];
                [rocketView sizeToFit];
                self.view.userInteractionEnabled = YES;
                
                updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
//                NSLog(@"Lose");
                totalPlays++;
                self.yAxisLabel.text = @"0.00";
                self.xAxisLabel.text = @"0.00";
                [self addFail];
            }
        }
        
    } else {
        totalPlays++;
        if ((rotation < 1 || rotation > 359) && fallingVariable < 5) {
//            NSLog(@"Win");
            totalWins++;
            self.yAxisLabel.text = @"0.00";
            self.xAxisLabel.text = @"0.00";
            [self addWin];
        }
        else {
//            NSLog(@"Lose");
            self.yAxisLabel.text = @"0.00";
            self.xAxisLabel.text = @"0.00";
            [self addFail];
        }
        [updateRocketTimer invalidate];
        
        rotation = 0;
        rocketView.transform = CGAffineTransformMakeRotation(0);
        rocketView.center = CGPointMake(self.view.center.x, -100);
        
        fallingVelocity = 0.0211f;
        fallingVariable = 1;
        sidewaysAcceleration = 0;
        fuelAmmount = 4.0f;
        self.fuelLabel.text = [NSString stringWithFormat:@"%.02f fuel", fuelAmmount * 2.0f];
        
        rocketView.image = [UIImage imageNamed:@"Spaceship0"];
        [rocketView sizeToFit];
        self.view.userInteractionEnabled = YES;
        
        updateRocketTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateRocketPosition) userInfo:nil repeats:YES];
        
        // Touching! Do something here
    }
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
    if (fallingVariable < 5) {
        NSLog(@"Falling variable %f", fallingVariable);
    }
    
    if (userTouching && fuelAmmount > 0) {
        if (fmodf(rotation, 360) == 0) {
            if (fallingVariable > 5) {
                fallingVariable-= 1.15f;
                fallingVelocity = fallingVariable*0.0211;
            }
            else {
                fallingVariable = 5;
                fallingVelocity = fallingVariable*0.0211;
            }
            
        }
        else if (fmodf(rotation, 360) < 90 && fmodf(rotation, 360) > 0) {
            if (fallingVariable > 5) {
                fallingVariable += -1.15*(fmodf(rotation, 360) / 90.0f);
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
                fallingVariable += -1.15*((fmodf(rotation, 360) - 270.0f) / 90.0f);
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
    if ([gameDefaults objectForKey:@"landingLeaderboard"]) {
        [self reportWin];
    }
    [self scoreSetter];
    
}

-(void)addFail {
    int landingTemp = [[gameDefaults objectForKey:@"failedLandingScore"] intValue] + 1;
    [gameDefaults setObject:[NSNumber numberWithInt:landingTemp] forKey:@"failedLandingScore"];
    [gameDefaults synchronize];
    if ([gameDefaults objectForKey:@"failedLeaderboard"]) {
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
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)reportFail {
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:[gameDefaults objectForKey:@"failedLeaderboard"]];
    score.value = [[gameDefaults objectForKey:@"failedLandingScore"] intValue];
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)scoreSwitchAction:(id)sender {
    if (allTime) {
        allTime = false;
        NSLog(@"New");
        self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", totalWins, totalPlays];
    }
    else {
        NSLog(@"Old");
        allTime = true;
        self.winLoseLabel.text = [NSString stringWithFormat:@"%i/%i", [[gameDefaults objectForKey:@"safeLandingScore"] intValue], [[gameDefaults objectForKey:@"failedLandingScore"] intValue]];
    }
}
@end

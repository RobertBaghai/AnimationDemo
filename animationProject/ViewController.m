//
//  ViewController.m
//  animationProject
//
//  Created by Robert Baghai on 11/27/15.
//  Copyright © 2015 Robert Baghai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

//UIAnimation
@property (nonatomic, strong) UIDynamicAnimator   *animator;
@property (nonatomic, strong) UIGravityBehavior   *gravity;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

//UI
@property (nonatomic, strong) UIImageView *ball;
@property (nonatomic, strong) UIImageView *paddle;
@property (nonatomic, strong) UIView      *bottomBarrier;
@property (nonatomic, strong) UIButton    *restartButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBall];
    [self createPaddle];
    [self createRestartButton];
    [self turnOnGravityWithBounds];
    [self createInvisibleBoundsOnBottomScreen];
    [self addBehaviorsAndPushBall];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addBehaviorsAndPushBall {
    UIPushBehavior *pushBall = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
    pushBall.pushDirection   = CGVectorMake(1.7, 1.4);
    pushBall.active          = YES;
    [self.animator addBehavior:pushBall];
    
    UIDynamicItemBehavior *paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddle]];
    paddleBehavior.elasticity             = 1.0;
    paddleBehavior.friction               = 0.0;
    paddleBehavior.resistance             = 0.0;
    paddleBehavior.allowsRotation         =  NO;
    paddleBehavior.anchored               = YES;
//    paddleBehavior.density                = 10000.0f;
    [self.animator addBehavior: paddleBehavior];
    
    UIDynamicItemBehavior *ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    ballBehavior.elasticity             = 1.0;
    ballBehavior.friction               = 0.0;
    ballBehavior.resistance             = 0.0;
    ballBehavior.allowsRotation         =  NO;
    [self.animator addBehavior: ballBehavior];
}

- (void)createRestartButton {
    self.restartButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 250, 300, 100)];
    [self.restartButton setTitle:@"Game Over. Click to Restart." forState:UIControlStateNormal];
    [self.view addSubview:self.restartButton];
    self.restartButton.hidden          = YES;
    self.restartButton.backgroundColor = [UIColor blueColor];
    [self.restartButton addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createBall {
    CGRect frameOfView = self.view.frame;
    CGRect frameOfBall = CGRectMake(CGRectGetMidX(frameOfView), 100, 50, 50);
    self.ball          = [[UIImageView alloc] initWithFrame:frameOfBall];
    self.ball.image    = [UIImage imageNamed:@"ball"];
    [self.view addSubview:self.ball];
}

- (void)createPaddle {
    self.paddle       = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame), 550, 120, 30)];
    self.paddle.image = [UIImage imageNamed:@"paddle"];
    [self.view addSubview:self.paddle];
}


- (void)turnOnGravityWithBounds {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity  = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    [self.animator addBehavior:self.gravity];
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ball,self.paddle]];
    // Creates collision boundaries from the bounds of the dynamic animator's referencing self.view
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.collisionMode     = UICollisionBehaviorModeEverything;
    [self.animator addBehavior:self.collisionBehavior];
}

- (void)createInvisibleBoundsOnBottomScreen {
    self.bottomBarrier = [[UIView alloc] initWithFrame:CGRectMake(0, 720, 500, 20)];
    [self.view addSubview:self.bottomBarrier];
    //adds invisible boundary to bottom of screen
    CGPoint B = CGPointMake(self.bottomBarrier.frame.origin.x + self.bottomBarrier.frame.size.width, self.bottomBarrier.frame.origin.y);
    CGPoint A = CGPointMake(self.bottomBarrier.frame.origin.x, self.bottomBarrier.frame.origin.y);
    [self.collisionBehavior addBoundaryWithIdentifier:@"bottomBoundary" fromPoint:A toPoint:B];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    if ( identifier ) {
        [self.animator removeAllBehaviors];
        self.restartButton.hidden = NO;
    }
}

- (void)restart {
    [self.ball removeFromSuperview];
    [self.paddle removeFromSuperview];
    self.restartButton.hidden = YES;
    [self viewDidLoad];
    [self viewWillAppear:YES];
    [self.view reloadInputViews];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        CGRect  newFrame = CGRectMake(location.x - 60, 550, 120, 30);
        //TODO: Fix to make sure paddle doesnt go beyond bounds of screen
        
        //        CGPoint newPostion = CGPointMake(location.x, 100);
        //is the x position of where im touching less then half the width of the paddle
        //if it is set it back to a minimum of half the width of the paddle
//                        if (newFrame.origin.x < self.paddle.frame.size.width/2) {
//                            newFrame.origin.x = self.paddle.frame.size.width/2;
//                        }
//        
//                        //        //is the touch position greater than the width of the screen minus half the width of the paddle?
//                        //        //if it is set it to the width of the screen minus half the width of the paddle
//                        if (newFrame.origin.x > self.view.bounds.size.width - (self.paddle.frame.size.width/2)) {
//                            newFrame.origin.x = self.view.bounds.size.width - (self.paddle.frame.size.width/2);
//                        }
        self.paddle.frame = newFrame;
        [self.animator updateItemUsingCurrentState:self.paddle];
    }
}

@end

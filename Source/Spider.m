//
//  Spider.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Spider.h"

//speed per pixel
static const float SPEED = 15.f;
@implementation Spider

//we treat this as a spider spawn
- (void)didLoadFromCCB
{
    [self setContentSize:CGSizeMake(50, 30)];
    CCLOG(@"asd %f %f",[self anchorPoint].x,[self anchorPoint].y);
    // call method to start animation after random delay
//    CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:1.5f angle:360];
//    [self runAction:[CCActionRepeatForever actionWithAction:actionSpin]];
    [self startSpawn];
}

- (void)startSpawn
{
    // the animation manager of each node is stored in the 'userObject' property
    CCBAnimationManager* animationManager = self.userObject;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"Spawn"];
}

- (void)startWalk
{
    // the animation manager of each node is stored in the 'userObject' property
    CCBAnimationManager* animationManager = self.userObject;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"Walking"];
}

- (void)startStanding
{
    // the animation manager of each node is stored in the 'userObject' property
    CCBAnimationManager* animationManager = self.userObject;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"Standing"];
}

-(void)walkTo:(CGPoint)dst{
    CGPoint vector = ccpSub(dst, self.position);
    CGFloat rotateAngle = -ccpToAngle(vector);
    CGFloat currentTouch = CC_RADIANS_TO_DEGREES(rotateAngle);
    CGFloat ang = currentTouch-self.rotation-90;
    float len = ccpLength(vector);
    float time = len/SPEED;
    [self runAction:[CCActionRotateBy actionWithDuration:1.f angle:ang]];
    [self startWalk];
    [self runAction:[CCActionMoveTo actionWithDuration:time position:dst]];
    [self performSelector:@selector(startStanding) withObject:nil afterDelay:time];
//    CCLOG(@"should take %f angle of %f from old angle of %f",len/SPEED,ang,self.rotation);

}
-(void)update:(CCTime)delta
{

                          
}

@end

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
@implementation Spider{
    id actionMoveDone;
}

//we treat this as a spider spawn
- (void)didLoadFromCCB
{
    _walking=true;
    _blocked=false;
    self.path = [NSMutableArray array];
    _currentPathIndex = 0;
    [self setContentSize:CGSizeMake(50, 30)];
    
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

-(void)walkPath{
    if (_currentPathIndex<[[self path] count]) {
        NSValue *nsv = ([self.path objectAtIndex:_currentPathIndex]);
        CGPoint pt = [nsv CGPointValue];
        
        if (_walking&&!_blocked) {
            _blocked=true;
            [self walkTo:pt];
            _currentPathIndex++;
        }
    }else if(!_blocked&&_walking){
        _walking=false;
        CCLOG(@"Done with path");
        _currentPathIndex=0;
        [self.path removeAllObjects];
        
        [self stopAllActions];
        [self startStanding];
    }
}

-(void)walkTo:(CGPoint)dst{
    CGPoint vector = ccpSub(dst, self.position);
    CGFloat rotateAngle = -ccpToAngle(vector);
    CGFloat currentTouch = CC_RADIANS_TO_DEGREES(rotateAngle);
    CGFloat ang = currentTouch-self.rotation-90;
    CCLOG(@"angle is %f",ang);
    float len = ccpLength(vector);
    float time = len/SPEED;
    [self runAction:[CCActionRotateBy actionWithDuration:0.25f angle:ang]];
    [self runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:time position:dst], [CCActionCallFunc actionWithTarget:self selector:@selector(Done)],[CCActionCallFunc actionWithTarget:self selector:@selector(walkPath)], nil]];
}

-(void)Done
{
    _blocked=false;
}

-(void)update:(CCTime)delta
{
    [self walkPath];
}

@end

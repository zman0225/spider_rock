//
//  Spider.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Spider.h"
#import "constants.h"

@implementation Spider

//we treat this as a spider spawn
- (void)didLoadFromCCB
{
    [self setSpeed:15.f];
    [self setWalking:true];
    [self setBlocked:false];
    [self setPath:[NSMutableArray array]];
    [self setCurrentPathIndex:0];
    [self setSpiderMode:SModeSpawn];
}

-(void)collidedWith:(Spider *)sp{
    
}

-(void)setSpiderMode:(SpiderMode)mode{
    if ((mode==[self mode])&&(SModeLast<=mode||mode<0)) {
        return;
    }
    
    [self setMode:(long)mode];
    CCBAnimationManager* animationManager = [self userObject];
    switch (mode) {
        case SModeSpawn:
            [animationManager runAnimationsForSequenceNamed:@"Spawn"];
            break;
        
        case SModeStanding:
            [animationManager runAnimationsForSequenceNamed:@"Standing"];
            break;
            
        case SModeWalking:
            [animationManager runAnimationsForSequenceNamed:@"Walking"];
            break;
            
        case SModeDeath:
            [animationManager runAnimationsForSequenceNamed:@"Death"];
            break;
            
        default:
            break;
    }
}

-(void)walkPath{
    if (_currentPathIndex<[[self path] count]) {
        if (_walking&&!_blocked) {
            NSValue *nsv = ([self.path objectAtIndex:_currentPathIndex]);
            CGPoint pt = [nsv CGPointValue];
            [self setSpiderMode:SModeWalking];
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
        [self setSpiderMode:SModeStanding];
    }
}

-(void)rotate:(CGPoint)vect{
    CGFloat rotateAngle = -ccpToAngle(vect);
    CGFloat currentTouch = CC_RADIANS_TO_DEGREES(rotateAngle);
    CGFloat ang = currentTouch-self.rotation-90;
    if (ABS(ang)>180) {
        if (ang<0) {
            ang = 360-ABS(ang);
        }else{
            ang = -(360-ang);
        }
    }
    [self runAction:[CCActionRotateBy actionWithDuration:0.25f angle:ang]];
}

-(void)walkTo:(CGPoint)dst{
    CGPoint vector = ccpSub(dst, self.position);
    float len = ccpLength(vector);
    float time = len/[self speed];
    [self rotate:vector];
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

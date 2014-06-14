//
//  Spider.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Spider.h"
#import "constants.h"

//the time we allow certain updates

const static float UPDATE_TIME = 0.5f;
@implementation Spider{
    float _updateTimeCtr;
    CCLabelTTF *_debugMode;
}

//we treat this as a spider spawn
- (void)didLoadFromCCB
{
    CCLOG(@"label say %@",[_debugMode string]);
    [self setAttack:15.f];
    [self setSpeed:25.f];
    [self setWalking:true];
    [self setBlocked:false];
    [self setPath:[NSMutableArray array]];
    [self setCurrentPathIndex:0];
    [self setSpiderMode:SModeSpawn];
    [self setTarget:nil];
    [self setDetectionRange:45];
    self.inRange = [[NSSet alloc] init];
}

-(void)setColor:(CCColor *)color
{
    for(CCNode* child in [self children]){
        [child setColor:color];
    }
}

-(void)initializeSpiderWithID:(int)ownerID range:(float)range attack:(float)attack
{
    [self setOwnerID:ownerID];
    [self setDetectionRange:range];
    [self setAttack:attack];
}

-(void)collidedWith:(Spider *)sp{
    //attack!
    if (self.ownerID!=sp.ownerID&&[[self inRange] containsObject:[self touchedTarget]]) {
        [self resetPath];
        [self setBlocked:false];
        [self setTarget:sp];
        
        [self rotate:ccpSub(sp.position, self.position)];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // generate a random number between 0.0 and 2.0
            float delay = (arc4random() % 800) / 1000.f;
            // call method to start animation after random delay
            [self performSelector:@selector(setToAttack) withObject:nil afterDelay:delay];
        });
        
        [self setBlocked:false];
    }
}

-(void)setToAttack
{
    [self setSpiderMode:SModeAttack];
    [self setBlocked:false];
}


-(void)setSpiderMode:(SpiderMode)mode{
    if (((NSInteger)mode==[self mode])||(SModeLast<=mode||mode<0)) {
        return;
    }
    [self stopAllActions];
    [self setMode:(long)mode];
    
    
    CCLOG(@"[%d] setting mode to %d",[self ownerID],mode);
    CCBAnimationManager* animationManager = [self userObject];
    switch (mode) {
        case SModeSpawn:
            [animationManager runAnimationsForSequenceNamed:@"Spawn"];
            break;
        
        case SModeStanding:
            [animationManager runAnimationsForSequenceNamed:@"Standing"];
            [self setWalking:false];
            break;
        
        case SModeFollow:
        case SModeWalking:
            [animationManager runAnimationsForSequenceNamed:@"Walking"];
            [self setWalking:true];
            break;
            
        case SModeDeath:
            [animationManager runAnimationsForSequenceNamed:@"Death"];
            break;
        
        case SModeAttack:
            [animationManager runAnimationsForSequenceNamed:@"Attacking"];
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
            _blocked=true;
            CCLOG(@"schedule walk");
            [self walkTo:pt];
            _currentPathIndex++;
        }
    }else if(!_blocked&&_walking){
        [self setSpiderMode:SModeStanding];
        [self resetPath];
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

-(void) checkTarget
{
    if ([self target]) {
        if ([[self target] isKindOfClass:[Spider class]]) {
            Spider *sp = (Spider*)[self target];
            if ([sp ownerID]!=[self ownerID]) {
                //enemy!
                //1 check if it is still in range else remove as target
//                if (![[self inRange] containsObject:sp]) {
//                    [self setTarget:nil];
//                    if (SModeFollow==[self mode]) {
//                        CCLOG(@"lost target");
//                        [self setSpiderMode:SModeStanding];
//                        [self resetPath];
//                        [self setBlocked:false];
//                    }
//                    return;
//                }
                
                //2 check if it is slipping away or not
//                if ([sp mode]==SModeWalking) {
                    //chase after it
//                    if ([self mode]==SModeAttack) {
//                        [self resetPath];
//                        [self setSpiderMode:SModeFollow];
//                    }
                    
                    //only add points if we are in follow mode!
//                    CCLOG(@"mode is now %f",[self distanceBetweenRect:[sp boundingBox] andPoint:[self position]]);

//                    if (SModeFollow==[self mode]) {
////                        CCLOG(@"chasing target");
//
//                        [self addPointToPathToFollow:[sp position]];
//                    }
//                }
            }
        }
    }
}

-(void) addPointToPath:(CGPoint)pt
{
    [[self path] addObject:[NSValue valueWithCGPoint:pt]];
    [self setSpiderMode:SModeWalking];
}

-(void) addPointToPathToFollow:(CGPoint)pt
{
//    if (ccpDistance(pt, [self position])>15) {
    CCLOG(@"adding points to follow");
        [[self path] addObject:[NSValue valueWithCGPoint:pt]];
        [self setSpiderMode:SModeFollow];
//    }
}

-(void)resetPath
{
    [self setCurrentPathIndex:0];
    [[self path] removeAllObjects];
}

-(void)followNode:(CCNode *)node
{
    [self resetPath];
    
}

-(void)Done
{
    _blocked=false;
}

-(BOOL)isInRangeWith:(CCNode*)node
{
    return ([self distanceBetweenRect:[node boundingBox] andPoint:self.position]<=[self detectionRange]);
}

-(void)detectInRange
{
    CCNode *parent = [self parent];
    NSMutableSet *temp = [NSMutableSet set];
    for(CCNode *child in [parent children]){
        if (child!=self&&[self isInRangeWith:child])
        {
            [temp addObject:child];
        }
    }
    self.inRange = [NSSet setWithSet:temp];
}

- (CGPoint)closestPointOnRect:(CGRect)rect andPoint:(CGPoint)point
{
    // next we see which point in rect is closest to point
    CGPoint closest = rect.origin;
    if (rect.origin.x + rect.size.width < point.x)
        closest.x += rect.size.width; // point is far right of us
    else if (point.x > rect.origin.x)
        closest.x = point.x; // point above or below us
    if (rect.origin.y + rect.size.height < point.y)
        closest.y += rect.size.height; // point is far below us
    else if (point.y > rect.origin.y)
        closest.y = point.y; // point is straight left or right
    
    return closest;
}

- (CGFloat)distanceBetweenRect:(CGRect)rect andPoint:(CGPoint)point
{
    // first of all, we check if point is inside rect. If it is, distance is zero
    if (CGRectContainsPoint(rect, point)) return 0.f;
    
    CGPoint closest = [self closestPointOnRect:rect andPoint:point];
    // we've got a closest point; now pythagorean theorem
    // distance^2 = [closest.x,y - closest.x,point.y]^2 + [closest.x,point.y - point.x,y]^2
    // i.e. [closest.y-point.y]^2 + [closest.x-point.x]^2
    CGFloat a = powf(closest.y-point.y, 2.f);
    CGFloat b = powf(closest.x-point.x, 2.f);
    return sqrtf(a + b);
}
    
-(void)update:(CCTime)delta
{
    if (_updateTimeCtr>UPDATE_TIME) {
        [self detectInRange];
    }
    if (_updateTimeCtr>5*UPDATE_TIME) {
        if (SModeFollow==[self mode]&&![[self path] containsObject:[NSValue valueWithCGPoint:[_touchedTarget position]]]) {
            CCLOG(@"following touched target %f %f",_touchedTarget.position.x,_touchedTarget.position.y);
            [self addPointToPathToFollow:[_touchedTarget position]];
        }
    }
    
    [self checkTarget];
    
    [self walkPath];
    NSString *narrativeText = [NSString stringWithFormat:@"%d",[self.path count] ];
    
    [_debugMode setString:narrativeText];
    _updateTimeCtr+=delta;
}

@end

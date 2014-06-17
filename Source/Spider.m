//
//  Spider.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Spider.h"
#import "Team.h"
//the time we allow certain updates

const static float UPDATE_TIME = 0.25f;
@implementation Spider{
    float _updateTimeCtr;
    float _attackTimeCtr;
    CCLabelTTF *_debugMode;
}

//we treat this as a spider spawn
- (void)didLoadFromCCB
{
//    CCLOG(@"label say %@",[_debugMode string]);
    [self setHealth:250.f];
    [self setAttack:15.f];
    [self setAttackSpeed:1.f];
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


-(void)collidedWithSpider:(Spider *)sp{
    //attack if it is a target, else ignore for now
    if (self.ownerID!=sp.ownerID&&[[self inRange] containsObject:[self target]]) {
        [self resetPath];
        [self setBlocked:false];
        
        [self rotate:ccpSub(sp.position, self.position)];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // generate a random number between 0.0 and 2.0
            float delay = (arc4random() % 800) / 1000.f;
            // call method to start animation after random delay
            [self performSelector:@selector(setToAttack) withObject:nil afterDelay:delay];
        });
        if ([sp mode]!=SModeAttack) {
            [sp setSpiderMode:SModeAttack];
            [sp attackedBy:self];
        }
        
        [self setBlocked:false];
    }
}

- (void)attackedBy:(Unit *)em
{
    [self setTarget:em];
    if ([[self target] isKindOfClass:[Spider class]]) {
        [self collidedWithSpider:(Spider*)em];
    }
}

-(void)collidedWithBase:(Base *)sp{
    //attack!
    if (self.ownerID!=sp.ownerID&&[[self inRange] containsObject:[self target]]) {
//        CCLOG(@"attack base!");
        [self resetPath];
        [self setBlocked:false];
        
        [self rotate:ccpSub(sp.position, self.position)];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // generate a random number between 0.0 and 2.0
            float delay = (arc4random() % 800) / 1000.f;
            // call method to start animation after random delay
            [self performSelector:@selector(setToSiege) withObject:nil afterDelay:delay];
        });
        
//        if ([sp mode]!=SModeAttack) {
//            [sp attackedBy:self];
//        }
        
        [self setBlocked:false];
    }
}


-(void)setToAttack
{
    [self setSpiderMode:SModeAttack];
    [self setBlocked:false];
}

-(void)setToSiege
{
    [self setSpiderMode:SModeSiege];
    [self setBlocked:false];
}

-(void)setSpiderMode:(SpiderMode)mode{
    if (((NSInteger)mode==[self mode])||(SModeLast<=mode||mode<0)) {
        return;
    }
    [self stopAllActions];
//    CCLOG(@"stopping all actions");
    [self setMode:(long)mode];
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
            [self Done];
            [animationManager runAnimationsForSequenceNamed:@"Walking"];
            [self setWalking:true];
            break;
            
        case SModeDeath:
            [animationManager runAnimationsForSequenceNamed:@"Death"];
            float delay = 1.0f;
            [self performSelector:@selector(removeSelf) withObject:nil afterDelay:delay];
            break;
        
        case SModeAttack:
            [animationManager runAnimationsForSequenceNamed:@"Attacking"];
            break;
            
        case SModeSiege:
            [animationManager runAnimationsForSequenceNamed:@"Attacking"];
            break;
            
        default:
            break;
    }
}

-(void) removeSelf
{
    Team *t = (Team *)[self team];
    [t removeUnit:self];
}

-(void)walkPath{
    if (_currentPathIndex<[[self path] count]) {
        if (_walking&&!_blocked) {
            _blocked=true;
            NSValue *nsv = ([self.path objectAtIndex:_currentPathIndex]);
            CGPoint pt = [nsv CGPointValue];
//            CCLOG(@"schedule walk to %f,%f from %f,%f",pt.x,pt.y,self.position.x,self.position.y);
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
        if ([self target].health<=0) {
            [self setTarget:nil];
            [self setSpiderMode:SModeStanding];
            return;
        }
        if (SModeAttack==[self mode]&&![[self inRange] containsObject:[self target]]) {
            [self setSpiderMode:SModeFollow];
        }
        if (SModeFollow==[self mode]&&![[self path] containsObject:[NSValue valueWithCGPoint:[[self target] position]]]) {
            CCLOG(@"%d following touched target  %f %f",[self mode],[self target].position.x,[self target].position.y);
            [self addPointToPathToFollow:[[self target] position]];
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
//    CCLOG(@"adding points to follow");
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
    
    if (_attackTimeCtr>[self attackSpeed]) {
//        CCLOG(@"%s",[[self inRange] containsObject:[self target]]?"t":"f");
        if (([self mode]==SModeAttack||[self mode]==SModeSiege)&&[[self inRange] containsObject:[self target]]){
            [[self target] addToHealth:-1.f*[self attack]];
            _attackTimeCtr=0.f;
        }
    }

    if (_updateTimeCtr>UPDATE_TIME) {
        [self detectInRange];
        [self checkTarget];
        _updateTimeCtr=0.f;
    }
    
    [self walkPath];
    NSString *narrativeText = [NSString stringWithFormat:@"%.2f %d %d %f %f",[self health],[self.path count],[self mode],self.position.x,self.position.y ];
    
    [_debugMode setString:narrativeText];
    
    if ([self health]<=0) {
        [self setSpiderMode:SModeDeath];
    }
    _updateTimeCtr+=delta;
    _attackTimeCtr+=delta;
}

@end

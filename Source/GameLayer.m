//
//  GameLayer.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameLayer.h"
#import "Spider.h"
#import "CCDrawingPrimitives.h"
#import "Team.h"
#import "Base.h"

const float PINCH_ZOOM_MULTIPLIER = 0.005f;
const float SCREEN_SCALE = 0.6666f;
@implementation GameLayer{
    bool _touched;
    CCPhysicsNode *_physicsNode;
    NSMutableArray *teams;
    Spider *_touchedSpider;
    CGPoint _lastPoint;
    Team *team1, *team2;
    Base *_base1, *_base2;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    _physicsNode.collisionDelegate = self;
    team1 = [[Team alloc] initWithBase:(Base *)_base1];
    team2 = [[Team alloc] initWithBase:(Base *)_base2];
    teams = [NSMutableArray arrayWithArray:@[team1,team2]];
    //    _physicsNode.debugDraw=true;
    self.userInteractionEnabled=YES;
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair spider:(CCNode *)nodeA spider:(CCNode *)nodeB
{
    CCLOG(@"collision between spiders!");
    Spider *a, *b;
    a = (Spider *)nodeA;
    b = (Spider *)nodeB;
    [a collidedWithSpider:b];
    [b collidedWithSpider:a];
    return true;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair spider:(CCNode *)nodeA base:(CCNode *)nodeB
{
    CCLOG(@"collision between spider and base!");
    Spider *a;
    Base *b;
    a = (Spider *)nodeA;
    b = (Base *)nodeB;
    [a collidedWithBase:(Base *)nodeB];
    //    [a collidedWith:b];
    //    [b collidedWith:a];
    return true;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    NSArray* allTouches = [[event allTouches] allObjects];
    if ([allTouches count] == 2) {
        _touchedSpider = nil;
    }else if ([allTouches count] == 1){
        CGPoint touchLoc = [touch locationInNode:self];
        CCLOG(@"x %f y %f",touchLoc.x,touchLoc.y);
        CGPoint converted = [self convertToWorldSpace:touchLoc];
        CCLOG(@"conv: x %f y %f",converted.x,converted.y);
        CCLOG(@"word: x %f y %f",self.position.x,self.position.y);
        
        _lastPoint=touchLoc;
        for(Team* team in teams){
            Unit *node = [team returnTouchedUnit:touchLoc];
            if (node) {
                if ([node isKindOfClass:[Spider class]]) {
                    Spider *sp = (Spider *)node;
                    _touched=true;
                    _touchedSpider = sp;
                    [_touchedSpider resetPath];
                    
                    //if it is following, stop it
                    [_touchedSpider setSpiderMode:SModeStanding];
                    return;
                }else if([node isKindOfClass:[Base class]]){
                    
                }
            }
        }
    }
}

- (void) scale:(CGFloat) newScale scaleCenter:(CGPoint) scaleCenter {
    // scaleCenter is the point to zoom to..
    // If you are doing a pinch zoom, this should be the center of your pinch.
    
    // Get the original center point.
    CGPoint oldCenterPoint = ccp(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    
    // Set the scale.
    self.scale = newScale;
    
    // Get the new center point.
    CGPoint newCenterPoint = ccp(scaleCenter.x * self.scale, scaleCenter.y * self.scale);
    
    // Then calculate the delta.
    CGPoint centerPointDelta  = ccpSub(oldCenterPoint, newCenterPoint);
    
    // Now adjust your layer by the delta.
    self.position = ccpAdd(self.position, centerPointDelta);
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    _touched=false;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    NSArray* allTouches = [[event allTouches] allObjects];
    if ([allTouches count] == 2) {
        // Get two of the touches to handle the zoom
        UITouch* touchOne = [allTouches objectAtIndex:0];
        UITouch* touchTwo = [allTouches objectAtIndex:1];
        
        // Get the touches and previous touches.
        CGPoint touchLocationOne = [touchOne locationInView: [touchOne view]];
        CGPoint touchLocationTwo = [touchTwo locationInView: [touchTwo view]];
        
        CGPoint previousLocationOne = [touchOne previousLocationInView: [touchOne view]];
        CGPoint previousLocationTwo = [touchTwo previousLocationInView: [touchTwo view]];
        
        // Get the distance for the current and previous touches.
        CGFloat currentDistance = sqrt(
                                       pow(touchLocationOne.x - touchLocationTwo.x, 2.0f) +
                                       pow(touchLocationOne.y - touchLocationTwo.y, 2.0f));
        
        CGFloat previousDistance = sqrt(
                                        pow(previousLocationOne.x - previousLocationTwo.x, 2.0f) +
                                        pow(previousLocationOne.y - previousLocationTwo.y, 2.0f));
        
        // Get the delta of the distances.
        CGFloat distanceDelta = currentDistance - previousDistance;
        
        // Next, position the camera to the middle of the pinch.
        // Get the middle position of the pinch.
        CGPoint pinchCenter = ccpMidpoint(touchLocationOne, touchLocationTwo);
        
        // Then, convert the screen position to node space... use your game layer to do this.
        pinchCenter = [self convertToNodeSpace:pinchCenter];
        
        // Finally, call the scale method to scale by the distanceDelta, pass in the pinch center as well.
        // Also, multiply the delta by PINCH_ZOOM_MULTIPLIER to slow down the scale speed.
        // A PINCH_ZOOM_MULTIPLIER of 0.005f works for me, but experiment to find one that you like.
        float newScale = self.scale - (distanceDelta * PINCH_ZOOM_MULTIPLIER)> SCREEN_SCALE?self.scale - (distanceDelta * PINCH_ZOOM_MULTIPLIER):SCREEN_SCALE;
        newScale = newScale>1.5?1.5:newScale;
        [self scale:newScale scaleCenter:pinchCenter];
        [self adjustFrame];
    }else if([allTouches count]==1){
        CGPoint location = [touch locationInNode:self];
        //        location = [[CCDirector sharedDirector] convertToGL:location];
        if (_touched&&ccpDistance(_lastPoint, location) > 15*[self scale]) {
            //SAVE THE POINT
            [_touchedSpider addPointToPath:location];
//            CCLOG(@"pt %f, %f",location.x,location.y);
            _lastPoint = location;
        }else if(!_touched){
            CGPoint diff = ccpSub(location,_lastPoint);
            CGPoint newPos = ccp(self.position.x+diff.x,self.position.y+diff.y);
            [self setPosition:newPos];
            [self adjustFrame];
        }
    }
    
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    NSArray* allTouches = [[event allTouches] allObjects];
    if ([allTouches count] == 2) {
        _touchedSpider = nil;
    }else if ([allTouches count] == 1&&_touched) {
        _touched=!_touched;
        CGPoint touchLoc = [touch locationInNode:self];
        //        touchLoc = [[CCDirector sharedDirector] convertToGL:touchLoc];
        
        //        [_touchedSpider addPointToPath:touchLoc];
        for(Team* team in teams){
            Unit *node = [team returnTouchedUnit:touchLoc];
            if (node&&node!=_touchedSpider) {
                ////                [_touchedSpider resetPath];
                [_touchedSpider setSpiderMode:SModeFollow];
                [_touchedSpider setTarget:node];
//                CCLOG(@"Target set");
                //                [_touchedSpider addPointToPathToFollow:[node position]];
                _touchedSpider = nil;
                return;
            }
        }
//        CCLOG(@"end touched");
        _touchedSpider = nil;
    }
}

-(void) visit
{
    // draw node and children first
    [super visit];
    
    // draw custom code on top of node and its children
    [self draw_lines];
    //    CCLOG(@"position %f %f %f",self.position.x,self.position.y, self.scale);
}

- (void) drawCurPoint:(CGPoint)curPoint PrevPoint:(CGPoint)prevPoint
{
    float lineWidth = 6.0*[self scale];
    //    ccColor4F r = ccc4f(209.0/255.0, 75.0/255.0, 75.0/255.0, 0.5);
    //    CCColor *red = [CCColor colorWithCcColor4f:r];
    //    //These lines will calculate 4 new points, depending on the width of the line and the saved points
    //    CGPoint dir = ccpSub(curPoint, prevPoint);
    //    CGPoint perpendicular = ccpNormalize(ccpPerp(dir));
    //    CGPoint A = ccpAdd(prevPoint, ccpMult(perpendicular, lineWidth / 2));
    //    CGPoint B = ccpSub(prevPoint, ccpMult(perpendicular, lineWidth / 2));
    //    CGPoint C = ccpAdd(curPoint, ccpMult(perpendicular, lineWidth / 2));
    //    CGPoint D = ccpSub(curPoint, ccpMult(perpendicular, lineWidth / 2));
    //
    //    CGPoint poly[4] = {A, C, D, B};
    
    //    ccDrawSolidPoly(poly, 4, red);
    ccDrawSolidCircle(prevPoint, lineWidth/2.0, 20);
    
    ccDrawSolidCircle(curPoint, lineWidth/2.0, 20);
    
}

- (void) draw_lines
{
    //    CCLOG(@"clear %d",[_touchedSpider.path count]);
    if ([_touchedSpider.path count] > 0) {
        
        ccGLEnable(GL_LINE_STRIP);
        
        ccColor4F red = ccc4f(209.0/255.0, 75.0/255.0, 75.0/255.0, 0.5);
        ccDrawColor4F(red.r, red.g, red.b, red.a);
        
        float lineWidth = 3.0 * [[CCDirector sharedDirector] contentScaleFactor];
        
        glLineWidth(lineWidth);
        
        unsigned long count = [_touchedSpider.path count];
        
        for (int i = 0; i < (count - 1); i++){
            CGPoint pos1 = [self convertToWorldSpace:[[_touchedSpider.path objectAtIndex:i] CGPointValue]];
            CGPoint pos2 = [self convertToWorldSpace:[[_touchedSpider.path objectAtIndex:i+1] CGPointValue]];
            
            //            if (i%2==0) {
            [self drawCurPoint:pos2 PrevPoint:pos1];
            //            }
            
        }
    }
}

-(void)adjustFrame
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float x = self.position.x;
    float y = self.position.y;
    float newX = -1*(self.contentSize.width*self.scale-screenRect.size.width);
    float newY = -1*(self.contentSize.height*self.scale-screenRect.size.height);
    CCLOG(@"%f %f %f %f",x,y, self.scale,-1*(self.contentSize.width*self.scale-320));
    if (x>0) {
        self.position = ccp(0, self.position.y);
    }
    
    if (y>0) {
        self.position = ccp(self.position.x,0);
    }
    
    if (x<newX) {
        self.position = ccp(newX, self.position.y);
    }
    
    if (y<newY) {
        self.position = ccp(self.position.x, newY);
    }
}

-(void)SpawnTeam1
{
    [[self menu] showBaseMenu];
//    CGPoint real = [_base1 positionInPoints];
//    Spider *temp = [team1 addSpiderWithX:real.x andY:real.y-30];
//    [_physicsNode addChild:temp];
}

-(void)SpawnTeam2
{
    CGPoint real = [_base2 positionInPoints];
    Spider *temp = [team2 addSpiderWithX:real.x andY:real.y+30];
    [_physicsNode addChild:temp];
}
@end

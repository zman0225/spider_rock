//
//  Gameplay.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Spider.h"
#import "CCDrawingPrimitives.h"
#import "Team.h"
#import "Base.h"

@implementation Gameplay{
    bool _touched;
    CCPhysicsNode *_physicsNode;
    NSMutableArray *teams;
    Spider *_touchedSpider;
    CGPoint _lastPoint;
    Team *team1, *team2;
    
    CCSprite *_base1, *_base2;
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

// called on every touch in this scene
//- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//    CGPoint touchLoc = [touch locationInNode:self];
//    _lastPoint=touchLoc;
//
//}

//- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{ 
//    CGPoint location = [touch locationInNode:self];
//    CGPoint diff = ccpSub(location, _lastPoint);
//    CGPoint newPos =ccpAdd([self position], diff);
//    CGRect box = [self boundingBox];
//    CGPoint newBound = ccp(self.position.x+box.size.width,self.position.y+box.size.height);
////    CCLOG(@"x %f width %f",self.position.x,box.size.width);
//    CCLOG(@"MOVING x:%f y:%f bounds are %f %f",newPos.x,newPos.y,newBound.x,newBound.y);
//
//    if (newPos.x<0&&newPos.y<0&&(newPos.x+box.size.width)<box.size.width&&(newPos.y+box.size.height)<box.size.height) {
//
//        [self setPosition:newPos];
//    }else{
//        
//    }
//}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair spider:(CCNode *)nodeA spider:(CCNode *)nodeB
{
    CCLOG(@"collision!");
    Spider *a, *b;
    a = (Spider *)nodeA;
    b = (Spider *)nodeB;
    [a collidedWith:b];
    [b collidedWith:a];
    return true;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLoc = [touch locationInNode:self];
    _lastPoint=touchLoc;
    for(Team* team in teams){
        CCNode *node = [team returnTouchedNode:touchLoc];
        if (node) {
            if ([node isKindOfClass:[Spider class]]) {
                Spider *sp = (Spider *)node;
                _touched=true;
                _touchedSpider = sp;
                [_touchedSpider resetPath];
                return;
            }else if([node isKindOfClass:[Base class]]){
                
            }
        }
    }
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    _touched=false;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (_touched&&ccpDistance(_lastPoint, location) > 15) {
        //SAVE THE POINT
        [_touchedSpider addPointToPath:location];
//        CCLOG(@"saving points");
        _lastPoint = location;
    }
    

}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_touched) {
        _touched=!_touched;
        CGPoint touchLoc = [touch locationInNode:self];
        [_touchedSpider addPointToPath:touchLoc];
        for(Team* team in teams){
            CCNode *node = [team returnTouchedNode:touchLoc];
            if (node) {
////                [_touchedSpider resetPath];
                [_touchedSpider setMode:SModeFollow];
                [_touchedSpider setTouchedTarget:node];
                CCLOG(@"added");
//                [_touchedSpider addPointToPathToFollow:[node position]];
                _touchedSpider = nil;
                return;
            }
        }
        _touchedSpider = nil;
    }
}

-(void) visit
{
    // draw node and children first
    [super visit];
    
    // draw custom code on top of node and its children
    [self draw_lines];
}

- (void) drawCurPoint:(CGPoint)curPoint PrevPoint:(CGPoint)prevPoint
{
    float lineWidth = 6.0;
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
            CGPoint pos1 = [[_touchedSpider.path objectAtIndex:i] CGPointValue];
            CGPoint pos2 = [[_touchedSpider.path objectAtIndex:i+1] CGPointValue];
            if (i%2==0) {
                [self drawCurPoint:pos2 PrevPoint:pos1];
            }
            
        }
    }
}

-(void)SpawnTeam1
{
    CGPoint real = [_base1 position];
    Spider *temp = [team1 addSpiderWithX:real.x andY:real.y-30];
    [_physicsNode addChild:temp];
}

-(void)SpawnTeam2
{
    CGPoint real = [_base2 position];
    Spider *temp = [team2 addSpiderWithX:real.x andY:real.y+30];
    [_physicsNode addChild:temp];
}
@end

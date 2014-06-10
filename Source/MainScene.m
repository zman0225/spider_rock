//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Spider.h"
#import "CCDrawingPrimitives.h"
#import "Team.h"
@implementation MainScene{
    bool _touched;
    CCPhysicsNode *_physicsNode;
    NSMutableArray *teams;
//    NSMutableArray *_spiders;
    Spider *_touchedSpider;
    CGPoint _lastPoint;
    Team *team1, *team2;
}

-(void)didLoadFromCCB{
    _physicsNode.collisionDelegate = self;

    team1 = [[Team alloc] init];
    team2 = [[Team alloc] init];
    teams = [NSMutableArray arrayWithArray:@[team1,team2]];
    _physicsNode.debugDraw=true;
    self.userInteractionEnabled=YES;
//    _spiders = [NSMutableArray array];
    
}

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
    for(Team* team in teams){
        Spider *sp = [team returnTouchedSpider:touchLoc];
        if (sp) {
            _touched=true;
            _lastPoint=touchLoc;
            _touchedSpider = sp;
            [_touchedSpider setWalking:true];
            return;
        }
    }
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    _touched=false;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (ccpDistance(_lastPoint, location) > 15) {
        //SAVE THE POINT
        [_touchedSpider.path addObject:[NSValue valueWithCGPoint:location]];
        [_touchedSpider setWalking:true];
        
        _lastPoint = location;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_touched) {
        _touched=!_touched;
        CGPoint touchLoc = [touch locationInNode:self];
        [_touchedSpider.path addObject:[NSValue valueWithCGPoint:touchLoc]];
       [_touchedSpider setWalking:true];
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

-(void)spawn
{
    int x = (arc4random() % (int)self.contentSizeInPoints.width-50)+25;
    int y = (arc4random() % (int)self.contentSizeInPoints.height-30)+15;
    
    int i = arc4random()%100;
    Spider *temp;
    if (i%2==0) {
        temp = [team1 addSpiderWithX:x andY:y];
    }else{
        temp = [team2 addSpiderWithX:x andY:y];
    }
    [_physicsNode addChild:temp];
}
@end

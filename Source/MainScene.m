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
@implementation MainScene{
    bool _touched;
    CCPhysicsNode *_physicsNode;
    NSMutableArray *_spiders;
    Spider *_touchedSpider;
    CGPoint _lastPoint;
}

-(void)didLoadFromCCB{
    self.userInteractionEnabled=YES;
    _spiders = [NSMutableArray array];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLoc = [touch locationInNode:self];
    for(Spider *sp in _spiders){
        CGRect rect = CGRectMake(sp.position.x+sp.contentSize.width/2, sp.position.y+sp.contentSize.height/2, -1*sp.contentSize.width, -1*sp.contentSize.height);
        if (CGRectContainsPoint(rect,touchLoc)) {
            _touched = true;
            _touchedSpider = sp;
            _touchedSpider.currentPathIndex = 0;
            [_touchedSpider.path removeAllObjects];
            _lastPoint = touchLoc;
            [_touchedSpider.path addObject:[NSValue valueWithCGPoint:touchLoc]];
            
            _touchedSpider.walking=true;
            [_touchedSpider startWalk];
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
    
    if (ccpDistance(_lastPoint, location) > 20) {
        //SAVE THE POINT
        [_touchedSpider.path addObject:[NSValue valueWithCGPoint:location]];
        
        _touchedSpider.walking=true;
        _lastPoint = location;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_touched) {

        _touched=!_touched;
        CGPoint touchLoc = [touch locationInNode:self];
        [_touchedSpider.path addObject:[NSValue valueWithCGPoint:touchLoc]];
        _touchedSpider.walking=true;
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
    ccColor4F r = ccc4f(209.0/255.0, 75.0/255.0, 75.0/255.0, 1.0);
    CCColor *red = [CCColor colorWithCcColor4f:r];
    //These lines will calculate 4 new points, depending on the width of the line and the saved points
    CGPoint dir = ccpSub(curPoint, prevPoint);
    CGPoint perpendicular = ccpNormalize(ccpPerp(dir));
    CGPoint A = ccpAdd(prevPoint, ccpMult(perpendicular, lineWidth / 2));
    CGPoint B = ccpSub(prevPoint, ccpMult(perpendicular, lineWidth / 2));
    CGPoint C = ccpAdd(curPoint, ccpMult(perpendicular, lineWidth / 2));
    CGPoint D = ccpSub(curPoint, ccpMult(perpendicular, lineWidth / 2));
    
    CGPoint poly[4] = {A, C, D, B};
    
    ccDrawSolidPoly(poly, 4, red);
    ccDrawSolidCircle(curPoint, lineWidth/2.0, 20);
    
}

- (void) draw_lines
{
    if ([_touchedSpider.path count] > 0) {

        ccGLEnable(GL_LINE_STRIP);
        
        ccColor4F red = ccc4f(209.0/255.0, 75.0/255.0, 75.0/255.0, 1.0);
        ccDrawColor4F(red.r, red.g, red.b, red.a);
        
        float lineWidth = 6.0 * CC_CONTENT_SCALE_FACTOR();
        
        glLineWidth(lineWidth);
        
        int count = [_touchedSpider.path count];
        
        for (int i = 0; i < (count - 1); i++){
            CGPoint pos1 = [[_touchedSpider.path objectAtIndex:i] CGPointValue];
            CGPoint pos2 = [[_touchedSpider.path objectAtIndex:i+1] CGPointValue];
            
            [self drawCurPoint:pos2 PrevPoint:pos1];
        }
    }
}

-(void)spawn
{
    CCLOG(@"spawning a spider");
    
    int x = (arc4random() % (int)self.contentSizeInPoints.width);
    int y = (arc4random() % (int)self.contentSizeInPoints.height);
    Spider *spider = (Spider*)[CCBReader load:@"Spider"];
    spider.position = ccp(x,y);
    [_spiders addObject:spider];
    [_physicsNode addChild:spider];
}
@end

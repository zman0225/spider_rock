//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Spider.h"
@implementation MainScene{
    bool _touched;
    CCPhysicsNode *_physicsNode;
    NSMutableArray *_spiders;
    Spider *_touchedSpider;
}
-(void)didLoadFromCCB{
    self.userInteractionEnabled=YES;
    _spiders = [NSMutableArray array];
    Spider *spider = (Spider*)[CCBReader load:@"Spider"];
    spider.position = ccp(150,300);
    [_spiders addObject:spider];
    [_physicsNode addChild:spider];
    [spider setAnchorPoint:ccp(0.5,0.5)];

    CGPoint temp = [spider convertToWorldSpace:spider.anchorPointInPoints];
    CCLOG(@"loaded anchor x %f y %f",temp.x,temp.y);
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLoc = [touch locationInNode:self];
    for(Spider *sp in _spiders){
        CGRect rect = CGRectMake(sp.position.x+sp.contentSize.width/2, sp.position.y+sp.contentSize.height/2, -1*sp.contentSize.width, -1*sp.contentSize.height);

        CCLOG(@"asd %f %f %f %f %f %f",touchLoc.x, touchLoc.y, rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);

        if (CGRectContainsPoint(rect,touchLoc)) {
            _touched = true;
            _touchedSpider = sp;
            CCLOG(@"touched down");
            return;
        }
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_touched) {
        CCLOG(@"touched up");

        _touched=!_touched;
        CGPoint touchLoc = [touch locationInNode:self];
        [_touchedSpider walkTo:touchLoc];
        _touchedSpider = nil;
    }
}

-(void)spawn
{
    CCLOG(@"spawning a spider");
}
@end

//
//  BaseMenu.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "BaseMenu.h"

@implementation BaseMenu{
    CCScrollView *_displayPanel;
    CCButton *_creatureBtn, *buildingBtn, *baseBtn;
}

-(void)didLoadFromCCB{
    CCLOG(@"size height: %f",_displayPanel.boundingBox.size.height);
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSArray *allTouches = [event allTouches];
    if ([allTouches count]==1) {
        UITouch *t = [allTouches objectAtIndex:0];
        CGPoint touch = [t locationInView:[t view]];
        CGPoint preTouch = [t previousLocationInView:[t view]];
        
//        CGPoint diff = touch
    }
}

-(void)CreaturePanel{
    CCLOG(@"clicked on creature");
}

-(void)BuildingPanel{
    CCLOG(@"clicked on building");
}

-(void)BasePanel{
    CCLOG(@"clicked on base");
}
@end

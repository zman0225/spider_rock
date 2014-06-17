//
//  MenuLayer.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MenuLayer.h"
#import "BaseMenu.h"

@implementation MenuLayer{
    CCButton *_menuBtn;
    BaseMenu *_baseMenuNode;
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = true;
    [_baseMenuNode removeFromParent];
    CCLayoutBox *asd;
    [asd setDirection:CCLayoutBoxDirectionVertical];
    
//    [_baseMenuNode setVisible:false];
}

-(void)menu{
    CCLOG(@"asd");
    
}

-(void)showBaseMenu{
    [_menuBtn setUserInteractionEnabled:false];
    [[self parent] setUserInteractionEnabled:NO];
    [[self parent] addChild:_baseMenuNode];
}

-(void)close{
    [_baseMenuNode removeFromParent];
}


@end

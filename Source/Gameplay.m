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
#import "MenuLayer.h"
#import "GameLayer.h"

@implementation Gameplay{
    GameLayer *_gameLayer;
    MenuLayer *_menuLayer;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    CCLOG(@"child %d",[_menuLayer.children count]);
    [_gameLayer setMenu:_menuLayer];
}

@end

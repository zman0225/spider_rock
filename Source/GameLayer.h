//
//  GameLayer.h
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
#ifndef SpiderRock_Gamelayer_h
#define SpiderRock_Gamelayer_h
#import "CCNode.h"
#import "MenuLayer.h"
@interface GameLayer : CCNode <CCPhysicsCollisionDelegate>
@property (nonatomic,strong) MenuLayer *menu;
@end
#endif
//
//  Team.h
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef SpiderRock_Team_h
#define SpiderRock_Team_h

#import <Foundation/Foundation.h>
#import "constants.h"
#import "Spider.h"
#import "Base.h"

@interface Team : NSObject
@property (nonatomic) int teamID;
@property (nonatomic) float points;
@property (nonatomic) float mana;
@property (nonatomic,strong) NSMutableArray *assets;
@property (nonatomic,strong) CCColor *teamColor;
@property (nonatomic) Unit *base;

-(id) init;
-(id) initWithBase:(Unit *)base;
-(Spider*) returnTouchedSpider:(CGPoint)touchLocation;
-(Spider*) addSpiderWithX:(float)x andY:(float)y;
-(Unit*) returnTouchedUnit:(CGPoint)touchLocation;
-(void) removeUnit:(Unit *)unit;

@end

#endif
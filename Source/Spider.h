//
//  Spider.h
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
#ifndef SpiderRock_Spider_h
#define SpiderRock_Spider_h

#import "constants.h"
#import "Unit.h"
#import "Base.h"

@interface Spider : Unit
@property (nonatomic,strong) NSMutableArray *path;
@property (nonatomic) int currentPathIndex;
@property (nonatomic) bool walking;
@property (nonatomic) bool blocked;
@property (nonatomic) NSInteger speed;

-(void)initializeSpiderWithID:(int)ownerID range:(float)range attack:(float)attack;
-(void)setSpiderMode:(SpiderMode)mode;
-(void)walkPath;
-(void)collidedWithSpider:(Spider *)sp;
-(void)collidedWithBase:(Base *)sp;
-(void)resetPath;
-(void) addPointToPath:(CGPoint)pt;
-(void) addPointToPathToFollow:(CGPoint)pt;

@end

#endif
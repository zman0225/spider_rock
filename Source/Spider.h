//
//  Spider.h
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Spider : CCSprite 
@property (nonatomic,strong) NSMutableArray *path;
@property (nonatomic) int currentPathIndex;
@property (nonatomic) bool walking;
@property (nonatomic) bool blocked;
@property (nonatomic) long mode;
@property (nonatomic) NSInteger speed;
@property (nonatomic) float detectionRange;
@property (nonatomic) int ownerID;
@property (nonatomic) float attack;

-(void)initializeSpiderWithID:(int)ownerID range:(float)range attack:(float)attack;
-(void)walkPath;
-(void)collidedWith:(Spider *)sp;
@end

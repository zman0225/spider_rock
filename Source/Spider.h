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
-(void)walkTo:(CGPoint)dst;
-(void)walkPath;
-(void)startWalk;

@end

//
//  Team.h
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spider.h"

@interface Team : NSObject
@property (nonatomic) int teamID;
@property (nonatomic) float points;
@property (nonatomic,strong) NSMutableArray *spiders;

-(id)init;
-(Spider*)returnTouchedSpider:(CGPoint)touchLocation;
-(Spider*)addSpiderWithX:(float)x andY:(float)y;

@end

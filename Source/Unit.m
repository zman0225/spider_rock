//
//  Unit.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Unit.h"

@implementation Unit
-(void)addToHealth:(float)pts
{
    [self setHealth:[self health]+pts];
}
@end

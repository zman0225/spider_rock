//
//  Team.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Team.h"

static int ID = 0;

@implementation Team

-(id)init
{
    self = [super init];
    if (self) {
        [self setTeamID:ID];
        ID++;
    }
    self.spiders = [NSMutableArray array];
    [self setPoints:200];
    return self;
    
}

-(Spider*)returnTouchedSpider:(CGPoint)touchLocation
{
    for(Spider *sp in [self spiders]){
        CGRect rect = CGRectMake(sp.position.x+sp.contentSize.width/2, sp.position.y+sp.contentSize.height/2, -1*sp.contentSize.width, -1*sp.contentSize.height);

        if (CGRectContainsPoint(rect,touchLocation)) {

            [sp setCurrentPathIndex:0];
            [[sp path] removeAllObjects];
            [[sp path] addObject:[NSValue valueWithCGPoint:touchLocation]];
            [sp setWalking:true];
            return sp;
        }
    }
    return nil;
}

-(Spider*)addSpiderWithX:(float)x andY:(float)y
{
    Spider *spider = (Spider*)[CCBReader load:@"Spider"];
    CCColor *color = [CCColor colorWithCcColor3b:ccc3(255, 255, 255)];
    [spider setColor:color];
    [spider setOwnerID:[self teamID]];
    [self addSpider:spider];
    spider.position = ccp(x,y);
    return spider;
}

-(void)addSpider:(Spider*)sp
{
    int ran = arc4random()%10;
    NSString *strFromInt = [NSString stringWithFormat:@"%d",ran];
    [[sp physicsBody] setCollisionType:@"spider"];
    [[sp physicsBody] setCollisionGroup:strFromInt];
    
    CCLOG(@"spider created with a collision type of %d",sp.ownerID);
    [[self spiders] addObject:sp];
}

-(void)removeSpider:(Spider*)sp
{
    [[self spiders] removeObject:sp];
    [sp removeFromParent];
}
@end

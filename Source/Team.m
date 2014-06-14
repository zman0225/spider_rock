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

-(id)initWithBase:(Base *)base
{
    self = [self init];
    [self setBase:base];
    [[self assets] addObject:base];
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self setTeamID:ID];
        ID++;
    }
    self.assets = [NSMutableArray array];
    [self setPoints:200];
    [self setTeamColor:[CCColor colorWithCcColor3b:ccc3(arc4random()%255,arc4random()%255,arc4random()%255)]];
    CCLOG(@"colors %d",(int)self.teamColor.ccColor3b.b);
    return self;
}

-(Spider*)returnTouchedSpider:(CGPoint)touchLocation
{
    for(CCNode *node in [self assets]){
        if ([node isKindOfClass:[Spider class]]) {
            Spider *sp = (Spider *)node;
            CGRect rect = CGRectMake(sp.position.x+sp.contentSize.width/2, sp.position.y+sp.contentSize.height/2, -1*sp.contentSize.width, -1*sp.contentSize.height);
            
            if (CGRectContainsPoint(rect,touchLocation)) {
                [sp resetPath];
                return sp;
            }
        }
    }
    return nil;
}

-(CCNode*)returnTouchedNode:(CGPoint)touchLocation
{
    for(CCNode *node in [self assets]){
        CGRect rect = CGRectMake(node.position.x+node.contentSize.width/2, node.position.y+node.contentSize.height/2, -1*node.contentSize.width, -1*node.contentSize.height);
        if (CGRectContainsPoint(rect,touchLocation)) {
            return node;
        }
    }
    return nil;
}

-(Spider*)addSpiderWithX:(float)x andY:(float)y
{
    Spider *spider = (Spider*)[CCBReader load:@"Spider"];
//    [spider setColor:[self teamColor]];
    spider.color = [self teamColor];
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
    [[self assets] addObject:sp];
}

-(void)removeSpider:(Spider*)sp
{
    [[self assets] removeObject:sp];
    [sp removeFromParent];
}
@end

//
//  Base.m
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Base.h"

@implementation Base{
    CCLabelTTF *_debugMode;
}
-(void)didLoadFromCCB
{
    [[self physicsBody] setCollisionType:@"base"];
    [self setMaxHealth:250.f];
    [self setHealth:250.f];
}

- (void)attackedBy:(Unit *)em
{
    [self setTarget:em];
//    if ([[self target] isKindOfClass:[Spider class]]) {
//        [self collidedWithSpider:(Spider*)em];
//    }
}

-(void)update:(CCTime)delta
{
    NSString *narrativeText = [NSString stringWithFormat:@"%.2f/%.2f ",[self health],[self maxHealth]];
    [_debugMode setString:narrativeText];
}
@end

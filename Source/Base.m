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
}

-(void)update:(CCTime)delta
{
    NSString *narrativeText = [NSString stringWithFormat:@"Health %f/%f ",[self health],[self maxHealth]];
    
    [_debugMode setString:narrativeText];
}
@end

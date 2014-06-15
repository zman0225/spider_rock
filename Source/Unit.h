//
//  Unit.h
//  SpiderRock
//
//  Created by Ziyuan Liu on 6/15/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Unit : CCSprite
@property (nonatomic) long mode;
@property (nonatomic) float detectionRange;
@property (nonatomic) int ownerID;

@property (nonatomic) float attack;
@property (nonatomic) float attackSpeed;

@property (nonatomic) NSSet *inRange;
@property (nonatomic) Unit *target;

@property (nonatomic) float capacity;
@property (nonatomic) float maxCapacity;

@property (nonatomic) float health;
@property (nonatomic) float maxHealth;
@property (nonatomic) id team;

-(void) attackedBy:(Unit *)em;
-(void) addToHealth:(float)pts;

@end

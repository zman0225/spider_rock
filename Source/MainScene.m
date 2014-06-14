//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

-(void)didLoadFromCCB{
    //    _spiders = [NSMutableArray array];
    
}

-(void)play
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


//-(void)spawn
//{
//    int x = (arc4random() % (int)self.contentSizeInPoints.width-50)+25;
//    int y = (arc4random() % (int)self.contentSizeInPoints.height-30)+15;
//    
//    int i = arc4random()%100;
//    Spider *temp;
//    if (i%2==0) {
//        temp = [team1 addSpiderWithX:x andY:y];
//    }else{
//        temp = [team2 addSpiderWithX:x andY:y];
//    }
//    
//    [_physicsNode addChild:temp];
//    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
//    [[CCDirector sharedDirector] replaceScene:gameplayScene];
//}
@end

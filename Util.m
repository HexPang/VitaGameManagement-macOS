//
//  Util.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "Util.h"

static Util *_instance = nil;
@implementation Util


+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (NSDictionary *) loadConfig{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"setting"];
}
@end

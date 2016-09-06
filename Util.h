//
//  Util.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject
+(instancetype) shareInstance ;
- (NSDictionary *) loadConfig;
- (NSURL *) getCacheFolder:(NSString *)name;
@end

//
//  VitaPackageHelper.h
//  VitaPackageHelper
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnzipKit.h"
#import "Util.h"

@interface VitaPackageHelper : NSObject
typedef void (^patchProgressBlock)(long total,int current);

- (NSArray *) loadPackage:(NSString*)path;
- (NSDictionary *) loadSFO:(NSString*) package;
- (BOOL) patchPackage:(NSString *)sourceFile withPatchFile:(NSString*)patchFile;
- (BOOL) patchPackage:(NSString *)sourceFile withPatchFile:(NSString*)patchFile withProgress:(patchProgressBlock)block;
@end

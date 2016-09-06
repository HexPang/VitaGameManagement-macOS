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
#import "SSZipArchive.h"
#import <Cocoa/Cocoa.h>

@interface VitaPackageHelper : NSObject
typedef void (^patchProgressBlock)(int state,float progress,NSString *file);

- (NSArray *) loadPackage:(NSString*)path;
- (NSDictionary *) loadSFO:(NSString*) package;
- (BOOL) patchPackage:(NSString *)sourceFile withPatchFile:(NSString*)patchFile;
- (BOOL) patchPackage:(NSString *)sourceFile withPatchFile:(NSString*)patchFile withProgress:(patchProgressBlock)block;
- (NSString *) splitPackage:(NSString *)sourcePackage withProgress:(patchProgressBlock)block;
@end

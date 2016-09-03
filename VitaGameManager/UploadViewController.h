//
//  UploadViewController.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Util.h"
#import "FTPManager.h"

@interface UploadViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource,FTPManagerDelegate>
@property (weak,nonatomic) IBOutlet NSTableView *tableView;
@end

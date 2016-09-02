//
//  GameItem.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GameItem : NSCollectionViewItem
@property IBOutlet NSImageView *iconView;
@property IBOutlet NSTextField *titleLabel;
@end

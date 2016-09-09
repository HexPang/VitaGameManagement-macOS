//
//  MyVitaViewController.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/6.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Util.h"
#import "MyVitaViewItem.h"

@interface MyVitaViewController : NSViewController<NSCollectionViewDelegate,NSCollectionViewDataSource>
@property (weak,nonatomic) IBOutlet NSCollectionView *collectionView;
@end

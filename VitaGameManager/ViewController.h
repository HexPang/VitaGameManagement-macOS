//
//  ViewController.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSCollectionViewDataSource,NSCollectionViewDelegate>
@property IBOutlet NSCollectionView *collectionView;
@property (weak,nonatomic) IBOutlet NSMenu *rightMenu;
@end


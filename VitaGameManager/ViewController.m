//
//  ViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "ViewController.h"
#import "VitaPackageHelper.h"

@implementation ViewController{
    NSArray *gameList;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"GameItem" forIndexPath:indexPath];
    NSLog(@"%@",item);
    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"-= numberOfItemsInSection =-");
    return [gameList count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    VitaPackageHelper *helper = [[VitaPackageHelper alloc]init];
    gameList = [helper loadPackage:@"/Volumes/Mac/PSVita_VPK/"];
}

@end

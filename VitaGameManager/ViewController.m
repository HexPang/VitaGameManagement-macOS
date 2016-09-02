//
//  ViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "ViewController.h"
#import "VitaPackageHelper.h"
#import "GameItem.h"
#import "GameItemView.h"

@implementation ViewController{
    NSArray *gameList;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSLog(@"Selected %@",indexPaths);
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *game = gameList[indexPath.item];
    
    GameItem *item = [collectionView makeItemWithIdentifier:@"GameItem" forIndexPath:indexPath];
    GameItemView *itemView = (GameItemView *)item.view;
    [itemView.titleLabel setStringValue:game[@"info"][@"TITLE"]];
    NSString *currentDir = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *dir = [NSString stringWithFormat:@"%@/cache/%@",currentDir,game[@"info"][@"CONTENT_ID"]];
    NSString *iconFile =[NSString stringWithFormat:@"%@/icon0.png",dir];
    NSString *picFile = [NSString stringWithFormat:@"%@/pic0.png",dir];
    
    NSData *iconData = [[NSData alloc] initWithContentsOfFile:iconFile];
    NSData *picData = [[NSData alloc] initWithContentsOfFile:picFile];
    
    [itemView.backgroundView setImage:[[NSImage alloc] initWithData:picData]];
    [itemView.iconView setAlphaValue:0.8f];
    [itemView.iconView.layer setMasksToBounds:YES];
    [itemView.iconView.layer setCornerRadius:45];
    
    [itemView.iconView setImage:[[NSImage alloc] initWithData:iconData]];
    
    [itemView.versionLabel setHidden:YES];
    
    [itemView updateLayer];
 
    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [gameList count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
}

- (void)viewDidAppear{
    VitaPackageHelper *helper = [[VitaPackageHelper alloc]init];
    NSURL *library = [[NSUserDefaults standardUserDefaults] URLForKey:@"library"];
    if(library != nil){
        gameList = [helper loadPackage:library.path];
        [self.collectionView reloadData];
    }
}

@end

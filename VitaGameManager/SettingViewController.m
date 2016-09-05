//
//  SettingViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void) updateLibraryURL {
    NSURL *url = [[NSUserDefaults standardUserDefaults] URLForKey:@"library"];
    if(url != nil){
        [self.libraryField setStringValue:url.path];
    }
}

- (IBAction)ChooseGameLibrary:(id)sender{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [panel URLs];
            for (NSURL *url in urls) {
                //here how to judge the url is a directory or a file
                if (url.isFileURL) {
                    BOOL isDir = NO;
                    // Verify that the file exists
                    // and is indeed a directory (isDirectory is an out parameter)
                    if ([[NSFileManager defaultManager] fileExistsAtPath: url.path isDirectory: &isDir]
                        && isDir) {
                        // Here you can be certain the url exists and is a directory
                        [[NSUserDefaults standardUserDefaults] setURL:url forKey:@"library"];
                        [self updateLibraryURL];
                    }
                }
            }
        }
    }];
}

- (void)loadConfig {
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"setting"];
    if(settings != nil){
        [self.vitaIPField setStringValue:settings[@"vita_ip"]];
        [self.vitaPortField setStringValue:settings[@"vita_port"]];
        
    }
}

- (void)saveConfig {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    if(self.vitaIPField.stringValue != nil){
        [settings setObject:self.vitaIPField.stringValue forKey:@"vita_ip"];
    }
    if(self.vitaPortField.stringValue != nil){
        [settings setObject:self.vitaPortField.stringValue forKey:@"vita_port"];
    }
    if([settings count] > 0){
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"setting"];
    }
}

- (IBAction)applySetting:(id)sender{
    [self saveConfig];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self updateLibraryURL];
    [self loadConfig];
}

@end

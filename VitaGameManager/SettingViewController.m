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

- (IBAction)ChooseFolder:(id)sender{
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
//                        [[NSUserDefaults standardUserDefaults] setURL:url forKey:@"library"];
                        NSButton *btn = sender;
                        if(btn.tag == 1){
                            [self.libraryField setStringValue:[url path]];
                        }else if(btn.tag == 2){
                            BOOL isDir = false;
                            if([[NSFileManager defaultManager] fileExistsAtPath:[[url URLByAppendingPathComponent:@"PSAVEDATA"] path] isDirectory:&isDir] && isDir)
                            {
                                NSTextField *CMA_PATH_VIEW = [self.view viewWithTag:11];
                                [CMA_PATH_VIEW setStringValue:[url path]];
                            }else{
                                NSRunAlertPanel(@"Error", @"Not Found [PSAVEDATA] Folder In This Path.", @"Ok", nil,nil);
                            }
                        }
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
        NSTextField *CMA_PATH_VIEW = [self.view viewWithTag:11];
        NSString *cma_path = settings[@"cma_path"];
        if(cma_path != nil){
            [CMA_PATH_VIEW setStringValue:cma_path];
        }
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
    NSTextField *CMA_PATH_VIEW = [self.view viewWithTag:11];
    if(CMA_PATH_VIEW.stringValue != nil){
        [settings setObject:CMA_PATH_VIEW.stringValue forKey:@"cma_path"];
    }
    if([settings count] > 0){
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"setting"];
    }
     [self updateLibraryURL];
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

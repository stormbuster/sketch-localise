//
//  StoreExportPanelSketchPanelController.m
//  WeLiveLikeThis-Store-Export
//
//  Created by Robert Kortenoeven on 09.10.17.
//Copyright © 2017 WeLiveLikeThis. All rights reserved.
//

#import "StoreExportPanelSketchPanelController.h"
#import "StoreExportPanelSketchPanelCell.h"
#import "StoreExportPanelSketchPanelCellHeader.h"
#import "StoreExportPanelSketchPanelCellDefault.h"
#import "StoreExportPanelSketchPanelCellSelectFolder.h"
#import "StoreExportPanelSketchPanelCellStart.h"
#import "StoreExportPanelSketchPanel.h"
#import "StoreExportPanelSketchPanelDataSource.h"
@import JavaScriptCore;
#import <Mocha/Mocha.h>
#import <Mocha/MOClosure.h>
#import <Mocha/MOJavaScriptObject.h>
#import <Mocha/MochaRuntime_Private.h>

#import "LLLanguageManager.h"


@interface StoreExportPanelSketchPanelController ()

@property (nonatomic, strong) id <StoreExportPanelMSInspectorStackView> stackView; // MSInspectorStackView
@property (nonatomic, strong) id <StoreExportPanelMSDocument> document;
@property (nonatomic, strong) StoreExportPanelSketchPanel *panel;
@property (nonatomic, copy) NSArray *selection;
@property (nonatomic, copy) NSArray *selectedTextLayers;


        
@end


@import JavaScriptCore;
@implementation StoreExportPanelSketchPanelController

- (instancetype)initWithDocument:(id <StoreExportPanelMSDocument>)document {
        if (self = [super init]) {
                _document = document;
                _panel = [[StoreExportPanelSketchPanel alloc] initWithStackView:nil];
                _panel.datasource = self;

        }
        return self;
}

- (void)selectionDidChange:(NSArray *)selection {
        
        self.selection = [selection valueForKey:@"layers"];         // To get NSArray from MSLayersArray
        
        self.panel.stackView = [(NSObject *)_document valueForKeyPath:@"inspectorController.currentController.stackView"];
        
        [self.panel reloadData];
}


- (void) selectProjectFolder:(id)sender {
        // create an open document panel
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel setCanCreateDirectories:NO];
        [panel setTitle:@"Select a folder with Localizations"];

        // display the panel
        [panel beginWithCompletionHandler:^(NSInteger result) {
                if (result == NSModalResponseOK) {

                        // grab a reference to what has been selected
                        NSURL *localizedFolderUrl = [[panel URLs]objectAtIndex:0];
                        [[LLLanguageManager shared] loadLanguagesWithUrl:localizedFolderUrl];
                        [self.panel reloadData];
                }
        }];
}

- (void) clearProjectFolder:(id)sender {
        [[LLLanguageManager shared] clearLanguages];
        [self.panel reloadData];
}

- (void) startLocalisation:(id)sender {
        NSString *actionID = @"localiseIOS.start";
        NSObject *appController = [NSClassFromString(@"AppController") valueForKeyPath:@"sharedInstance"];
        NSObject *pluginManager = [appController valueForKeyPath:@"pluginManager"];
        [pluginManager performSelector:NSSelectorFromString(@"sendToInterestedCommandsActionWithID:context:") withObject:actionID withObject:_pluginContext];
}

- (void) exportArtboards:(id)sender {
        NSString *actionID = @"exportAllPages.start";
        NSObject *appController = [NSClassFromString(@"AppController") valueForKeyPath:@"sharedInstance"];
        NSObject *pluginManager = [appController valueForKeyPath:@"pluginManager"];
        [pluginManager performSelector:NSSelectorFromString(@"sendToInterestedCommandsActionWithID:context:") withObject:actionID withObject:_pluginContext];
}

#pragma mark - StoreExportPanelSketchPanelDataSource

- (StoreExportPanelSketchPanelCell *)headerForStoreExportPanelSketchPanel:(StoreExportPanelSketchPanel *)panel {
        StoreExportPanelSketchPanelCellHeader *cell = (StoreExportPanelSketchPanelCellHeader *)[panel dequeueReusableCellForReuseIdentifier:@"header"];
        if ( ! cell) {
                cell = [StoreExportPanelSketchPanelCellHeader loadNibNamed:@"StoreExportPanelSketchPanelCellHeader"];
                cell.reuseIdentifier = @"header";
        }
        cell.titleLabel.stringValue = @"Localize Screens";
        return cell;
}

- (NSUInteger)numberOfRowsForStoreExportPanelSketchPanel:(StoreExportPanelSketchPanel *)panel {
        return 3;    // Using self.selection as number of rows in the panel
}

- (StoreExportPanelSketchPanelCell *)StoreExportPanelSketchPanel:(StoreExportPanelSketchPanel *)panel itemForRowAtIndex:(NSUInteger)index {
        
        if (index == 0) {
                StoreExportPanelSketchPanelCellSelectFolder *cell = (StoreExportPanelSketchPanelCellSelectFolder *)[panel dequeueReusableCellForReuseIdentifier:@"selectFolderCell"];
                if ( ! cell) {
                        cell = [StoreExportPanelSketchPanelCellSelectFolder loadNibNamed:@"StoreExportPanelSketchPanelCellSelectFolder"];
                        cell.reuseIdentifier = @"selectFolderCell";
                }
                cell.selectButton.title = [[LLLanguageManager shared] languages].count ? @"Clear" : @"Select…"; //check if localised file is selected
                [cell.selectButton setAction:[[LLLanguageManager shared] languages].count ? @selector(clearProjectFolder:) : @selector(selectProjectFolder:)];
                [cell.selectButton setTarget:self];
                return cell;
        } else if (index == 1) {
                StoreExportPanelSketchPanelCellDefault *cell = (StoreExportPanelSketchPanelCellDefault *)[panel dequeueReusableCellForReuseIdentifier:@"layerCell"];
                if ( ! cell) {
                        cell = [StoreExportPanelSketchPanelCellDefault loadNibNamed:@"StoreExportPanelSketchPanelCellDefault"];
                        cell.reuseIdentifier = @"layerCell";
                }
                cell.titleTextView.string = [[LLLanguageManager shared] languages].count ? [NSString stringWithFormat:@"\n\nCreate %lu new pages with translated versions of the current page?", [[LLLanguageManager shared] languages].count] : @"Select the 'Localizations' folder for your project. This can usually be found in the 'Resources' folder for standard Xcode projects.";
                NSParagraphStyle* tStyle = [NSParagraphStyle defaultParagraphStyle];
                NSMutableParagraphStyle* tMutStyle = [tStyle mutableCopy];
                [tMutStyle setAlignment:NSTextAlignmentLeft];
                [cell.titleTextView setDefaultParagraphStyle:tMutStyle];
                [cell.titleTextView setHorizontallyResizable:YES];
                [cell.titleTextView
                 setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
                return cell;
        } else {
                StoreExportPanelSketchPanelCellStart *cell = (StoreExportPanelSketchPanelCellStart *)[panel dequeueReusableCellForReuseIdentifier:@"startLocaliseCell"];
                if ( ! cell) {
                        cell = [StoreExportPanelSketchPanelCellStart loadNibNamed:@"StoreExportPanelSketchPanelCellStart"];
                        cell.reuseIdentifier = @"startLocaliseCell";
                        cell.selectButton.title = @"Translate"; //check if localised file is selected
                        cell.exportButton.title = @"Export"; //check if localised file is selected

                        [cell.selectButton setAction:@selector(startLocalisation:)];
                        [cell.selectButton setTarget:self];
                        
                        [cell.exportButton setAction:@selector(exportArtboards:)];
                        [cell.exportButton setTarget:self];
                }
                cell.selectButton.enabled = [[LLLanguageManager shared] languages].count;
//                cell.exportButton.enabled = [[LLLanguageManager shared] languages].count;
            
                return cell;
        }
        
        return nil;
}




@end

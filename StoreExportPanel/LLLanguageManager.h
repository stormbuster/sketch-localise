//
//  LLLanguageManager.h
//  StoreExportPanel
//
//  Created by Robert Kortenoeven on 14.10.17.
//  Copyright © 2017 EyeEm. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LLLanguageManager : NSObject


@property (nonatomic, strong) NSMutableArray<NSString *> *languages;
+ (id)shared;
-(void)loadLanguagesWithUrl:(NSURL *)localizedFolderUrl;
- (void)setLanguage:(NSString *)language;
- (void)clearLanguages;
- (NSString *)stringForKey:(NSString *)stringKey;
- (NSString *)languageNameForCode:(NSString *)code;

@end

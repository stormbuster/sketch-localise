//
//  LLLanguageManager.m
//  StoreExportPanel
//
//  Created by Robert Kortenoeven on 14.10.17.
//  Copyright © 2017 EyeEm. All rights reserved.
//

#import "LLLanguageManager.h"

#import "NSBundle+Language.h"

static NSBundle *localizedBundle = nil;

@interface LanguageConstants: NSObject
+(NSDictionary*)getConstDictionary;
@end

@implementation LanguageConstants
+(NSDictionary*)getConstDictionary {
    static NSDictionary *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @{
                 @"ar": @"Arabic",
                 @"da": @"Danish",
                 @"de": @"German",
                 @"en": @"English (U.S.)",
                 @"en-GB": @"English (British)",
                 @"en-AU": @"English (Australia)",
                 @"en-CA": @"English (Canadian)",
                 @"en-IN": @"English (Indian)",
                 @"es": @"Spanish",
                 @"es-MX": @"Spanish (Mexico)",
                 @"el": @"Greek",
                 @"fr": @"French",
                 @"fr-CA": @"French (Canadian)",
                 @"fi": @"Finnish",
                 @"id": @"Indonesian",
                 @"it": @"Italian",
                 @"ja": @"Japanese",
                 @"ko": @"Korean",
                 @"nl": @"Dutch",
                 @"nb": @"Norwegian (Bokmal)",
                 @"pl": @"Polish",
                 @"pt-BR": @"Portugese (Brasil)",
                 @"pt-PT": @"Portugese (Portugal)",
                 @"ru": @"Russian",
                 @"sv": @"Swedish",
                 @"th": @"Thai",
                 @"tr": @"Turkish",
                 @"uk": @"Ukranian",
                 @"vi": @"Vietnamese",
                 @"zh-Hans": @"Chinese (Simplified)",
                 @"zh-Hant": @"Chinese (Traditional)",
                 @"he": @"Hebrew",
                 @"ro": @"Romanian",
                 @"ca": @"Catalan",
                 @"hr": @"Croatian",
                 @"sk": @"Slovak",
                 @"cs": @"Czech",
                 @"hu": @"Hungarian",
                 @"hi": @"Hindi",
                 @"ms": @"Malay"
                 };
    });
    return inst;
}
@end



@implementation LLLanguageManager

+ (id)shared {
    static LLLanguageManager *sharedLLLanguageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLLLanguageManager = [[self alloc] init];
    });
    return sharedLLLanguageManager;
}
- (id)init {
    if (self = [super init]) {
    }
    return self;
}


- (void)clearLanguages {
    _languages = nil;
}

- (void)setLanguage:(NSString *)language {
    [NSBundle setLanguage:language withBundle:localizedBundle];
//    NSLog(@"string for key: %@", NSLocalizedString(@"kEYEErrorTextLoginFailed", @"")); //test
}

-(void)loadLanguagesWithUrl:(NSURL *)localizedFolderUrl {
    localizedBundle = [NSBundle bundleWithPath:localizedFolderUrl.path];
    
    [self clearLanguages];
    _languages = [NSMutableArray array];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSURL *bundleDirectory = [localizedBundle bundleURL];
    NSDirectoryEnumerator *dirEnumerator = [fileMgr enumeratorAtURL:bundleDirectory includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey,nil] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    
    for (NSURL *theURL in dirEnumerator) {
        NSString *folderName;
        [theURL getResourceValue:&folderName forKey:NSURLNameKey error:NULL];
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        if([isDirectory boolValue] && ![folderName isEqualToString:@"Base.lproj"])  // exclude English
        {
            [_languages addObject:[folderName stringByDeletingPathExtension]];
        }
    }
}

- (NSString *)stringForKey:(NSString *)stringKey {
    return NSLocalizedString(stringKey, @"");
}

- (NSString *)languageNameForCode:(NSString *)code {
    return [NSString stringWithFormat:@"%@ - %@", code, [[LanguageConstants getConstDictionary] objectForKey:code]];
}


@end


//
//  PDR_Manager_Feature.h
//  Pandora
//
//  Created by Mac Pro_C on 12-12-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PDRExendPluginType) {
    PDRExendPluginTypeApp = 0,
    PDRExendPluginTypeFrame = 1,
    PDRExendPluginTypeNView = 2
};

@interface PDRExendPluginInfo : NSObject
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *impClassName;
@property(nonatomic, copy)NSString *javaScript;
@property(nonatomic, assign)PDRExendPluginType type;
+(PDRExendPluginInfo*)infoWithName:(NSString*)name
                      impClassName:(NSString*)impClassName
                              type:(PDRExendPluginType)pluginType
                        javaScript:(NSString*)javasrcipt;
@end

typedef NS_ENUM(NSInteger, H5CoreAppSplashType) {
    H5CoreAppSplashTypeAuto = 0,
    H5CoreAppSplashTypeDefault = 1
};

@interface DC5PAppStartParams : NSObject
@property(nonatomic, copy)NSString *version;
@property(nonatomic, copy)NSString *appid;
@property(nonatomic, copy)NSString *documentPath;
@property(nonatomic, copy)NSString *rootPath;
@property(nonatomic, copy)NSString *arguments;
@property(nonatomic, copy)NSString *arguments_restore;
@property(nonatomic, copy)NSString *launcher;
@property(nonatomic, copy)NSString *channel;
@property(nonatomic, copy)NSString *launch_path;
@property(nonatomic, copy)NSString *launch_path_restore;
@property(nonatomic, copy)NSString *launch_path_id;
@property(nonatomic, copy)NSString *launcher_comfrom;
@property(nonatomic, copy)NSString *iconPath;
@property(nonatomic, copy)NSString *summary;
@property(nonatomic, assign)BOOL    needCheckUpdate;
@property(nonatomic, copy)NSString *origin;
@property(nonatomic, copy)NSString *direct_page;
@property(nonatomic, copy)NSString *direct_page_backup;
@property(nonatomic, assign, readonly)BOOL isTestVersion;
@property(nonatomic, assign)BOOL streamApp;
@property(nonatomic, assign)BOOL isW2APackage;
@property(nonatomic, assign)BOOL wapApp;
@property(nonatomic, assign)BOOL debug;
@property(nonatomic, assign)BOOL isSDKApp;
@property(nonatomic, assign)BOOL isHomePageVisable;
@property(nonatomic, assign)BOOL isHomePageVisable_restore;
@property(nonatomic, assign)H5CoreAppSplashType splashType;
@property(nonatomic, assign)H5CoreAppSplashType splashType_restore;
@property(nonatomic, assign)BOOL isRecovery;
- (void)copySelfTo:(DC5PAppStartParams*)startParams;
- (void)setVersionStatus:(BOOL)isTestVersion;
- (BOOL)isSetupVersionStatus;
- (NSString*)getMaketChannel;
@end

@interface PDRCoreSettings : NSObject
@property(nonatomic, assign)BOOL fullScreen;
@property(nonatomic, assign)UIStatusBarStyle statusBarStyle;
@property(nonatomic, assign)BOOL reserveStatusbarOffset;
@property(nonatomic, copy)NSString *version;
@property(nonatomic, copy)NSString *innerVersion;
@property(nonatomic, copy)NSString *versionCode;
@property(nonatomic, retain)NSMutableDictionary *uniVersionDic;
@property (nonatomic,assign)BOOL isweexdebugMode;
@property (nonatomic,assign)BOOL isWXDevToolAlert;
@property (nonatomic,assign)BOOL isWXDevToolReload;
@property(nonatomic, assign)BOOL debug;
@property(nonatomic, assign)BOOL syncDebug;
@property(nonatomic, assign, readonly)BOOL ns;
@property(nonatomic, retain)NSArray *apps;
@property(nonatomic, retain)NSString *autoStartdAppid;
@property(nonatomic, retain)NSString *docmentPath;
@property(nonatomic, retain)NSString *downloadPath;
@property(nonatomic, retain)NSString *executableAppsPath;
@property(nonatomic, retain)NSString *workAppsPath;
@property(nonatomic, readonly)NSArray *extendPlugins;
@property(nonatomic, retain)UIColor *statusBarColor;
@property(nonatomic, retain)NSString *extendPluginsJs;
@property(nonatomic, assign)CGFloat navBarHeight;
@property(nonatomic, assign)BOOL showNavbar;
@property(nonatomic, assign)NSInteger openAppMax;
@property(nonatomic, assign)NSInteger trimMemoryAppCount;
- (void) load;
- (BOOL)configSupportOrientation:(UIInterfaceOrientation)orientation ;
- (BOOL) supportsOrientation:(UIInterfaceOrientation)orientation;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (UIInterfaceOrientationMask)setlockOrientationWithArray:(NSArray*)orientations;
- (void) setlockOrientation:(NSUInteger)orientation;
- (void) unlockOrientation;
- (void)setAppid:(NSString*)appid documentPath:(NSString*)doumnetPath;
- (DC5PAppStartParams*)settingWithAppid:(NSString*)appid;
- (void)setupAutoStartdAppid:(NSString *)autoStartdAppid;
- (PDRExendPluginInfo*)regPluginWithName:(NSString*)pluginName
                            impClassName:(NSString*)impClassName
                                    type:(PDRExendPluginType)pluginType
                              javaScript:(NSString*)javaScript;
@end

extern NSString *kDCCoreSettingPortraitPrimary;
extern NSString *kDCCoreSettingPortraitSecondary;
extern NSString *kDCCoreSettingLandscapePrimary;
extern NSString *kDCCoreSettingLandscapeSecondary;
extern NSString *kDCCoreSettingPortrait;
extern NSString *kDCCoreSettingLandscape;

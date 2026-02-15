//
//  PDRCoreDefs.h
//  PDRCore
//
//  Created by X on 14-2-11.
//  Copyright (c) 2014年 io.dcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const PDRCoreOpenUrlNotification;
UIKIT_EXTERN NSString *const PDRCoreOpenUniversalLinksNotification;
UIKIT_EXTERN NSString *const PDRCoreRevDeviceToken;
UIKIT_EXTERN NSString *const PDRCoreRegRemoteNotificationsError;

#if __has_feature(objc_arc)
#define H5_AUTORELEASE(exp) exp
#define H5_RELEASE(exp) exp
#define H5_RETAIN(exp) exp
#else
#define H5_AUTORELEASE(exp) [exp autorelease]
#define H5_RELEASE(exp) [exp release]
#define H5_RETAIN(exp) [exp retain]
#endif

#ifndef H5_STRONG
#if __has_feature(objc_arc)
#define H5_STRONG strong
#else
#define H5_STRONG retain
#endif
#endif

#ifndef H5_WEAK
#if __has_feature(objc_arc_weak)
#define H5_WEAK weak
#elif __has_feature(objc_arc)
#define H5_WEAK unsafe_unretained
#else
#define H5_WEAK assign
#endif
#endif

#if DEBUG
#define H5CORE_LOG NSLog
#else
#define H5CORE_LOG
#endif

#define kPDRCoreAppWindowAnimationDefaltDuration .3f

typedef NS_ENUM(NSInteger, PDRCoreRunMode) {
    PDRCoreRunModeNormal = 0,
    PDRCoreRunModeWebviewClient = 1,
    PDRCoreRunModeAppClient
};

typedef NS_ENUM(NSInteger, PDRCoreSysEvent) {
    PDRCoreSysEventNetChange = 1,
    PDRCoreSysEventEnterBackground,
    PDRCoreSysEventEnterForeGround,
    PDRCoreSysEventOpenURL,
    PDRCoreSysEventOpenURLWithOptions,
    PDRCoreSysEventRevLocalNotification,
    PDRCoreSysEventRevRemoteNotification,
    PDRCoreSysEventRevDeviceToken,
    PDRCoreSysEventRegRemoteNotificationsError,
    PDRCoreSysEventReceiveMemoryWarning,
    PDRCoreSysEventInterfaceOrientation,
    PDRCoreSysEventKeyEvent,
    PDRCoreSysEventEnterFullScreen,
    PDRCoreSysEventPeekQuickAction,
    PDRCoreSysEventResignActive,
    PDRCoreSysEventBecomeActive,
    PDRCoreSysEventStatusbarChange,
    PDRCoreSysEventWeexPostMessage,
    PDRCoreSysEventWeexOutputLog,
    PDRCoreSysEventPostMessageToWeexControl,
    PDRCoreSysEventContinueUserActivity,
    PDRCoreSysEventWeexSDKEngineRestart
};

typedef enum {
    PDRCoreStatusBarStyleLight,
    PDRCoreStatusBarStyleDark
} PDRCoreStatusBarStyle;

typedef NS_ENUM(NSInteger, PDRCoreStatusBarMode) {
    PDRCoreStatusBarModeNormal = 1,
    PDRCoreStatusBarModeImmersion
};

enum {
    PDRCoreSuccess = 0,
    PDRCoreNetObserverCreateError = 1,
    PDRCoreInvalidParamError,
    PDRCoreFileNotExistError,
    PDRCorePandoraApibundleMiss,
    PDRCoreStatusError,
    PDRCoreNetError,
    PDRCoreUnknownError,
    PDRCoreErrorResManagerBase = 10000,
    PDRCoreErrorAppManagerBase = 20000,
    PDRCoreErrorDownloadStreamJSON,
    PDRCoreErrorStreamJSONFormat,
    PDRCoreErrorDownloadIndexPage,
    PDRCoreErrorUsercancel,
    PDRCoreInvalidMainpageError,
    PDRCoreAppInvalidMainfestError
};

#define kAppManagerOpenAppMaxDefalut 3
#define kWindowAppBarViewHeight (44)
#define kWindowTitleNViewHeight (44)
#define kWindowTitleNView_btn_W (41)
#define kWindowStatusBarViewHeight (20)

#define DCCoreWeexBridge ([PDRCore Instance].weexImport)
@interface H5Server : NSObject
+ (NSString*)identifier;
- (void)onCreate;
- (void)onDestroy;
@end

typedef void (^H5CoreComplete)(id);

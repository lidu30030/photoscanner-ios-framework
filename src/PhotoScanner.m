#import "PhotoScanner.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

#define PHOTOSCANNER_DOC_DIR @"_doc"

#ifndef PHOTOSCANNER_BUILD
#define PHOTOSCANNER_BUILD "2026-02-24_003"
#endif

@implementation PhotoScanner

UNI_EXPORT_METHOD(@selector(ping:callback:))
UNI_EXPORT_METHOD(@selector(scan:callback:))

- (NSString *)docDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *base = (paths.count > 0) ? paths[0] : NSTemporaryDirectory();
    NSString *dir = [base stringByAppendingPathComponent:PHOTOSCANNER_DOC_DIR];
    NSError *err = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
    return dir;
}

- (void)doScan:(NSDictionary *)opt cb:(UniModuleKeepAliveCallback)cb {
    NSInteger limit = [opt[@"limit"] integerValue];
    if (limit < 0) limit = 0;

    PHAuthorizationStatus st;
    if (@available(iOS 14.0, *)) st = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    else st = [PHPhotoLibrary authorizationStatus];

    if (st != PHAuthorizationStatusAuthorized) {
        if (cb) cb(@{ @"ok": @NO, @"msg": @"no_permission", @"st": @(st) }, NO);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *fetchOpt = [[PHFetchOptions alloc] init];
        fetchOpt.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOpt];

        PHImageRequestOptions *reqOpt = [[PHImageRequestOptions alloc] init];
        reqOpt.networkAccessAllowed = NO;
        reqOpt.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        reqOpt.synchronous = YES;

        PHImageManager *mgr = [PHImageManager defaultManager];
        NSString *doc = [self docDir];
        NSInteger totalAll = assets.count;
        NSInteger max = limit > 0 ? MIN(totalAll, limit) : totalAll;
        NSInteger batch = [opt[@"batch"] integerValue];
        if (batch <= 0) batch = 20;
        NSMutableArray *buf = [NSMutableArray arrayWithCapacity:batch];

        for (NSInteger i = 0; i < max; i++) {
            @autoreleasepool {
                PHAsset *a = [assets objectAtIndex:i];
                __block NSData *data = nil;
                if (@available(iOS 13.0, *)) {
                    [mgr requestImageDataAndOrientationForAsset:a options:reqOpt resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                        data = imageData;
                    }];
                } else {
                    [mgr requestImageDataForAsset:a options:reqOpt resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        data = imageData;
                    }];
                }
                if (!data || data.length <= 0) continue;

                if (data.length > 600 * 1024) {
                    UIImage *img = [UIImage imageWithData:data];
                    if (img) {
                        CGFloat q = 0.7;
                        NSData *compressed = UIImageJPEGRepresentation(img, q);
                        while (compressed && compressed.length > 600 * 1024 && q > 0.1) {
                            q -= 0.1;
                            compressed = UIImageJPEGRepresentation(img, q);
                        }
                        if (compressed && compressed.length > 0) data = compressed;
                    }
                }

                NSString *name = [NSString stringWithFormat:@"ios_%lld_%ld.jpg", (long long)([[NSDate date] timeIntervalSince1970] * 1000), (long)i];
                NSString *abs = [doc stringByAppendingPathComponent:name];
                if (![data writeToFile:abs atomically:YES]) continue;
                [buf addObject:@{ @"path": abs, @"name": name }];

                if (buf.count >= batch) {
                    NSArray *chunk = [buf copy];
                    [buf removeAllObjects];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (cb) cb(@{ @"items": chunk, @"done": @NO, @"total": @(totalAll), @"plan": @(max) }, YES);
                    });
                }
            }
        }

        NSArray *last = [buf copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (last.count > 0) {
                if (cb) cb(@{ @"items": last, @"done": @NO, @"total": @(totalAll), @"plan": @(max) }, YES);
            }
            if (cb) cb(@{ @"items": @[], @"done": @YES, @"total": @(totalAll), @"plan": @(max) }, NO);
        });
    });
}

- (void)ping:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    if (callback) callback(@{ @"ok": @YES, @"ping": @YES }, NO);
}

- (void)scan:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSDictionary *opt = [options isKindOfClass:[NSDictionary class]] ? options : @{};

    PHAuthorizationStatus st;
    if (@available(iOS 14.0, *)) st = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    else st = [PHPhotoLibrary authorizationStatus];

    if (st == PHAuthorizationStatusNotDetermined) {
        NSDictionary *opt2 = opt ? [opt copy] : @{};
        if (@available(iOS 14.0, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self doScan:opt2 cb:callback];
                });
            }];
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self doScan:opt2 cb:callback];
                });
            }];
        }
        return;
    }

    [self doScan:opt cb:callback];
}

@end

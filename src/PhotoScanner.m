#import "PhotoScanner.h"
#import <Photos/Photos.h>
#import "PDRCore.h"

@implementation PhotoScanner

- (void)scan:(PGMethod *)command {
    NSString *cb = nil;
    @try { cb = [command valueForKey:@"callBackID"]; } @catch (NSException *e) {}
    if (!cb || cb.length <= 0) { @try { cb = [command valueForKey:@"callbackId"]; } @catch (NSException *e) {} }
    if (!cb || cb.length <= 0) { @try { cb = [command valueForKey:@"callbackID"]; } @catch (NSException *e) {} }
    if (!cb || cb.length <= 0) {
        if ([command.arguments count] > 0 && [command.arguments[0] isKindOfClass:[NSString class]]) {
            cb = (NSString*)command.arguments[0];
        }
    }
    NSDictionary *opt = @{};
    if ([command.arguments count] > 0) {
        id a0 = command.arguments[0];
        if ([a0 isKindOfClass:[NSDictionary class]]) {
            opt = (NSDictionary *)a0;
        } else if ([a0 isKindOfClass:[NSString class]] && [command.arguments count] > 1 && [command.arguments[1] isKindOfClass:[NSDictionary class]]) {
            opt = (NSDictionary *)command.arguments[1];
        }
    }
    NSInteger limit = [opt[@"limit"] integerValue];
    if (limit < 0) limit = 0;

    PHAuthorizationStatus st = [PHPhotoLibrary authorizationStatus];
    if (st == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scan:command];
            });
        }];
        return;
    }

    BOOL ok = (st == PHAuthorizationStatusAuthorized);
    if (!ok) {
        if (@available(iOS 14.0, *)) {
            if (st == PHAuthorizationStatusLimited) ok = YES;
        }
    }
    if (!ok) {
        PDRPluginResult *res = [PDRPluginResult resultWithStatus:PDRCommandStatusError messageAsDictionary:@{ @"msg": @"no_permission", @"st": @(st) }];
        if (cb && cb.length > 0) [self toCallback:cb withReslut:[res toJSONString]];
        return;
    }

    if (cb && cb.length > 0) {
        PDRPluginResult *ping = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsDictionary:@{ @"ping": @YES }];
        ping.keepCallback = YES;
        [self toCallback:cb withReslut:[ping toJSONString]];
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
        NSString *doc = [PDRCore appDocPath];
        NSInteger totalAll = assets.count;
        NSInteger max = limit > 0 ? MIN(totalAll, limit) : totalAll;
        NSInteger batch = [opt[@"batch"] integerValue];
        if (batch <= 0) batch = 20;
        NSMutableArray *buf = [NSMutableArray arrayWithCapacity:batch];

        for (NSInteger i = 0; i < max; i++) {
            @autoreleasepool {
                PHAsset *a = [assets objectAtIndex:i];
                __block NSData *data = nil;
                [mgr requestImageDataForAsset:a options:reqOpt resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    data = imageData;
                }];
                if (!data || data.length <= 0) {
                    continue;
                }

                NSString *name = [NSString stringWithFormat:@"ios_%lld_%ld.jpg", (long long)([[NSDate date] timeIntervalSince1970] * 1000), (long)i];
                NSString *abs = [doc stringByAppendingPathComponent:name];
                if (![data writeToFile:abs atomically:YES]) continue;
                [buf addObject:@{ @"path": [@"_doc/" stringByAppendingString:name], @"name": name }];

                if (buf.count >= batch) {
                    NSArray *chunk = [buf copy];
                    [buf removeAllObjects];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!cb || cb.length <= 0) return;
                        PDRPluginResult *res = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsDictionary:@{ @"items": chunk, @"done": @NO, @"total": @(totalAll), @"plan": @(max) }];
                        res.keepCallback = YES;
                        [self toCallback:cb withReslut:[res toJSONString]];
                    });
                }
            }
        }

        NSArray *last = [buf copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!cb || cb.length <= 0) return;
            if (last.count > 0) {
                PDRPluginResult *res = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsDictionary:@{ @"items": last, @"done": @NO, @"total": @(totalAll), @"plan": @(max) }];
                res.keepCallback = YES;
                [self toCallback:cb withReslut:[res toJSONString]];
            }
            PDRPluginResult *end = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsDictionary:@{ @"items": @[], @"done": @YES, @"total": @(totalAll), @"plan": @(max) }];
            [self toCallback:cb withReslut:[end toJSONString]];
        });
    });
}

@end

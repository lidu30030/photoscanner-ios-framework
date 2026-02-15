#import "PhotoScanner.h"
#import <Photos/Photos.h>
#import "PDRCore.h"

@implementation PhotoScanner

- (void)scan:(PGMethod *)command {
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

    if (st != PHAuthorizationStatusAuthorized
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
        && st != PHAuthorizationStatusLimited
#endif
    ) {
        PDRPluginResult *res = [PDRPluginResult resultWithStatus:PDRCommandStatusError messageAsDictionary:@{ @"msg": @"no_permission", @"st": @(st) }];
        [self toCallback:command.callbackId withReslut:[res toJSONString]];
        return;
    }

    PHFetchOptions *fetchOpt = [[PHFetchOptions alloc] init];
    fetchOpt.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOpt];

    PHImageRequestOptions *reqOpt = [[PHImageRequestOptions alloc] init];
    reqOpt.networkAccessAllowed = NO;
    reqOpt.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    reqOpt.synchronous = YES;

    PHImageManager *mgr = [PHImageManager defaultManager];
    NSString *doc = [PDRCore appDocPath];
    NSMutableArray *out = [NSMutableArray array];

    NSInteger max = limit > 0 ? MIN(assets.count, limit) : assets.count;
    for (NSInteger i = 0; i < max; i++) {
        PHAsset *a = [assets objectAtIndex:i];
        __block NSData *data = nil;
        [mgr requestImageDataForAsset:a options:reqOpt resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            data = imageData;
        }];
        if (!data || data.length <= 0) continue;

        NSString *name = [NSString stringWithFormat:@"ios_%lld_%ld.jpg", (long long)([[NSDate date] timeIntervalSince1970] * 1000), (long)i];
        NSString *abs = [doc stringByAppendingPathComponent:name];
        if (![data writeToFile:abs atomically:YES]) continue;
        [out addObject:@{ @"path": [@"_doc/" stringByAppendingString:name], @"name": name }];
    }

    PDRPluginResult *res = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsArray:out];
    [self toCallback:command.callbackId withReslut:[res toJSONString]];
}

@end

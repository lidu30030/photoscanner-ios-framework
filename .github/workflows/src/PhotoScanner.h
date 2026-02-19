#import "PGPlugin.h"

#import "PGMethod.h"

@interface PhotoScanner : PGPlugin
- (void)scan:(PGMethod *)command;
- (void)ping:(PGMethod *)command;
@end

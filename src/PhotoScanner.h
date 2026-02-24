
 #import "DCUniModule.h"
 
 @interface PhotoScanner : DCUniModule
 - (void)ping:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;
 - (void)scan:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;
 @end

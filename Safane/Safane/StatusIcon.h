// StatusIcon.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface StatusIcon : NSObject

+ (NSImage*)statusItemImage:(BOOL)hightlighted;

#ifdef DEBUG
+ (void)generateAppIcon;
#endif

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
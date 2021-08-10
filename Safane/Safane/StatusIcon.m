// StatusIcon.m

#import "StatusIcon.h"
#import "THFoundation.h"
#import "THLog.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation StatusIcon

+ (NSImage*)statusItemImage:(BOOL)hightlighted
{
	NSSize frameSz=NSMakeSize(18.0,18.0);
	NSPoint center=NSMakePoint(CGFloatFloor(frameSz.width/2.0),CGFloatFloor(frameSz.height/2.0));
	BOOL isDark=[THOSAppearance isDarkMode];

	NSImage *img=[[NSImage alloc] initWithSize:frameSz];
	[img lockFocus];

	NSColor *fillColor=[NSColor colorWithCalibratedWhite:(isDark || hightlighted)?1.0:0.0 alpha:1.0];

	// fleche
	NSBezierPath *fleche=[self flecheAt:center size:NSMakeSize(10.0, 20.0) angle:45];
	[fillColor set];
	[fleche fill];

	// o center
	NSGraphicsContext *theContext=[NSGraphicsContext currentContext];
	theContext.compositingOperation=NSCompositingOperationDestinationOut;
	CGFloat ovRad=4.0;
	[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(center.x-ovRad/2.0,center.y-ovRad/2.0,ovRad,ovRad)] fill];
	[theContext saveGraphicsState];
	[theContext restoreGraphicsState];

	[img unlockFocus];

	return img;
}

+ (NSBezierPath*)triangleinRect:(NSRect)rect sens:(NSInteger)sens
{
	NSBezierPath *bz=[NSBezierPath bezierPath];
	bz.lineWidth=0.0;

	[bz moveToPoint:NSMakePoint(rect.origin.x,rect.origin.y+rect.size.height)];
	[bz lineToPoint:NSMakePoint(rect.origin.x+rect.size.width/2.0,rect.origin.y)];
	[bz lineToPoint:NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height)];
	[bz closePath];

	return bz;
}

+ (NSBezierPath*)flecheAt:(NSPoint)center size:(NSSize)size angle:(CGFloat)angle
{
	NSBezierPath *bz=[NSBezierPath bezierPath];
	[bz moveToPoint:NSMakePoint(center.x,center.y+size.height/2.0)];
	[bz lineToPoint:NSMakePoint(center.x+size.width/2.0,center.y)];
	[bz lineToPoint:NSMakePoint(center.x,center.y-size.height/2.0)];
	[bz lineToPoint:NSMakePoint(center.x-size.width/2.0,center.y)];
	[bz closePath];

	NSAffineTransform *xfm=[NSAffineTransform transform];
	[xfm translateXBy:center.x yBy:center.y];
	[xfm rotateByDegrees:angle];
	[xfm translateXBy:-center.x yBy:-center.y];
	[bz transformUsingAffineTransform:xfm];
	
	return bz;
}

#ifdef DEBUG

+ (void)generateAppIcon
{
	NSString *bundlePath=[[[NSString stringWithUTF8String:__FILE__] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
	NSString *iconsDir=[bundlePath stringByAppendingPathComponent:@"Images.xcassets/AppIcon.appiconset"];
	THException([[NSFileManager defaultManager] fileExistsAtPath:iconsDir]==NO,@"iconsDir:%@",iconsDir);

	for (NSNumber *size in @[@(16),@(32),@(128),@(512)])
	{
		for (NSNumber *scale in @[@(1),@(2)])
		{
			NSInteger sz=[size integerValue];
			NSInteger sc=[scale integerValue];

			NSString *file=[NSString stringWithFormat:@"icon_%d%@.png",(int)sz,sc==2?@"@2x":@""];
			NSString *p=[iconsDir stringByAppendingPathComponent:file];

			[self icon_builder:sz scale:sc outfile:p];
		}
	}

	[self icon_builder:256 scale:1 outfile:[@"~/Desktop/toto.png" stringByExpandingTildeInPath]];
}

+ (void)icon_builder:(NSInteger)size scale:(NSInteger)scale outfile:(NSString*)outfile
{
	NSSize frameSz=NSMakeSize(size*scale,size*scale);
	NSPoint center=NSMakePoint(CGFloatFloor(frameSz.width/2.0),CGFloatFloor(frameSz.height/2.0));

	NSImage *img=[[NSImage alloc] initWithSize:frameSz];
	[img lockFocus];

//	[[NSColor orangeColor] set];
//	[NSBezierPath fillRect:NSMakeRect(0.0,0.0,frameSz.width,frameSz.height)];

	NSColor *fillColor=[NSColor colorWithCalibratedWhite:0.0 alpha:1.0];

	// arc
	NSBezierPath *arc=[NSBezierPath bezierPath];
	[arc appendBezierPathWithArcWithCenter:center radius:frameSz.width*0.34 startAngle:180.0 endAngle:-130.0 clockwise:YES];
	arc.lineWidth=frameSz.width*0.08;
	[fillColor set];
	[arc stroke];
	
	// triangle
	NSBezierPath *tr=[self triangleinRect:NSMakeRect(	0.0,
																						CGFloatCeil(center.y-frameSz.height*0.2),
																						CGFloatFloor(frameSz.width*0.33),
																						frameSz.height*0.2) sens:-1];
	[fillColor set];
	[tr fill];

	// fleche
	NSBezierPath *fleche=[self flecheAt:center
													size:NSMakeSize(CGFloatFloor(frameSz.width*0.22), CGFloatFloor(frameSz.height*0.56))
													angle:45];
	[fillColor set];
	[fleche fill];

	// o center
	NSGraphicsContext *theContext=[NSGraphicsContext currentContext];
	theContext.compositingOperation=NSCompositingOperationDestinationOut;
	CGFloat ovRad=frameSz.width*0.1;
	[[NSColor whiteColor] set];
	[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(center.x-ovRad/2.0,center.y-ovRad/2.0,ovRad,ovRad)] fill];
	[theContext saveGraphicsState];
	[theContext restoreGraphicsState];

	[img unlockFocus];
	

	[img.th_PNGRepresentation writeToFile:outfile atomically:YES];
}
#endif

@end
//--------------------------------------------------------------------------------------------------------------------------------------------

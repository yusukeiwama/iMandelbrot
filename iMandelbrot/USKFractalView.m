//
//  USKFractalView.m
//  iMandelbrot
//
//  Created by Yusuke Iwama on 10/25/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKFractalView.h"
#import "complex.h"

@implementation USKFractalView {
	size_t width, height;
	CGRect currentCRect;
}

@synthesize delegate;
@synthesize currentMagnification;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.contentMode = UIViewContentModeScaleAspectFit;
		self.userInteractionEnabled = YES;

		width = frame.size.width;
		height = frame.size.height;
		
//		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
//			([UIScreen mainScreen].scale == 2.0)) {
//			// Retina display
//			width = frame.size.width * 2.0;
//			height = frame.size.height * 2.0;
//		} else {
//			// non-Retina display
//			width = frame.size.width;
//			height = frame.size.height;
//		}
		
		[self drawMandelbrotSet];
    }
    return self;
}

- (void)drawMandelbrotSet
{
	CGRect complexRect = CGRectMake(-2.0, -2.0, 4.0, 4.0);
	currentMagnification = 1.0;
	[delegate updateMagnificationLabel];
	[self drawMandelbrotSetInComplexRect:complexRect];
}

- (void)drawMandelbrotSetInComplexRect:(CGRect)cRect
{
	currentCRect = cRect;
	
	// Draw Mandelbrot Set
	NSUInteger maxIteration = 100;
	NSUInteger iteration;
	double _Complex z0 = 0 + 0 * I;
	
	size_t bytePerPixel = sizeof(unsigned char) * 3;
	size_t bitsPerPixel, bytesPerRow;
	unsigned char *imageData = calloc(width * height, sizeof(unsigned char) * bytePerPixel);
	
	for (NSUInteger i = 0; i < height; i++) {
		for (NSUInteger j = 0; j < width; j++) {
			double _Complex c = currentCRect.size.width * j / width + currentCRect.origin.x + (currentCRect.size.height * i / height + currentCRect.origin.y) * I;
			double _Complex z = z0;
			for (iteration = 0; iteration < maxIteration; iteration++) {
				z = z * z + c;
				if (cabs(z) > 2) {
					break;
				}
			}
			if (cabs(z) > 1) {
				unsigned char R, G, B;
				
				// RGB
				//				double darkness = 1 - (double)iteration / maxIteration;
				//				R = 255 * darkness, G = 255 * darkness, B = 255 * darkness;
				
				
				// HSV -> RGB
				//				double H = iteration / (maxIteration + 1.0) * 100.0 + 200; // 0 <= hue < 360
				double H = iteration / (maxIteration + 1.0) * 360; // 0 <= hue < 360
				int Hi = floor(H / 60.0);
				double f = H / 60.0 - Hi;
				double S = 1.0;
				double V = (double)iteration / maxIteration; // Value (a.k.a Brightness, Lightness)
				double p = V * (1 - S);
				double q = V * (1 - f * S);
				double t = V * (1 - (1 - f * S));
				switch (Hi) {
					case 0: R = V * 255, G = t * 255, B = p * 255; break;
					case 1: R = q * 255, G = V * 255, B = p * 255; break;
					case 2: R = p * 255, G = V * 255, B = t * 255; break;
					case 3: R = p * 255, G = q * 255, B = V * 255; break;
					case 4: R = t * 255, G = p * 255, B = V * 255; break;
					case 5: R = V * 255, G = p * 255, B = q * 255; break;
					default:R = 0, G = 0, B = 0; break;
				}
				
				imageData[(i * height + j) * bytePerPixel + 0] = R;
				imageData[(i * height + j) * bytePerPixel + 1] = G;
				imageData[(i * height + j) * bytePerPixel + 2] = B;
			}
		}
	}
	
	
	CGBitmapInfo bitmapInfo = 0;
	
	// データをNSData型にラップ
	NSData *data = [NSData dataWithBytes:imageData
								  length:bytePerPixel * width * height];
	
	// NSDataを元にDataProviderを作成し、それを元にCGImageRefを作成
	bitsPerPixel = 8 * bytePerPixel;
	bytesPerRow = bytePerPixel * width;
	bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(width,						// Width
										height,						// Height
										sizeof(unsigned char) * 8,	// Bits per component
										bitsPerPixel,               // Bits per pixel
										bytesPerRow,                // Bytes per row
										colorSpace,                 // Colorspace
										bitmapInfo,                 // Bitmap info flags
										provider,                   // CGDataProviderRef
										NULL,                       // Decode
										false,                      // Should interpolate
										kCGRenderingIntentDefault); // Intent
	
	// CGImageRefを使ってUIImageとして初期化
	// imageRefだけでは倍率と方向が不明なため別途指定する
	UIImage *mandelbrotSetImage = [[UIImage alloc] initWithCGImage:imageRef
															 scale:0
													   orientation:UIImageOrientationUp];
	
	// 不要になった情報を削除
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	
	self.image = mandelbrotSetImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint p = [[touches anyObject] locationInView:self];
	CGPoint relativeP = CGPointMake(p.x / self.frame.size.width, p.y / self.frame.size.height);
	double magnification = 3.0;
	CGPoint complexP = CGPointMake(currentCRect.origin.x + currentCRect.size.width * relativeP.x,
								   currentCRect.origin.y + currentCRect.size.height * relativeP.y);
	CGSize newSize = CGSizeMake(currentCRect.size.width / magnification, currentCRect.size.height / magnification);
	
	[self drawMandelbrotSetInComplexRect:CGRectMake(complexP.x - newSize.width / 2.0,
													complexP.y - newSize.height / 2.0,
													newSize.width,
													newSize.height)];
	currentMagnification *= magnification;
	[delegate updateMagnificationLabel];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

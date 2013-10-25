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
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.contentMode = UIViewContentModeScaleAspectFit;
		self.userInteractionEnabled = YES;
		[self drawMandelbrotSetInComplexRect:CGRectMake(-2.0, -2.0, 4.0, 4.0)];
    }
    return self;
}

- (void)drawMandelbrotSetInComplexRect:(CGRect)cRect
{
	// Draw Mandelbrot Set
	NSUInteger maxIteration = 100;
	NSUInteger iteration;
	double _Complex z0 = 0 + 0 * I;
	
	width = 1536;
	height = width;
	
	size_t bytePerPixel = sizeof(unsigned char) * 3;
	size_t bitsPerPixel, bytesPerRow;
	unsigned char *imageData = calloc(width * height, sizeof(unsigned char) * bytePerPixel);
	
	for (NSUInteger i = 0; i < height; i++) {
		for (NSUInteger j = 0; j < width; j++) {
			double _Complex c = cRect.size.width * j / width + cRect.origin.x + (cRect.size.height * i / height + cRect.origin.y) * I;
			double _Complex z = z0;
			for (iteration = 0; iteration < maxIteration; iteration++) {
				z = z * z + c;
				if (cabs(z) > 2) {
					break;
				}
			}
			if (cabs(z) > 1) {
				imageData[(i * height + j) * bytePerPixel + 0] = 255 * (1 - iteration / (double)maxIteration);
				imageData[(i * height + j) * bytePerPixel + 1] = 255 * (1 - iteration / (double)maxIteration);
				imageData[(i * height + j) * bytePerPixel + 2] = 255 * (1 - iteration / (double)maxIteration);
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
	printf("p = (%f, %f)\tc = (%f, %f)\n", p.x, p.y, p.x / width - 0.5, p.y / height - 0.5);
	[self drawMandelbrotSetInComplexRect:CGRectMake(p.x / width - 0.5, p.y / height - 0.5, 1.0, 1.0)];
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

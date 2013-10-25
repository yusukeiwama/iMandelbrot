//
//  USKFractalView.h
//  iMandelbrot
//
//  Created by Yusuke Iwama on 10/25/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol USKFractalViewDelegate <NSObject>

- (void)updateMagnificationLabel;

@end

@interface USKFractalView : UIImageView

@property id delegate;
@property (readonly) double currentMagnification;

- (void)drawMandelbrotSet;
- (void)drawMandelbrotSetInComplexRect:(CGRect)cRect;

@end

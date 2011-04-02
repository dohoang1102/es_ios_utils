//
//  ESVerticalLayoutView.m
//  es_ios_utils
//
//  Created by Peter DeWeese on 3/23/11.
//  Copyright 2011 Eye Street Research, LLC. All rights reserved.
//

#import "ESUtils.h"
#import "ESVerticalLayoutView.h"
#import "math.h"
@implementation ESVerticalLayoutView

@synthesize padding;

-(void)setPadding:(double)p
{
    if(p!=padding)
    {
        padding = p;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{    
    double curY = padding;
    
    for(UIView *v in self.subviews)
    {
        if(self.autoresizesSubviews)
            v.width = self.width;
        v.y = curY;
        v.x = padding;
        curY += padding + v.height;
    }
    self.height = curY + padding;
}

@end

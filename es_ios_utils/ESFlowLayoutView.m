//
//  ESFlowLayoutView.m
//  es_ios_utils
//
//  Created by Peter DeWeese on 3/23/11.
//  Copyright 2011 Eye Street Research, LLC. All rights reserved.
//

#import "ESFlowLayoutView.h"
#import "ESUtils.h"
#import "math.h"
@implementation ESFlowLayoutView

@synthesize padding;

-(void)setPadding:(double)p
{
    if(p!=padding)
    {
        padding = p;
        [self setNeedsLayout];
    }
}

//Orders in rows.  Could be improved to save initial widths for items that are too wide to fit a row.
- (void)layoutSubviews
{
    double rowY = padding;
    double maxHeight = 0.0;
    double curX = padding;
    int itemsInRow = 0;
    
    for(UIView *v in self.subviews)
    {
        //start a new row if needed. If the first item is too wide, present it regardless.
        if(itemsInRow>0 && curX+v.width > self.width)
        {
            rowY = maxHeight + padding;
            maxHeight = 0.0;
            curX = padding;
            itemsInRow = 0;
        }
        
        v.y = rowY;
        v.x = curX;
        curX += v.width + padding;
        maxHeight = MAX(maxHeight, v.height);
        itemsInRow++;
    }
    self.height = rowY + maxHeight + padding;
}

@end

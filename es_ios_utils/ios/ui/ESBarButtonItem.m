#if IS_IOS

#import "ESBarButtonItem.h"
#import <objc/message.h>

@interface ESBarButtonItem()
@property(nonatomic, retain) UIPopoverController* popoverController;
@property(nonatomic, retain) id  userTarget;
@property(nonatomic, assign) SEL userAction;
@end


@implementation ESBarButtonItem

+(ESBarButtonItem*)barButtonItemWithTitle:(NSString*)title action:(void(^)(void))blockAction

{
    ESBarButtonItem* result = [[ESBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil].autoReleaseIfNotARC;
    result.blockAction = blockAction;
    return result;
}

+(ESBarButtonItem*)barButtonItemToEditTable:(UITableView*)t
{
    ESBarButtonItem* item __block;
    item = [ESBarButtonItem barButtonItemWithTitle:@"Edit" action:^{
        [t setEditing:!t.editing animated:YES];
        item.title = t.editing ? @"Done" : @"Edit";
        item.style = t.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
    }];
    return item;
}

@synthesize blockAction, createViewControllerForPopover, viewControllerForPopover, userTarget, userAction;
@synthesize /*private*/ popoverController;

-(void)setViewControllerForPopover:(UIViewController*)new
{
    if(new != viewControllerForPopover)
    {
        [new retainIfNotARC];
        [viewControllerForPopover releaseIfNotARC];
        viewControllerForPopover = new;
        
        [popoverController dismissPopoverAnimated:YES];
        self.popoverController = [UIPopoverController popoverControllerWithNavigationAndContentViewController:viewControllerForPopover];
    }
}

//It's a bit of a hack, but target and action will not return what they are set to. This is how we coopt the press event while still allowing a user to set the target and action.
-(id)target { return self; }
-(void)setTarget:(id)new { self.userTarget = new; }
-(SEL)action { return @selector(pressed:); }
-(void)setAction:(SEL)new { self.userAction = new; }

-(void)pressed:(id)sender
{
    if(popoverController)
        [self dismissPopover];
    else
    {
        if(userTarget && userAction && [userTarget respondsToSelector:userAction])
            objc_msgSend(userTarget, userAction);
        
        [self presentPopover];
        
        if(blockAction) blockAction();
    }
}

#pragma mark - Popovers

-(void)presentPopover
{
    if(!popoverController)
    {
        UIViewController* vc = viewControllerForPopover ?: (createViewControllerForPopover!=nil ? createViewControllerForPopover() : nil);
        if(vc)
        {
            self.popoverController = [UIPopoverController popoverControllerWithNavigationAndContentViewController:vc];
            popoverController.delegate = self;
            [popoverController presentPopoverFromBarButtonItem:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

-(void)dismissPopover
{
    [popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)pc
{
    self.popoverController = nil;
}


#pragma mark - Cleanup

-(void)dealloc
{
    self.blockAction                    = nil;
    self.viewControllerForPopover       = nil;
    self.popoverController              = nil;
    self.userTarget                     = nil;
    self.userAction                     = nil;
    self.createViewControllerForPopover = nil;
    self.userTarget = nil;
    self.userAction = nil;
    
    [super deallocIfNotARC];
}

@end

#endif /*IS_IOS*/
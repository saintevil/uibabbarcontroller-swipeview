//
//  AWTabBarController.m
//  tab
//
//  Created by kwangsik.shin on 2014. 9. 18..
//  Copyright (c) 2014년 Arewith. All rights reserved.
//

#import "AWTabBarController.h"

// customizeable button attributes
#define X_BUFFER 0 // the number of pixels on either side of the segment
#define Y_BUFFER 0 // number of pixels on top of the segment

// customizeable selector bar attributes (the black bar under the buttons)
#define ANIMATION_SPEED 0.2 // the number of seconds it takes to complete the animation
#define SELECTOR_Y_BUFFER 0 // the y-value of the bar that shows what page you are on (0 is the top)
#define SELECTOR_HEIGHT 4 // thickness of the selector bar

#define X_OFFSET 0 // for some reason there's a little bit of a glitchy offset.  I'm going to look for a better workaround in the future

@interface AWTabBarController () <UITabBarControllerDelegate>
@property (strong, nonatomic) UIView * tabBarView;
@property (strong, nonatomic) UIView * selectionBar;

@end

@implementation AWTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    for (UIViewController * vc in  self.childViewControllers) {
        UIPanGestureRecognizer * gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        gesture.maximumNumberOfTouches = 1;
        [vc.view addGestureRecognizer:gesture];
    }
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [self setupSegmentButtons];
}

- (void) setSelectedSegmentColor:(UIColor *)selectedSegmentColor {
    _selectedSegmentColor = selectedSegmentColor;
    _selectionBar.backgroundColor = _selectedSegmentColor;
}

- (void) setCustomSegmentButtons:(NSArray *)customSegmentButtons {
    _customSegmentButtons = [NSArray arrayWithArray:customSegmentButtons];
    if (_tabBarView) {
        [_tabBarView removeFromSuperview];
        _tabBarView = nil;
    }
    if (_selectionBar) {
        [_selectionBar removeFromSuperview];
        _selectionBar = nil;
    }
    [self setupSegmentButtons];
}

- (void)adjustAutolayout:(UIViewController*)vc add:(BOOL)added {
    if (vc) {
        // for autolayout
        // if u needed, added code
        UIView * containerView = self.selectedViewController.view.superview;
        UIView * view = vc.view;
        if (added) {
            [containerView insertSubview:view belowSubview:containerView];

            // using custom autolayout
            //view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        else {
            [view removeFromSuperview];
            //view.translatesAutoresizingMaskIntoConstraints = YES;
        }
    }
}

- (void)panGesture:(UIPanGestureRecognizer*)gesture {

    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0; // I'm just doing horizontal scrolling

    UIView * leftView = self.leftViewController.view;
    UIView * currView = self.selectedViewController.view;
    UIView * rightView = self.rightViewController.view;

    // if we're done with gesture, animate frames to new locations
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (leftView) {
            [self adjustAutolayout:self.leftViewController add:YES];
            leftView.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
        }
        if (rightView) {
            [self adjustAutolayout:self.rightViewController add:YES];
            rightView.frame = [self frameForNextViewWithTranslate:CGPointZero];
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        leftView.frame = [self frameForPreviousViewWithTranslate:translate];
        currView.frame = [self frameForCurrentViewWithTranslate:translate];
        rightView.frame = [self frameForNextViewWithTranslate:translate];
        [self moveSelectionBar:translate];
    } else if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed) {
        CGPoint velocity = [gesture velocityInView:gesture.view];
        // figure out if we've moved (or flicked) more than 50% the way across
        if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (gesture.view.bounds.size.width / 2.0) && leftView) {
            // moving right (and/or flicked right)
            [UIView animateWithDuration:ANIMATION_SPEED
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 leftView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 currView.frame = [self frameForNextViewWithTranslate:CGPointZero];
                                 [self moveSelectionBar:CGPointMake(+currView.bounds.size.width, 0)];
                             }
                             completion:^(BOOL finished) {
                                 leftView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 [self adjustAutolayout:self.leftViewController add:NO];
                                 [self adjustAutolayout:self.rightViewController add:NO];
                                 self.selectedIndex = self.selectedIndex-1;
                                 [self moveSelectionBar:CGPointZero];
                             }];
        } else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(gesture.view.frame.size.width / 2.0) && rightView) {
            // moving left (and/or flicked left)
            [UIView animateWithDuration:ANIMATION_SPEED
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 rightView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 currView.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                                 [self moveSelectionBar:CGPointMake(-currView.bounds.size.width, 0)];
                             }
                             completion:^(BOOL finished) {
                                 rightView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 [self adjustAutolayout:self.leftViewController add:NO];
                                 [self adjustAutolayout:self.rightViewController add:NO];
                                 self.selectedIndex = self.selectedIndex+1;
                                 [self moveSelectionBar:CGPointZero];
                             }];
        } else {
            // return to original location
            [UIView animateWithDuration:ANIMATION_SPEED
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 leftView.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                                 currView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 rightView.frame = [self frameForNextViewWithTranslate:CGPointZero];
                                 [self moveSelectionBar:CGPointZero];
                             }
                             completion:^(BOOL finished) {
                                 currView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 [self adjustAutolayout:self.leftViewController add:NO];
                                 [self adjustAutolayout:self.rightViewController add:NO];
                                 [self moveSelectionBar:CGPointZero];
                             }];
        }
    }
}


-(void)tapSegmentButtonAction:(UIButton *)button {

    if (button.selected) {
        if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
            [((UINavigationController*)self.selectedViewController) popToRootViewControllerAnimated:YES];
        }
    }
    else {
        self.selectedIndex = button.tag;
        
        [UIView animateWithDuration:ANIMATION_SPEED
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self moveSelectionBar:CGPointZero];
                         }
                         completion:^(BOOL finished) {
                             [self moveSelectionBar:CGPointZero];
                         }];
    }
}

- (void)moveSelectionBar:(CGPoint)movedPoint {
    NSUInteger currentPageIndex = self.selectedIndex;
    NSInteger xCoor = X_BUFFER+_selectionBar.frame.size.width*currentPageIndex-X_OFFSET;
    _selectionBar.frame = CGRectMake(xCoor-movedPoint.x/[self.childViewControllers count], _selectionBar.frame.origin.y, _selectionBar.frame.size.width, _selectionBar.frame.size.height);
}

- (CGRect)frameForPreviousViewWithTranslate:(CGPoint)translate {
    CGRect rt = self.selectedViewController.view.bounds;
    rt.origin.x = -rt.size.width + translate.x;
    return rt;
}

- (CGRect)frameForCurrentViewWithTranslate:(CGPoint)translate {
    CGRect rt = self.selectedViewController.view.bounds;
    rt.origin.x = translate.x;
    return rt;
}

- (CGRect)frameForNextViewWithTranslate:(CGPoint)translate {
    CGRect rt = self.selectedViewController.view.bounds;
    rt.origin.x = +rt.size.width + translate.x;
    return rt;
}

- (NSUInteger) selectedIndex {
    NSUInteger selectedIndex = [super selectedIndex];
    if (selectedIndex >= [self.childViewControllers count]) {
        selectedIndex = 0;
    }
    return selectedIndex;
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex {
    if (_tabBarView) {
        [(UIButton*)[_customSegmentButtons objectAtIndex:self.selectedIndex] setSelected:NO];
        [super setSelectedIndex:selectedIndex];
        [(UIButton*)[_customSegmentButtons objectAtIndex:self.selectedIndex] setSelected:YES];
    }
    else {
        [super setSelectedIndex:selectedIndex];
        [self moveSelectionBar:CGPointZero];
    }
}

- (UIViewController*)leftViewController {
    NSArray * arr = self.childViewControllers;
    if (self.selectedIndex > 0) {
        return [arr objectAtIndex:self.selectedIndex-1];
    }
    return nil;
}

- (UIViewController*)rightViewController {
    NSArray * arr = self.childViewControllers;
    if (self.selectedIndex < [arr count]-1 ) {
        return [arr objectAtIndex:self.selectedIndex+1];
    }
    return nil;
}

// custom tabbar;
// sets up the tabs using a loop.  You can take apart the loop to customize individual buttons, but remember to tag the buttons.  (button.tag=0 and the second button.tag=1, etc)
-(void)setupSegmentButtons
{
    if ([_customSegmentButtons count] == 0) {
        if (_tabBarView == nil) {
            UITabBar * parentView = self.tabBar;
            _tabBarView = [[UIView alloc] initWithFrame:parentView.bounds];
            _tabBarView.backgroundColor = [UIColor clearColor];
            [parentView addSubview:_tabBarView];
            [self setupSelector];
        }
    }
    else {
        UITabBar * parentView = self.tabBar;
        NSInteger numControllers = [self.childViewControllers count];

        if (_tabBarView == nil) {
            _tabBarView = [[UIView alloc] initWithFrame:parentView.bounds];
            _tabBarView.backgroundColor = [UIColor clearColor];

            NSInteger i = 0;
            for (UIButton * button in _customSegmentButtons) {
                button.tag = i++;
                [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];

                [_tabBarView addSubview:button];
            }
            [parentView addSubview:_tabBarView];

            [(UIButton*)[_customSegmentButtons objectAtIndex:self.selectedIndex] setSelected:YES];
            [self setupSelector];
        }
        NSInteger i = 0;
        for (UIButton * btn in _customSegmentButtons) {
            btn.frame = CGRectMake(X_BUFFER+i*(self.view.frame.size.width-2*X_BUFFER)/numControllers-X_OFFSET, Y_BUFFER, (self.view.frame.size.width-2*X_BUFFER)/numControllers, parentView.frame.size.height);
            i++;
        }
    }
}

// sets up the selection bar under the buttons on the navigation bar
-(void)setupSelector {
    if (_selectionBar == nil) {
        _selectionBar = [[UIView alloc] initWithFrame:CGRectMake(X_BUFFER-X_OFFSET, SELECTOR_Y_BUFFER,(self.view.frame.size.width-2*X_BUFFER)/[self.childViewControllers count], SELECTOR_HEIGHT)];
        if (_selectedSegmentColor) {
            _selectionBar.backgroundColor = _selectedSegmentColor;
        }
        else {
            _selectionBar.backgroundColor = [UIColor greenColor]; // sbcolor
        }
        _selectionBar.alpha = 0.8; // sbalpha
        [_tabBarView addSubview:_selectionBar];
    }

    CGPoint center = _selectionBar.center;
    center.x += self.selectedIndex*(self.view.frame.size.width-2*X_BUFFER)/[self.childViewControllers count];
    _selectionBar.center = center;
}

#pragma mark -
#pragma mark UITabBarControllerDeleagte
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self moveSelectionBar:CGPointZero];
}


@end


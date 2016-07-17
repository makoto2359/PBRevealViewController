//
//  PBRevealViewController.m
//  PBRevealViewController
//
//  Created by Patrick BODET on 29/06/2016.
//  Copyright © 2016 iDevelopper. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PBRevealViewController.h"

#pragma mark - UIViewController(PBRevealViewController) Category

@implementation UIViewController(PBRevealViewController)

- (PBRevealViewController *)revealViewController
{
    UIViewController *parent = self;
    Class revealClass = [PBRevealViewController class];
    while ( nil != (parent = [parent parentViewController]) && ![parent isKindOfClass:revealClass] ) {}
    return (id)parent;
}

@end

#pragma mark - PBRevealViewControllerSegueSetController segue identifiers

NSString * const PBSegueLeftIdentifier =    @"pb_left";
NSString * const PBSegueMainIdentifier =    @"pb_main";
NSString * const PBSegueRightIdentifier =   @"pb_right";


#pragma mark - PBRevealViewControllerSegueSetController class

@implementation PBRevealViewControllerSegueSetController

- (void)perform
{
    NSString *identifier = self.identifier;
    PBRevealViewController *rvc = self.sourceViewController;
    UIViewController *dvc = self.destinationViewController;
    
    if ([identifier isEqualToString:PBSegueMainIdentifier]) {
        rvc.mainViewController = dvc;
    }
    else if ([identifier isEqualToString:PBSegueLeftIdentifier]) {
        rvc.leftViewController = dvc;
    }
    else if ([identifier isEqualToString:PBSegueRightIdentifier]) {
        rvc.rightViewController = dvc;
    }
}

@end

#pragma mark - SWRevealViewControllerSeguePushController class

@implementation PBRevealViewControllerSeguePushController

- (void)perform
{
    PBRevealViewController *rvc = [self.sourceViewController revealViewController];
    UIViewController *dvc = self.destinationViewController;
    [rvc pushMainViewController:dvc animated:YES];
}

@end

#pragma mark - PBRevealViewControllerPanGestureRecognizer

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PBRevealViewControllerPanGestureRecognizer : UIPanGestureRecognizer
@end

@implementation PBRevealViewControllerPanGestureRecognizer
{
    BOOL _dragging;
    CGPoint _beginPoint;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    _beginPoint = [touch locationInView:self.view];
    _dragging = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if ( _dragging || self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    const CGFloat kDirectionPanThreshold = 5;
    
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self.view];
    
    if (ABS(nowPoint.x - _beginPoint.x) > kDirectionPanThreshold) {
        _dragging = YES;
    }
    else if (ABS(nowPoint.y - _beginPoint.y) > kDirectionPanThreshold) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

@end

#pragma mark - PBRevealViewController Class

@interface PBRevealViewController() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *contentView;

@property (nonatomic) BOOL userInteractionStore;

@end

@implementation PBRevealViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self initDefaultProperties];
    }
    return self;
}

- (id)initWithLeftViewController:(UIViewController *)leftViewController mainViewController:(UIViewController *)mainViewController rightViewController:(UIViewController *)rightViewController
{
    self = [super init];
    if ( self )
    {
        [self initDefaultProperties];
        
        _leftViewController = leftViewController;
        _mainViewController = mainViewController;
        _rightViewController = rightViewController;
        
        [self reloadLeftShadow];
        [self reloadRightShadow];
    }
    return self;
}

- (void)initDefaultProperties
{
    self.leftViewRevealWidth = 260.0f;
    self.isLeftViewOpen = NO;
    self.isRightViewOpen = NO;
    self.isLeftViewDragging = NO;
    self.isRightViewDragging = NO;
    self.rightViewRevealWidth = 160.0f;
    self.swipeVelocity = 250.0f;
    self.leftToggleAnimationDuration = 0.5f;
    self.leftToggleSpringDampingRatio = 0.8f;
    self.leftToggleSpringVelocity = 0.5f;
    self.rightToggleAnimationDuration = 0.5f;
    self.rightToggleSpringDampingRatio = 0.8f;
    self.rightToggleSpringVelocity = 0.5f;
    self.replaceViewAnimationDuration = 0.25f;
    self.leftViewShadowRadius = 5.0f;
    self.leftViewShadowOffset = CGSizeMake(0.0f, 2.5f);
    self.leftViewShadowOpacity = 1.0f;
    self.leftViewShadowColor = [UIColor blackColor];

    self.rightViewShadowRadius = 5.0f;
    self.rightViewShadowOffset = CGSizeMake(0.0f, 2.5f);
    self.rightViewShadowOpacity = 1.0f;
    self.rightViewShadowColor = [UIColor blackColor];
    
    self.userInteractionStore = YES;
}

#pragma mark - View lifecycle
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadStoryboardControllers];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    [self addChildViewController:_mainViewController];
    [_mainViewController didMoveToParentViewController:self];
    
    self.contentView = [[UIView alloc] initWithFrame:frame];
    
    //[_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    [_contentView addSubview:_mainViewController.view];
    
    self.view = _contentView;
    
    [self tapGestureRecognizer];
    [self panGestureRecognizer];
    
    [self wakeUpLeftView];
}
*/

- (void)loadView
{
    [super loadView];
    
    [self loadStoryboardControllers];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    [self addChildViewController:_mainViewController];
    [_mainViewController didMoveToParentViewController:self];

    self.contentView = [[UIView alloc] initWithFrame:frame];
    
    //[_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
 
    
    self.view = _contentView;
    [_contentView addSubview:_mainViewController.view];
    
    [self tapGestureRecognizer];
    [self panGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _userInteractionStore = _contentView.userInteractionEnabled;
}

// Load any defined Main/Left/Right controllers from the storyboard
- (void)loadStoryboardControllers
{
    if (self.storyboard && _leftViewController == nil)
    {
        //Try each segue separately so it doesn't break prematurely if either Rear or Right views are not used.
        @try
        {
            [self performSegueWithIdentifier:PBSegueLeftIdentifier sender:nil];
        }
        @catch(NSException *exception) {}
        
        @try
        {
            [self performSegueWithIdentifier:PBSegueMainIdentifier sender:nil];
        }
        @catch(NSException *exception) {}
        
        @try
        {
            [self performSegueWithIdentifier:PBSegueRightIdentifier sender:nil];
        }
        @catch(NSException *exception) {}
    }
}

#pragma mark - Public methods and property accessors

- (void)setLeftViewShadowRadius:(CGFloat)leftViewShadowRadius
{
    _leftViewShadowRadius = leftViewShadowRadius;
    [self reloadLeftShadow];
}

- (void)setLeftViewShadowOffset:(CGSize)leftViewShadowOffset
{
    _leftViewShadowOffset = leftViewShadowOffset;
    [self reloadLeftShadow];
}

- (void)setLeftViewShadowOpacity:(CGFloat)leftViewShadowOpacity
{
    _leftViewShadowOpacity = leftViewShadowOpacity;
    [self reloadLeftShadow];
}

- (void)setLeftViewShadowColor:(UIColor *)leftViewShadowColor
{
    _leftViewShadowColor = leftViewShadowColor;
    [self reloadLeftShadow];
}

- (void)reloadLeftShadow
{
    CALayer *layer = _leftViewController.view.layer;
    layer.shadowColor = _leftViewShadowColor.CGColor;
    layer.shadowOpacity = _leftViewShadowOpacity;
    layer.shadowOffset = _leftViewShadowOffset;
    layer.shadowRadius = _leftViewShadowRadius;
}

- (void)setRightViewShadowRadius:(CGFloat)rightViewShadowRadius
{
    _rightViewShadowRadius = rightViewShadowRadius;
    [self reloadRightShadow];
}

- (void)setRightViewShadowOffset:(CGSize)rightViewShadowOffset
{
    _rightViewShadowOffset = rightViewShadowOffset;
    [self reloadRightShadow];
}

- (void)setRightViewShadowOpacity:(CGFloat)rightViewShadowOpacity
{
    _rightViewShadowOpacity = rightViewShadowOpacity;
    [self reloadRightShadow];
}

- (void)setRightViewShadowColor:(UIColor *)rightViewShadowColor
{
    _rightViewShadowColor = rightViewShadowColor;
    [self reloadRightShadow];
}

- (void)reloadRightShadow
{
    CALayer *layer = _rightViewController.view.layer;
    layer.shadowColor = _rightViewShadowColor.CGColor;
    layer.shadowOpacity = _rightViewShadowOpacity;
    layer.shadowOffset = _rightViewShadowOffset;
    layer.shadowRadius = _rightViewShadowRadius;
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    [self setLeftViewController:leftViewController animated:NO];
}

- (void)setLeftViewController:(UIViewController *)leftViewController animated:(BOOL)animated
{
    if (_isLeftViewOpen) {
        [self swapFromViewController:_leftViewController toViewController:leftViewController operation:PBRevealControllerOperationReplaceLeftController animated:animated];
    }
    _leftViewController = leftViewController;
    [self reloadLeftShadow];
}

- (void)setMainViewController:(UIViewController *)mainViewController
{
    [self setMainViewController:mainViewController animated:NO];
}

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated
{
    if (_mainViewController) {
        [self swapFromViewController:_mainViewController toViewController:mainViewController operation:PBRevealControllerOperationReplaceMainController animated:animated];
    }
    _mainViewController = mainViewController;
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    [self setRightViewController:rightViewController animated:NO];
}

- (void)setRightViewController:(UIViewController *)rightViewController animated:(BOOL)animated
{
    if (_isRightViewOpen) {
        [self swapFromViewController:_rightViewController toViewController:rightViewController operation:PBRevealControllerOperationReplaceRightController animated:animated];
    }
    _rightViewController = rightViewController;
    [self reloadRightShadow];
}

- (void)pushMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated {
    [self swapFromViewController:_mainViewController toViewController:mainViewController operation:PBRevealControllerOperationPushMainController animated:animated];
    _mainViewController = mainViewController;
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController operation:(PBRevealControllerOperation)operation animated:(BOOL)animated
{
    if ([_delegate respondsToSelector:@selector(revealController:willAddViewController:forOperation:animated:)]) {
        [_delegate revealController:self willAddViewController:toViewController forOperation:operation animated:animated];
    }
    NSTimeInterval duration = animated ? _replaceViewAnimationDuration : 0.0;
    
    if (fromViewController != toViewController) {
        toViewController.view.frame = fromViewController.view.frame;
        [fromViewController willMoveToParentViewController:nil];
        [self addChildViewController:toViewController];
        [self transitionFromViewController:fromViewController toViewController:toViewController duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            switch (operation) {
                case PBRevealControllerOperationReplaceLeftController:
                case PBRevealControllerOperationReplaceRightController:
                    [_contentView addSubview:toViewController.view];
                    break;
                    
                case PBRevealControllerOperationReplaceMainController:
                case PBRevealControllerOperationPushMainController:
                    [_contentView insertSubview:toViewController.view belowSubview:self.childViewControllers[0].view];
                    // XXXX
                    [toViewController.view addGestureRecognizer:_tapGestureRecognizer];
                    [toViewController.view addGestureRecognizer:_panGestureRecognizer];
                    //
                    break;
                    
                default:
                    break;
            }
        } completion:^(BOOL finished) {
            [toViewController didMoveToParentViewController:self];
            if (operation == PBRevealControllerOperationPushMainController) {
                [self hideLeftView];
            }
            if ([_delegate respondsToSelector:@selector(revealController:didAddViewController:forOperation:animated:)]) {
                [_delegate revealController:self didAddViewController:toViewController forOperation:operation animated:animated];
            }
        }];
    }
}

#pragma mark - Reveal and hide actions

- (IBAction)revealLeftView
{
    if (_leftViewController) {
        if (_isRightViewOpen) {
            [self hideRightView];
        }
        if ([_delegate respondsToSelector:@selector(revealController:shouldShowLeftViewController:)]) {
            if ([_delegate revealController:self shouldShowLeftViewController:_leftViewController] == NO)
                return;
        }
        if ([_delegate respondsToSelector:@selector(revealController:willShowLeftViewController:)]) {
            [_delegate revealController:self willShowLeftViewController:_leftViewController];
        }
        
        [self addChildViewController:_leftViewController];
        CGRect frame = _leftViewController.view.frame;
        frame.origin.x = -(_leftViewRevealWidth);
        frame.size.width = _leftViewRevealWidth;
        _leftViewController.view.frame = frame;
        
        [_contentView addSubview:_leftViewController.view];
        [_leftViewController didMoveToParentViewController:self];
        
        frame.origin.x = 0;
        frame.size.width = _leftViewRevealWidth;
    
        [UIView animateWithDuration:_leftToggleAnimationDuration delay:0.0 usingSpringWithDamping:_leftToggleSpringDampingRatio initialSpringVelocity:_leftToggleSpringVelocity options:UIViewAnimationOptionTransitionNone animations:^{
            _leftViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            self.isLeftViewOpen = YES;
            if (!_leftViewController.view.hidden) {
                if ([_delegate respondsToSelector:@selector(revealController:didShowLeftViewController:)]) {
                    [_delegate revealController:self didShowLeftViewController:_leftViewController];
                }
            }
        }];
    }
}

- (IBAction)revealRightView
{
    if (_rightViewController) {
        if (_isLeftViewOpen) {
            [self hideLeftView];
        }
        if ([_delegate respondsToSelector:@selector(revealController:shouldShowRightViewController:)]) {
            if ([_delegate revealController:self shouldShowRightViewController:_rightViewController] == NO)
                return;
        }
        if ([_delegate respondsToSelector:@selector(revealController:willShowRightViewController:)]) {
            [_delegate revealController:self willShowRightViewController:_rightViewController];
        }
        [self addChildViewController:_rightViewController];
        CGRect frame = _rightViewController.view.frame;
        frame.origin.x = +[UIScreen mainScreen].bounds.size.width;
        frame.size.width = _rightViewRevealWidth;
        _rightViewController.view.frame = frame;
        
        [_contentView addSubview:_rightViewController.view];
        [_rightViewController didMoveToParentViewController:self];
        
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - _rightViewRevealWidth;
        frame.size.width = _rightViewRevealWidth;

        [UIView animateWithDuration:_rightToggleAnimationDuration delay:0.0 usingSpringWithDamping:_rightToggleSpringDampingRatio initialSpringVelocity:_rightToggleSpringVelocity options: UIViewAnimationOptionTransitionNone animations:^{
            _rightViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            self.isRightViewOpen = YES;
            if ([_delegate respondsToSelector:@selector(revealController:didShowRightViewController:)]) {
                [_delegate revealController:self didShowRightViewController:_rightViewController];
            }
        }];
    }
}

- (void)hideLeftView
{
    if (_leftViewController) {
        //self.isLeftViewDragging = NO;
        CGRect frame = _leftViewController.view.frame;
        frame.origin.x = -(_leftViewRevealWidth);
        frame.size.width = _leftViewRevealWidth;
        
        [UIView animateWithDuration:_leftToggleAnimationDuration delay:0.0 usingSpringWithDamping:_leftToggleSpringDampingRatio initialSpringVelocity:_leftToggleSpringVelocity options:UIViewAnimationOptionTransitionNone animations:^{
            _leftViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            self.isLeftViewOpen = NO;
            [_leftViewController willMoveToParentViewController:nil];
            [_leftViewController.view removeFromSuperview];
            [_leftViewController removeFromParentViewController];
        }];
    }
}

- (void)hideRightView
{
    if (_rightViewController) {
        //self.isRightViewDragging = NO;
        CGRect frame = _rightViewController.view.frame;
        frame.origin.x = +[UIScreen mainScreen].bounds.size.width;
        frame.size.width = _rightViewRevealWidth;
        
        [UIView animateWithDuration:_rightToggleAnimationDuration delay:0. usingSpringWithDamping:_rightToggleSpringDampingRatio initialSpringVelocity:_rightToggleSpringVelocity options:UIViewAnimationOptionTransitionNone animations:^{
            _rightViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            self.isRightViewOpen = NO;
            [_rightViewController willMoveToParentViewController:nil];
            [_rightViewController.view removeFromSuperview];
            [_rightViewController removeFromParentViewController];
        }];
    }
}

#pragma mark - Gesture Recognizer

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_tapGestureRecognizer == nil)
    {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
        
        _tapGestureRecognizer.delegate = self;

        [_mainViewController.view addGestureRecognizer:_tapGestureRecognizer];
    }
    return _tapGestureRecognizer;
}

- (UIPanGestureRecognizer*)panGestureRecognizer
{
    if ( _panGestureRecognizer == nil )
    {
        self.panGestureRecognizer = [[PBRevealViewControllerPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        _panGestureRecognizer.delegate = self;

        [_mainViewController.view addGestureRecognizer:_panGestureRecognizer];
    }
    return _panGestureRecognizer;
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if (recognizer == _tapGestureRecognizer) {
        if ([_delegate respondsToSelector:@selector(revealControllerTapGestureShouldBegin:)]) {
            if ([_delegate revealControllerTapGestureShouldBegin:self] == NO) {
                return NO;
            }
        }
    }
    if (recognizer == _panGestureRecognizer) {
        CGFloat velocity = [_panGestureRecognizer velocityInView:_mainViewController.view].x;
        if ([_delegate respondsToSelector:@selector(revealControllerPanGestureShouldBegin:direction:)]) {
            if ([_delegate revealControllerPanGestureShouldBegin:self direction:velocity > 0 ? PBRevealControllerPanDirectionLeft : PBRevealControllerPanDirectionRight] == NO) {
                return NO;
            }
            if (_isLeftViewOpen || _isRightViewOpen) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( gestureRecognizer == _panGestureRecognizer )
    {
        if ( [_delegate respondsToSelector:@selector(revealController:panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:)] )
            if ( [_delegate revealController:self panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer] != NO )
                return YES;
    }
    if ( gestureRecognizer == _tapGestureRecognizer )
    {
        if ( [_delegate respondsToSelector:@selector(revealController:tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:)] )
            if ( [_delegate revealController:self tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer] != NO )
                return YES;
    }
    
    return NO;
}

- (void)_moveLeftViewToPosition:(CGFloat)position
{
    if (_leftViewController) {
        if (![self.childViewControllers containsObject:_leftViewController]) {
            [self addChildViewController:_leftViewController];
            _leftViewController.view.frame = CGRectMake(0, 0, 0, [UIScreen mainScreen].bounds.size.height);
            [_contentView addSubview:_leftViewController.view];
            [_leftViewController didMoveToParentViewController:self];
        }
        
        CGRect frame = _leftViewController.view.frame;
        frame.origin.x = 0;
        
        if (position <= 0) {
            [self hideLeftView];
            self.panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
        }
        else if (position < _leftViewRevealWidth) {
            frame.size.width = position;
            _leftViewController.view.frame = frame;
        }
        else {
            if ([_delegate respondsToSelector:@selector(revealController:willShowLeftViewController:)]) {
                [_delegate revealController:self willShowLeftViewController:_leftViewController];
            }
            self.isLeftViewOpen = YES;
            frame.size.width = _leftViewRevealWidth;
            
            [UIView animateWithDuration:_leftToggleAnimationDuration delay:0.0 usingSpringWithDamping:_leftToggleSpringDampingRatio initialSpringVelocity:_leftToggleSpringVelocity options:UIViewAnimationOptionTransitionNone animations:^{
                _leftViewController.view.frame = frame;
            } completion:^(BOOL finished) {
                if ([_delegate respondsToSelector:@selector(revealController:didShowLeftViewController:)]) {
                    [_delegate revealController:self didShowLeftViewController:_leftViewController];
                }
            }];
        }
    }
}

- (void)_moveRightViewToPosition:(CGFloat)position
{
    if (_rightViewController) {
        if (![self.childViewControllers containsObject:_rightViewController]) {
            NSLog(@"------------> Add Right Child");
            [self addChildViewController:_rightViewController];
            _rightViewController.view.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 0, [UIScreen mainScreen].bounds.size.height);
            [_contentView addSubview:_rightViewController.view];
            [_rightViewController didMoveToParentViewController:self];
        }
        
        CGRect frame = _rightViewController.view.frame;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - ABS(position);
        
        if (position >= 0) {
            [self hideRightView];
            self.panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
        }
        else if (ABS(position) < _rightViewRevealWidth) {
            frame.size.width = ABS(position);
            _rightViewController.view.frame = frame;
        }
        else {
            if ([_delegate respondsToSelector:@selector(revealController:willShowRightViewController:)]) {
                [_delegate revealController:self willShowRightViewController:_rightViewController];
            }
            self.isRightViewOpen = YES;
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - _rightViewRevealWidth;
            frame.size.width = _rightViewRevealWidth;
            
            [UIView animateWithDuration:_rightToggleAnimationDuration delay:0.0 usingSpringWithDamping:_rightToggleSpringDampingRatio initialSpringVelocity:_rightToggleSpringVelocity options:UIViewAnimationOptionTransitionNone animations:^{
                _rightViewController.view.frame = frame;
            } completion:^(BOOL finished) {
                if ([_delegate respondsToSelector:@selector(revealController:didShowRightViewController:)]) {
                    [_delegate revealController:self didShowRightViewController:_rightViewController];
                }
            }];
        }
    }
}

#pragma mark - UserInteractionEnabling

// disable userInteraction on the entire control
- (void)disableUserInteraction
{
    [_contentView setUserInteractionEnabled:NO];
}

// restore userInteraction on the control
- (void)restoreUserInteraction
{
    // we use the stored userInteraction state just in case a developer decided
    // to have our view interaction disabled beforehand
    [_contentView setUserInteractionEnabled:_userInteractionStore];
}


#pragma mark - Gesture Handle

- (void)_handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (_isLeftViewOpen) {
        [self hideLeftView];
    }
    if (_isRightViewOpen) {
        [self hideRightView];
    }
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGFloat position = [recognizer translationInView:_mainViewController.view].x;
    CGFloat velocity = [recognizer velocityInView:_mainViewController.view].x;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self notifyPanGestureBegan:position];
            if (velocity > 0 && _leftViewController && !_isRightViewDragging) {
                self.isLeftViewDragging = YES;
            }
            else if (_rightViewController) {
                self.isRightViewDragging = YES;
            }
            [self disableUserInteraction];
            if (ABS(velocity) > _swipeVelocity) {
                //NSLog(@"Velocity = %f", velocity);
                if (_isLeftViewDragging) {
                    [self _moveLeftViewToPosition:_leftViewRevealWidth];
                }
                else {
                    if (velocity < 0) [self _moveRightViewToPosition:-(_rightViewRevealWidth)];
                }
            }
            break;
            
        case UIGestureRecognizerStateChanged:
            [self notifyPanGestureMoved:position];
            if (_isLeftViewOpen || _isRightViewOpen) {
                self.panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                break;
            }
            
            if (_isLeftViewDragging) {
                [self _moveLeftViewToPosition:position];
            }
            else {
                [self _moveRightViewToPosition:position];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (_isLeftViewOpen || _isRightViewOpen) {
                [self notifyPanGestureEnded:position];
                break;
            }
            
            if (_isLeftViewDragging) {
                if (position > _leftViewRevealWidth * 0.50) {
                    [self _moveLeftViewToPosition:_leftViewRevealWidth];
                }
                else {
                    [self hideLeftView];
                }
            }
            else {
                if (ABS(position) > _rightViewRevealWidth * 0.50) {
                    [self _moveRightViewToPosition:-(_rightViewRevealWidth)];
                }
                else {
                    [self hideRightView];
                }
            }
            [self notifyPanGestureEnded:position];
            break;
            
        case UIGestureRecognizerStateCancelled:
            //NSLog(@"Cancelled, position = %f", position);
            [self notifyPanGestureEnded:position];
            break;
            
        default:
            break;
    }
}

- (void)notifyPanGestureBegan:(CGFloat)position
{
    if ([_delegate respondsToSelector:@selector(revealControllerPanGestureBegan:direction:)]) {
        CGFloat velocity = [_panGestureRecognizer velocityInView:_mainViewController.view].x;
        [_delegate revealControllerPanGestureBegan:self direction:velocity > 0 ? PBRevealControllerPanDirectionLeft : PBRevealControllerPanDirectionRight];
    }
}

- (void)notifyPanGestureMoved:(CGFloat)position
{
    if ([_delegate respondsToSelector:@selector(revealControllerPanGestureMoved:direction:)]) {
        CGFloat velocity = [_panGestureRecognizer velocityInView:_mainViewController.view].x;
        [_delegate revealControllerPanGestureMoved:self direction:velocity > 0 ? PBRevealControllerPanDirectionLeft : PBRevealControllerPanDirectionRight];
    }
}

- (void)notifyPanGestureEnded:(CGFloat)position
{
    self.isLeftViewDragging = NO;
    self.isRightViewDragging = NO;
    [self restoreUserInteraction];
    if ([_delegate respondsToSelector:@selector(revealControllerPanGestureEnded:direction:)]) {
        CGFloat velocity = [_panGestureRecognizer velocityInView:_mainViewController.view].x;
        [_delegate revealControllerPanGestureEnded:self direction:velocity > 0 ? PBRevealControllerPanDirectionLeft : PBRevealControllerPanDirectionRight];
    }
}

# pragma mark - override rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         CGRect frame;
         
         frame = _leftViewController.view.frame;
         frame.size.width = _leftViewRevealWidth;
         _leftViewController.view.frame = frame;
         
         frame = _rightViewController.view.frame;
         frame.origin.x = [UIScreen mainScreen].bounds.size.width - _rightViewRevealWidth;
         frame.size.width = _rightViewRevealWidth;
         _rightViewController.view.frame = frame;
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end



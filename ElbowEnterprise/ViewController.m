//  ViewController.m
//  ElbowEnterprise
//
//  Created by Frederick C. Lee on 8/30/14.
//  Copyright (c) 2014 Amourine Technologies. All rights reserved.
// -----------------------------------------------------------------------------------------------------------------------

#import "ViewController.h"

static const NSInteger leftVCTag = 20;
static const NSInteger rightVCTag = 30;
static const NSInteger navOverlayTag = 100;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    UIStoryboard *storyboard;
    BOOL waitABit;
    CGRect leftStageRect, rightStageRect, displayRect, leftDisplayRect, rightDisplayRect;
}

@property (nonatomic, strong) NSMutableArray *chat;
@property(nonatomic, strong) UIViewController *leftVC;
@property(nonatomic, strong) UIViewController *rightVC;
@property (weak, nonatomic) IBOutlet UIView *navOverlayView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        leftStageRect = CGRectMake(0.0, 0.0, 0.0, height);
        rightStageRect = CGRectMake(width, 0.0, 0.0, height);
        
        leftDisplayRect = CGRectMake(0.0, 0.0, width/2.0, height);
        rightDisplayRect = CGRectMake((width/2.0),0.0,width/2.0, height);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
        self.chat = [NSArray arrayWithContentsOfFile:path];
    }
    return self;
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.leftVC = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"leftVC"];
    self.rightVC = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"rightVC"];
    _leftVC.view.tag = leftVCTag;               // ...using tag for easy ID in view hierarchy.
    _rightVC.view.tag = rightVCTag;
    _navOverlayView.tag = navOverlayTag;
    [self addGestureRecognizers];
    _leftVC.view.frame = leftStageRect;
    _rightVC.view.frame = rightStageRect;
    
    [self addGestureRecognizers];
    
    [self addChildViewController:_leftVC];
    [_leftVC didMoveToParentViewController:self];
    [self addChildViewController:_rightVC];
    [_rightVC didMoveToParentViewController:self];
    
    [self.view addSubview:_leftVC.view];
    [self.view addSubview:_rightVC.view];
    

}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark -

- (void)addGestureRecognizers {
    // --- tap:
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(handleTap:)];
    
    [_navOverlayView addGestureRecognizer:tapGesture];

    // --- SwipeRight:
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(handleSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_navOverlayView addGestureRecognizer:swipeRight];
    
    // --- SwipeLeft:
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_navOverlayView addGestureRecognizer:swipeLeft];
    
    // -------------------------------------------------------
    // --- DismissSwipeRight:
    UISwipeGestureRecognizer *dismissSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(handleSwipeRight:)];
    dismissSwipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [_rightVC.view addGestureRecognizer:dismissSwipeRight];
    
    // --- DismissSwipeLeft:
    UISwipeGestureRecognizer *dismissSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(handleSwipeLeft:)];
    dismissSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [_leftVC.view addGestureRecognizer:dismissSwipeLeft];
    
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark - UIGestureRecognizer handlers

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [self.messageTextField resignFirstResponder];
    [self dismissLeftVC];
    [self dismissRightVC];
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)sender {
    NSInteger tag = sender.view.tag;
    
    switch (tag) {
        case navOverlayTag:
            waitABit = NO;
            [self revealLeftVC];
            break;
            
        case rightVCTag:
            [self dismissRightVC];
            break;
    }
    
    return;
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)sender {
    NSInteger tag = sender.view.tag;
    
    switch (tag) {
        case navOverlayTag:
            waitABit = NO;
            [self revealRightVC];
            break;
            
        case leftVCTag:
            [self dismissLeftVC];
            break;
    }
    
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark -

- (void)revealLeftVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _leftVC.view.frame = leftDisplayRect;
        } completion:^(BOOL finished){
            if (finished) {
                if ((CGRectEqualToRect (_rightVC.view.frame, rightDisplayRect))) {
                    [self dismissRightVC];
                }
            }
        }];
    });
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)dismissRightVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _rightVC.view.frame = rightStageRect;
        } completion:^(BOOL finished){
            if (finished) {
            }
        }];
    });
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)revealRightVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _rightVC.view.frame = rightDisplayRect;
        } completion:^(BOOL finished){
            if (finished) {
                if (CGRectEqualToRect (_leftVC.view.frame, leftDisplayRect)) {
                    [self dismissLeftVC];
                }
            }
        }];
    });
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)dismissLeftVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _leftVC.view.frame = leftStageRect;
        } completion:^(BOOL finished){
            if (finished) {
            }
        }];
    });
}


// -----------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    // We only have one section in our table view.
    return 1;
}

// -----------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section {
    // This is the number of chat messages.
    return [self.chat count];
}

// -----------------------------------------------------------------------------------------------------------------------

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)index {
    static NSString *CellIdentifier = @"elbowCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSDictionary *chatMessage = [self.chat objectAtIndex:index.row];
    
    cell.textLabel.text = chatMessage[@"message"];
    cell.detailTextLabel.text = chatMessage[@"from"];
    
    return cell;
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_leftVC removeFromParentViewController];
    [_rightVC removeFromParentViewController];
}


@end

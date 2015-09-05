//
//  DetailView.m
//  Shokuji
//
//  Created by Kevin Frans on 9/4/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "DetailView.h"
#import "ViewController.h"
#import "BALoadingView.h"

@interface DetailView ()

@end

#define dWidth self.view.frame.size.width
#define dHeight self.view.frame.size.height

@implementation DetailView
{
    UIImage* image;
    BALoadingView* loadingView;
    UIView* popup;
    UIView* bg;
    float margin;
    ViewController* myParent;
    UIScrollView* scroll;
    UILabel* loadLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}


-(void) setParent:(id)vc
{
    myParent = vc;
}

-(void) viewDidAppear:(BOOL)animated
{
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
    swipeUpGestureRecognizer.delegate = self;
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeUpGestureRecognizer];
    
    
    margin = 200;
    bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    bg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bg];
    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    scroll.contentSize = CGSizeMake(dWidth, dHeight+100);
    [self.view addSubview:scroll];
    [scroll setShowsVerticalScrollIndicator:NO];
//    [scroll sets]
    
    popup = [[UIView alloc] initWithFrame:CGRectMake(0, margin+dHeight, dWidth, dHeight)];
    popup.backgroundColor = [UIColor clearColor];
    [scroll addSubview:popup];
    
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
    viewWithBlurredBackground.frame = CGRectMake(0, 0, dWidth, dHeight);
//    viewWithBlurredBackground.layer.opacity = 0.8;
    [popup addSubview:viewWithBlurredBackground];
    
    UIVisualEffectView * viewInducingVibrancy =
    [[UIVisualEffectView alloc] initWithEffect:effect]; // must be the same effect as the blur view
    [viewWithBlurredBackground.contentView addSubview:viewInducingVibrancy];
//    UILabel * vibrantLabel = [UILabel new];
//    // Set the text and the position of your label
//    [viewInducingVibrancy.contentView addSubview:vibrantLabel];
    
    float loadsize = 150;
    loadingView = [[BALoadingView alloc] initWithFrame:CGRectMake(dWidth/2 - loadsize/2, 50, loadsize, loadsize)];
    [viewInducingVibrancy addSubview:loadingView];
    loadingView.segmentColor = [UIColor blackColor];
    [loadingView initialize];
    [loadingView startAnimation:BACircleAnimationFullCircle];
    
    loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,150, dWidth, 200)];
    loadLabel.text = @"shokuji shimasu";
    loadLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    [viewInducingVibrancy addSubview:loadLabel];
    
    
    [UIView animateWithDuration:0.6 delay:0.0 options:
     UIViewAnimationOptionCurveEaseIn animations:^{
         bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
         popup.frame = CGRectMake(0, margin, dWidth, dHeight-margin);
     } completion:^ (BOOL completed) {
         //         [v removeFromSuperview];
         //         [self detailScreen];
     }];
    
    [self performSelector:@selector(callback) withObject:nil afterDelay:3];

}


-(void) callback
{
    NSLog(@"callback");
    [loadingView removeFromSuperview];
    [loadLabel removeFromSuperview];
    scroll.contentSize = CGSizeMake(dWidth, 2000);
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0,margin, dWidth, 50)];
    title.text = @"Gatorade";
    title.textColor = [UIColor blackColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f];
    title.numberOfLines = 1;
    [scroll addSubview:title];
    
    UILabel* calories = [[UILabel alloc] initWithFrame:CGRectMake(0,margin+50, dWidth, 50)];
    calories.text = @"Calories: 240";
    title.textColor = [UIColor blackColor];
    calories.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    calories.numberOfLines = 1;
    [scroll addSubview:calories];
}

- (void)handleSwipeUpFrom:(UIGestureRecognizer*)recognizer {
    NSLog(@"swipe up");
//    [UIView animateWithDuration:5 delay:0.0 options:
//     UIViewAnimationOptionCurveEaseIn animations:^{
//         bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//         popup.frame = CGRectMake(0, margin, dWidth, dHeight-margin);
//         
//     } completion:^ (BOOL completed) {
//         [myParent reload];
//         [self dismissViewControllerAnimated:NO completion:^{}];
//     }];
//    [self close];
}

-(void)close
{
    [myParent reload];
    [self dismissViewControllerAnimated:YES completion:^{}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

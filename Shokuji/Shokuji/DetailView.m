//
//  DetailView.m
//  Shokuji
//
//  Created by Kevin Frans on 9/4/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "DetailView.h"
#import "ViewController.h"

@interface DetailView ()

@end

#define dWidth self.view.frame.size.width
#define dHeight self.view.frame.size.height

@implementation DetailView
{
    UIImage* image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated
{
    float margin = 200;
    UIView* bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    bg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bg];
    
    UIView* popup = [[UIView alloc] initWithFrame:CGRectMake(0, margin+dHeight, dWidth, dHeight-margin)];
    popup.backgroundColor = [UIColor clearColor];
    [self.view addSubview:popup];
    
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * viewWithBlurredBackground =
    [[UIVisualEffectView alloc] initWithEffect:effect];
    viewWithBlurredBackground.frame = CGRectMake(0, 0, dWidth, dHeight);
    [popup addSubview:viewWithBlurredBackground];
    
    
    [UIView animateWithDuration:0.6 delay:0.0 options:
     UIViewAnimationOptionCurveEaseIn animations:^{
         bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
         popup.frame = CGRectMake(0, margin, dWidth, dHeight-margin);
     } completion:^ (BOOL completed) {
         //         [v removeFromSuperview];
         //         [self detailScreen];
     }];
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

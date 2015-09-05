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
    
    margin = 400;
    bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    bg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bg];
    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    scroll.contentSize = CGSizeMake(dWidth, dHeight+100);
    [self.view addSubview:scroll];
    [scroll setShowsVerticalScrollIndicator:NO];
//    [scroll sets]
    
    float sidem = 10;
    popup = [[UIView alloc] initWithFrame:CGRectMake(sidem, margin, dWidth - sidem*2, dHeight-margin - sidem)];
    popup.backgroundColor = [UIColor whiteColor];
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = popup.bounds;
    gradient2.cornerRadius = 7;
    gradient2.colors = [NSArray arrayWithObjects:(id)[[[UIColor orangeColor] colorWithAlphaComponent:0.8] CGColor], (id)[[[UIColor redColor] colorWithAlphaComponent:0.8] CGColor], nil];
    [popup.layer insertSublayer:gradient2 atIndex:0];
    popup.layer.cornerRadius = 7;
    [scroll addSubview:popup];
    
    
    float loadsize = 50;
    loadingView = [[BALoadingView alloc] initWithFrame:CGRectMake((dWidth-sidem*2)/2 - loadsize/2, 20, loadsize, loadsize)];
    [popup addSubview:loadingView];
    loadingView.segmentColor = [UIColor whiteColor];
    [loadingView initialize];
    [loadingView startAnimation:BACircleAnimationFullCircle];
    
    loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70, (dWidth-sidem*2), 30)];
    loadLabel.text = @"shokuji shimasu";
    loadLabel.textColor = [UIColor whiteColor];
    loadLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    [popup addSubview:loadLabel];
    
    
//    [self performSelector:@selector(callback) withObject:nil afterDelay:3];

}


-(void) giveData:(NSData *)data
{
    NSLog(@"callback");
    
    [loadingView removeFromSuperview];
    [loadLabel removeFromSuperview];
    //    scroll.contentSize = CGSizeMake(dWidth, 2000);
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSData *tdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:tdata options:0 error:nil];
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+5, dWidth, 20)];
    title.text = json[@"result"][@"object_name"];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    title.numberOfLines = 1;
    [scroll addSubview:title];
    [title sizeToFit];
    
    UILabel* calories = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+30, dWidth - 35, 50)];
    calories.text = [NSString stringWithFormat:@"Calories: %@",json[@"result"][@"data"][@"fields"][@"nf_calories"]];
    calories.textColor = [UIColor whiteColor];
    calories.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    calories.numberOfLines = 1;
    [scroll addSubview:calories];
    [calories sizeToFit];
    
    UIView* bar = [[UIView alloc] initWithFrame:CGRectMake(20, margin+55, dWidth - 35, 1)];
    bar.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:bar];
    
    NSLog(@"function over");
}

-(void) sendRequest:(NSURLRequest*) request
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error,%@", [error localizedDescription]);
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self giveData:data];
//                 bg.backgroundColor = [UIColor blueColor];
                 NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
             });
         }
     }];
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

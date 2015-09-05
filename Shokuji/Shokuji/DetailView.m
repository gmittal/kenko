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
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    
    margin = 400;
    bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    bg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bg];
    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    scroll.contentSize = CGSizeMake(dWidth, dHeight+10);
    [self.view addSubview:scroll];
    [scroll setShowsVerticalScrollIndicator:NO];
    
    [scroll addGestureRecognizer:swipeUpGestureRecognizer];
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
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+5, dWidth - 105, 20)];
    title.text = json[@"result"][@"object_name"];
//    title.text = @"adjasd asd asdas dasd sad sad as das das dsad";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
//    title.numberOfLines = 1;
    title.adjustsFontSizeToFitWidth = NO;
    title.lineBreakMode = NSLineBreakByTruncatingTail;
    [scroll addSubview:title];
//    [title sizeToFit];
    
    UILabel* calories = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+5, dWidth - 35, 20)];
    calories.text = [NSString stringWithFormat:@"%@ cal",json[@"result"][@"data"][@"fields"][@"nf_calories"]];
    calories.textAlignment = NSTextAlignmentRight;
    calories.textColor = [UIColor whiteColor];
    calories.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    calories.numberOfLines = 1;
    [scroll addSubview:calories];
//    [calories sizeToFit];
    
    UILabel* serving = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+25, dWidth - 35, 20)];
    serving.text = [NSString stringWithFormat:@"serving size: %@ %@",json[@"result"][@"data"][@"fields"][@"nf_serving_size_qty"],json[@"result"][@"data"][@"fields"][@"nf_serving_size_unit"]];
    serving.textAlignment = NSTextAlignmentLeft;
    serving.textColor = [UIColor whiteColor];
    serving.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    serving.numberOfLines = 1;
    [scroll addSubview:serving];
    
    UILabel* confidence = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+25, dWidth - 35, 20)];
    confidence.text = [NSString stringWithFormat:@"%@ confidence",json[@"result"][@"confidence"]];
    confidence.textAlignment = NSTextAlignmentRight;
    confidence.textColor = [UIColor whiteColor];
    confidence.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    confidence.numberOfLines = 1;
    [scroll addSubview:confidence];
    
    UIView* bar = [[UIView alloc] initWithFrame:CGRectMake(20, margin+45, dWidth - 35, 1)];
    bar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [scroll addSubview:bar];
    
    UILabel* fat = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+50, dWidth - 35, 20)];
    fat.text = [NSString stringWithFormat:@"total fat: %@",json[@"result"][@"data"][@"fields"][@"nf_total_fat"]];
    fat.textAlignment = NSTextAlignmentLeft;
    fat.textColor = [UIColor whiteColor];
    fat.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:fat];
    
    UILabel* sat = [[UILabel alloc] initWithFrame:CGRectMake(30,margin+65, dWidth - 35, 20)];
    sat.text = [NSString stringWithFormat:@"saturated fat: %@",json[@"result"][@"data"][@"fields"][@"nf_saturated_fat"]];
    sat.textAlignment = NSTextAlignmentLeft;
    sat.textColor = [UIColor whiteColor];
    sat.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:sat];
    
    UILabel* trans = [[UILabel alloc] initWithFrame:CGRectMake(30,margin+80, dWidth - 35, 20)];
    trans.text = [NSString stringWithFormat:@"trans fat: %@",json[@"result"][@"data"][@"fields"][@"nf_trans_fatty_acid"]];
    trans.textAlignment = NSTextAlignmentLeft;
    trans.textColor = [UIColor whiteColor];
    trans.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:trans];
    
    UILabel* cholestrol = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+95, dWidth - 35, 20)];
    cholestrol.text = [NSString stringWithFormat:@"cholestrol: %@",json[@"result"][@"data"][@"fields"][@"nf_cholesterol"]];
    cholestrol.textAlignment = NSTextAlignmentLeft;
    cholestrol.textColor = [UIColor whiteColor];
    cholestrol.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:cholestrol];
    
    UILabel* sodium = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+110, dWidth - 35, 20)];
    sodium.text = [NSString stringWithFormat:@"sodium: %@",json[@"result"][@"data"][@"fields"][@"nf_sodium"]];
    sodium.textAlignment = NSTextAlignmentLeft;
    sodium.textColor = [UIColor whiteColor];
    sodium.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:sodium];
    
    UILabel* protein = [[UILabel alloc] initWithFrame:CGRectMake(20,margin+125, dWidth - 35, 20)];
    protein.text = [NSString stringWithFormat:@"protein: %@",json[@"result"][@"data"][@"fields"][@"nf_protein"]];
    protein.textAlignment = NSTextAlignmentLeft;
    protein.textColor = [UIColor whiteColor];
    protein.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:protein];
    
    UILabel* carb = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+50, dWidth - 35, 20)];
    carb.text = [NSString stringWithFormat:@"total carbs: %@",json[@"result"][@"data"][@"fields"][@"nf_total_carbohydrate"]];
    carb.textAlignment = NSTextAlignmentLeft;
    carb.textColor = [UIColor whiteColor];
    carb.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:carb];
    
    UILabel* diet = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+65, dWidth - 35, 20)];
    diet.text = [NSString stringWithFormat:@"dietary fiber: %@",json[@"result"][@"data"][@"fields"][@"nf_dietary_fiber"]];
    diet.textAlignment = NSTextAlignmentLeft;
    diet.textColor = [UIColor whiteColor];
    diet.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:diet];
    
    UILabel* sugar = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+80, dWidth - 35, 20)];
    sugar.text = [NSString stringWithFormat:@"sugars: %@",json[@"result"][@"data"][@"fields"][@"nf_sugars"]];
    sugar.textAlignment = NSTextAlignmentLeft;
    sugar.textColor = [UIColor whiteColor];
    sugar.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [scroll addSubview:sugar];
    
    
    
    UIView* support = [[UIView alloc] initWithFrame:CGRectMake((dWidth-10)/2, margin+50, 1, 100)];
    support.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [scroll addSubview:support];
    
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
    [self close];
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

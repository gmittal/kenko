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
    UIImageView* imageView;
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

-(void) setImage:(UIImage*)theimg
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    imageView.image = theimg;
    [self.view insertSubview:imageView atIndex:0];
}

-(void) viewDidAppear:(BOOL)animated
{
    
    
//    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
//    swipeUpGestureRecognizer.delegate = self;
//    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    UIPanGestureRecognizer *dragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandler:)];
//    [self.view addGestureRecognizer:dragGestureRecognizer];
    dragGestureRecognizer.delegate = self;
    
    
    margin = 300;
    bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:bg];
    
    
    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    scroll.contentSize = CGSizeMake(dWidth, dHeight+10);
    [self.view addSubview:scroll];
    [scroll setShowsVerticalScrollIndicator:NO];
    
    [scroll addGestureRecognizer:dragGestureRecognizer];
//    [scroll sets]
    
    float sidem = 0;
    popup = [[UIView alloc] initWithFrame:CGRectMake(0, margin, dWidth, dHeight-margin)];
    popup.backgroundColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.50];
    [scroll addSubview:popup];
    
    UIView* leftbridge = [[UIView alloc] initWithFrame:CGRectMake(-100, 0, 100, dHeight)];
    [self.view addSubview:leftbridge];
    CAGradientLayer *gradient3 = [CAGradientLayer layer];
    gradient3.frame = leftbridge.bounds;
    gradient3.startPoint = CGPointMake(0.0, 0.5);
    gradient3.endPoint = CGPointMake(1.0, 0.5);
    gradient3.cornerRadius = 7;
    gradient3.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.0] CGColor], (id)[[[UIColor blackColor] colorWithAlphaComponent:0.8] CGColor], nil];
    [leftbridge.layer insertSublayer:gradient3 atIndex:0];
    
    
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

-(void)dragHandler:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint vel;
    vel = [recognizer translationInView:self.view];
    NSLog(@"%f",vel.x);
    
    if(vel.x > 0)
    {
        self.view.frame = CGRectMake(vel.x, 0, dWidth, dHeight);
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if(vel.x < 200 && vel.x > -200)
        {
            [UIView animateWithDuration:0.6 animations:^{
                self.view.frame = CGRectMake(0, 0, dWidth, dHeight);
            }];
        }
        if(vel.x > 200)
        {
            [UIView animateWithDuration:0.6 animations:^{
                self.view.frame = CGRectMake(320, 0, dWidth, dHeight);
            } completion:^(BOOL finished){
                [self close];
            }];
            
        }
    }
    
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
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+5, dWidth - 105, 20)];
    title.text = json[@"result"][@"object_name"];
//    title.text = @"adjasd asd asdas dasd sad sad as das das dsad";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"Roboto-Bold" size:20];
//    title.numberOfLines = 1;
    title.adjustsFontSizeToFitWidth = NO;
    title.lineBreakMode = NSLineBreakByTruncatingTail;
    [scroll addSubview:title];
//    [title sizeToFit];
    
    UILabel* calories = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+5, dWidth - 20, 20)];
    calories.text = [NSString stringWithFormat:@"%@ cal",json[@"result"][@"data"][@"fields"][@"nf_calories"]];
    calories.textAlignment = NSTextAlignmentRight;
    calories.textColor = [UIColor whiteColor];
    calories.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:20];
    calories.numberOfLines = 1;
    [scroll addSubview:calories];
//    [calories sizeToFit];
    
    UILabel* serving = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+25, dWidth - 20, 20)];
    serving.text = [NSString stringWithFormat:@"Serving Size: %@ %@",json[@"result"][@"data"][@"fields"][@"nf_serving_size_qty"],json[@"result"][@"data"][@"fields"][@"nf_serving_size_unit"]];
    serving.textAlignment = NSTextAlignmentLeft;
    serving.textColor = [UIColor whiteColor];
    serving.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    serving.numberOfLines = 1;
    [scroll addSubview:serving];
    
    UILabel* confidence = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+25, dWidth - 20, 20)];
    confidence.text = [NSString stringWithFormat:@"Confidence: %@",json[@"result"][@"confidence"]];
    confidence.textAlignment = NSTextAlignmentRight;
    confidence.textColor = [UIColor whiteColor];
    confidence.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    confidence.numberOfLines = 1;
    [scroll addSubview:confidence];
    
    UIView* bar = [[UIView alloc] initWithFrame:CGRectMake(0, margin+50, dWidth, 2)];
    bar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    [scroll addSubview:bar];
    
    UILabel* fat = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+55, dWidth - 35, 20)];
    fat.text = [NSString stringWithFormat:@"total fat: %@",json[@"result"][@"data"][@"fields"][@"nf_total_fat"]];
    fat.textAlignment = NSTextAlignmentLeft;
    fat.textColor = [UIColor whiteColor];
    fat.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:fat];
    
    UILabel* sat = [[UILabel alloc] initWithFrame:CGRectMake(30,margin+75, dWidth - 35, 20)];
    sat.text = [NSString stringWithFormat:@"saturated fat: %@",json[@"result"][@"data"][@"fields"][@"nf_saturated_fat"]];
    sat.textAlignment = NSTextAlignmentLeft;
    sat.textColor = [UIColor whiteColor];
    sat.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:sat];
    
    UILabel* trans = [[UILabel alloc] initWithFrame:CGRectMake(30,margin+95, dWidth - 35, 20)];
    trans.text = [NSString stringWithFormat:@"trans fat: %@",json[@"result"][@"data"][@"fields"][@"nf_trans_fatty_acid"]];
    trans.textAlignment = NSTextAlignmentLeft;
    trans.textColor = [UIColor whiteColor];
    trans.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:trans];
    
    UILabel* cholestrol = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+115, dWidth - 35, 20)];
    cholestrol.text = [NSString stringWithFormat:@"cholestrol: %@",json[@"result"][@"data"][@"fields"][@"nf_cholesterol"]];
    cholestrol.textAlignment = NSTextAlignmentLeft;
    cholestrol.textColor = [UIColor whiteColor];
    cholestrol.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:cholestrol];
    
    UILabel* sodium = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+135, dWidth - 35, 20)];
    sodium.text = [NSString stringWithFormat:@"sodium: %@",json[@"result"][@"data"][@"fields"][@"nf_sodium"]];
    sodium.textAlignment = NSTextAlignmentLeft;
    sodium.textColor = [UIColor whiteColor];
    sodium.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:sodium];
    
    
    
    UILabel* carb = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+55, dWidth - 35, 20)];
    carb.text = [NSString stringWithFormat:@"total carbs: %@",json[@"result"][@"data"][@"fields"][@"nf_total_carbohydrate"]];
    carb.textAlignment = NSTextAlignmentLeft;
    carb.textColor = [UIColor whiteColor];
    carb.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:carb];
    
    UILabel* diet = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+75, dWidth - 35, 20)];
    diet.text = [NSString stringWithFormat:@"dietary fiber: %@",json[@"result"][@"data"][@"fields"][@"nf_dietary_fiber"]];
    diet.textAlignment = NSTextAlignmentLeft;
    diet.textColor = [UIColor whiteColor];
    diet.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:diet];
    
    UILabel* sugar = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+95, dWidth - 35, 20)];
    sugar.text = [NSString stringWithFormat:@"sugars: %@",json[@"result"][@"data"][@"fields"][@"nf_sugars"]];
    sugar.textAlignment = NSTextAlignmentLeft;
    sugar.textColor = [UIColor whiteColor];
    sugar.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:sugar];
    
    UILabel* protein = [[UILabel alloc] initWithFrame:CGRectMake(10 + dWidth/2,margin+115, dWidth - 35, 20)];
    protein.text = [NSString stringWithFormat:@"protein: %@",json[@"result"][@"data"][@"fields"][@"nf_protein"]];
    protein.textAlignment = NSTextAlignmentLeft;
    protein.textColor = [UIColor whiteColor];
    protein.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:15];
    [scroll addSubview:protein];
    
    UIButton* order = [[UIButton alloc] initWithFrame:CGRectMake(0, margin+164, dWidth, 50)];
    order.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:order];
    
    UILabel* orderlabel = [[UILabel alloc] initWithFrame:order.frame];
    orderlabel.text = @"Order This For Me";
    orderlabel.textAlignment = NSTextAlignmentCenter;
    orderlabel.textColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.65];
    orderlabel.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:18];
    [scroll addSubview:orderlabel];
    
    UIButton* health = [[UIButton alloc] initWithFrame:CGRectMake(0, margin+218, dWidth, 50)];
    health.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:health];
    
    UILabel* healthLabel = [[UILabel alloc] initWithFrame:health.frame];
    healthLabel.text = @"Save to Health Kit";
    healthLabel.textAlignment = NSTextAlignmentCenter;
    healthLabel.textColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.65];
    healthLabel.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:18];
    [scroll addSubview:healthLabel];
    
    UIView* support = [[UIView alloc] initWithFrame:CGRectMake(dWidth/2, margin+50, 2, 130)];
    support.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
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
    [self dismissViewControllerAnimated:NO completion:^{}];

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

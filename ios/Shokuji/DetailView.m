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
#import <HealthKit/HealthKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DetailView ()

@end

#define dWidth self.view.frame.size.width
#define dHeight self.view.frame.size.height

@implementation DetailView
{
    UIImage* image;
    UIImageView* imageView;
    BALoadingView* loadingView;
    UIImageView* popup;
    UIView* bg;
    float margin;
    ViewController* myParent;
    UIScrollView* scroll;
    UILabel* loadLabel;
    UILabel* title;
    UIView* tbar;
    
    UIImageView* facts;
    UIView* factsbg;
    
    NSString* foodname;
    NSString* city;
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
    
    
    margin = 0;
    bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:bg];
    
    
    
//    tbar = [[UIView alloc] initWithFrame:CGRectMake(100, -10+80, self.view.frame.size.width - 200, 2)];
//    tbar.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:tbar];
    
    
    
    scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    scroll.contentSize = CGSizeMake(dWidth, dHeight+10);
    [self.view addSubview:scroll];
    [scroll setShowsVerticalScrollIndicator:NO];
    
    [scroll addGestureRecognizer:dragGestureRecognizer];
//    [scroll sets]
    
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(0, -10, self.view.frame.size.width, 100)];
    title.font = [UIFont fontWithName:@"Hybrea" size:40];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.text = @"kenko";
    [self.view addSubview:title];
    
    
    
    float sidem = 0;
    popup = [[UIImageView alloc] initWithFrame:CGRectMake(0, margin+dHeight, dWidth, dHeight-margin)];
    popup.image = [UIImage imageNamed:@"kenko-gradient.png"];
    popup.layer.opacity = 0.65;
    [scroll addSubview:popup];
    
//    UIView* leftbridge = [[UIView alloc] initWithFrame:CGRectMake(-100, 0, 100, dHeight)];
//    [self.view addSubview:leftbridge];
//    CAGradientLayer *gradient3 = [CAGradientLayer layer];
//    gradient3.frame = leftbridge.bounds;
//    gradient3.startPoint = CGPointMake(0.0, 0.5);
//    gradient3.endPoint = CGPointMake(1.0, 0.5);
//    gradient3.cornerRadius = 7;
//    gradient3.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.0] CGColor], (id)[[[UIColor blackColor] colorWithAlphaComponent:0.8] CGColor], nil];
//    [leftbridge.layer insertSublayer:gradient3 atIndex:0];
    
    
    float loadsize = 100;
    loadingView = [[BALoadingView alloc] initWithFrame:CGRectMake((dWidth-sidem*2)/2 - loadsize/2, dHeight/2 - loadsize, loadsize, loadsize)];
    [popup addSubview:loadingView];
    loadingView.segmentColor = [UIColor whiteColor];
    [loadingView initialize];
    [loadingView startAnimation:BACircleAnimationFullCircle];
    
    loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, dHeight/2 + loadsize/2, (dWidth-sidem*2), 30)];
    loadLabel.text = @"Processing Image";
    loadLabel.textColor = [UIColor whiteColor];
    loadLabel.font = [UIFont fontWithName:@"Roboto Light" size:22.0f];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    [popup addSubview:loadLabel];
    
    [UIView animateWithDuration:0.6 animations:^{
        popup.frame = CGRectMake(0, margin, dWidth, dHeight-margin);
    }];
    
    
//    [self performSelector:@selector(callback) withObject:nil afterDelay:3];

}

-(void)dragHandler:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint vel;
    vel = [recognizer translationInView:self.view];
    NSLog(@"%f",vel.x);
    
    if(vel.x > 0)
    {
        self.view.frame = CGRectMake(vel.x, 0, dWidth, dHeight);
        imageView.layer.opacity = (200-vel.x)/200.0;
        bg.layer.opacity = (200-vel.x)/200.0;
        title.layer.opacity = (200-vel.x)/200.0;
        tbar.layer.opacity = (200-vel.x)/200.0;
        factsbg.layer.opacity = (200-vel.x)/200.0;
        facts.layer.opacity = (200-vel.x)/200.0;
        popup.layer.opacity = (200-vel.x)*0.65/200.0;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if(vel.x < 100 && vel.x > -100)
        {
            [UIView animateWithDuration:0.6 animations:^{
                self.view.frame = CGRectMake(0, 0, dWidth, dHeight);
                imageView.layer.opacity = 1;
                bg.layer.opacity = 1;
                title.layer.opacity = 1;
                tbar.layer.opacity = 1;
                factsbg.layer.opacity = 1;
                facts.layer.opacity = 1;
                popup.layer.opacity = 0.65;
            }];
        }
        if(vel.x > 100)
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
    
   
    
    
    //    scroll.contentSize = CGSizeMake(dWidth, 2000);
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [self setJson:jsonString];
    
}

-(void) setJson:(NSString*) jsonString
{
    
    [loadingView removeFromSuperview];
    [loadLabel removeFromSuperview];
    
     NSDate   *now = [NSDate date];
    
    NSData *tdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:tdata options:0 error:nil];

    if(json[@"NUTRITION_LABEL"] != NULL)
    {
        
        UIImage *imagef = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:json[@"NUTRITION_LABEL"]]]];
        
        facts = [[UIImageView alloc] initWithImage:image];
//        float ratio = (dWidth - 40.0) / json[@"width"];
//        NSLog(@"%f",ratio);
        NSLog(@" image %@",json[@"height"]);
        facts.frame = CGRectMake(20,100,dWidth-40, 400 );
//        facts.frame = CGRectMake(30, 30, 200, 200);
        facts.image = imagef;
        
        
        factsbg = [[UIView alloc] initWithFrame:CGRectMake(20, 100, dWidth-40, 400)];
        factsbg.backgroundColor = [UIColor whiteColor];
        factsbg.layer.cornerRadius = 10;
        
        [scroll addSubview:factsbg];
        [scroll addSubview:facts];

        
        NSLog(@"function over");
        
    }
    else if(json[@"Scan_Error"] != NULL)
    {
        UILabel* sry = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+35, dWidth - 20, 70)];
        sry.text = @"Uh oh.";
        sry.textAlignment = NSTextAlignmentCenter;
        sry.textColor = [UIColor whiteColor];
        sry.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:60];
        [scroll addSubview:sry];
        
        UILabel* detail = [[UILabel alloc] initWithFrame:CGRectMake(60,margin+90, dWidth - 120, 100)];
        detail.text = json[@"Scan_Error"];
        detail.textAlignment = NSTextAlignmentCenter;
        detail.textColor = [UIColor whiteColor];
        detail.numberOfLines = 3;
        detail.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:20];
        [scroll addSubview:detail];
        
        float sidem = 100;
        UIButton* retry = [[UIButton alloc] initWithFrame:CGRectMake(sidem, margin+200, dWidth - sidem*2, 40)];
        retry.layer.cornerRadius = 20;
        retry.backgroundColor = [UIColor whiteColor];
        [scroll addSubview:retry];
        
        UILabel* desc = [[UILabel alloc] initWithFrame:retry.frame];
        desc.text = @"Try Again";
        desc.textAlignment = NSTextAlignmentCenter;
        desc.textColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.50];
        //        desc.numberOfLines = 3;
        desc.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:20];
        [scroll addSubview:desc];
        [retry addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
//        UILabel* sry = [[UILabel alloc] initWithFrame:CGRectMake(10,margin+35, dWidth - 20, 70)];
//        sry.text = @"Sorry.";
//        sry.textAlignment = NSTextAlignmentCenter;
//        sry.textColor = [UIColor whiteColor];
//        sry.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:60];
//        [scroll addSubview:sry];
        
        UIImageView* cross = [[UIImageView alloc] initWithFrame:CGRectMake(dWidth/2 - 70, 120, 140, 140)];
        cross.image = [UIImage imageNamed:@"ios7-close-outline.png"];
        [scroll addSubview:cross];
        
        UILabel* detail = [[UILabel alloc] initWithFrame:CGRectMake(30,margin+250, dWidth - 60, 100)];
        detail.text = @"There was an error processing the image.";
        detail.textAlignment = NSTextAlignmentCenter;
        detail.textColor = [UIColor whiteColor];
        detail.numberOfLines = 3;
        detail.font = [UIFont fontWithName:@"Roboto Light" size:22];
        [scroll addSubview:detail];
        
//        float sidem = 100;
//        UIButton* retry = [[UIButton alloc] initWithFrame:CGRectMake(sidem, margin+200, dWidth - sidem*2, 40)];
//        retry.layer.cornerRadius = 20;
//        retry.backgroundColor = [UIColor whiteColor];
//        [scroll addSubview:retry];
        
        
        UIButton* button2 = [[UIButton alloc] initWithFrame:CGRectMake(80, margin+400, self.view.frame.size.width - 160, 40)];
        button2.layer.cornerRadius = 20;
        button2.backgroundColor = [UIColor colorWithRed:68/255.0 green:138/255.0 blue:255/255.0 alpha:1];
        [self.view addSubview:button2];
        
        UILabel* label2 = [[UILabel alloc] initWithFrame:button2.frame];
        label2.font = [UIFont fontWithName:@"Avenir Next" size:16];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.textColor = [UIColor whiteColor];
        label2.text = @"Try Again";
        [self.view addSubview:label2];
        [button2 addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}


-(void) search
{
    NSLog(@"searching");
    NSString* url = [NSString stringWithFormat:@"http://www.yelp.com/search?find_desc=%@",[foodname stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSLog(url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
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
    if(myParent != NULL)
    {
        [myParent reload];
    }
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

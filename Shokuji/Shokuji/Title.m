//
//  Title.m
//  Shokuji
//
//  Created by Kevin Frans on 9/5/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "Title.h"
#import "ViewController.h"
#import "DetailView.h"
#import <AVFoundation/AVFoundation.h>

@interface Title ()

@end

@implementation Title
{
    UIButton* button1;
    UIButton* button2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [session addInput:input];
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    newCaptureVideoPreviewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //    newCaptureVideoPreviewLayer.la
    [self.view.layer addSublayer:newCaptureVideoPreviewLayer];
    [session startRunning];
    
    UIView* overlay = [[UIView alloc] initWithFrame:self.view.frame];
    overlay.backgroundColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.65];
    [self.view addSubview:overlay];
    
    UIView* overlay2 = [[UIView alloc] initWithFrame:self.view.frame];
    overlay2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    [self.view addSubview:overlay2];
    
    float margin = 160;
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, margin, self.view.frame.size.width, 100)];
    title.font = [UIFont fontWithName:@"Roboto-Bold" size:50];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.text = @"kenko";
    [self.view addSubview:title];
    
    UIView* bar = [[UIView alloc] initWithFrame:CGRectMake(80, margin+80, self.view.frame.size.width - 160, 2)];
    bar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bar];
    
    button1 = [[UIButton alloc] initWithFrame:CGRectMake(80, margin+110, self.view.frame.size.width - 160, 40)];
    button1.layer.cornerRadius = 20;
    button1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:button1];
    
    UILabel* label1 = [[UILabel alloc] initWithFrame:button1.frame];
    label1.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:20];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.65];
    label1.text = @"Take a Photo";
    [self.view addSubview:label1];
    [button1 addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];

    
    button2 = [[UIButton alloc] initWithFrame:CGRectMake(80, margin+160, self.view.frame.size.width - 160, 40)];
    button2.layer.cornerRadius = 20;
    button2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:button2];
    
    UILabel* label2 = [[UILabel alloc] initWithFrame:button2.frame];
    label2.font = [UIFont fontWithName:@"RobotoCondensed-Light" size:20];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor colorWithRed:242/255.0 green:38/255.0 blue:9/255.0 alpha:0.65];
    label2.text = @"Choose Photo";
    [self.view addSubview:label2];
    [button2 addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) takePhoto
{
    ViewController* vc = [[ViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [self.view addSubview:vc.view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:NO completion:^{}];
    });
}


-(void) choosePhoto
{
    FSMediaPicker *picker = [[FSMediaPicker alloc] init];
    picker.delegate = self;
//    picker.
    [picker showFromView:self.view];
    
    

}


- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo
{
    
    NSLog(@"pick");
    
    NSData *imageData2 = UIImageJPEGRepresentation(mediaInfo.editedImage, 1.0);
    NSString *encodedString = [imageData2 base64Encoding];
    
    
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //         NSLog(encodedString);
    
    NSString *post = [NSString stringWithFormat:@"image=%@",encodedString];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://usekenko.co/food-analysis"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    
    DetailView* dv = [[DetailView alloc] init];
    [dv setParent:self];
    dv.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:dv animated:NO completion:^{}];
    
    [dv sendRequest:request];
    [dv setImage:mediaInfo.editedImage];
//    [picker dismissViewControllerAnimated:YES completion:nil];
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

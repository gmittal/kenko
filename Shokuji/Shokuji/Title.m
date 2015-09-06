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
#import "Newspaper.h"

@interface Title ()

@end

@implementation Title
{
    UIButton* button1;
    UIButton* button2;
    UIImagePickerController* imagePicker;
    NSMutableData *responseData;
    id json;
    NSString* jsondata;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[responseData
                                                   length]);
    NSString *txt = [[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding];
    jsondata = txt;
    if([jsondata isEqualToString:@"No new content."])
    {
        
    }
    else
    {
//    NSLog(@"%@",txt);
    NSData *tdata = [txt dataUsingEncoding:NSUTF8StringEncoding];
    json = [NSJSONSerialization JSONObjectWithData:tdata options:0 error:nil];
    
    
    [self showNews];
    }
//    NSLog(@"%@",json);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *myURL = [NSURL URLWithString:@"http://507288d1.ngrok.io/saved-user-data"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    [button2 addTarget:self action:@selector(showNews) forControlEvents:UIControlEventTouchUpInside];
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


-(void) showNews
{
        Newspaper* news = [[Newspaper alloc] init];
        [self presentViewController:news animated:NO completion:^{}];
        [news giveJson:jsondata];
}


-(void) choosePhoto
{
    imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData2 = UIImageJPEGRepresentation(selectedImage, 1.0);
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
    
    [imagePicker dismissModalViewControllerAnimated:YES];
    
    DetailView* dv = [[DetailView alloc] init];
//    [dv setParent:self];
    dv.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:dv animated:NO completion:^{}];
    
    [dv sendRequest:request];
    [dv setImage:selectedImage];
    
}


- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo
{
    
    NSLog(@"pick");
    
    
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

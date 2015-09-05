//
//  ViewController.m
//  Shokuji
//
//  Created by Kevin Frans on 9/4/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "ViewController.h"
#import "DetailView.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>


@interface ViewController ()

@end

@implementation ViewController
{
    AVCaptureStillImageOutput* stillImageOutput;
    UIImageView* capturedView;
    UIButton* capture;
    UILabel* label;
}

#define dWidth self.view.frame.size.width
#define dHeight self.view.frame.size.height

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
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
    newCaptureVideoPreviewLayer.frame = CGRectMake(0, 0, dWidth, dHeight);
//    newCaptureVideoPreviewLayer.la
    [self.view.layer addSublayer:newCaptureVideoPreviewLayer];
    [session startRunning];
    
    capturedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
//    capturedView.image = image;
    [self.view addSubview:capturedView];

    
    

    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
    
    float gradHeight = 100;
    UIView *bottomGrad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, dHeight - gradHeight, dWidth, gradHeight)];
    [self.view addSubview:bottomGrad];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = bottomGrad.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor], nil];
    [bottomGrad.layer insertSublayer:gradient atIndex:0];
    
    UIView *topGrad = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0, dWidth, gradHeight)];
    [self.view addSubview:topGrad];
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = bottomGrad.bounds;
    gradient2.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [topGrad.layer insertSublayer:gradient2 atIndex:0];
    
    float width = 75;
    float height = 75;
    capture = [[UIButton alloc] initWithFrame:CGRectMake(dWidth/2 - (width/2), dHeight - height*1.3, width, height)];
    capture.layer.cornerRadius = 75/2.0;
    capture.layer.borderColor = [[UIColor whiteColor] CGColor];
    capture.layer.borderWidth= 1;
    
    capture.backgroundColor = [UIColor clearColor];
    
    label = [[UILabel alloc] initWithFrame:capture.frame];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    [self.view addSubview:label];
    label.text = @"SHOKU";
    
    [self.view addSubview:capture];
    
    [capture addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    

//    UIImageView* cameraview
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) capture
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
//             NSLog(@"attachements: %@", exifAttachments);
         } else {
             NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         capturedView.image = image;
         label.layer.opacity = 0;
         capture.layer.opacity = 0;
         
         
         NSData *imageData2 = UIImageJPEGRepresentation(image, 1.0);
         NSString *encodedString = [imageData2 base64Encoding];
         
         
         encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
         
//         NSLog(encodedString);
         
         NSString *post = [NSString stringWithFormat:@"image=%@",encodedString];
         NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
         
         NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
         
         NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
         [request setURL:[NSURL URLWithString:@"http://6d2a06c5.ngrok.io/food-analysis"]];
         [request setHTTPMethod:@"POST"];
         [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
         [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
         [request setHTTPBody:postData];
         
         NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

         
//         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
         [self flashScreen];
     }];
}


-(void) reload
{
    capturedView.image = NULL;
    label.layer.opacity = 1;
    capture.layer.opacity = 1;
}


-(void) flashScreen {
    UIView* v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, dWidth, dHeight)];
    [self.view addSubview: v];
    v.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.2 delay:0.0 options:
     UIViewAnimationOptionCurveEaseIn animations:^{
         v.backgroundColor = [UIColor clearColor];
     } completion:^ (BOOL completed) {
         [v removeFromSuperview];
         [self detailScreen];
     }];
}

-(void) detailScreen
{
    DetailView* dv = [[DetailView alloc] init];
    [dv setParent:self];
    dv.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:dv animated:NO completion:^{}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  Shokuji
//
//  Created by Kevin Frans on 9/4/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "ViewController.h"
#import "DetailView.h"
#import "ZXingObjC.h"
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



-(BOOL) barcode:(UIImage*) image
{
    CGImageRef imageToDecode = image.CGImage;  // Given a CGImage in which we are looking for barcodes
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (result) {
        // The coded result as a string. The raw data can be accessed with
        // result.rawBytes and result.length.
        NSString *contents = result.text;
        
        // The barcode format, such as a QR code or UPC-A
        ZXBarcodeFormat format = result.barcodeFormat;
        
        NSLog(@"barcode");
        
        return true;
    } else {
        NSLog(@"no code");
        
        return false;
        // Use error to determine why we didn't get a result, such as a barcode
        // not being found, an invalid checksum, or a format inconsistency.
    }
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
         
         if(![self barcode:image])
         {
         
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
         
         

         DetailView* dv = [[DetailView alloc] init];
         [dv setParent:self];
         dv.modalPresentationStyle = UIModalPresentationOverCurrentContext;
         self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
         
         [dv sendRequest:request];
         
         
         UIView* v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, dWidth, dHeight)];
         [self.view addSubview: v];
         v.backgroundColor = [UIColor whiteColor];
         [UIView animateWithDuration:0.2 delay:0.0 options:
          UIViewAnimationOptionCurveEaseIn animations:^{
              v.backgroundColor = [UIColor clearColor];
          } completion:^ (BOOL completed) {
              [v removeFromSuperview];
              [self presentViewController:dv animated:NO completion:^{}];
          }];
             
             
         }
     }];
}


-(void) reload
{
    capturedView.image = NULL;
    label.layer.opacity = 1;
    capture.layer.opacity = 1;
}


-(void) flashScreen {
    
}

-(void) detailScreen
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

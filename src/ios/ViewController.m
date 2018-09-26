//
//  ViewController.m
//  libTest
//
//  Created by 65-0A40338-01 on 2017/3/21.
//  Copyright © 2017年 65-0A40338-01. All rights reserved.
//

#import "ViewController.h"
#import "LightCodeOOKLibrary.h"

@interface ViewController (){
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    LightCodeOOKLibrary *lib;
    __weak IBOutlet UIView *scanView;
    __weak IBOutlet UILabel *resultView;
    __weak IBOutlet UIButton *cancelButton;
    __weak IBOutlet UIButton *switchButton;
    __weak IBOutlet UIImageView *customImageView;
    __weak IBOutlet UIWebView *customWebIMageView;
    
    NSString *strScan;
    float scanFontSize;
    int camera_num;
    double flash_timeer;
    Boolean bEnableFlash;
    Boolean bSwitchButtonShowHide;
    NSString *strCustomImage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View Controller load camera %d", camera_num);
    // init libOCC
    lib = [[LightCodeOOKLibrary alloc]init];
    //init captureSession
    captureSession = [lib LCcameraControl:captureSession cameraLocation:camera_num];
    
    if(captureSession != NULL){
        //Add outputStream to captureSession
        [self setVideoOutput];
        //Set captureSession Preview
        [self setPreviewLayer];
        //Start running
        [captureSession startRunning];
    }
}

- ( void )viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ( captureSession ){
        [captureSession startRunning];
    }
}
    
- ( void )viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ( captureSession ){
        [captureSession stopRunning];
    }
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    //NSLog(@"frame dropped.");
    
}

//UInt64 startTime=0;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    NSString *res = [lib readLC:sampleBuffer];
    if(res){
        dispatch_async(dispatch_get_main_queue(), ^{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            NSLog(@"LightCode ID is %@",res);
        //    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
        //    [resultView setText:[NSString stringWithFormat:@"Result: %@ %4llu",res,(recordTime-startTime)]];
        //    startTime = recordTime;
            [resultView setText:[NSString stringWithFormat:@"Result: %@",res]];
            //result scan result;
            [delegate scanViewResult:res];
        });
    }
    
}
- (void)setPreviewLayer{
    
    [scanView setTranslatesAutoresizingMaskIntoConstraints:NO];
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    previewLayer.frame = scanView.bounds;
    [scanView.layer addSublayer:previewLayer];
    CGRect bounds = self.view.layer.bounds;
    [previewLayer setBounds:bounds];
    [previewLayer setPosition:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    [scanView.layer addSublayer:previewLayer];
    //
    if (bEnableFlash && flash_timeer != 0.0) {
        if (strScan == NULL) {
            [resultView setText:[NSString stringWithFormat:@"Scaning ..."]];
        }
        else {
            [resultView setText:strScan];
        }
        resultView.alpha = 1;
        [UIView animateWithDuration:flash_timeer delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            resultView.alpha = 0;
        } completion:nil];
    }
}

- (void)setVideoOutput{
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureConnection *videoConnection;
    
    videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],(id)kCVPixelBufferPixelFormatTypeKey, //YUV, '420f'
                                       nil]];
    
    videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    dispatch_queue_t queue = dispatch_queue_create("videoGetQueue", NULL);
    [videoDataOutput setSampleBufferDelegate:self queue:queue];
    videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [captureSession addOutput:videoDataOutput];
}

-(void) setCloseString:(NSString *)strClose {
    
}

-(void) setScaningString:(NSString *)strScaning :(NSString*)fontSize {
    strScan = [NSString stringWithFormat:@"%@", strScaning];
    scanFontSize = [fontSize floatValue];
    //[resultView.layer removeAllAnimations];
    [resultView setText:strScan];
    [resultView setFont:[UIFont systemFontOfSize:scanFontSize]];
    [resultView setNeedsDisplay];
}

-(void) setCameraNum:(NSString *)strCameraNum {
    camera_num = 1;
    NSString* temp = [NSString stringWithFormat:@"%@", strCameraNum];
    if ([temp isEqual:@"0"]) {
        camera_num = 0;
    }
    NSLog(@"setCameraNum %@, %d", strCameraNum , camera_num);
}

-(void) setFlashTimer:(NSString*)strTimer : (NSString*)strEnableFlash {
    bEnableFlash = true;
    NSString* temp = [NSString stringWithFormat:@"%@", strEnableFlash];
    if ([temp isEqual:@"0"]) {
        bEnableFlash = false;
    }
    flash_timeer = [strTimer doubleValue];
    NSLog(@"setFlashTimer %@, %f", strTimer , flash_timeer);
}

-(void) isShowHideSwitchButton:(NSString*)strShow {
    
    NSLog(@"isShowHideSwitchButton %@", strShow);
    
    NSString* temp = [NSString stringWithFormat:@"%@", strShow];
    if ([temp isEqual:@"0"]) {
        bSwitchButtonShowHide = false;
        switchButton.enabled = false;
        switchButton.hidden = true;
    }
    else {
        bSwitchButtonShowHide = true;
    }
}

-(void) setCustomImage:(NSString *)strImage {
    strCustomImage = [NSString stringWithFormat:@"%@", strImage];
    NSLog(@"setCustomImage %@", strCustomImage);
    if ([strCustomImage length] == 0) {
        //[customImageView setHidden:TRUE];
        customImageView.hidden = TRUE;
        customWebIMageView.hidden = TRUE;
    }
    else if([self validateUrl:strCustomImage]) {
        customImageView.hidden = TRUE;
        customWebIMageView.hidden = FALSE;
		scanView.hidden = TRUE;
        NSURL *url = [NSURL URLWithString:strCustomImage];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [customWebIMageView loadRequest:request];
    }
    else {
        customImageView.image = [UIImage imageNamed:strCustomImage];
		customWebIMageView.hidden = TRUE;
		scanView.hidden = TRUE;
    }
}

- (BOOL) validateUrl: (NSString *) candidate {
    /*
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
     */
    if ([candidate containsString:@"http"]) {
        return TRUE;
    }
    return FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
- (IBAction)handleButtonCancel:(id)sender {
    NSLog(@"handleButtonCancel");
    [delegate scanViewResult:@""];
}
    
    //
- (IBAction)handleButtonSwitch:(id)sender {
    NSLog(@"handleButtonSwitch");
    [captureSession stopRunning];
    if(camera_num==1){
        //切換成前鏡頭
        camera_num=0;
    }
    else{
        //切換成後鏡頭
        camera_num=1;
    }
    captureSession = [lib LCcameraControl:captureSession cameraLocation:camera_num];
    if(captureSession != NULL){
        //Add outputStream to captureSession
        [self setVideoOutput];
        //Set captureSession Preview
        [self setPreviewLayer];
        //Start running
        [captureSession startRunning];
    }
    
}

@synthesize delegate;
@end

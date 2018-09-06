/********* lcr.m Cordova Plugin Implementation *******/

#import "lcr.h"

@interface lcr (){
  // Member variables go here.
    ViewController* vc;
}

@end

@implementation lcr

//
CDVInvokedUrlCommand *scanCommand = nil;

- (void)scan:(CDVInvokedUrlCommand*)command
{
    //
    if (scanCommand != nil)
    {
        NSLog(@"Pre plugin didn't exist.");
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera is busy now."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    scanCommand = command;
    //
    NSString* strClose = [[scanCommand arguments] objectAtIndex:0];
    NSString* strScaning = [[scanCommand arguments] objectAtIndex:1];
    NSString* numCamera = [[scanCommand arguments] objectAtIndex:2];
    NSString* strScanFontSize = [[scanCommand arguments] objectAtIndex:3];
    NSString* scaningFlash = [[scanCommand arguments] objectAtIndex:4];
    NSString* customImage = [[scanCommand arguments] objectAtIndex:5];
    NSString* showSwitchBtn = [[scanCommand arguments] objectAtIndex:6];
    NSLog(@"Command arguments are %@ , %@, %@, %@, %@, %@, %@",strClose, strScaning, numCamera, strScanFontSize, scaningFlash, customImage, showSwitchBtn);
    //
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Scan" bundle:nil];
    vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.delegate = self;
    [vc setCameraNum:numCamera];
    [vc setFlashTimer:@"0.8" : scaningFlash];
    //
    [self.viewController addChildViewController:vc];
    [self.webView addSubview:vc.view];
    //
    [vc setCloseString:strClose];
    [vc setScaningString:strScaning:strScanFontSize];
    [vc isShowHideSwitchButton:showSwitchBtn];
    [vc setCustomImage:customImage];
}


//implement ViewControllerDelegate portocol
-(void)scanViewResult:(NSString *)result {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:scanCommand.callbackId];
    //
    scanCommand = nil;
    //
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
}

@end

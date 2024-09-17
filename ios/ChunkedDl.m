#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

typedef void (^CompletionHandler)(void);

@interface RCT_EXTERN_MODULE(ChunkedDl, RCTEventEmitter<RCTBridgeModule>)

RCT_EXTERN_METHOD(download:(NSDictionary*)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopDownload:(int)jobId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(suspendDownload:(int)jobId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(resumeDownload:(int)jobId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)


+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end

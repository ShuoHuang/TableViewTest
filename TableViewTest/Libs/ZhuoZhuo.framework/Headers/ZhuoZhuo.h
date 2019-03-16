// Auto generated by kmgIosFramework. You should not edit it.

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"

// from: src/Feedx/IosUiProcessFrameworkEntryPoint/zzzig_kmgRpcGoAndObjectiveC.h
// +build darwin
// Auto generated by kmgRpcGoAndObjectiveC , do not edit it.

#import <Foundation/Foundation.h>

@class ResponseModel;
@class ClickInfo;
@class ImageSize;
@interface ResponseModel:NSObject
@property NSString* Title;
@property NSString* Context;
@property NSArray<ClickInfo*>* ClickInfoList;
@property NSString* ImageUrl;
@property ImageSize* ImageSizeInfo;
@end

@interface ClickInfo:NSObject
@property NSString* TargetString;
@property NSString* Url;
@end

@interface ImageSize:NSObject
@property size_t Width;
@property size_t Height;
@end

NSArray<ResponseModel*>* RdTestGetResource__NotAllowedInMainThread();


#pragma clang diagnostic pop

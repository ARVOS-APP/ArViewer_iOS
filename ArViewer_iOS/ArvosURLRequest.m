//
//  ArvosURLRequest.m
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 5/1/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import "ArvosURLRequest.h"

static const NSTimeInterval kURLRequestTimeout = 60.;

NSMutableDictionary* _requests;

@interface ArvosURLRequest (Private)

- (void)startRequest;

@end

@implementation ArvosURLRequest

+ (ArvosURLRequest*)requestWithURL:(NSURL*)url
                        completion:(ArvosURLRequestCompletion)completionBock {
    return [[self alloc] initWithURL:url
                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                          completion:completionBock];
}
+ (ArvosURLRequest*)uncachedRequestWithURL:(NSURL *)url
                                completion:(ArvosURLRequestCompletion)completionBock {
    return [[self alloc] initWithURL:url
                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                          completion:completionBock];
}

- (id)initWithURL:(NSURL*)url
      cachePolicy:(NSURLCacheStoragePolicy)cachePolicy
       completion:(ArvosURLRequestCompletion)completionBlock {
    self = [super init];
    if (self) {
        if (!_requests) {
            _requests = [NSMutableDictionary dictionary];
        }
        mCachePolicy = cachePolicy;
        mURL = url;
        @synchronized(_requests) {
            if (_requests[mURL]) {
                [_requests[mURL] addObject:completionBlock];
            } else {
                _requests[mURL] = [NSMutableArray arrayWithObject:completionBlock];
            }
        }
        mOutputData = [NSMutableData data];
        [self startRequest];
    }
    return self;
}

@end


@implementation ArvosURLRequest (Private)

- (void)startRequest {
    NSAssert(mURLConnection == nil, @"there is already a connection present");
    NSAssert(mURL != nil, @"url is nil");
    
    NSURLRequest* request = [NSURLRequest requestWithURL:mURL
                                             cachePolicy:mCachePolicy
                                         timeoutInterval:kURLRequestTimeout];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               @synchronized(_requests) {
                                   for (ArvosURLRequestCompletion block in _requests[mURL]) {
                                       block(data, error);
                                   }
                                   [_requests removeObjectForKey:mURL];
                               }
                           }];
    
}

@end
//
//  ArvosURLRequest.h
//  ArViewer_iOS
//
//  Created by Ulrich Zurucker on 5/1/13.
//  Copyright (c) 2013 Peter Graf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ArvosURLRequestCompletion)(NSData*, NSError*);

/** Utility class for async HTTP downloads. */

@interface ArvosURLRequest : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSURLConnection*            mURLConnection;
    NSURL*                      mURL;
    NSMutableData*              mOutputData;
    NSURLCacheStoragePolicy     mCachePolicy;
}

/** Cretes a new Async Download. The request will prefer cached results.
 @param url The request URL
 @param completionBlock The block will called on the main thread when the download
    completes. If an other request with the same URL is already in progress, no
    further HTTP request will be done.
 */

+ (ArvosURLRequest*)requestWithURL:(NSURL*)url
                        completion:(ArvosURLRequestCompletion)completionBock;

/**
 Like requestWithURL:completion:, ignores all cached data and forces download
 */
+ (ArvosURLRequest*)uncachedRequestWithURL:(NSURL*)url
                                completion:(ArvosURLRequestCompletion)completionBock;

/**
 Initializes a new ArvosURLRequest object
 @param url the request URL
 @param cachePolicy cachePolicy of the request
 @param completionBlock The completion Block
 */
- (id)initWithURL:(NSURL*)url
      cachePolicy:(NSURLCacheStoragePolicy)cachePolicy
       completion:(ArvosURLRequestCompletion)completionBlock;

@end

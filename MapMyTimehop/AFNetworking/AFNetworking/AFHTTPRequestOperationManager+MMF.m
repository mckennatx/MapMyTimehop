//
//  AFHTTPRequestOperationManager+MMF.m
//  iMapMy3
//
//  Created by Whittlesey, Skyler on 4/22/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import "AFHTTPRequestOperationManager+MMF.h"

@implementation AFHTTPRequestOperationManager (MMF)

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters ignoreParams:(BOOL)ignoreParams
{
    NSError *error;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:(method ?: @"GET") URLString:[NSURL URLWithString:path relativeToURL:self.baseURL].absoluteString parameters:parameters error:&error];
    
    if (!error) {
        NSString *requestString = request.URL.absoluteString;
        
        for (NSOperation *operation in self.operationQueue.operations) {
            if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
                continue;
            }
            
            NSURL *urlToMatch = ((AFHTTPRequestOperation *)operation).request.URL;
            if (ignoreParams == YES) {
                NSURLComponents *components = [[NSURLComponents alloc] initWithURL:urlToMatch resolvingAgainstBaseURL:YES];
                components.query = nil;
                components.fragment = nil;
                
                urlToMatch = components.URL;
            }
            
            BOOL hasMatchingMethod = !method || [method isEqualToString:((AFHTTPRequestOperation *)operation).request.HTTPMethod];
            BOOL hasMatchingURL = [urlToMatch.absoluteString isEqualToString:requestString];
            
            if (hasMatchingMethod && hasMatchingURL) {
                [operation cancel];
            }
        }
    }
}

@end

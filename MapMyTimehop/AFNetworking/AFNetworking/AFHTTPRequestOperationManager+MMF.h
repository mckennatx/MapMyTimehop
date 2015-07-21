//
//  AFHTTPRequestOperationManager+MMF.h
//  iMapMy3
//
//  Created by Whittlesey, Skyler on 4/22/15.
//  Copyright (c) 2015 MapMyFitness. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (MMF)

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters ignoreParams:(BOOL)ignoreParams;

@end

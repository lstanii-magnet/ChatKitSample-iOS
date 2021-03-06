/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "MMUser+Privacy.h"
#import "MMXClient.h"
#import "MMXPrivacyManager.h"
#import "MMXConstants.h"

@implementation MMUser (Privacy)

+ (void)blockUsers:(NSSet <MMUser *>*)usersToBlock
           success:(nullable void (^)())success
           failure:(nullable void (^)(NSError *error))failure {
    
    if ([self currentUser] != nil) {
        [[MMXClient sharedClient].privacyManager blockUsers:usersToBlock success:success failure:failure];
    } else {
        if (failure) {
            failure([self unauthorizedError]);
        }
    }
}

+ (void)unblockUsers:(NSSet <MMUser *>*)usersToUnblock
             success:(nullable void (^)())success
             failure:(nullable void (^)(NSError *error))failure {
    if ([self currentUser] != nil) {
        [[MMXClient sharedClient].privacyManager unblockUsers:usersToUnblock success:success failure:failure];
    } else {
        if (failure) {
            failure([self unauthorizedError]);
        }
    }
}

+ (void)blockedUsersWithSuccess:(nullable void (^)(NSArray <MMUser *>*users))success
                        failure:(nullable void (^)(NSError *error))failure {
    if ([self currentUser] != nil) {
        [[MMXClient sharedClient].privacyManager blockedUsersWithSuccess:success failure:failure];
    } else {
        if (failure) {
            failure([self unauthorizedError]);
        }
    }
}

#pragma mark - Private implementation

+ (NSError *)unauthorizedError {
    return [NSError errorWithDomain:MMXErrorDomain
                               code:401
                           userInfo:nil];
}

@end

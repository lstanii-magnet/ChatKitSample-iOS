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

#import "MMXChannel.h"
@class MMXTopic;

@interface MMXChannel ()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *ownerUserID;
@property (nonatomic, readwrite) int numberOfMessages;
@property (nonatomic, readwrite) NSDate *lastTimeActive;
@property (nonatomic, readwrite) NSSet *tags;
@property (nonatomic, readwrite) BOOL isSubscribed;
@property (nonatomic, readwrite) NSDate * creationDate;
@property (nonatomic, readwrite) MMXPublishPermissions publishPermissions;
@property (nonatomic, strong) NSArray <NSString *>* subscribers;
@property (nonatomic, assign) BOOL privateChannel;

- (MMXTopic *)asTopic;

+ (instancetype)channelWithName:(NSString *)name
						summary:(NSString *)summary
					   isPublic:(BOOL)isPublic
			 publishPermissions:(MMXPublishPermissions)publishPermissions;

+ (NSArray *)channelsFromTopics:(NSArray *)topics summaries:(NSArray *)summaries subscriptions:(NSArray *)subscriptions;

@end

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

#import "MMXMessage.h"
@class MMXPubSubMessage;

@interface MMXMessage ()

@property(nonatomic, strong) MMAttachmentProgress *attachmentProgress;

@property (nonatomic, readwrite) MMXMessageType messageType;

@property(nonatomic, readwrite) NSString *messageID;

@property(nonatomic, readwrite) NSDate *timestamp;

@property(nonatomic, readwrite) MMUser *sender;

@property(nonatomic, copy) NSString *senderDeviceID;

@property (nonatomic, readwrite) MMXChannel *channel;

@property(nonatomic, readwrite) NSSet *recipients;

@property(nonatomic, readwrite) NSDictionary <NSString *, NSString *> *messageContent;

@property(nonatomic, strong) NSMutableArray<MMAttachment *> *mutableAttachments;

@property(nonatomic, readwrite) NSArray<MMAttachment *> *attachments;

+ (instancetype)messageFromPubSubMessage:(MMXPubSubMessage *)pubSubMessage
								  sender:(MMUser *)sender;

@end
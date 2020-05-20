//
//  ASCProtocolAutoImplementer.h
//  ASCode
//
//  Created by Adair Wang on 2020/5/18.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
 
@interface ASCProtocolAutoImplementer : NSObject

// NSCoding
+ (BOOL)implementNSCodingWithClass:(Class)aClass;
+ (BOOL)implementNSCodingWithClass:(Class)aClass excludeVarNames:(nullable NSArray<NSString *> *)excludeVarNames;
// if you have implemented NSCoding stub, you can use the following methods: only encode/decode instance variables from the current class
+ (void)encodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder;
+ (void)decodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder;
+ (void)encodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder excludeVarNames:(nullable NSArray<NSString *> *)excludeVarNames;
+ (void)decodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder excludeVarNames:(nullable NSArray<NSString *> *)excludeVarNames;

// NSCopying
+ (BOOL)implementNSCopyingWithClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END

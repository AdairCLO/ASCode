//
//  ASCProtocolAutoImplementer.m
//  ASCode
//
//  Created by Adair Wang on 2020/5/18.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCProtocolAutoImplementer.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define FUNC_OBJECT_GETIVAR(type,obj,ivar) (((type(*)(id,Ivar))(object_getIvar))(obj,ivar))
#define FUNC_OBJECT_SETIVAR(type,obj,ivar,value) (((void(*)(id,Ivar,type))(object_setIvar))(obj,ivar,value))

@implementation ASCProtocolAutoImplementer

+ (BOOL)implementNSCodingWithClass:(Class)aClass;
{
    return [self implementNSCodingWithClass:aClass excludeVarNames:nil];
}

+ (BOOL)implementNSCodingWithClass:(Class)aClass excludeVarNames:(nullable NSArray<NSString *> *)excludeVarNames
{
    if (aClass == nil)
    {
        return NO;
    }
    
    Protocol *toImplementProtocol = @protocol(NSCoding);
    SEL toImplementEncoderSelector = @selector(encodeWithCoder:);
    SEL toImplementDecoderSelector = @selector(initWithCoder:);

    // 1. check if implement the protocol
    BOOL hasImplementedProtocol = NO;
    unsigned int protocol_count = 0;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(aClass, &protocol_count);
    for (unsigned int i = 0; i < protocol_count; i++)
    {
        Protocol *p = protocols[i];
        if (protocol_isEqual(p, toImplementProtocol))
        {
            hasImplementedProtocol = YES;
            break;
        }
    }
    free(protocols);
    if (hasImplementedProtocol)
    {
        return NO;
    }
    
    // 2. check if implement the methods of the protocol
    BOOL hasImplementedMethod = NO;
    unsigned int method_count = 0;
    Method *method = class_copyMethodList(aClass, &method_count);
    for (unsigned int i = 0; i < method_count; i++)
    {
        Method *current_method = method + i;
        SEL method_name = method_getName(*current_method);
        if (sel_isEqual(method_name, toImplementEncoderSelector) || sel_isEqual(method_name, toImplementDecoderSelector))
        {
            hasImplementedMethod = YES;
            break;
        }
    }
    free(method);
    if (hasImplementedMethod)
    {
        return NO;
    }
    
    NSArray<NSString *> *excludeVarNamesArray = nil;
    if (excludeVarNames.count > 0)
    {
        excludeVarNamesArray = [excludeVarNames copy];
    }
    
    // 3_1. add methods of the protocol: encodeWithCoder
    BOOL ok = class_addMethod(aClass, toImplementEncoderSelector, imp_implementationWithBlock(^(id aSelf, NSCoder *coder) {
        // implement of encodeWithCoder:
        
        // capture the "aClass"
        if ([[aClass superclass] instancesRespondToSelector:@selector(encodeWithCoder:)])
        {
            // call super's implement
            struct objc_super aSuper;
            aSuper.receiver = aSelf;
            aSuper.super_class = [aClass superclass];
            ((void(*)(struct objc_super *,SEL,NSCoder *))objc_msgSendSuper)(&aSuper, @selector(encodeWithCoder:), coder);
        }
        
        [[ASCProtocolAutoImplementer class] encodeObject:aSelf inClass:aClass withCoder:coder excludeVarNames:excludeVarNamesArray];
    }), "v@:@");
    if (!ok)
    {
        return NO;
    }
    
    // 3_2. add methods of the protocol: initWithCoder:
    ok = class_addMethod(aClass, toImplementDecoderSelector, imp_implementationWithBlock(^(id aSelf, NSCoder *coder) {
        // implement of initWithCoder:
        
        id obj = nil;

        // capture the "aClass"
        if ([[aClass superclass] instancesRespondToSelector:@selector(initWithCoder:)])
        {
            // call super's implement
            struct objc_super aSuper;
            aSuper.receiver = aSelf;
            aSuper.super_class = [aClass superclass];
            obj = ((id(*)(struct objc_super *,SEL,NSCoder *))objc_msgSendSuper)(&aSuper, @selector(initWithCoder:), coder);
        }
        else
        {
            obj = [[[aSelf class] alloc] init];

            // important: need for ARC
            CFBridgingRetain(obj);
        }
        
        [[ASCProtocolAutoImplementer class] decodeObject:obj inClass:aClass withCoder:coder excludeVarNames:excludeVarNamesArray];

        return obj;
    }), "@@:@");
    if (!ok)
    {
        return NO;
    }
    
    // 4. add protocol
    ok = class_addProtocol(aClass, toImplementProtocol);
    
    return ok;
}

+ (void)encodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder
{
    [self encodeObject:obj inClass:aClass withCoder:coder];
}

+ (void)decodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder
{
    [self decodeObject:obj inClass:aClass withCoder:coder excludeVarNames:nil];
}

+ (void)encodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder excludeVarNames:(NSArray<NSString *> *)excludeVarNames
{
    NSMutableDictionary<NSString *, NSNumber *> *excludeVarNamesDict = nil;
    if (excludeVarNames.count > 0)
    {
        excludeVarNamesDict = [[NSMutableDictionary alloc] init];
        [excludeVarNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.length > 0)
            {
                [excludeVarNamesDict setObject:@(1) forKey:obj];
            }
        }];
    }
    
    unsigned int ivar_count = 0;
    Ivar *ivar = class_copyIvarList(aClass, &ivar_count);
    for (unsigned int i = 0; i < ivar_count; i++)
    {
        Ivar *current_ivar = ivar + i;
        const char *name = ivar_getName(*current_ivar);
        NSString *nameString = [NSString stringWithUTF8String:name];
        if ([excludeVarNamesDict objectForKey:nameString] != nil)
        {
            continue;
        }
        const char *type_encoding = ivar_getTypeEncoding(*current_ivar);
        if (type_encoding[0] == '@')
        {
            id value = object_getIvar(obj, *current_ivar);
            [coder encodeObject:value forKey:nameString];
        }
        else if (type_encoding[0] == 'c')
        {
            // char
            char value = FUNC_OBJECT_GETIVAR(char, obj, *current_ivar);
            [coder encodeInt:value forKey:nameString];
        }
        else if (type_encoding[0] == 'i')
        {
            // int
            int value = FUNC_OBJECT_GETIVAR(int, obj, *current_ivar);
            [coder encodeInt:value forKey:nameString];
        }
        else if (type_encoding[0] == 's')
        {
            // short
            short value = FUNC_OBJECT_GETIVAR(short, obj, *current_ivar);
            [coder encodeInt:value forKey:nameString];
        }
        else if (type_encoding[0] == 'l')
        {
            // long
            long value = FUNC_OBJECT_GETIVAR(long, obj, *current_ivar);
            [coder encodeInt32:(int32_t)value forKey:nameString];
        }
        else if (type_encoding[0] == 'q')
        {
            // long long
            long long value = FUNC_OBJECT_GETIVAR(long long, obj, *current_ivar);
            [coder encodeInt64:(int64_t)value forKey:nameString];
        }
        else if (type_encoding[0] == 'C')
        {
            // unsigned char
            unsigned char value = FUNC_OBJECT_GETIVAR(unsigned char, obj, *current_ivar);
            [coder encodeInt:value forKey:nameString];
        }
        else if (type_encoding[0] == 'I')
        {
            // unsigned int
            unsigned int value = FUNC_OBJECT_GETIVAR(unsigned int, obj, *current_ivar);
            [coder encodeInt:value forKey:nameString];
        }
        else if (type_encoding[0] == 'S')
        {
            // unsigned short
            unsigned short value = FUNC_OBJECT_GETIVAR(unsigned short, obj, *current_ivar);
            [coder encodeInt:value forKey:nameString];
        }
        else if (type_encoding[0] == 'L')
        {
            // unsigned long
            unsigned long value = FUNC_OBJECT_GETIVAR(unsigned long, obj, *current_ivar);
            [coder encodeInt32:(int32_t)value forKey:nameString];
        }
        else if (type_encoding[0] == 'Q')
        {
            // unsigned long long
            unsigned long long value = FUNC_OBJECT_GETIVAR(unsigned long long, obj, *current_ivar);
            [coder encodeInt64:(int64_t)value forKey:nameString];
        }
        else if (type_encoding[0] == 'f')
        {
            // float
            float value = FUNC_OBJECT_GETIVAR(float, obj, *current_ivar);
            [coder encodeFloat:value forKey:nameString];
        }
        else if (type_encoding[0] == 'd')
        {
            // double
            double value = FUNC_OBJECT_GETIVAR(double, obj, *current_ivar);
            [coder encodeDouble:value forKey:nameString];
        }
        else
        {
            NSAssert(NO, @"not implemented");
        }
    }
    free(ivar);
}

+ (void)decodeObject:(id)obj inClass:(Class)aClass withCoder:(NSCoder *)coder excludeVarNames:(NSArray<NSString *> *)excludeVarNames
{
    NSMutableDictionary<NSString *, NSNumber *> *excludeVarNamesDict = nil;
    if (excludeVarNames.count > 0)
    {
        excludeVarNamesDict = [[NSMutableDictionary alloc] init];
        [excludeVarNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.length > 0)
            {
                [excludeVarNamesDict setObject:@(1) forKey:obj];
            }
        }];
    }
    
    unsigned int ivar_count = 0;
    Ivar *ivar = class_copyIvarList(aClass, &ivar_count);
    for (unsigned int i = 0; i < ivar_count; i++)
    {
        Ivar *current_ivar = ivar + i;
        const char *name = ivar_getName(*current_ivar);
        NSString *nameString = [NSString stringWithUTF8String:name];
        if ([excludeVarNamesDict objectForKey:nameString] != nil)
        {
            continue;
        }
        const char *type_encoding = ivar_getTypeEncoding(*current_ivar);
        if (type_encoding[0] == '@')
        {
            id value = [coder decodeObjectForKey:nameString];
            object_setIvar(obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'c')
        {
            // char
            char value = [coder decodeIntForKey:nameString];
            FUNC_OBJECT_SETIVAR(char, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'i')
        {
            // int
            int value = [coder decodeIntForKey:nameString];
            FUNC_OBJECT_SETIVAR(int, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 's')
        {
            // short
            short value = [coder decodeIntForKey:nameString];
            FUNC_OBJECT_SETIVAR(short, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'l')
        {
            // long
            long value = [coder decodeInt32ForKey:nameString];
            FUNC_OBJECT_SETIVAR(long, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'q')
        {
            // long long
            long long value = [coder decodeInt64ForKey:nameString];
            FUNC_OBJECT_SETIVAR(long long, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'C')
        {
            // unsigned char
            unsigned char value = [coder decodeIntForKey:nameString];
            FUNC_OBJECT_SETIVAR(unsigned char, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'I')
        {
            // unsigned int
            unsigned int value = [coder decodeIntForKey:nameString];
            FUNC_OBJECT_SETIVAR(unsigned int, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'S')
        {
            // unsigned short
            unsigned short value = [coder decodeIntForKey:nameString];
            FUNC_OBJECT_SETIVAR(unsigned short, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'L')
        {
            // unsigned long
            unsigned long value = [coder decodeInt32ForKey:nameString];
            FUNC_OBJECT_SETIVAR(unsigned long, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'Q')
        {
            // unsigned long long
            unsigned long long value = [coder decodeInt64ForKey:nameString];
            FUNC_OBJECT_SETIVAR(unsigned long long, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'f')
        {
            // float
            float value = [coder decodeFloatForKey:nameString];
            FUNC_OBJECT_SETIVAR(float, obj, *current_ivar, value);
        }
        else if (type_encoding[0] == 'd')
        {
            // double
            double value = [coder decodeDoubleForKey:nameString];
            FUNC_OBJECT_SETIVAR(double, obj, *current_ivar, value);
        }
        else
        {
            NSAssert(NO, @"not implemented");
        }
    }
    free(ivar);
}

+ (BOOL)implementNSCopyingWithClass:(Class)aClass;
{
    if (aClass == nil)
    {
        return NO;
    }
    
    Protocol *toImplementProtocol = @protocol(NSCopying);
    SEL toImplementSelector = @selector(copyWithZone:);

    // 1. check if implement the protocol
    BOOL hasImplementedProtocol = NO;
    unsigned int protocol_count = 0;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(aClass, &protocol_count);
    for (unsigned int i = 0; i < protocol_count; i++)
    {
        Protocol *p = protocols[i];
        if (protocol_isEqual(p, toImplementProtocol))
        {
            hasImplementedProtocol = YES;
            break;
        }
    }
    free(protocols);
    if (hasImplementedProtocol)
    {
        return NO;
    }
    
    // 2. check if implement the methods of the protocol
    BOOL hasImplementedMethod = NO;
    unsigned int method_count = 0;
    Method *method = class_copyMethodList(aClass, &method_count);
    for (unsigned int i = 0; i < method_count; i++)
    {
        Method *current_method = method + i;
        SEL method_name = method_getName(*current_method);
        if (sel_isEqual(method_name, toImplementSelector))
        {
            hasImplementedMethod = YES;
            break;
        }
    }
    free(method);
    if (hasImplementedMethod)
    {
        return NO;
    }
    
    // 3. add methods of the protocol
    BOOL ok = class_addMethod(aClass, toImplementSelector, imp_implementationWithBlock(^(id aSelf, NSZone *zone) {
        // implement of copyWithZone:
        
        id obj = nil;
        
        // capture the "aClass"
        if ([[aClass superclass] instancesRespondToSelector:@selector(copyWithZone:)])
        {
            // call super's implement
            struct objc_super aSuper;
            aSuper.receiver = aSelf;
            aSuper.super_class = [aClass superclass];
            obj = ((id(*)(struct objc_super *,SEL,NSZone *))objc_msgSendSuper)(&aSuper, @selector(copyWithZone:), zone);
        }
        else
        {
            obj = [[[aSelf class] alloc] init];
            
            // important: need for ARC
            CFBridgingRetain(obj);
        }
        
        // get all instance variables and set their values to the new object
        // important: just "retain" value, no "copy" value to the new object!! so it's "shadow copy, not deep copy".
        // if need "deep copy": try to get related property to get if need copy?????????
        unsigned int ivar_count = 0;
        Ivar *ivar = class_copyIvarList(aClass, &ivar_count);
        for (unsigned int i = 0; i < ivar_count; i++)
        {
            Ivar *current_ivar = ivar + i;
            const char *type_encoding = ivar_getTypeEncoding(*current_ivar);
            if (type_encoding[0] == '@')
            {
                id value = object_getIvar(aSelf, *current_ivar);
                object_setIvar(obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'c')
            {
                // char
                char value = FUNC_OBJECT_GETIVAR(char, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(char, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'i')
            {
                // int
                int value = FUNC_OBJECT_GETIVAR(int, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(int, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 's')
            {
                // short
                short value = FUNC_OBJECT_GETIVAR(short, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(short, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'l')
            {
                // long
                long value = FUNC_OBJECT_GETIVAR(long, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(long, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'q')
            {
                // long long
                long long value = FUNC_OBJECT_GETIVAR(long long, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(long long, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'C')
            {
                // unsigned char
                unsigned char value = FUNC_OBJECT_GETIVAR(unsigned char, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(unsigned char, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'I')
            {
                // unsigned int
                unsigned int value = FUNC_OBJECT_GETIVAR(unsigned int, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(unsigned int, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'S')
            {
                // unsigned short
                unsigned short value = FUNC_OBJECT_GETIVAR(unsigned short, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(unsigned short, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'L')
            {
                // unsigned long
                unsigned long value = FUNC_OBJECT_GETIVAR(unsigned long, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(unsigned long, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'Q')
            {
                // unsigned long long
                unsigned long long value = FUNC_OBJECT_GETIVAR(unsigned long long, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(unsigned long long, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'f')
            {
                // float
                float value = FUNC_OBJECT_GETIVAR(float, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(float, obj, *current_ivar, value);
            }
            else if (type_encoding[0] == 'd')
            {
                // double
                double value = FUNC_OBJECT_GETIVAR(double, aSelf, *current_ivar);
                FUNC_OBJECT_SETIVAR(double, obj, *current_ivar, value);
            }
            else
            {
                NSAssert(NO, @"not implemented");
            }
        }
        free(ivar);
        
        return obj;
    }), "@@:@");
    if (!ok)
    {
        return NO;
    }
    
    // 4. add protocol
    ok = class_addProtocol(aClass, toImplementProtocol);
    
    return ok;
}

@end

//
//  NSObject+NSCoding.m
//  OpenStack
//
//  Created by Michael Mayo on 3/4/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "NSObject+NSCoding.h"
#import <objc/runtime.h>


@implementation NSObject (NSCoding)

- (NSMutableDictionary *)propertiesForClass:(Class)klass {

    //初始化字典用来存储对象的属性
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    //获取对象的所有属性
    unsigned int outCount, i;  //定义属性数量变量
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        //获取属性名
        NSString *pname = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
#pragma ------获取属性类型字符串
        
        NSString *pattrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
//        NSLog(@"--pattrs = %@",pattrs);
    /*
           *pattrs 的格式是 T@"",&,N,V_属性名 。例如：T@"NSString",&,N,V_ID
    */
        pattrs = [[pattrs componentsSeparatedByString:@","] objectAtIndex:0];
        pattrs = [pattrs substringFromIndex:1];
        
        [results setObject:pattrs forKey:pname];
    }
    //释放属性
    free(properties);
    
    //判断将父类遵守协议，获取父类属性最后编码
    if ([klass superclass] != [NSObject class]) {
        //重复执行，将字典添加到results字典中
        [results addEntriesFromDictionary:[self propertiesForClass:[klass superclass]]];
    }
    
    return results;
}

- (NSDictionary *)properties {
    return [self propertiesForClass:[self class]];
}

- (void)autoEncodeWithCoder:(NSCoder *)coder {
    NSDictionary *properties = [self properties];
/*
     *格式类型是@"\ "\" "类型，例如:@"\"NSString\""
*/
//    NSLog(@"properties = %@",properties);
    for (NSString *key in properties) {
        NSString *type = [properties objectForKey:key];
        id value;
        unsigned long long ullValue;
        BOOL boolValue;
        float floatValue;
        double doubleValue;
        int intValue;
        unsigned long ulValue;
		long longValue;
		unsigned unsignedValue;
		short shortValue;
        NSString *className;
		
        //获取方法签名
        NSMethodSignature *signature = [self methodSignatureForSelector:NSSelectorFromString(key)]; //获取属性getter方法的方法签名
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:NSSelectorFromString(key)];
        [invocation setTarget:self];
        
        //筛选不同类型的数据进行编码
        switch ([type characterAtIndex:0]) {
            case '@':   // object--对象类型
                if ([[type componentsSeparatedByString:@"\""] count] > 1) {                 //存在类型名称
                    className = [[type componentsSeparatedByString:@"\""] objectAtIndex:1]; //第一个是 @
                    Class class = NSClassFromString(className);
                    
#warning UIImage类型的属性不归档  add by yhy
                    if ([className isEqualToString:@"UIImage"]) {
                        //如果属性是UIImage类型的，不进行归档
                        break;
                    }
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    //调用属性的getter方法
                    value = [self performSelector:NSSelectorFromString(key)];
#pragma clang diagnostic pop
					
                    // only decode if the property conforms to NSCoding 遵守协议可以进行编码
                    if([class conformsToProtocol:@protocol(NSCoding)]){
                        [coder encodeObject:value forKey:key];
                    }
                }
                break;
            case 'c':   // bool
                [invocation invoke];
                [invocation getReturnValue:&boolValue];  //给定义的boolValue赋值
                [coder encodeObject:[NSNumber numberWithBool:boolValue] forKey:key];
                break;
            case 'f':   // float
                [invocation invoke];
                [invocation getReturnValue:&floatValue];
                [coder encodeObject:[NSNumber numberWithFloat:floatValue] forKey:key];
                break;
            case 'd':   // double
                [invocation invoke];
                [invocation getReturnValue:&doubleValue];
                [coder encodeObject:[NSNumber numberWithDouble:doubleValue] forKey:key];
                break;
            case 'i':   // int
                [invocation invoke];
                [invocation getReturnValue:&intValue];
                [coder encodeObject:[NSNumber numberWithInt:intValue] forKey:key];
                break;
            case 'L':   // unsigned long
                [invocation invoke];
                [invocation getReturnValue:&ulValue];
                [coder encodeObject:[NSNumber numberWithUnsignedLong:ulValue] forKey:key];
                break;
            case 'Q':   // unsigned long long
                [invocation invoke];
                [invocation getReturnValue:&ullValue];
                [coder encodeObject:[NSNumber numberWithUnsignedLongLong:ullValue] forKey:key];
                break;
            case 'l':   // long
                [invocation invoke];
                [invocation getReturnValue:&longValue];
                [coder encodeObject:[NSNumber numberWithLong:longValue] forKey:key];
                break;
            case 's':   // short
                [invocation invoke];
                [invocation getReturnValue:&shortValue];
                [coder encodeObject:[NSNumber numberWithShort:shortValue] forKey:key];
                break;
            case 'I':   // unsigned
                [invocation invoke];
                [invocation getReturnValue:&unsignedValue];
                [coder encodeObject:[NSNumber numberWithUnsignedInt:unsignedValue] forKey:key];
                break;
            default:
                break;
        }
    }
}

- (void)autoDecode:(NSCoder *)coder {
    NSDictionary *properties = [self properties];
    for (NSString *key in properties) {
        NSString *type = [properties objectForKey:key];
        id value;
        NSNumber *number;
        int i;
        CGFloat f;
        BOOL b;
        double d;
        unsigned long ul;
        unsigned long long ull;
		long longValue;
		unsigned unsignedValue;
		short shortValue;
        
        NSString *className;
        
        switch ([type characterAtIndex:0]) {
            case '@':   // object
                if ([[type componentsSeparatedByString:@"\""] count] > 1) {
                    className = [[type componentsSeparatedByString:@"\""] objectAtIndex:1];
                    Class class = NSClassFromString(className);
                    
#warning UIImage类型的属性不归档  add by yhy
                    if ([className isEqualToString:@"UIImage"]) {
                        //如果属性是UIImage类型的，不进行反归档
                        break;
                    }

                    // only decode if the property conforms to NSCoding
                    if ([class conformsToProtocol:@protocol(NSCoding )]){
                        value = [coder decodeObjectForKey:key];
                        [self setValue:value forKey:key];
                    }
                }
                break;
            case 'c':   // bool
                number = [coder decodeObjectForKey:key];
                b = [number boolValue];
                [self setValue:@(b) forKey:key];
                break;
            case 'f':   // float
                number = [coder decodeObjectForKey:key];
                f = [number floatValue];
                [self setValue:@(f) forKey:key];
                break;
            case 'd':   // double
                number = [coder decodeObjectForKey:key];
                d = [number doubleValue];
                [self setValue:@(d) forKey:key];
                break;
            case 'i':   // int
                number = [coder decodeObjectForKey:key];
                i = [number intValue];
                [self setValue:@(i) forKey:key];
                break;
            case 'L':   // unsigned long
                number = [coder decodeObjectForKey:key];
                ul = [number unsignedLongValue];
                [self setValue:@(ul) forKey:key];
                break;
            case 'Q':   // unsigned long long
                number = [coder decodeObjectForKey:key];
                ull = [number unsignedLongLongValue];
                [self setValue:@(ull) forKey:key];
                break;
			case 'l':   // long
                number = [coder decodeObjectForKey:key];
                longValue = [number longValue];
                [self setValue:@(longValue) forKey:key];
                break;
            case 'I':   // unsigned
                number = [coder decodeObjectForKey:key];
                unsignedValue = [number unsignedIntValue];
                [self setValue:@(unsignedValue) forKey:key];
                break;
            case 's':   // short
                number = [coder decodeObjectForKey:key];
                shortValue = [number shortValue];
                [self setValue:@(shortValue) forKey:key];
                break;
            default:
                break;
        }
    }
}

@end
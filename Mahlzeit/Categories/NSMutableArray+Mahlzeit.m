//
//  NSMutableArray+Mahlzeit.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 7/6/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import "NSMutableArray+Mahlzeit.h"

@implementation NSMutableArray (Mahlzeit)


- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end

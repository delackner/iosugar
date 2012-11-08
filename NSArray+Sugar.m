#import "IOSugar.h"

@implementation NSArray(sugar)

- (id) $0 {
    return [self objectAtIndex: 0];
}

- (id) $1 {
    return [self objectAtIndex: 1];
}

- (id) $2 {
    return [self objectAtIndex: 2];
}

- (id) $3 {
    return [self objectAtIndex: 3];
}

- (id) $4 {
    return [self objectAtIndex: 4];
}

- (NSArray*) sortedByTag {
    return [self sortedArrayUsingComparator:^NSComparisonResult(UIView* a, UIView* b) {
        return (a.tag < b.tag) ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (NSArray *)map:(Block_id_id)block {
    NSMutableArray *output = [[NSMutableArray alloc] initWithCapacity: self.count];
    for (id x in self) {
        [output addObject:block(x)];
    }
    return output;
}

@end

NSArray *array(id items, ...) {
    NSMutableArray *array = [NSMutableArray array];
    va_list args;
    va_start(args, items);
    for (id arg = items; arg != nil; arg = va_arg(args, id)) {
        [array addObject:arg];
    }
    va_end(args);
    return array;
}

@implementation NSMutableArray(sugar)

- (id) $0 {
    return [self objectAtIndex: 0];
}

- (id) $1 {
    return [self objectAtIndex: 1];
}

- (id) $2 {
    return [self objectAtIndex: 2];
}

- (id) $3 {
    return [self objectAtIndex: 3];
}

- (id) $4 {
    return [self objectAtIndex: 4];
}

- (void)shuffle {
    if (self.count > 1) {
        // http://en.wikipedia.org/wiki/Knuth_shuffle
        //NSLog(@"shuffling: %@\n", [[[self description] stringByReplacingOccurrencesOfString:@"\n" withString:@","] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        for(NSUInteger i = [self count]; --i > 0; ) {
            NSUInteger j = random_below(i + 1);
            [self exchangeObjectAtIndex:i withObjectAtIndex:j];
            //NSLog(@"%d <-> %d: %@", i, j, [[[self description] stringByReplacingOccurrencesOfString:@"\n" withString:@","] stringByReplacingOccurrencesOfString:@" " withString:@""]);
        }
    }
}

@end
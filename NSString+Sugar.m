#import "NSString+Sugar.h"

#ifndef DBLog
#define DBLog NSLog
#endif

NSString* MakeShortString(NSString* pString, int max) {
	NSString* outString;
	
	int slen = [pString length];
    
	if (slen >= max) {
		if (max < 4) {
			outString = [@"..." substringToIndex:max];
		}
		else if (max < 6) {
			outString = [[pString substringWithRange: NSMakeRange(0, max - 3)] stringByAppendingString:@"..."];
		}
		else {
			int cut = (slen - (max - 3));
			int leftLen = (slen - cut)/2 + (slen - cut)%2 ;
			int rightLen = (slen - cut)/2;
			int rightStart = slen - rightLen;
			
			outString = [NSString stringWithFormat: @"%@...%@",
						 [pString substringWithRange: NSMakeRange(0, leftLen)],
						 [pString substringWithRange: NSMakeRange(rightStart, rightLen)]];
		}
	}
	else {
		outString = pString;
	}
	
	return outString;
}


NSString* FileLastModifiedString(NSString* path) {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSError* err = nil;
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: path error: &err];
	NSDate* date = nil;
	if (err) {
		date = [NSDate date];
	}
	else {
		date = (NSDate*)[fileAttributes objectForKey: NSFileModificationDate];
	}
	
	NSString* dateText = [dateFormatter stringFromDate: date];
	return dateText;
}

NSString* ResourcePath(NSString* file) {
    static NSString* part = nil;
    if (!part) {
#if TARGET_OS_IPHONE
        part = [[[NSBundle mainBundle] resourcePath] stringByAppendingString: @"/"];
#else
        NSString* root = [[NSBundle mainBundle] resourcePath];
        if (!root) {
            root = @ STRINGIZE(PROJECT_DIR);
        }
        part = [root stringByAppendingString: @"/"];
#endif
    }
    return [part stringByAppendingString: file];
}

NSString* LibraryPath(NSString* subPath) {
    static NSString* p = nil;
    if (!p) {
        p = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return [p stringByAppendingPathComponent: subPath];
}

NSString* DocumentsPath(void) {
    static NSString* p = nil;
    if (!p) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        p = [paths objectAtIndex:0];
    }
    return p;
}

NSString* SupportPath(void) {
    return LibraryPath(@"support") ;
}

NSString* ResolveSoftResourcePath (NSString* sub) {
    NSString* path = nil;
    if (sub) {
        path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"BUILTIN"] stringByAppendingPathComponent: sub];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath: path]) {
            path = LibraryPath(FMT(@"ua/downloads/%@", sub));
            if (![fm fileExistsAtPath: path]) {
                path = [DocumentsPath() stringByAppendingPathComponent: sub];
                if (![fm fileExistsAtPath: path]) {
                    NSLog(@"cannot find downloaded resource: %@", path);
                    path = nil;
                }
            }
        }
    }
    return path;
}

int ParseHMS(NSString* s) {
    NSEnumerator* parts = [[s componentsSeparatedByString:@":"] reverseObjectEnumerator];
    int t = 0;
    NSString* part = nil;
    int mul = 1;
    while (nil != (part = [parts nextObject])) {
        t += mul * [part intValue];
        mul *= 60;
    }
    return t;
}

NSString* Timestamp(NSDate* date) {
    static NSDateFormatter* d = nil;
    if (!d) {
        d = [[NSDateFormatter alloc] init];
        [d setLocale: [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"]];
    }
    [d setDateFormat: @"yyyyMMddHHmmss"];
    return [d stringFromDate: date];
}

NSString* Datestamp(NSDate* date) {
    static NSDateFormatter* d = nil;
    if (!d) {
        d = [[NSDateFormatter alloc] init];
        [d setLocale: [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"]];
    }
    [d setDateFormat: @"yyyyMMdd"];
    return [d stringFromDate: date];
}

@implementation NSString (Sugar)

- (NSString*) withPathExtension: (NSString*) newExtension {
    if (0 == [[self pathExtension] length]) {
        return [self stringByAppendingPathExtension: newExtension];
    }
    return [[self stringByDeletingPathExtension] stringByAppendingPathExtension: newExtension];
}

- (NSString*) urlEncode {
    return (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
}

- (NSString*) strip: (NSString*) strip {
	NSCharacterSet* stripSet = [NSCharacterSet characterSetWithCharactersInString: strip];
	NSScanner* scanner = [NSScanner scannerWithString: self];
	[scanner setCharactersToBeSkipped: nil];
	NSString *buf;
	//NSString* rubbish;
	NSMutableString *mStripped = [[NSMutableString alloc] init];
	while ([scanner isAtEnd] == NO) {
		if ([scanner scanUpToCharactersFromSet:stripSet intoString:&buf]) {
			[mStripped appendString:buf];
		}
		if ([scanner scanCharactersFromSet:stripSet intoString: nil]) { //&rubbish]) {
			//DBLog(@"rubbish: %d: %@", [rubbish length], rubbish);
		}
	}
	NSString* stripped = [mStripped copy];
	
	DBLog(@"strip: %@ from:\n[%@]\n->\n[%@]", strip, self, stripped);
	return stripped;
}

- (NSString*) trim {
    NSMutableString* ms = [self mutableCopy];
    int count = [self length];
    unichar c;
    for (int i = count; --i >= 1;) {
        c = [ms characterAtIndex: i];
        if ('\n' == c) {
            if ('\r' == [ms characterAtIndex: i - 1]) {
                [ms replaceCharactersInRange:NSMakeRange(i - 1, 2) withString:@"\n"];
                i--;
            }
        }
        else if ('\r' == c) {
            [ms replaceCharactersInRange:NSMakeRange(i, 1) withString:@"\n"];
        }
    }
    //    NSString* tests = [self stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    //    tests = [tests stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    //    if (![tests isEqualToString: ms]) {
    //        NSLog(@"not same");
    //    }
    count = [ms length];
    int n = count;
    while (n > 0 && [ms characterAtIndex: n - 1] == '\n') {
        n--;
    }
    if (n < count) {
        return [ms substringToIndex: n];
    }
    return ms;
}

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil)
        return [self writeToFile:path atomically:YES encoding:encoding error:nil];
    
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [self dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    [fh synchronizeFile];
    [fh closeFile];
    return YES;
}

#if TARGET_OS_IPHONE
- (void) drawWithFont: (UIFont*) font centeredInRect: (CGRect) r {
	float fontSize;
	CGSize textSize = [self sizeWithFont: font constrainedToSize: r.size];
	CGRect textRect = CGRectMake(r.origin.x + (r.size.width - textSize.width)/2, r.origin.y + (r.size.height - [font pointSize])/2, r.size.width, r.size.height);
	[self drawAtPoint:textRect.origin forWidth:textRect.size.width withFont:font minFontSize:8 actualFontSize:&fontSize lineBreakMode:UILineBreakModeClip baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
}
#endif

@end

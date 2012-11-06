// necessary evil for DEFS(x)
#define STRINGIZE_(x) #x
#define STRINGIZE(x) STRINGIZE_(x)

// for defining constants.  DEFH goes in the header.  DEFS goes in the .m
#define DEFS(x) NSString* x = @ STRINGIZE(x)
#define DEFH(x) extern NSString* x

#define ITOS(x) [NSString stringWithFormat: @"%d", x]

#define FMT(...) ([NSString stringWithFormat: __VA_ARGS__ ])

#ifdef __cplusplus
extern "C" {
#endif

NSString* MakeShortString(NSString* pString, int max);
NSString* FileLastModifiedString(NSString* path);
NSString* ResourcePath(NSString* file);
NSString* DocumentsPath(void);
NSString* LibraryPath(NSString* p);
NSString* SupportPath(void);
NSString* MakeWindowsSafeFilename(NSString* title);

NSString* ResolveSoftResourcePath (NSString* sub);
int ParseHMS(NSString* s);
NSString* Timestamp(NSDate* date);
NSString* Datestamp(NSDate* date);

#ifdef __cplusplus
} //C
#endif

@interface NSString (Sugar)
#pragma mark Manipulation
- (NSString*) strip: (NSString*) strip;
- (NSString*) trim;
- (NSString*) withPathExtension: (NSString*) newExtension;

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

#pragma mark Drawing
- (void) drawWithFont: (UIFont*) font centeredInRect: (CGRect) r ;

@end

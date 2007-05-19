#import <Cocoa/Cocoa.h>

@interface NSString (NSStringXtra)

/* Used by RSS class */
- (NSString *)trimWhiteSpace;
- (NSString *)ellipsizeAfterNWords: (int) n;
- (NSString *)stripHTML; // recoded using regex in Perl (NSTask) 
- (NSString *)stripHTMLSimple; // from RSS class
+ (BOOL)stringIsEmpty:(NSString *)s;

/* Parsing helpers */
- (NSString *)makeHTMLReadable:(NSString *)fromString;
- (NSString *)removeWhiteSpace:(NSArray *)w;
- (NSString *)removeExtraLines;
- (NSString *)removeScriptTags; // removes <script>...</script> from a string
- (NSString *)removeEntities;

- (NSString *)replace:(NSString *)str1 with:(NSString *)str2;
- (BOOL)containsString:(NSString *)aString;

- (NSString *)removeNumberOfPathComponents:(int)number;
- (NSString *)wordsUpTo:(int)length;
- (NSString *)correctFilename;
- (NSString *)removeCdataStuff;

- (NSString *)URLSafe;

- (NSString *)reverseString;

- (NSString *)cleanForXML;

@end

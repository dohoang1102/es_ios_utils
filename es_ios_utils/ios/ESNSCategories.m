#import "ESNSCategories.h"
#import <objc/runtime.h>

@implementation ESNSCategories
@end


@implementation NSDate(ESUtils)

-(NSString*)asStringWithShortFormat
{
    NSDateFormatter *formatter = NSDateFormatter.alloc.init.autoReleaseIfNotARC;
    
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.dateStyle = NSDateFormatterShortStyle;
    
    return [formatter stringFromDate:self];
}

-(NSString*)asRelativeString
{
    NSDateFormatter *f = NSDateFormatter.alloc.init.autoReleaseIfNotARC;
    f.timeStyle = NSDateFormatterNoStyle;
    f.dateStyle = NSDateFormatterMediumStyle;
    f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"].autoReleaseIfNotARC;
    f.doesRelativeDateFormatting=YES;
    
    return [f stringForObjectValue:self];
}

-(BOOL)isAfter:(NSDate*)d
{
    return [self compare:d] == NSOrderedDescending;
}

-(BOOL)isBefore:(NSDate*)d
{
    return [self compare:d] == NSOrderedAscending;
}

-(BOOL)isPast
{
    return [self isBefore:NSDate.date];
}

-(BOOL)isFuture
{
    return [self isAfter:NSDate.date];
}

-(NSDate*)dateByAddingDays:(int)d
{
    return [self dateByAddingTimeInterval:d * 24 * 60 * 60];
}

-(NSDate*)dateByAddingHours:(int)h
{
    return [self dateByAddingTimeInterval:h * 60 * 60];
}

-(NSDate*)dateByAddingMinutes:(int)m
{
    return [self dateByAddingTimeInterval:m * 60];
}

-(NSDate*)dateByAddingSeconds:(int)s
{
    return [self dateByAddingTimeInterval:s];
}

-(NSInteger)hour
{
    return [[NSCalendar currentCalendar] components:kCFCalendarUnitHour fromDate:self].hour;
}

-(NSInteger)minute
{
    return [[NSCalendar currentCalendar] components:kCFCalendarUnitMinute fromDate:self].minute;
}

-(NSInteger)second
{
    return [[NSCalendar currentCalendar] components:kCFCalendarUnitSecond fromDate:self].second;
}

@end


@implementation NSDecimalNumber(ESUtils)

-(BOOL)isNotANumber
{
    return [[NSDecimalNumber notANumber] isEqualToNumber:self];
}

@end


@implementation NSError(ESUtils)

-(void)log
{
    NSLog(@"%@", self.localizedDescription);
}

-(void)logWithMessage:(NSString*)message
{
    NSLog(@"%@ - %@", message, self);
}

@end


@implementation NSObject(ESUtils)

-(NSString*)className
{
    return [NSString stringWithClassName:self.class];
}

-(id)autoReleaseIfNotARC
{
    #if !HAS_ARC
        [self autorelease];
    #endif
    return self;
}

-(id)releaseIfNotARC
{
    #if !HAS_ARC
        [self release];
    #endif
    return self;
}

-(id)retainIfNotARC
{
    #if !HAS_ARC
        [self retain];
    #endif
    return self;
}

-(void)deallocIfNotARC
{
    #if !HAS_ARC
        [self dealloc];
    #endif
}

@end


@implementation NSRegularExpression(ESUtils)

-(BOOL)matches:(NSString*)string
{
    return [self rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)].location != NSNotFound;
}

@end


@implementation NSString(ESUtils)

-(NSMutableString*)asMutableString
{
    return [self.mutableCopy autoReleaseIfNotARC];
}

//REFACTOR: consider pulling up into a math util library
float logx(float value, float base);
float logx(float value, float base) 
{
    return log10f(value) / log10f(base);
}

+(NSString*)stringWithFormattedFileSize:(unsigned long long)byteLength
{
    if(byteLength == 0)
        return @"0 B";
    //REFACTOR: consider storing for reuse
    NSArray *labels = $array(@"B", @"KB", @"MB", @"GB", @"TB");
    
    int power = MIN(labels.count-1, floor(logx(byteLength, 1024)));
    float size = (float)byteLength/powf(1024, power);
    
    return $format(@"%@ %@",
                   power?$format(@"%1.1f",size):$format(@"%i",byteLength),
                   [labels objectAtIndex:power]);
}

+(NSString*)stringWithClassName:(Class)c
{
    return [NSString stringWithUTF8String:class_getName(c)];
}

+(NSString*)stringWithUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(__bridge NSString *)string autoReleaseIfNotARC];
}

-(NSData*)dataWithUTF8
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString*)strip
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

-(BOOL)containsString:(NSString*)substring
{
    return [self rangeOfString:substring].location != NSNotFound;
}

-(BOOL)isEmpty
{
    return self.length == 0;
}

-(BOOL)isNotEmpty
{
    return self.length > 0;
}

-(BOOL)isBlank
{
    // Shortcuts object creation by testing before trimming.
    return self.isEmpty || self.strip.isEmpty;
}

-(BOOL)isPresent
{
    return !self.isEmpty && !self.strip.isEmpty;
}

//credit: http://stackoverflow.com/questions/1918972/camelcase-to-underscores-and-back-in-objective-c
-(NSString*)asCamelCaseFromUnderscore
{
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [self length]; idx += 1) {
        unichar c = [self characterAtIndex:idx];
        if (c == '_') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

-(NSString*)asUnderscoreFromCamelCase
{
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < [self length]; idx += 1) {
        unichar c = [self characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@"_%@", [[NSString stringWithCharacters:&c length:1] lowercaseString]];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

@end


@implementation NSThread(ESUtils)

+(void)detachNewThreadBlockImplementation:(ESEmptyBlock)block
{
    @autoreleasepool
    {
        block();
    }
}

+(void)detachNewThreadBlock:(ESEmptyBlock)block
{
    [NSThread detachNewThreadSelector:@selector(detachNewThreadBlockImplementation:) toTarget:self withObject:[block copy]];
}

@end

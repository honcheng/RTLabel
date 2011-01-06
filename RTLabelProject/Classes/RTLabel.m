//
//  RTLabel.m
//  RTLabelProject
//
//  Created by honcheng on 1/6/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import "RTLabel.h"



@interface RTLabelComponent : NSObject
{
	NSString *text;
	NSString *tagLabel;
	NSMutableDictionary *attributes;
}

@property (nonatomic, retain) NSString *text, *tagLabel;
@property (nonatomic, retain) NSMutableDictionary *attributes;
- (id)initWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)atrributes;
+ (id)componentWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)atrributes;
@end

@implementation RTLabelComponent
@synthesize text, tagLabel;
@synthesize attributes;

- (id)initWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)_attributes;
{
	if (self = [super init]) 
	{
		self.text = _text;
		self.tagLabel = _tagLabel;
		self.attributes = _attributes;
	}
	return self;
}

+ (id)componentWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)_attributes
{
	return [[[self alloc] initWithString:_text tag:_tagLabel attributes:_attributes] autorelease];
}

- (NSString*)description
{
	NSMutableString *desc = [NSMutableString string];
	[desc appendFormat:@"text: %@", self.text];
	if (self.tagLabel) [desc appendFormat:@", tag: %@", self.tagLabel];
	if (self.attributes) [desc appendFormat:@", attributes: %@", self.attributes];
	return desc;
}

@end

@interface RTLabel()
@property (nonatomic, retain) NSString *_text;
@property (nonatomic, retain) NSString *_plainText;
@property (nonatomic, retain) NSMutableArray *_textComponent;
- (CGFloat)frameHeight:(CTFrameRef)frame;
- (NSArray *)components;
- (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags;
- (NSArray*) colorForHex:(NSString *)hexColor;
@end

@implementation RTLabel
@synthesize _text;
@synthesize font;
@synthesize textColor;
@synthesize _plainText, _textComponent;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		[self setBackgroundColor:[UIColor whiteColor]];
		self.font = [UIFont systemFontOfSize:15];
		self.textColor = [UIColor blackColor];
		self._text = @"";
		_textAlignment = RTTextAlignmentLeft;
		_lineBreakMode = RTTextLineBreakModeWordWrapping;
    }
    return self;
}

- (void)setTextAlignment:(RTTextAlignment)textAlignment
{
	_textAlignment = textAlignment;
	[self setNeedsDisplay];
}

- (void)setLineBreakMode:(RTTextLineBreakMode)lineBreakMode
{
	_lineBreakMode = lineBreakMode;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect 
{
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.frame.size.height);
	CGContextConcatCTM(context, flipVertical);
	
	// Initialize an attributed string.
	CFStringRef string = (CFStringRef)self._plainText;
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), string);
	
	CFMutableDictionaryRef styleDict1 = ( CFDictionaryCreateMutable( (0), 0, (0), (0) ) );
	// Create a color and add it as an attribute to the string.
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorSpaceRelease(rgbColorSpace);
	CFDictionaryAddValue( styleDict1, kCTForegroundColorAttributeName, [self.textColor CGColor] );
	CFAttributedStringSetAttributes( attrString, CFRangeMake( 0, CFAttributedStringGetLength(attrString) ), styleDict1, 0 ); 

	CFMutableDictionaryRef styleDict = ( CFDictionaryCreateMutable( (0), 0, (0), (0) ) );
	
	// attempt to add weight
	float half = 1.0;
	CFNumberRef weight = ( CFNumberCreate( (0), 12, &half ) );
	CFDictionaryAddValue( styleDict, kCTFontWeightTrait, weight );

	// direction
	CTWritingDirection direction = kCTWritingDirectionLeftToRight; 
	// leading
	//CGFloat firstLineIndent = 0.0; 
	//CGFloat headIndent = firstLineIndent + 1.0; 
	//CGFloat tailIndent = headIndent + 1.0; 
	//CGFloat tabInterval = 10; //tailIndent + 1.0; 
	//CGFloat lineHeightMultiple = tabInterval + 1.0; 
	//CGFloat maxLineHeight = lineHeightMultiple + 1.0; 
	//CGFloat minLineHeight = maxLineHeight + 1.0; 
	CGFloat lineSpacing = 1; // minLineHeight + 1.0; 
	
	CTParagraphStyleSetting theSettings[] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment }, // justify text
		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode }, // break mode 
		{ kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(CTWritingDirection), &direction }, 
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing }, // leading
		//{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineIndent }, 
		//{ kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent }, 
		//{ kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &tailIndent }, 
		//{ kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops }, 
		//{ kCTParagraphStyleSpecifierDefaultTabInterval, sizeof(CGFloat), &tabInterval }, 
		//{ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple }, 
		//{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight }, 
		//{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight }, 
		//{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing }, 
		//{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore }
	};
	CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, sizeof(theSettings) / sizeof(CTParagraphStyleSetting));
	CFDictionaryAddValue( styleDict, kCTParagraphStyleAttributeName, theParagraphRef );
	
	int stringLength = CFStringGetLength(string);
	CFAttributedStringSetAttributes( attrString, CFRangeMake( 0, stringLength ), styleDict, 0 ); 
	
	CTFontRef thisFont = CTFontCreateWithName ((CFStringRef)[self.font fontName], [self.font pointSize], NULL); 
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, thisFont);
	
	int position = 0;
	for (RTLabelComponent *component in self._textComponent)
	{
		if ([component.tagLabel isEqualToString:@"i"])
		{
			// make font italic
			UIFont *font2 = [UIFont italicSystemFontOfSize:self.font.pointSize];
			CTFontRef italicFont = CTFontCreateWithName ((CFStringRef)[font2 fontName], [font2 pointSize], NULL); 
			CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTFontAttributeName, italicFont);
		}
		else if ([component.tagLabel isEqualToString:@"b"])
		{
			// make font bold
			UIFont *font2 = [UIFont boldSystemFontOfSize:self.font.pointSize];
			CTFontRef boldFont = CTFontCreateWithName ((CFStringRef)[font2 fontName], [font2 pointSize], NULL); 
			CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTFontAttributeName, boldFont);
		}
		else if ([component.tagLabel isEqualToString:@"u"] || [component.tagLabel isEqualToString:@"uu"])
		{
			// underline
			if ([component.tagLabel isEqualToString:@"u"])
			{
				CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTUnderlineStyleAttributeName,  (CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleSingle]);
			}
			else if ([component.tagLabel isEqualToString:@"uu"])
			{
				CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTUnderlineStyleAttributeName,  (CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleDouble]);
			}
			
			if ([component.attributes objectForKey:@"color"])
			{
				NSString *value = [component.attributes objectForKey:@"color"];
				value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
				
				if ([value rangeOfString:@"#"].location==0)
				{
					value = [value stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
					NSArray *colorComponents = [self colorForHex:value];
					CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
					CGColorRef color = CGColorCreate(rgbColorSpace, components);
					CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]),kCTUnderlineColorAttributeName, color);
				}
				else
				{
					value = [value stringByAppendingString:@"Color"];
					SEL colorSel = NSSelectorFromString(value);
					UIColor *_color = nil;
					if ([UIColor respondsToSelector:colorSel])
					{
						_color = [UIColor performSelector:colorSel];
						CGColorRef color = [_color CGColor];
						CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]),kCTUnderlineColorAttributeName, color);
					}				
				}
			}
		}
		else if ([component.tagLabel isEqualToString:@"font"])
		{
			for (NSString *key in component.attributes)
			{
				NSString *value = [component.attributes objectForKey:key];
				value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
				
				if ([key isEqualToString:@"color"])
				{
					if ([value rangeOfString:@"#"].location==0)
					{
						value = [value stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
						NSArray *colorComponents = [self colorForHex:value];
						CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
						CGColorRef color = CGColorCreate(rgbColorSpace, components);
						CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]),kCTForegroundColorAttributeName, color);
					}
					else
					{
						
						value = [value stringByAppendingString:@"Color"];
						SEL colorSel = NSSelectorFromString(value);
						UIColor *_color = nil;
						if ([UIColor respondsToSelector:colorSel])
						{
							_color = [UIColor performSelector:colorSel];
							CGColorRef color = [_color CGColor];
							CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]),kCTForegroundColorAttributeName, color);
						}				
					}
				}
				else if ([key isEqualToString:@"stroke"])
				{
					CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTStrokeWidthAttributeName, [NSNumber numberWithFloat:[[component.attributes objectForKey:@"stroke"] intValue]]);
				}
				else if ([key isEqualToString:@"kern"])
				{
					CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTKernAttributeName, [NSNumber numberWithFloat:[[component.attributes objectForKey:@"kern"] intValue]]);
				}
			}
			
			UIFont *font2 = nil;
			if ([component.attributes objectForKey:@"face"] && [component.attributes objectForKey:@"size"])
			{
				NSString *fontName = [component.attributes objectForKey:@"face"];
				fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
				
				font2 = [UIFont fontWithName:fontName size:[[component.attributes objectForKey:@"size"] intValue]];
			}
			else if ([component.attributes objectForKey:@"face"] && ![component.attributes objectForKey:@"size"])
			{
				NSString *fontName = [component.attributes objectForKey:@"face"];
				fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
				
				font2 = [UIFont fontWithName:fontName size:self.font.pointSize];
			}
			else if (![component.attributes objectForKey:@"face"] && [component.attributes objectForKey:@"size"])
			{
				font2 = [UIFont fontWithName:[self.font fontName] size:[[component.attributes objectForKey:@"size"] intValue]];
			}
			if (font2)
			{
				CTFontRef customFont = CTFontCreateWithName ((CFStringRef)[font2 fontName], [font2 pointSize], NULL); 
				CFAttributedStringSetAttribute(attrString, CFRangeMake(position, [component.text length]), kCTFontAttributeName, customFont);
			}
		}
		
		position += [component.text length];
	}
	
	//CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 20), kCTVerticalFormsAttributeName, [NSNumber numberWithBool:YES]);
	//CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 20), kCTLigatureAttributeName, [NSNumber numberWithInt:2]);
	//CFAttributedStringSetAttribute(attrString, CFRangeMake(20, 20), kCTParagraphStyleAttributeName, [NSNumber numberWithInt:kCTParagraphStyleSpecifierBaseWritingDirection ]);
	CFAttributedStringSetAttribute(attrString, CFRangeMake(1, 2), kCTSuperscriptAttributeName, [NSNumber numberWithInt:-1 ]);
	
	// Create the framesetter with the attributed string.
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	CFRelease(attrString);
	
	
	// Initialize a rectangular path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	CGPathAddRect(path, NULL, bounds);
	
	// Create the frame and draw it into the graphics context
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, NULL);
	
	CFRelease(framesetter);
	CTFrameDraw(frame, context);
	CFRelease(frame);
	/*
	 const CGFloat border = 0.0;
	 CGRect frameRect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	 CGMutablePathRef path = NULL;
	 CTFrameRef ctframe = NULL;
	 
	 frameRect.size.height = FLT_MAX;
	 frameRect.size.width -= (border * 2);
	 
	 path = CGPathCreateMutable();
	 if (path) {
	 CGPathAddRect(path, NULL, frameRect);
	 ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	 if (ctframe) {
	 frameRect.size.height = [self measureFrameHeight:ctframe];
	 CFRelease(ctframe);
	 }
	 CFRelease(path);
	 }
	 
	 frameRect.origin.y = CGRectGetMaxY(frameRect) - frameRect.size.height - border;
	 frameRect.origin.x += border;
	 
	 path = CGPathCreateMutable();
	 if (path) {
	 CGPathAddRect(path, NULL, frameRect);
	 ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	 if (ctframe) {
	 CGContextAddPath(context, path);
	 CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.5);
	 CGContextFillPath(context);
	 
	 CGContextSetTextMatrix(context, CGAffineTransformIdentity);			
	 CTFrameDraw(ctframe, context);
	 CFRelease(ctframe);
	 }
	 CGPathRelease(path);
	 }*/
}

- (void)setText:(NSString *)text
{
	self._text = text;
	[self parse:self._text valid_tags:nil];
	NSLog(@"%@", self._plainText);
	NSLog(@"%@", self._textComponent); 
	[self setNeedsDisplay];
}

- (NSString*)text
{
	return self._text;
}

- (CGFloat)frameHeight:(CTFrameRef)frame
{
	CFArrayRef lines = CTFrameGetLines(frame);
    CGFloat height = 0.0;
    CGFloat ascent, descent, leading;
    for (CFIndex index = 0; index < CFArrayGetCount(lines); index++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, index);
        CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
        height += (ascent + fabsf(descent) + leading);
    }
    return ceil(height);
}

- (void)dealloc {
	[self._text release];
    [super dealloc];
}

- (NSArray *)components;
{
	NSScanner *scanner = [NSScanner scannerWithString:self._text];
	[scanner setCharactersToBeSkipped:nil]; 
	
	NSMutableArray *components = [NSMutableArray array];
	
	while (![scanner isAtEnd]) 
	{
		NSString *currentComponent;
		NSLog(@">>>>>>> %@", currentComponent);
		BOOL foundComponent = [scanner scanUpToString:@"http" intoString:&currentComponent];
		NSLog(@">>>>>>>11 %@", currentComponent);
		if (foundComponent) 
		{
			[components addObject:currentComponent];
			
			NSString *string;
			BOOL foundURLComponent = [scanner scanUpToString:@" " intoString:&string];
			if (foundURLComponent) 
			{
				// if last character of URL is punctuation, its probably not part of the URL
				NSCharacterSet *punctuationSet = [NSCharacterSet punctuationCharacterSet];
				NSInteger lastCharacterIndex = string.length - 1;
				if ([punctuationSet characterIsMember:[string characterAtIndex:lastCharacterIndex]]) 
				{
					// remove the punctuation from the URL string and move the scanner back
					string = [string substringToIndex:lastCharacterIndex];
					[scanner setScanLocation:scanner.scanLocation - 1];
				}        
				[components addObject:string];
			}
		} 
		else 
		{ // first string is a link
			NSString *string;
			BOOL foundURLComponent = [scanner scanUpToString:@" " intoString:&string];
			if (foundURLComponent) 
			{
				[components addObject:string];
			}
		}
	}
	return [[components copy] autorelease];
}


- (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags
{
	//use to strip the HTML tags from the data
	NSScanner *scanner;
	NSString *text = nil;
	NSString *tag = nil;
	
	NSMutableArray *components = [NSMutableArray array];
	
	//set up the scanner
	scanner = [NSScanner scannerWithString:data];
	NSMutableDictionary *lastAttributes = nil;
	
	int last_position = 0;
	while([scanner isAtEnd] == NO) 
	{
		//find start of tag
		[scanner scanUpToString:@"<" intoString:NULL];
		
		//find end of tag
		[scanner scanUpToString:@">" intoString:&text];
		
		NSMutableDictionary *attributes = nil;
		//get the name of the tag
		if([text rangeOfString:@"</"].location != NSNotFound)
			tag = [text substringFromIndex:2]; //remove </
		else 
		{
			tag = [text substringFromIndex:1]; //remove <
			//find out if there is a space in the tag
			if([tag rangeOfString:@" "].location != NSNotFound)
			{
				attributes = [NSMutableDictionary dictionary];
				NSArray *rawAttributes = [tag componentsSeparatedByString:@" "];
				for (int i=1; i<[rawAttributes count]; i++)
				{
					NSArray *pair = [[rawAttributes objectAtIndex:i] componentsSeparatedByString:@"="];
					if ([pair count]==2)
					{
						[attributes setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
					}
				}
				
				//remove text after a space
				tag = [tag substringToIndex:[tag rangeOfString:@" "].location];
			}
		}

		//if not a valid tag, replace the tag with a space
		if([valid_tags containsObject:tag] == NO)
		{
			NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
			int position = [data rangeOfString:delimiter].location;
			BOOL isEnd = [delimiter rangeOfString:@"</"].location!=NSNotFound;
			if (position!=NSNotFound)
			{
				NSString *text2 = [data substringWithRange:NSMakeRange(last_position, position-last_position)];
				if (isEnd)
				{
					// is inside a tag
					//NSLog(@">>>>>>> %@: %@ %@", tag, text2, lastAttributes);
					[components addObject:[RTLabelComponent componentWithString:text2 tag:tag attributes:lastAttributes]];
				}
				else
				{
					// is outside a tag
					//NSLog(@">>>>>>> normal: %@ %@", text2, lastAttributes);
					[components addObject:[RTLabelComponent componentWithString:text2 tag:nil attributes:lastAttributes]];
				}
	
				//NSLog(@".......... %i %i %i %@", [data length], last_position, position, [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NULL range:NSMakeRange(last_position, position+delimiter.length)]);
				data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
				
				last_position = position;
				
			}
			else
			{
				NSString *text2 = [data substringFromIndex:last_position];
				// is outside a tag
				//NSLog(@">>>>>>> normal: %@ %@", text2, lastAttributes);
				[components addObject:[RTLabelComponent componentWithString:text2 tag:nil attributes:lastAttributes]];
			}
			
			//data = [data stringByReplacingOccurrencesOfString:delimiter withString:@""];

			lastAttributes = attributes;
		}
	}
	
	self._textComponent = components;
	self._plainText = data;
}

- (NSArray*)colorForHex:(NSString *)hexColor 
{
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  

    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString *rString = [hexColor substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  

	
	NSArray *components = [NSArray arrayWithObjects:[NSNumber numberWithFloat:((float) r / 255.0f)],[NSNumber numberWithFloat:((float) g / 255.0f)],[NSNumber numberWithFloat:((float) b / 255.0f)],[NSNumber numberWithFloat:1.0],nil];
	return components;
	
}



@end

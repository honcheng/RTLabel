//
//  RTLabel.m
//  RTLabelProject
//
/**
 * Copyright (c) 2010 Muh Hon Cheng
 * Created by honcheng on 1/6/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import "RTLabel.h"

@interface RTLabelButton : UIButton
{
	int componentIndex;
	NSURL *url;
}
@property (nonatomic, assign) int componentIndex;
@property (nonatomic, retain) NSURL *url;
@end

@implementation RTLabelButton
@synthesize componentIndex;
@synthesize url;
@end


@interface RTLabelComponent : NSObject
{
	NSString *text;
	NSString *tagLabel;
	NSMutableDictionary *attributes;
	int position;
	int componentIndex;
}
@property (nonatomic, assign) int componentIndex;
@property (nonatomic, retain) NSString *text, *tagLabel;
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, assign) int position;

- (id)initWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)_attributes;
+ (id)componentWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)_attributes;
- (id)initWithTag:(NSString*)_tagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes;
+ (id)componentWithTag:(NSString*)_tagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes;

@end

@implementation RTLabelComponent
@synthesize text, tagLabel;
@synthesize attributes;
@synthesize position;
@synthesize componentIndex;

- (id)initWithString:(NSString*)_text tag:(NSString*)_tagLabel attributes:(NSMutableDictionary*)_attributes;
{
    self = [super init];
	if (self) 
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

- (id)initWithTag:(NSString*)_tagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes
{
	if (self = [super init]) 
	{
		self.tagLabel = _tagLabel;
		self.position = _position;
		self.attributes = _attributes;
	}
	return self;
}

+(id)componentWithTag:(NSString*)_tagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes
{
	return [[[self alloc] initWithTag:_tagLabel position:_position attributes:_attributes] autorelease];
}

- (NSString*)description
{
	NSMutableString *desc = [NSMutableString string];
	[desc appendFormat:@"text: %@", self.text];
	[desc appendFormat:@", position: %i", self.position];
	if (self.tagLabel) [desc appendFormat:@", tag: %@", self.tagLabel];
	if (self.attributes) [desc appendFormat:@", attributes: %@", self.attributes];
	return desc;
}

@end

@interface RTLabel()
@property (nonatomic, retain) NSString *_text;
@property (nonatomic, retain) NSString *_plainText;
@property (nonatomic, retain) NSMutableArray *_textComponent;
@property (nonatomic, assign) CGSize _optimumSize;

- (CGFloat)frameHeight:(CTFrameRef)frame;
- (NSArray *)components;
- (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags;
- (NSArray*) colorForHex:(NSString *)hexColor;
//- (void)render;
- (void)extractTextStyle:(NSString*)text;


#pragma mark -
#pragma mark styling
- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyUnderlineColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyFontAttributes:(NSDictionary*)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length;
@end

@implementation RTLabel
@synthesize _text;
@synthesize font;
@synthesize textColor;
@synthesize _plainText, _textComponent;
@synthesize _optimumSize;
@synthesize linkAttributes, selectedLinkAttributes;
@synthesize delegate;
@synthesize paragraphReplacement;

- (id)initWithFrame:(CGRect)_frame {
    
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code.
		[self setBackgroundColor:[UIColor clearColor]];
		self.font = [UIFont systemFontOfSize:15];
		self.textColor = [UIColor blackColor];
		//self._text = @"";
		[self setText:@""];
		_textAlignment = RTTextAlignmentLeft;
		_lineBreakMode = RTTextLineBreakModeWordWrapping;
		_lineSpacing = 3;
		currentSelectedButtonComponentIndex = -1;
        self.paragraphReplacement = @"\n";
		
		[self setMultipleTouchEnabled:YES];
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
	[self render];
}

- (void)render
{
	if (currentSelectedButtonComponentIndex==-1)
	{
		for (id view in [self subviews])
		{
			if ([view isKindOfClass:[UIView class]])
			{
				[view removeFromSuperview];
			}
		}
	}
	
    if (!self._plainText) return;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context != NULL)
    {
        // Drawing code.
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.frame.size.height);
        CGContextConcatCTM(context, flipVertical);
    }
	
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
	
	[self applyParagraphStyleToText:attrString attributes:nil atPosition:0 withLength:CFAttributedStringGetLength(attrString)];
	
	
	CTFontRef thisFont = CTFontCreateWithName ((CFStringRef)[self.font fontName], [self.font pointSize], NULL); 
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, thisFont);
	
	NSMutableArray *links = [NSMutableArray array];
	
	for (RTLabelComponent *component in self._textComponent)
	{
		int index = [self._textComponent indexOfObject:component];
		component.componentIndex = index;
		
		if ([component.tagLabel caseInsensitiveCompare:@"i"] == NSOrderedSame)
		{
			// make font italic
			[self applyItalicStyleToText:attrString atPosition:component.position withLength:[component.text length]];
		}
		else if ([component.tagLabel caseInsensitiveCompare:@"b"] == NSOrderedSame)
		{
			// make font bold
			[self applyBoldStyleToText:attrString atPosition:component.position withLength:[component.text length]];
		}
		else if ([component.tagLabel caseInsensitiveCompare:@"a"] == NSOrderedSame)
		{
			if (currentSelectedButtonComponentIndex==index)
			{
				if (selectedLinkAttributes)
				{
					[self applyFontAttributes:selectedLinkAttributes toText:attrString atPosition:component.position withLength:[component.text length]];
				}
				else
				{
					[self applyBoldStyleToText:attrString atPosition:component.position withLength:[component.text length]];
					[self applyColor:@"#FF0000" toText:attrString atPosition:component.position withLength:[component.text length]];
				}
			}
			else
			{
				if (linkAttributes)
				{
					[self applyFontAttributes:linkAttributes toText:attrString atPosition:component.position withLength:[component.text length]];
				}
				else
				{
					[self applyBoldStyleToText:attrString atPosition:component.position withLength:[component.text length]];
					[self applySingleUnderlineText:attrString atPosition:component.position withLength:[component.text length]];
				}
			}
			
			NSString *value = [component.attributes objectForKey:@"href"];
			value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
			[component.attributes setObject:value forKey:@"href"];
			
			[links addObject:component];
		}
		else if ([component.tagLabel caseInsensitiveCompare:@"u"] == NSOrderedSame || [component.tagLabel caseInsensitiveCompare:@"uu"] == NSOrderedSame)
		{
			// underline
			if ([component.tagLabel caseInsensitiveCompare:@"u"] == NSOrderedSame)
			{
				[self applySingleUnderlineText:attrString atPosition:component.position withLength:[component.text length]];
			}
			else if ([component.tagLabel caseInsensitiveCompare:@"uu"] == NSOrderedSame)
			{
				[self applyDoubleUnderlineText:attrString atPosition:component.position withLength:[component.text length]];
			}
			
			if ([component.attributes objectForKey:@"color"])
			{
				NSString *value = [component.attributes objectForKey:@"color"];
				[self applyUnderlineColor:value toText:attrString atPosition:component.position withLength:[component.text length]];
			}
		}
		else if ([component.tagLabel caseInsensitiveCompare:@"font"] == NSOrderedSame)
		{
			[self applyFontAttributes:component.attributes toText:attrString atPosition:component.position withLength:[component.text length]];
		}
		else if ([component.tagLabel caseInsensitiveCompare:@"p"] == NSOrderedSame)
		{
			[self applyParagraphStyleToText:attrString attributes:component.attributes atPosition:component.position withLength:[component.text length]];
		}
		
	}
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
	
    // Initialize a rectangular path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	CGPathAddRect(path, NULL, bounds);
	
	// Create the frame and draw it into the graphics context
	//CTFrameRef 
	frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, NULL);
	
	CFRange range;
	CGSize constraint = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
	self._optimumSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self._plainText length]), nil, constraint, &range);
	
	
	if (currentSelectedButtonComponentIndex==-1)
	{
		// only check for linkable items the first time, not when it's being redrawn on button pressed
		
		for (RTLabelComponent *linkableComponents in links)
		{
			float height = 0.0;
			CFArrayRef frameLines = CTFrameGetLines(frame);
			for (CFIndex i=0; i<CFArrayGetCount(frameLines); i++)
			{
				CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(frameLines, i);
				CFRange lineRange = CTLineGetStringRange(line);
				CGFloat ascent;
				CGFloat descent;
				CGFloat leading;
				
				CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
				
				if ( (linkableComponents.position<lineRange.location && linkableComponents.position+linkableComponents.text.length>lineRange.location) || (linkableComponents.position>=lineRange.location && linkableComponents.position<lineRange.location+lineRange.length))
				{
					//NSLog(@"line %i: location %i, length %i", i+1, lineRange.location, lineRange.length);
					//NSLog(@"ascent %f, descent %f, leading %f, width %f", ascent, descent, leading, width);
					//NSLog(@"height %f", height);
					
					CGFloat secondaryOffset;
					double primaryOffset = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(frameLines,i), linkableComponents.position, &secondaryOffset);
					double primaryOffset2 = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(frameLines,i), linkableComponents.position+linkableComponents.text.length, NULL);
					//NSLog(@"primary offset %f, secondary offset %f", primaryOffset, secondaryOffset);
					
					float button_width = primaryOffset2 - primaryOffset;
					
					RTLabelButton *button = [[RTLabelButton alloc] initWithFrame:CGRectMake(primaryOffset, height, button_width, ascent+descent)];
					[self addSubview:button];
					[button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
					[button setComponentIndex:linkableComponents.componentIndex];
					
					[button setUrl:[NSURL URLWithString:[linkableComponents.attributes objectForKey:@"href"]]];
					[button addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
					[button addTarget:self action:@selector(onButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
					[button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
					
				}
				
				//height += (ascent + fabsf(descent) + leading);
				
				//CGRect rect = CTLineGetImageBounds(line, context);
				//NSLog(@"???? %f %f", rect.origin.y, rect.size.height);
				
				CGPoint origin;
				CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin);
				origin.y = self.frame.size.height - origin.y;
				//NSLog(@"---------- %f", origin.y);
				height = origin.y + descent + _lineSpacing;
			}
		}
	}
	
	visibleRange = CTFrameGetVisibleStringRange(frame);
	//NSLog(@"??? >>>> %i %i", visibleRange.location, visibleRange.length);
	
	//CFArrayRef frameLines = CTFrameGetLines(frame);
	//NSLog(@">>>>>>>>>>>>> %f %f %f", [self frameHeight:frame], self._optimumSize.height, (self._optimumSize.height-[self frameHeight:frame])/(CFArrayGetCount(frameLines)-1));
	
	CFRelease(thisFont);
	//CFRelease(theParagraphRef);
	CFRelease(path);
	CFRelease(styleDict1);
	CFRelease(styleDict);
	//CFRelease(weight);
	CFRelease(framesetter);
	
	CTFrameDraw(frame, context);
	//CFRelease(frame);
	
	/*
	 CFArrayRef frameLines = CTFrameGetLines(frame);
	 for (CFIndex i=0; i<CFArrayGetCount(frameLines); i++)
	 {
	 CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(frameLines, i);
	 CFRange cfStringRange = CTLineGetStringRange(line);
	 NSRange stringRange = NSMakeRange(cfStringRange.location, cfStringRange.length);
	 static const unichar softHypen = 0x00AD;
	 unichar lastChar = [self._plainText characterAtIndex:stringRange.location + stringRange.length-1];
	 
	 if(softHypen == lastChar) {
	 NSMutableAttributedString* lineAttrString = [[attrString attributedSubstringFromRange:stringRange] mutableCopy];
	 NSRange replaceRange = NSMakeRange(stringRange.length-1, 1);
	 [lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];
	 
	 CTLineRef hyphenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)lineAttrString);
	 CTLineRef justifiedLine = CTLineCreateJustifiedLine(hyphenLine, 1.0, self.frame.size.width); 
	 
	 CTLineDraw(justifiedLine, context);
	 } else {
	 //CTLineDraw(originalLine, context);
	 }
	 }
	 */
    
	
    
}

#pragma mark -
#pragma mark styling

- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length
{
	//NSLog(@"%@", attributes);
	
	CFMutableDictionaryRef styleDict = ( CFDictionaryCreateMutable( (0), 0, (0), (0) ) );
	
	// direction
	CTWritingDirection direction = kCTWritingDirectionLeftToRight; 
	// leading
	CGFloat firstLineIndent = 0.0; 
	CGFloat headIndent = 0.0; 
	CGFloat tailIndent = 0.0; 
	CGFloat lineHeightMultiple = 1.0; 
	CGFloat maxLineHeight = 0; 
	CGFloat minLineHeight = 0; 
	CGFloat paragraphSpacing = 0.0;
	CGFloat paragraphSpacingBefore = 0.0;
	int textAlignment = _textAlignment;
	int lineBreakMode = _lineBreakMode;
	int lineSpacing = _lineSpacing;
	
	for (int i=0; i<[[attributes allKeys] count]; i++)
	{
		NSString *key = [[attributes allKeys] objectAtIndex:i];
		id value = [attributes objectForKey:key];
		if ([key caseInsensitiveCompare:@"align"] == NSOrderedSame)
		{
			if ([value caseInsensitiveCompare:@"left"] == NSOrderedSame)
			{
				textAlignment = kCTLeftTextAlignment;
			}
			else if ([value caseInsensitiveCompare:@"right"] == NSOrderedSame)
			{
				textAlignment = kCTRightTextAlignment;
			}
			else if ([value caseInsensitiveCompare:@"justify"] == NSOrderedSame)
			{
				textAlignment = kCTJustifiedTextAlignment;
			}
			else if ([value caseInsensitiveCompare:@"center"] == NSOrderedSame)
			{
				textAlignment = kCTCenterTextAlignment;
			}
		}
		else if ([key caseInsensitiveCompare:@"indent"] == NSOrderedSame)
		{
			firstLineIndent = [value floatValue];
		}
		else if ([key caseInsensitiveCompare:@"linebreakmode"] == NSOrderedSame)
		{
			if ([value caseInsensitiveCompare:@"wordwrap"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByWordWrapping;
			}
			else if ([value caseInsensitiveCompare:@"charwrap"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByCharWrapping;
			}
			else if ([value caseInsensitiveCompare:@"clipping"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByClipping;
			}
			else if ([value caseInsensitiveCompare:@"truncatinghead"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByTruncatingHead;
			}
			else if ([value caseInsensitiveCompare:@"truncatingtail"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByTruncatingTail;
			}
			else if ([value caseInsensitiveCompare:@"truncatingmiddle"] == NSOrderedSame)
			{
				lineBreakMode = kCTLineBreakByTruncatingMiddle;
			}
		}
	}
	
	CTParagraphStyleSetting theSettings[] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode  },
		{ kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(CTWritingDirection), &direction }, 
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing }, // leading
		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineIndent }, 
		{ kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent }, 
		{ kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &tailIndent }, 
		{ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple }, 
		{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight }, 
		{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight }, 
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing }, 
		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore }
	};
	
	
	CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, sizeof(theSettings) / sizeof(CTParagraphStyleSetting));
	CFDictionaryAddValue( styleDict, kCTParagraphStyleAttributeName, theParagraphRef );
	
	CFAttributedStringSetAttributes( text, CFRangeMake(position, length), styleDict, 0 ); 
	CFRelease(theParagraphRef);
	CFRelease(styleDict);
}

- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTUnderlineStyleAttributeName,  (CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleSingle]);
}

- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTUnderlineStyleAttributeName,  (CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleDouble]);
}

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CTFontRef actualFontSize = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, NULL);
	
	UIFont *_font = [UIFont boldSystemFontOfSize:CTFontGetSize(actualFontSize)];
	CTFontRef italicFont = CTFontCreateWithName ((CFStringRef)[_font fontName], [_font pointSize], NULL); 
	CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, italicFont);
	
	CFRelease(italicFont);
}

- (void)applyFontAttributes:(NSDictionary*)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	for (NSString *key in attributes)
	{
		NSString *value = [attributes objectForKey:key];
		value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		if ([key caseInsensitiveCompare:@"color"] == NSOrderedSame)
		{
			[self applyColor:value toText:text atPosition:position withLength:length];
		}
		else if ([key caseInsensitiveCompare:@"stroke"] == NSOrderedSame)
		{
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTStrokeWidthAttributeName, [NSNumber numberWithFloat:[[attributes objectForKey:@"stroke"] intValue]]);
		}
		else if ([key caseInsensitiveCompare:@"kern"] == NSOrderedSame)
		{
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTKernAttributeName, [NSNumber numberWithFloat:[[attributes objectForKey:@"kern"] intValue]]);
		}
		else if ([key caseInsensitiveCompare:@"underline"] == NSOrderedSame)
		{
			int numberOfLines = [value intValue];
			if (numberOfLines==1)
			{
				[self applySingleUnderlineText:text atPosition:position withLength:length];
			}
			else if (numberOfLines==2)
			{
				[self applyDoubleUnderlineText:text atPosition:position withLength:length];
			}
		}
		else if ([key caseInsensitiveCompare:@"style"] == NSOrderedSame)
		{
			if ([value caseInsensitiveCompare:@"bold"] == NSOrderedSame)
			{
				[self applyBoldStyleToText:text atPosition:position withLength:length];
			}
			else if ([value caseInsensitiveCompare:@"italic"] == NSOrderedSame)
			{
				[self applyItalicStyleToText:text atPosition:position withLength:length];
			}
		}
	}
	
	UIFont *_font = nil;
	if ([attributes objectForKey:@"face"] && [attributes objectForKey:@"size"])
	{
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		_font = [UIFont fontWithName:fontName size:[[attributes objectForKey:@"size"] intValue]];
	}
	else if ([attributes objectForKey:@"face"] && ![attributes objectForKey:@"size"])
	{
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		_font = [UIFont fontWithName:fontName size:self.font.pointSize];
	}
	else if (![attributes objectForKey:@"face"] && [attributes objectForKey:@"size"])
	{
		_font = [UIFont fontWithName:[self.font fontName] size:[[attributes objectForKey:@"size"] intValue]];
	}
	if (_font)
	{
		CTFontRef customFont = CTFontCreateWithName ((CFStringRef)[_font fontName], [_font pointSize], NULL); 
		CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, customFont);
		CFRelease(customFont);
	}
}

- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CTFontRef actualFontSize = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, NULL);
	
	UIFont *_font = [UIFont boldSystemFontOfSize:CTFontGetSize(actualFontSize)];
	CTFontRef boldFont = CTFontCreateWithName ((CFStringRef)[_font fontName], [_font pointSize], NULL); 
	CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, boldFont);
	CFRelease(boldFont);
}

- (void)applyColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	if ([value rangeOfString:@"#"].location==0)
	{
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
		CGColorRef color = CGColorCreate(rgbColorSpace, components);
		CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTForegroundColorAttributeName, color);
		CFRelease(color);
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
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTForegroundColorAttributeName, color);
			
		}				
	}
	CGColorSpaceRelease(rgbColorSpace);
}

- (void)applyUnderlineColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
	if ([value rangeOfString:@"#"].location==0)
	{
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
		CGColorRef color = CGColorCreate(rgbColorSpace, components);
		CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTUnderlineColorAttributeName, color);
		CGColorRelease(color);
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
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTUnderlineColorAttributeName, color);
			// CGColorRelease(color);
		}				
	}
	CGColorSpaceRelease(rgbColorSpace);
}

#pragma mark -
#pragma mark button 

- (void)onButtonTouchDown:(id)sender
{
	RTLabelButton *button = (RTLabelButton*)sender;
	currentSelectedButtonComponentIndex = button.componentIndex;
	[self setNeedsDisplay];
}

- (void)onButtonTouchUpOutside:(id)sender
{
	//RTLabelButton *button = (RTLabelButton*)sender;
	currentSelectedButtonComponentIndex = -1;
	[self setNeedsDisplay];
}

- (void)onButtonPressed:(id)sender
{
	RTLabelButton *button = (RTLabelButton*)sender;
	currentSelectedButtonComponentIndex = -1;
	[self setNeedsDisplay];
	
	if ([delegate respondsToSelector:@selector(rtLabel:didSelectLinkWithURL:)])
	{
		[delegate rtLabel:self didSelectLinkWithURL:button.url];
	}
}

- (CGSize)optimumSize
{
	[self render];
	return self._optimumSize;
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
	_lineSpacing = lineSpacing;
	[self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
	self._text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
	[self extractTextStyle:self._text];
	[self setNeedsDisplay];
}

- (NSString*)text
{
	return self._text;
}

// http://forums.macrumors.com/showthread.php?t=925312
// not accurate
- (CGFloat)frameHeight:(CTFrameRef)theFrame
{
	CFArrayRef lines = CTFrameGetLines(theFrame);
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
	//CFRelease(frame);
	//CFRelease(framesetter);
    self._textComponent = nil;
    self._plainText = nil;
    self.textColor = nil;
    self.font = nil;
	self._text = nil;
    self.paragraphReplacement = nil;
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
		//NSLog(@">>>>>>> %@", currentComponent);
		BOOL foundComponent = [scanner scanUpToString:@"http" intoString:&currentComponent];
		//NSLog(@">>>>>>>11 %@", currentComponent);
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

- (void)extractTextStyle:(NSString*)data
{
	//NSLog(@"%@", data);
	
	NSScanner *scanner; 
	NSString *text = nil;
	NSString *tag = nil;
	
	NSMutableArray *components = [NSMutableArray array];
	
	int last_position = 0;
	scanner = [NSScanner scannerWithString:data];
	while (![scanner isAtEnd])
	{
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&text];
		
		NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
		int position = [data rangeOfString:delimiter].location;
		if (position!=NSNotFound)
		{
			if ([delimiter rangeOfString:@"<p"].location==0)
			{
				data = [data stringByReplacingOccurrencesOfString:delimiter withString:self.paragraphReplacement options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
			}
			else
			{
				data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
			}
			
			data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
			data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
		}
		
		if ([text rangeOfString:@"</"].location==0)
		{
			// end of tag
			tag = [text substringFromIndex:2];
			//NSLog(@"end of tag: %@", tag);
			if (position!=NSNotFound)
			{
				
				for (int i=[components count]-1; i>=0; i--)
				{
					RTLabelComponent *component = [components objectAtIndex:i];
					if (component.text==nil && [component.tagLabel isEqualToString:tag])
					{
						NSString *text2 = [data substringWithRange:NSMakeRange(component.position, position-component.position)];
						component.text = text2;
						break;
					}
				}
			}
			
			
		}
		else
		{
			// start of tag
			NSArray *textComponents = [[text substringFromIndex:1] componentsSeparatedByString:@" "];
			tag = [textComponents objectAtIndex:0];
			//NSLog(@"start of tag: %@", tag);
			NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
			for (int i=1; i<[textComponents count]; i++)
			{
				NSArray *pair = [[textComponents objectAtIndex:i] componentsSeparatedByString:@"="];
				if ([pair count] > 0) {
					NSString *key = [[pair objectAtIndex:0] lowercaseString];
					
					if ([pair count]>=2) {
						// Trim " charactere
						NSString *value = [[pair subarrayWithRange:NSMakeRange(1, [pair count] - 1)] componentsJoinedByString:@"="];
						value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 1)];
						value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange([value length]-1, 1)];
						
						[attributes setObject:value forKey:key];
					} else if ([pair count]==1) {
						[attributes setObject:key forKey:key];
					}
				}
			}
			//NSLog(@"%@", attributes);
			
			RTLabelComponent *component = [RTLabelComponent componentWithString:nil tag:tag attributes:attributes];
			component.position = position;
			[components addObject:component];
		}
		
		last_position = position;
		
	}
	
	//NSLog(@"%@", components);
	self._textComponent = components;
	self._plainText = data;
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
	//self._plainText = [self._plainText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	//self._plainText = [self._plainText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
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

#pragma mark touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
	 UITouch *touch = [touches anyObject];
	 CGPoint currentTouch = [touch locationInView:self];
	 //NSLog(@"%i %i", currentTouch.x, currentTouch.y);
	 
	 float height = 0.0;
	 CFArrayRef frameLines = CTFrameGetLines(frame);
	 for (CFIndex i=0; i<CFArrayGetCount(frameLines); i++)
	 {
	 CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(frameLines, i);
	 CFRange lineRange = CTLineGetStringRange(line);
	 CGFloat ascent;
	 CGFloat descent;
	 CGFloat leading;
	 
	 CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	 
	 CGPoint origin;
	 CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin);
	 origin.y = self.frame.size.height - origin.y;
	 height = origin.y + descent + _lineSpacing;
	 
	 if (currentTouch.y < height)
	 {
	 for (int j=0; j<lineRange.length; j++)
	 {
	 CGFloat secondaryOffset;
	 double primaryOffset = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(frameLines,i),lineRange.location+j, &secondaryOffset);
	 //NSLog(@"? %i %i %f", j, lineRange.location, primaryOffset);
	 if (primaryOffset>currentTouch.x)
	 {
	 //NSLog(@">>>>> %i", lineRange.location+j);
	 //NSLog(@"clicked on [%@]", [self._plainText substringWithRange:NSMakeRange(lineRange.location+j-1, 1)]);
	 break;
	 }
	 
	 }
	 break;
	 }
	 }*/
}


- (NSString*)visibleText
{
    [self render];
    NSString *text = [_text substringWithRange:NSMakeRange(visibleRange.location, visibleRange.length)];
    return text;
}

@end

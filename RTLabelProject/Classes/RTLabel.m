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
@property (nonatomic, assign) int componentIndex;
@property (nonatomic) NSURL *url;
@end

@implementation RTLabelButton
@end

@implementation RTLabelComponent

- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
    self = [super init];
	if (self) {
		_text = aText;
		_tagLabel = aTagLabel;
		_attributes = theAttributes;
	}
	return self;
}

+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
	return [[self alloc] initWithString:aText tag:aTagLabel attributes:theAttributes];
}

- (id)initWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes 
{
    self = [super init];
    if (self) {
        _tagLabel = aTagLabel;
		_position = aPosition;
		_attributes = theAttributes;
    }
    return self;
}

+(id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
	return [[self alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes];
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

@implementation RTLabelExtractedComponent

+ (RTLabelExtractedComponent*)rtLabelExtractComponentsWithTextComponent:(NSMutableArray*)textComponents plainText:(NSString*)plainText
{
    RTLabelExtractedComponent *component = [[RTLabelExtractedComponent alloc] init];
    [component setTextComponents:textComponents];
    [component setPlainText:plainText];
    return component;
}

@end

@interface RTLabel()
- (CGFloat)frameHeight:(CTFrameRef)frame;
- (NSArray *)components;
- (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags;
- (NSArray*) colorForHex:(NSString *)hexColor;
- (void)render;

#pragma mark -
#pragma mark styling

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyBoldItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyUnderlineColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyFontAttributes:(NSDictionary*)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length;
@end

@implementation RTLabel

- (id)initWithFrame:(CGRect)_frame
{
    self = [super initWithFrame:_frame];
    if (self)
	{
		[self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{    
    self = [super initWithCoder:aDecoder];
    if (self)
	{
		[self initialize];
    }
    return self;
}

- (void)initialize
{
	[self setBackgroundColor:[UIColor clearColor]];

	_font = [UIFont systemFontOfSize:15];
	_textColor = [UIColor blackColor];
	_text = @"";
	_textAlignment = RTTextAlignmentLeft;
	_lineBreakMode = RTTextLineBreakModeWordWrapping;
	_lineSpacing = 3;
	_currentSelectedButtonComponentIndex = -1;
	_paragraphReplacement = @"\n";
	
	[self setMultipleTouchEnabled:YES];
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
	if (self.currentSelectedButtonComponentIndex==-1)
	{
		for (id view in [self subviews])
		{
			if ([view isKindOfClass:[UIView class]])
			{
				[view removeFromSuperview];
			}
		}
	}
	
    if (!self.plainText) return;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context != NULL)
    {
        // Drawing code.
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.frame.size.height);
        CGContextConcatCTM(context, flipVertical);
    }
	
	// Initialize an attributed string.
	CFStringRef string = (__bridge CFStringRef)self.plainText;
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
	
	
	CTFontRef thisFont = CTFontCreateWithName ((__bridge CFStringRef)[self.font fontName], [self.font pointSize], NULL); 
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, thisFont);
	
	NSMutableArray *links = [NSMutableArray array];
	NSMutableArray *textComponents = nil;
    if (self.highlighted) textComponents = self.highlightedTextComponents;
    else textComponents = self.textComponents;
    
	for (RTLabelComponent *component in textComponents)
	{
		int index = [textComponents indexOfObject:component];
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
        else if ([component.tagLabel caseInsensitiveCompare:@"bi"] == NSOrderedSame)
        {
            [self applyBoldItalicStyleToText:attrString atPosition:component.position withLength:[component.text length]];
        }
		else if ([component.tagLabel caseInsensitiveCompare:@"a"] == NSOrderedSame)
		{
			if (self.currentSelectedButtonComponentIndex==index)
			{
				if (self.selectedLinkAttributes)
				{
					[self applyFontAttributes:self.selectedLinkAttributes toText:attrString atPosition:component.position withLength:[component.text length]];
				}
				else
				{
					[self applyBoldStyleToText:attrString atPosition:component.position withLength:[component.text length]];
					[self applyColor:@"#FF0000" toText:attrString atPosition:component.position withLength:[component.text length]];
				}
			}
			else
			{
				if (self.linkAttributes)
				{
					[self applyFontAttributes:self.linkAttributes toText:attrString atPosition:component.position withLength:[component.text length]];
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
		else if ([component.tagLabel caseInsensitiveCompare:@"center"] == NSOrderedSame)
		{
			[self applyCenterStyleToText:attrString attributes:component.attributes atPosition:component.position withLength:[component.text length]];
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
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, NULL);
	
	CFRange range;
	CGSize constraint = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
	self.optimumSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self.plainText length]), nil, constraint, &range);
	
	
	if (self.currentSelectedButtonComponentIndex==-1)
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
                CGPoint origin;
				CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &origin);
                
				if ( (linkableComponents.position<lineRange.location && linkableComponents.position+linkableComponents.text.length>(u_int16_t)(lineRange.location)) || (linkableComponents.position>=lineRange.location && linkableComponents.position<lineRange.location+lineRange.length))
				{
					CGFloat secondaryOffset;
					CGFloat primaryOffset = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(frameLines,i), linkableComponents.position, &secondaryOffset);
					CGFloat primaryOffset2 = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(frameLines,i), linkableComponents.position+linkableComponents.text.length, NULL);
					
					CGFloat button_width = primaryOffset2 - primaryOffset;
					
					RTLabelButton *button = [[RTLabelButton alloc] initWithFrame:CGRectMake(primaryOffset+origin.x, height, button_width, ascent+descent)];
					
					[button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
					[button setComponentIndex:linkableComponents.componentIndex];
					
					[button setUrl:[NSURL URLWithString:[linkableComponents.attributes objectForKey:@"href"]]];
					[button addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
					[button addTarget:self action:@selector(onButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
					[button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
					
				}
				
				origin.y = self.frame.size.height - origin.y;
				height = origin.y + descent + _lineSpacing;
			}
		}
	}
	
	self.visibleRange = CTFrameGetVisibleStringRange(frame);

	CFRelease(thisFont);
	CFRelease(path);
	CFRelease(styleDict1);
	CFRelease(styleDict);
	CFRelease(framesetter);
	CTFrameDraw(frame, context);
    CFRelease(frame);
}

#pragma mark -
#pragma mark styling

- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length
{
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
	CTTextAlignment textAlignment = (CTTextAlignment)_textAlignment;
	CTLineBreakMode lineBreakMode = (CTLineBreakMode)_lineBreakMode;
	CGFloat lineSpacing = _lineSpacing;
	
	for (NSUInteger i=0; i<[[attributes allKeys] count]; i++)
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
		{ kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }, // leading
		{ kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing }, // leading
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

- (void)applyCenterStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length
{
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
	int lineSpacing = (int)_lineSpacing;

    textAlignment = kCTCenterTextAlignment;
	
	CTParagraphStyleSetting theSettings[] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode  },
		{ kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(CTWritingDirection), &direction },
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
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
	CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTUnderlineStyleAttributeName,  (__bridge CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleSingle]);
}

- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTUnderlineStyleAttributeName,  (__bridge CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleDouble]);
}

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
    CFTypeRef actualFontRef = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, NULL);
    CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(actualFontRef, 0.0, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    if (!italicFontRef) {
        //fallback to system italic font
        UIFont *font = [UIFont italicSystemFontOfSize:CTFontGetSize(actualFontRef)];
        italicFontRef = CTFontCreateWithName ((__bridge CFStringRef)[font fontName], [font pointSize], NULL);
    }
    CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, italicFontRef);
    CFRelease(italicFontRef);
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
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTStrokeWidthAttributeName, (__bridge CFTypeRef)([NSNumber numberWithFloat:[[attributes objectForKey:@"stroke"] intValue]]));
		}
		else if ([key caseInsensitiveCompare:@"kern"] == NSOrderedSame)
		{
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTKernAttributeName, (__bridge CFTypeRef)([NSNumber numberWithFloat:[[attributes objectForKey:@"kern"] intValue]]));
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
	
	UIFont *font = nil;
	if ([attributes objectForKey:@"face"] && [attributes objectForKey:@"size"])
	{
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		font = [UIFont fontWithName:fontName size:[[attributes objectForKey:@"size"] intValue]];
	}
	else if ([attributes objectForKey:@"face"] && ![attributes objectForKey:@"size"])
	{
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		font = [UIFont fontWithName:fontName size:self.font.pointSize];
	}
	else if (![attributes objectForKey:@"face"] && [attributes objectForKey:@"size"])
	{
		font = [UIFont fontWithName:[self.font fontName] size:[[attributes objectForKey:@"size"] intValue]];
	}
	if (font)
	{
		CTFontRef customFont = CTFontCreateWithName ((__bridge CFStringRef)[font fontName], [font pointSize], NULL); 
		CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, customFont);
		CFRelease(customFont);
	}
}

- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
    CFTypeRef actualFontRef = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, NULL);
    CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(actualFontRef, 0.0, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
    if (!boldFontRef) {
        //fallback to system bold font
        UIFont *font = [UIFont boldSystemFontOfSize:CTFontGetSize(actualFontRef)];
        boldFontRef = CTFontCreateWithName ((__bridge CFStringRef)[font fontName], [font pointSize], NULL);
    }
    CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, boldFontRef);
    CFRelease(boldFontRef);
}

- (void)applyBoldItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
    CFTypeRef actualFontRef = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, NULL);
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(actualFontRef, 0.0, NULL, kCTFontBoldTrait | kCTFontItalicTrait , kCTFontBoldTrait | kCTFontItalicTrait);
    if (!boldItalicFontRef) {
        //try fallback to system boldItalic font
        NSString *fontName = [NSString stringWithFormat:@"%@-BoldOblique", self.font.fontName];
        boldItalicFontRef = CTFontCreateWithName ((__bridge CFStringRef)fontName, [self.font pointSize], NULL);
    }
    
    if (boldItalicFontRef) {
        CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, boldItalicFontRef);
        CFRelease(boldItalicFontRef);
    }

}

- (void)applyColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	
	if ([value rangeOfString:@"#"].location==0)
	{
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
		CGColorRef color = CGColorCreate(rgbColorSpace, components);
		CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTForegroundColorAttributeName, color);
		CFRelease(color);
        CGColorSpaceRelease(rgbColorSpace);
	} else {
		value = [value stringByAppendingString:@"Color"];
		SEL colorSel = NSSelectorFromString(value);
		UIColor *_color = nil;
		if ([UIColor respondsToSelector:colorSel]) {
			_color = [UIColor performSelector:colorSel];
			CGColorRef color = [_color CGColor];
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTForegroundColorAttributeName, color);
		}				
	}
}

- (void)applyUnderlineColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	
	value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
	if ([value rangeOfString:@"#"].location==0) {
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
		CGColorRef color = CGColorCreate(rgbColorSpace, components);
		CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTUnderlineColorAttributeName, color);
		CGColorRelease(color);
        CGColorSpaceRelease(rgbColorSpace);
	}
	else
	{
		value = [value stringByAppendingString:@"Color"];
		SEL colorSel = NSSelectorFromString(value);
		if ([UIColor respondsToSelector:colorSel]) {
			UIColor *_color = [UIColor performSelector:colorSel];
			CGColorRef color = [_color CGColor];
			CFAttributedStringSetAttribute(text, CFRangeMake(position, length),kCTUnderlineColorAttributeName, color);
			//CGColorRelease(color);
		}				
	}
	
}

#pragma mark -
#pragma mark button 

- (void)onButtonTouchDown:(id)sender
{
	RTLabelButton *button = (RTLabelButton*)sender;
    [self setCurrentSelectedButtonComponentIndex:button.componentIndex];
	[self setNeedsDisplay];
}

- (void)onButtonTouchUpOutside:(id)sender
{
	[self setCurrentSelectedButtonComponentIndex:-1];
	[self setNeedsDisplay];
}

- (void)onButtonPressed:(id)sender
{
	RTLabelButton *button = (RTLabelButton*)sender;
	[self setCurrentSelectedButtonComponentIndex:-1];
	[self setNeedsDisplay];

	if ([self.delegate respondsToSelector:@selector(rtLabel:didSelectLinkWithURL:)])
	{
		[self.delegate rtLabel:self didSelectLinkWithURL:button.url];
	}
}

- (CGSize)optimumSize
{
	[self render];
	return _optimumSize;
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
	_lineSpacing = lineSpacing;
	[self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted!=_highlighted)
    {
        _highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

- (void)setHighlightedText:(NSString *)text
{
	_highlightedText = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
	RTLabelExtractedComponent *component = [RTLabel extractTextStyleFromText:_highlightedText paragraphReplacement:self.paragraphReplacement];
    [self setHighlightedTextComponents:component.textComponents];
}

- (void)setText:(NSString *)text
{
	_text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
	RTLabelExtractedComponent *component = [RTLabel extractTextStyleFromText:_text paragraphReplacement:self.paragraphReplacement];
    [self setTextComponents:component.textComponents];
    [self setPlainText:component.plainText];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text extractedTextComponent:(RTLabelExtractedComponent*)extractedComponent
{
	_text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    [self setTextComponents:extractedComponent.textComponents];
    [self setPlainText:extractedComponent.plainText];
	[self setNeedsDisplay];
}

- (void)setHighlightedText:(NSString *)text extractedTextComponent:(RTLabelExtractedComponent*)extractedComponent
{
    _highlightedText = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    [self setHighlightedTextComponents:extractedComponent.textComponents];
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
    return ceilf(height);
}

- (void)dealloc 
{
    self.delegate = nil;
}

- (NSArray *)components
{
	NSScanner *scanner = [NSScanner scannerWithString:self.text];
	[scanner setCharactersToBeSkipped:nil]; 
	
	NSMutableArray *components = [NSMutableArray array];
	
	while (![scanner isAtEnd]) 
	{
		NSString *currentComponent;
		BOOL foundComponent = [scanner scanUpToString:@"http" intoString:&currentComponent];
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
	return [components copy];
}

+ (RTLabelExtractedComponent*)extractTextStyleFromText:(NSString*)data paragraphReplacement:(NSString*)paragraphReplacement
{
	NSScanner *scanner = nil; 
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
				data = [data stringByReplacingOccurrencesOfString:delimiter withString:paragraphReplacement options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
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
			for (NSUInteger i=1; i<[textComponents count]; i++)
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
			RTLabelComponent *component = [RTLabelComponent componentWithString:nil tag:tag attributes:attributes];
			component.position = position;
			[components addObject:component];
		}
		last_position = position;
	}
	
    return [RTLabelExtractedComponent rtLabelExtractComponentsWithTextComponent:components plainText:data];
}


- (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags
{
	//use to strip the HTML tags from the data
	NSScanner *scanner = nil;
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
				for (NSUInteger i=1; i<[rawAttributes count]; i++)
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
					[components addObject:[RTLabelComponent componentWithString:text2 tag:tag attributes:lastAttributes]];
				}
				else
				{
					// is outside a tag
					[components addObject:[RTLabelComponent componentWithString:text2 tag:nil attributes:lastAttributes]];
				}
				data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
				
				last_position = position;
			}
			else
			{
				NSString *text2 = [data substringFromIndex:last_position];
				// is outside a tag
				[components addObject:[RTLabelComponent componentWithString:text2 tag:nil attributes:lastAttributes]];
			}
			lastAttributes = attributes;
		}
	}
    [self setTextComponents:components];
    [self setPlainText:data];
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

- (NSString*)visibleText
{
    [self render];
    NSString *text = [self.text substringWithRange:NSMakeRange(self.visibleRange.location, self.visibleRange.length)];
    return text;
}

#pragma mark deprecated methods

- (void)setText:(NSString *)text extractedTextStyle:(NSDictionary*)extractTextStyle
{
	_text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    [self setTextComponents:[extractTextStyle objectForKey:@"textComponents"]];
    [self setPlainText:[extractTextStyle objectForKey:@"plainText"]];
	[self setNeedsDisplay];
}

+ (NSDictionary*)preExtractTextStyle:(NSString*)data
{
    NSString* paragraphReplacement = @"\n";
	
    RTLabelExtractedComponent *component = [RTLabel extractTextStyleFromText:data paragraphReplacement:paragraphReplacement];
	return [NSDictionary dictionaryWithObjectsAndKeys:component.textComponents, @"textComponents", component.plainText, @"plainText", nil];
}


@end

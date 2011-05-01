//
//  RTLabel.h
//  RTLabelProject
//
//  Created by honcheng on 1/6/11.
//  Copyright 2011 honcheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef enum
{
	RTTextAlignmentRight = kCTRightTextAlignment,
	RTTextAlignmentLeft = kCTLeftTextAlignment,
	RTTextAlignmentCenter = kCTCenterTextAlignment,
	RTTextAlignmentJustify = kCTJustifiedTextAlignment
} RTTextAlignment;

typedef enum
{
	RTTextLineBreakModeWordWrapping = kCTLineBreakByWordWrapping,
	RTTextLineBreakModeCharWrapping = kCTLineBreakByCharWrapping,
	RTTextLineBreakModeClip = kCTLineBreakByClipping,
}RTTextLineBreakMode;

@protocol RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url;
- (BOOL)respondsToSelector:(SEL)selector;
@end

@interface RTLabel : UIView {
	NSString *_text;
	UIFont *font;
	UIColor *textColor;
	RTTextAlignment _textAlignment;
	RTTextLineBreakMode _lineBreakMode;
	NSString *_plainText;
	NSMutableArray *_textComponent;
	CGSize _optimumSize;
	CGFloat _lineSpacing;
	int currentSelectedButtonComponentIndex;
	NSDictionary *linkAttributes, *selectedLinkAttributes;
	id<RTLabelDelegate> delegate;
	CTFrameRef frame;
    CFRange visibleRange;
    int columnCount, columnWidth, alley;
}

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) NSDictionary *linkAttributes, *selectedLinkAttributes;
@property (nonatomic, assign) id<RTLabelDelegate> delegate;
@property (nonatomic, assign) int columnCount, columnWidth, alley;

- (void)render;
- (NSString*)text;
- (void)setText:(NSString*)text;
- (void)setTextAlignment:(RTTextAlignment)textAlignment;
- (void)setLineBreakMode:(RTTextLineBreakMode)lineBreakMode;
- (CGSize)optimumSize;
- (void)setLineSpacing:(CGFloat)lineSpacing;
- (NSString*)visibleText;

@end

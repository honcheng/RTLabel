RTLabel 
=======

Rich text formatting based on HTML-like markups for iOS. 

<img src="https://github.com/honcheng/RTLabel/raw/master/screenshot.png"/>

RTLabel works like UILabel, but supports html-like markups for rich text display. 
It is based on Core Text, so it supports some of the stuff that Core Text supports

Features
--------

* bold and italic style
* color and size
* stroke
* indenting
* kerning
* line spacing
* clickable links

Usage
-----

1) Drag RTLabel.h and RTLabel.m into your project. Import CoreText framework

    #import "RTLabel.h"
	
2) Create RTLabel
	
    NSString *sample_text = @"<b>bold</b>,<i>italic</i> and <u>underlined</u> text, and <font face='HelveticaNeue-CondensedBold' size=20 color='#CCFF00'>text with custom font and color</font>";
	
	RTLabel *label = [[RTLabel alloc] initWithFrame:...];
	[self addSubview:label];
	[label setText:sample_text];
	
3) Supports the following tags
	
    <b>Bold</b>
	<i>Italic</i>
	<bi>Bold & Italic</bi>
	<u>underline</u>, <u color=red>underline with color</u>
	<a href='http://..'>link</a>
	<uu>double underline</uu> , <uu color='#ccff00'>double underline with color</uu>
	<font face='HelveticaNeue-CondensedBold' size=20 color='#CCFF00'>custom font</font>
	<font face='HelveticaNeue-CondensedBold' size=20 color='#CCFF00' stroke=1>custom font with strokes</font>
	<font face='HelveticaNeue-CondensedBold' size=20 color='#CCFF00' kern=35>custom font with kerning</font>
	<p align=justify>alignment</p>
	<p indent=20>indentation</p>

Minimum Requirements
--------------------
* ARC - this project uses ARC. If you are not using ARC in your project, add '-fobjc-arc' as a compiler flag for StyledPageControl.h and StyledPageControl.m
* XCode 4.4 and newer (auto-synthesis required)

Contact
-------

[twitter.com/honcheng](http://twitter.com/honcheng)  
[honcheng.com](http://honcheng.com)

![](http://www.cocoacontrols.com/analytics/honcheng/rtlabel.png)

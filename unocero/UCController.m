//
//  UCController.m
//  UnoCero
//
//  Created by Kevin Wojniak on 7/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
// 


#import "UCController.h"
#import "UCText.h"

typedef enum
{
	Binary,
	Hexadecimal,
	Octal,
	Decimal
} UCType;

@implementation UCController

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if ([anObject class] == [NSTextField class])
	{
		if (anObject == binTextField)
		{
			if (binEditor == nil)
			{
				binEditor = [[UCText alloc] init];
				[binEditor setAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"01"]];
			}
			return binEditor;
		}
		else if (anObject == hexTextField)
		{
			if (hexEditor == nil)
			{
				hexEditor = [[UCText alloc] init];
				[hexEditor setAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"]];
			}
			return hexEditor;
		}
		else if (anObject == octTextField)
		{
			if (octEditor == nil)
			{
				octEditor = [[UCText alloc] init];
				[octEditor setAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"01234567"]];
			}
			return octEditor;
		}
		else if (anObject == decTextField)
		{
			if (decEditor == nil)
			{
				decEditor = [[UCText alloc] init];
				[decEditor setAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
			}
			return decEditor;
		}
	}
	
	return nil;
}

- (void)dealloc
{
	[binEditor release];
	[hexEditor release];
	[octEditor release];
	[decEditor release];
	[super dealloc];
}

#pragma mark -

- (int)numberForBinaryCharacter:(char)binChar
{
	if (binChar == '1')
		return 1;
	return 0;
}

- (int)numberForHexadecimalCharacter:(char)hexChar
{
	if (hexChar >= '0' && hexChar <= '9')
		return (int)hexChar - 48;
	else if (hexChar >= 'A' && hexChar <= 'F')
		return (int)hexChar - 55;
	else if (hexChar >= 'a' && hexChar <= 'f')
		return (int)hexChar - 87;
	return 0;
}

- (int)numberForOctalCharacter:(char)octChar
{
	if (octChar >= '0' && octChar <= '8')
		return (int)octChar - 48;
	return 0;
}

- (NSString *)stringForNumber:(int)num type:(UCType)type
{
	switch (type)
	{
		case Binary:
		{
			NSMutableString *str = [NSMutableString string];
			int current = num;
			while (current / 2 != 0)
			{
				[str insertString:[NSString stringWithFormat:@"%d", (current % 2)] atIndex:0];
				current /= 2;
			}
			[str insertString:[NSString stringWithFormat:@"%d", (current % 2)] atIndex:0];
			return str;
		}
		case Hexadecimal:
		{
			return [NSString stringWithFormat:@"%X", num];
		}
		case Octal:
		{
			return [NSString stringWithFormat:@"%o", num];
		}
		case Decimal:
		default:
		{
			return [NSString stringWithFormat:@"%d", num];
		}
	}
	
	return nil;
}

- (int)numberForString:(NSString *)string type:(UCType)type
{
	switch (type)
	{
		case Binary:
		{
			int n = 0, i, k = 0;
			for (i=[string length]-1; i>=0; i--)
			{
				n += pow(2, k) * [self numberForBinaryCharacter:[string characterAtIndex:i]];
				k++;
			}
			return n;
		}
		case Hexadecimal:
		{
			int n = 0, i, k = 0;
			for (i=[string length]-1; i>=0; i--)
			{
				n += pow(16, k) * [self numberForHexadecimalCharacter:[string characterAtIndex:i]];
				k++;
			}
			return n;
		}
		case Octal:
		{
			int n = 0, i, k = 0;
			for (i=[string length]-1; i>=0; i--)
			{
				n += pow(8, k) * [self numberForOctalCharacter:[string characterAtIndex:i]];
				k++;
			}
			return n;
		}
		case Decimal:
		default:
		{
			return [string intValue];
		}
	}
	
	return nil;
}

- (UCType)typeForTextField:(NSTextField *)currentTextField
{
	if (currentTextField == binTextField)
		return Binary;
	else if (currentTextField == hexTextField)
		return Hexadecimal;
	else if (currentTextField == octTextField)
		return Octal;
	else if (currentTextField == decTextField)
		return Decimal;
	return nil;
}

- (void)updateFields:(NSTextField *)currentTextField
{
	NSString *string = [currentTextField stringValue];
	int num = [self numberForString:string type:[self typeForTextField:currentTextField]];
	
	if (currentTextField != binTextField)
		[binTextField setStringValue:[self stringForNumber:num type:[self typeForTextField:binTextField]]];
	if (currentTextField != hexTextField)
		[hexTextField setStringValue:[self stringForNumber:num type:[self typeForTextField:hexTextField]]];
	if (currentTextField != octTextField)
		[octTextField setStringValue:[self stringForNumber:num type:[self typeForTextField:octTextField]]];
	if (currentTextField != decTextField)
		[decTextField setStringValue:[self stringForNumber:num type:[self typeForTextField:decTextField]]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self updateFields:(NSTextField *)[aNotification object]];
}

@end

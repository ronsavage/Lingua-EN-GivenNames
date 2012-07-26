#!/usr/bin/env perl

use feature qw/say unicode_strings/;
use open qw(:std :utf8);
use strict;
use warnings;
use warnings qw(FATAL utf8);

# -----------------------------------------------

my($s) = join(' ', @ARGV);

say 'Testing: <', join('> <', split(/\s+/, $s) ), '>';

# CATHY: English pet form of French Catharine, meaning "pure."

if ($s =~	/
			(.+?):\s* # 1
				(     # 2
				Anglicized|Breton|Contracted|Diminutive|Elaborated|
				English\s+?and\s+?Latin|
				(?:(?:American|British)\s+?)?English|
				Feminine|French|Irish\s+?Gaelic|Latin|Medieval\s+?English|Old\s+?English|
				Pet|Polish|Scottish(?:\s+Anglicized)|Short|Unisex|
				(?:V|v)ariant
				)\s+?
			((?:(?:contracted|feminine|pet|short|unisex|variant)?\s*?)(?:form|spelling)\s+?) # 3
			(?:of\s+?)?(.+?)\s+?(.+?)\s*?(?:,\s*?)? # 4, 5
			(?:possibly\s+?)?meaning\s*?(?:simply\s*)?"(.+?)" # 6
			/x
	)
{
	say "Name: <$1>. Kind: <$2>. Style: <$3>. Source: <$4>. Original: <$5>. Meaning: <$6>.";
}
else
{
	say "Did not match";
}

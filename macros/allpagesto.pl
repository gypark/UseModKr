$MacroFunc{"allpagesto"} = \&allpagesto;

sub allpagesto {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;allpagesto\(([^\n]+)\)\&__GT__;/&MacroAllPagesTo($1)/gei;

	return $txt;
}

sub MacroAllPagesTo {
	my ($string) = @_;
	my @x = ();
	my ($pagelines, $pagename, $txt);
	my $pagename;
	
	$string = &RemoveLink($string);
	$string = &FreeToNormal($string);
	if (&ValidId($string) ne "") {
		return "&lt;allpagesto($string)&gt;";
	}

	foreach $pagelines (&GetFullLinkList("empty=0&sort=1&reverse=$string")) {
		my @pages = split(' ', $pagelines);
		@x = (@x, shift(@pages));
	}

	foreach $pagename (@x) {
		$txt .= ".... "  if ($pagename =~ m|/|);
		$txt .= &GetPageLink($pagename) . "<br>";
	}

	return $txt;
}

1;

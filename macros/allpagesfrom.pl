$MacroFunc{"allpagesfrom"} = \&allpagesfrom;

sub allpagesfrom {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;allpagesfrom\(([^,\n]+)(,\d)?\)\&__GT__;/&MacroAllPagesFrom($1, $2)/gei;

	return $txt;
}

sub MacroAllPagesFrom {
	my ($string, $exists) = @_;
	my (@x, @links, $pagename, %seen, %pgExists);
	my $txt;
	
	$string = &RemoveLink($string);
	$string = &FreeToNormal($string);
	if (&ValidId($string) ne "") {
		return "&lt;allpagesfrom($string)&gt;";
	}

	if ($exists =~ /,(\d)/) {
		$exists = $1;
	} else {
		$exists = 2;
	}
	
	%pgExists = ();
	foreach $pagename (&AllPagesList()) {
		$pgExists{$pagename} = 1;
	}

	@x = &GetPageLinksFromFile($string, 1, 0, 0);

	foreach $pagename (@x) {
		$pagename = (split('/',$string))[0]."$pagename" if ($pagename =~ /^\//);
		if ($seen{$pagename} != 0) {
			next;
		}
		if (($exists == 0) && ($pgExists{$pagename} == 1)) {
			next;
		}
		if (($exists == 1) && ($pgExists{$pagename} != 1)) {
			next;
		}
		$seen{$pagename}++;
		push (@links, $pagename);
	}
	@links = sort(@links);

	foreach $pagename (@links) {
		$txt .= ".... "  if ($pagename =~ m|/|);
		$txt .= &GetPageOrEditLink($pagename) . "<br>";
	}

	return $txt;
}

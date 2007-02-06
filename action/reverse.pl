sub action_reverse {
	my ($string) = &GetParam('id');
	my @x = ();
	my $pagelines;

	if ($string eq '') {
		&DoIndex();
		return;
	}
	print &GetHeader('', &QuoteHtml(Ts('Links to %s', $string)), '');
### hide page by gypark
	if (&PageIsHidden($string)) {
		print Ts('%s is a hidden page', $string);
		print &GetCommonFooter();
		return;
	}
###
	print '<br>';

	foreach $pagelines (&GetFullLinkList("page=1&inter=1&unique=1&sort=1&exists=2&empty=0&reverse=$string")) {
		my @pages = split(' ', $pagelines);
		@x = (@x, shift(@pages));
	}
	
	&PrintPageList(@x);

	if ($#x eq -1) {
		print T('No reverse link.') . "<br>";
	}
	if (&ValidId($string) eq "") {
		print "<hr size=\"1\">";
		print Ts('Return to %s' , &GetPageLink($string)) . "<br>";
	}

	print &GetCommonFooter();
}

1;

sub mysign {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;mysign\(([^,]+),(\d+-\d+-\d+ \d+:\d+.*)\)\&__GT__;/&MacroMySign($1, $2)/gei;

	return $txt;
}

sub MacroMySign {
	my ($author, $timestamp) = @_;
	return "<DIV class='mysign'>-- $author <small>$timestamp</small></DIV>";
}

1;

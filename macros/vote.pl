$MacroFunc{"vote"} = \&vote;

sub vote {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;vote\((\d+)(,(\d+))?\)&__GT__;/&MacroVote($1,$3)/gei;

	return $txt;
}

sub MacroVote {
	my ($count, $scale) = @_;
	my $maximum = 1000;
	$scale = 10 if ($scale eq '');
	my $width = $count * $scale;
	$width = $maximum if ($width > $maximum);

	return "<table ".(($width)?"bgcolor=\"lightgrey\" ":"")
		."width=\"$width\" style=\"border:1 solid gray;\">"
		."<tr><td style=\"padding:0; border:none; font-size:8pt;\">$count"
		."</td></tr></table>";
}

1;

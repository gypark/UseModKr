$MacroFunc{"date"} = \&date;

sub date {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;Date\&__GT__;/&MacroDate()/gei;

	return $txt;
}

sub MacroDate() { return &CalcDay(time); }

1;

$MacroFunc{"thread"} = \&thread;

sub thread {
	my ($txt) = @_;

	$txt =~ s/(\&__LT__;thread\(([^,]+),([-+]?\d+),(\d+)\)\&__GT__;)/&MacroThread($1,$2,$3,1,$4)/gei;
	$txt =~ s/(\&__LT__;thread\(([^,]+),([-+]?\d+)\)\&__GT__;)/&MacroThread($1,$2,$3,1,0)/gei;
	$txt =~ s/(\&__LT__;threadhere\(([^,]+),([-+]?\d+),(\d+)\)\&__GT__;)//gei;

	return $txt;
}

sub MacroThread {
	my ($itself, $id, $up, $long, $threadindent) = @_;
	my $txt;

	if ($threadindent > 0) {
		my $marginleft = 3.3*($threadindent-1) if ($threadindent > 0);
		$txt = "<DIV class='threadreply' style='margin-left: $marginleft em'>";
	} else {
		$txt = "<DIV class='threadnew'>";
	}
	$txt .= &MacroComments($itself, $id, $up, $long, $threadindent)."</DIV>";

	return $txt;
}

1;

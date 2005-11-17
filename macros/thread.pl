sub thread {
	my ($txt) = @_;

    # 페이지 이름을 쓰지 않음
	$txt =~ s/(&__LT__;thread\()([-+]?\d+(,\d+)?)(\)&__GT__;)/$1$pageid,$2$4/gi;

	$txt =~ s/(&__LT__;thread\(([^,]+),([-+]?\d+),(\d+)\)&__GT__;)/&MacroThread($1,$2,$3,1,$4)/gei;
	$txt =~ s/(&__LT__;thread\(([^,]+),([-+]?\d+)\)&__GT__;)/&MacroThread($1,$2,$3,1,0)/gei;
	$txt =~ s/(&__LT__;thread&__GT__;((.)*?)&__LT__;\/thread&__GT__;)/&MacroThreadBlock($2)/geis;

	return $txt;
}

sub MacroThread {
	my ($itself, $id, $up, $long, $threadindent) = @_;
	my $txt;

	if ($threadindent > 0) {
		my $marginleft = 0;
		$marginleft = 3.3*($threadindent-1) if ($threadindent > 0);
		$txt = "<DIV class='threadreply' style='margin-left: $marginleft"."em'>";
	} else {
		$txt = "<DIV class='threadnew'>";
	}
	$txt .= &MacroComments($itself, $id, $up, $long, $threadindent)."</DIV>";

	return $txt;
}

sub MacroThreadBlock {
	my ($blocktext) = @_;
	my $txt;

	$txt = "<DIV class='threaditem'>" . $blocktext . "</DIV>";

	return $txt;
}

1;

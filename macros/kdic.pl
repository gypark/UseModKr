$MacroFunc{"kdic"} = \&kdic;

sub kdic {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;kdic\(([^)]+)\)\&__GT__;/&MacroKDic($1)/gei;

	return $txt;
}

sub MacroKDic {
	return "<A class='dic' href='http://krdic.naver.com/krdic?query=@_' target='dictionary'>@_</A>";
}


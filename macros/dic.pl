sub dic {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;dic\(([^)]+)\)\&__GT__;/&MacroEDic($1)/gei;

	return $txt;
}

sub MacroEDic {
	return "<A class='dic' href='http://dic.naver.com/endic?query=@_' target='dictionary'>@_</A>";
}

1;

$MacroFunc{"jdic"} = \&jdic;

sub jdic {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;jdic\(([^)]+)\)\&__GT__;/&MacroJDic($1)/gei;

	return $txt;
}

sub MacroJDic {
	return "<A class='dic' href='http://jpdic.naver.com/jpdic?query=@_' target='dictionary'>@_</A>";
}

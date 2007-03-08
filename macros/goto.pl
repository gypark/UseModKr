sub goto {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;goto\((.*?)\)\&__GT__;/&MacroGoto($1)/gei;

	return $txt;
}

sub MacroGoto {
	my ($string) = @_;

	$string = &RemoveLink($string);

	return
		"<form name=goto><input type=\"hidden\" name=\"action\" value=\"browse\" id=\"hidden-box\">".
		"<input name='id' type='text' size=10 value='$string'>" . "&nbsp;" .
		"<input type=submit value=\"". T('Go') . "\">".
		"</form>";
}

1;

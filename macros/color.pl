$MacroFunc{"color"} = \&color;

sub color {
	my ($txt) = @_;

	$txt =~ s/&__LT__;color\(([^,)]+),([^,)]+),([^\n]+?)\)&__GT__;/&MacroColorBk($1, $2, $3)/gei;
	$txt =~ s/&__LT__;color\(([^,)]+),([^\n]+?)\)&__GT__;/&MacroColor($1, $2)/gei;

	return $txt;
}

sub MacroColor {
	my ($color, $message) = @_;
	return "<span style='color:$color;'>$message</span>";
}

sub MacroColorBk {
	my ($color, $bgcolor, $message) = @_;
	return "<span style='color:$color; background-color:$bgcolor'>$message</span>";
}

1;

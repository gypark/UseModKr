$MacroFunc{"anchor"} = \&anchor;

sub anchor {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;Anchor\((.*)\)\&__GT__;/&MacroAnchor($1)/gei;

	return $txt;
}

sub MacroAnchor() {	return "<a name=\"@_\"></a>"; }

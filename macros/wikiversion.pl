$MacroFunc{"wikiversion"} = \&wikiversion;

sub wikiversion {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;wikiversion&__GT__;/&MacroWikiVersion()/gei;

	return $txt;
}

sub MacroWikiVersion {
	return &ScriptLink("action=version", $WikiVersion);
}

1;

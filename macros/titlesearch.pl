sub titlesearch {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;titlesearch\((.*)\)\&__GT__;/&MacroTitleSearch($1)/gei;

	return $txt;
}

sub MacroTitleSearch {
	my ($string) = @_;
	my ($name, $freeName, $txt);

	foreach $name (&AllPagesList()) {
		if ($name =~ /$string/i) {
			$txt .= &GetPageLink($name) . "<br>";
		} elsif ($FreeLinks && ($name =~ m/_/)) {
			$freeName = $name;
			$freeName =~ s/_/ /g;
			if ($freeName =~ /$string/i) {
				$txt .= &GetPageLink($name) . "<br>";
			}
		}
	}
	return $txt;
}

1;

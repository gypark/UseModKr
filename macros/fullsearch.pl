$MacroFunc{"fullsearch"} = \&fullsearch;

sub fullsearch {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;FullSearch\((.*)\)\&__GT__;/&MacroFullSearch($1)/gei;

	return $txt;
}

sub MacroFullSearch()
{
	my $pagename;
	my ($string) = @_;
	my @x = &SearchTitleAndBody($string);
	my $txt;

	foreach $pagename (@x) {
		$txt .= ".... "  if ($pagename =~ m|/|);
		$txt .= &GetPageLink($pagename) . "<br>";
	}
	return $txt;
}

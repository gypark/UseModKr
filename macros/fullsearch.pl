sub fullsearch {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;FullSearch\((.*?)\)\&__GT__;/&MacroFullSearch($1)/gei;

    return $txt;
}

sub MacroFullSearch
{
    my ($string) = @_;
    my @x = &SearchTitleAndBody($string);
    my $txt;

    foreach my $pagename (@x) {
        $txt .= ".... "  if ($pagename =~ m|/|);
        $txt .= &GetPageLink($pagename) . "<br>";
    }
    return $txt;
}

1;

use strict;

sub allpagesto {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;allpagesto\((.+?)\)\&__GT__;/&MacroAllPagesTo($1)/gei;

    return $txt;
}

sub MacroAllPagesTo {
    my ($string) = @_;
    my @x = ();
    my $txt;
    
    $string = &RemoveLink($string);
    $string = &FreeToNormal($string);
    if (&ValidId($string) ne "") {
        return "&lt;allpagesto($string)&gt;";
    }

    foreach my $pagelines (&GetFullLinkList("empty=0&sort=1&reverse=$string")) {
        my @pages = split(' ', $pagelines);
        @x = (@x, shift(@pages));
    }

    foreach my $pagename (@x) {
        $txt .= ".... "  if ($pagename =~ m|/|);
        $txt .= &GetPageLink($pagename) . "<br>";
    }

    return $txt;
}

1;

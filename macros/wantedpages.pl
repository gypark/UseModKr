sub wantedpages {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;wantedpages\&__GT__;/&MacroWantedPages()/gei;

    return $txt;
}

sub MacroWantedPages {
    my ($pageline, @found, $page);
    my %numOfReverse;
    my $txt;

    foreach $pageline (&GetFullLinkList("exists=0&sort=0")) {
        my @links = split(' ', $pageline);
        my $id = shift(@links);
        foreach $page (@links) {
            $page = (split('/',$id))[0]."$page" if ($page =~ /^\//);
            push(@found, $page) if ($numOfReverse{$page} == 0);
            $numOfReverse{$page}++;
        }
    }
    @found = sort(@found);

    foreach $page (@found) {
        $txt .= ".... " if ($page =~ m|/|);
        $txt .= &GetPageOrEditLink($page, $page) . " ("
            . &ScriptLink("action=links&editlink=1&empty=0&reverse=$page", $numOfReverse{$page})
            . ")<br>";
    }

    return $txt;
}

1;

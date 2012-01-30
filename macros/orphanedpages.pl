sub orphanedpages {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;orphanedpages\(([-+])?(\d+)\)\&__GT__;/&MacroOrphanedPages($1, $2)/gei;

    return $txt;
}

sub MacroOrphanedPages {
    my ($less_or_more, $criterion) = @_;
    my (@allPages);
    my %numOfReverse;
    my $txt;

    @allPages = &AllPagesList();

    foreach my $page (@allPages) {
        $numOfReverse{$page} = 0;
    }

    foreach my $pageline (&GetFullLinkList("exists=1&sort=0")) {
        my @links = split(' ', $pageline);
        my $id = shift(@links);
        foreach my $link (@links) {
            $link = (split('/',$id))[0]."$link" if ($link =~ /^\//);
            next if ($id eq $link);
            $numOfReverse{$link}++;
        }
    }

    foreach my $page (@allPages) {
        next if (($less_or_more eq "-") && ($numOfReverse{$page} > $criterion));
        next if (($less_or_more eq "+") && ($numOfReverse{$page} < $criterion));
        next if (($less_or_more eq "") && ($numOfReverse{$page} != $criterion));
        $txt .= ".... " if ($page =~ m|/|);
        $txt .= &GetPageLink($page) . "<br>";
    }

    return $txt;
}

1;

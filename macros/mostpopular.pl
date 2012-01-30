sub mostpopular {
    my ($txt) = @_;

    $txt =~ s/(\&__LT__;mostpopular\(([-+]?\d+),([-+]?\d+)\)\&__GT__;)/&MacroMostPopular($1,$2, $3)/gei;

    return $txt;
}

sub MacroMostPopular {
    my ($itself, $start, $end) = (@_);
    my (%pgcount, $countfile, $status, $count, @pages);
    my $txt;

    if (($start == 0) || ($end == 0)) { return $itself; }

    foreach my $page (&AllPagesList()) {
        $countfile = &GetCountFile($page);
        ($status, $count) = &ReadFile($countfile);
        if ($status) {
            $pgcount{$page} = $count;
        } else {
            $pgcount{$page} = 0;
        }
    }

    @pages = sort {
        $pgcount{$b} <=> $pgcount{$a}
                ||
        $a cmp $b
    } keys %pgcount;

    if ($start > 0) {
        $start--;
    } else {
        $start = $#pages + $start + 1;
    }
    if ($end > 0) {
        $end--;
    } else {
        $end = $#pages + $end + 1;
    }
    $start = 0 if ($start < 0);
    $start = $#pages if ($start > $#pages);
    $end = 0 if ($end < 0);
    $end = $#pages if ($end > $#pages);

    if ($start <= $end) {
        @pages = @pages[$start .. $end];
    } else {
        @pages = reverse(@pages[$end .. $start]);
    }

    foreach my $page (@pages) {
        $txt .= ".... "  if ($page =~ m|/|);
        $txt .= &GetPageLink($page) . 
            " (".Ts('%s hit'.(($pgcount{$page}>1)?'s':''), $pgcount{$page}) . ")<br>";
    }

    return $txt;
}

1;

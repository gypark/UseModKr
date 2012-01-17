sub pagecount {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;PageCount\&__GT__;/&MacroPageCount()/gei;

    return $txt;
}

sub MacroPageCount() {
    my @pageList = &AllPagesList();
    return $#pageList + 1;
}

1;

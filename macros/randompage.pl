sub randompage {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;RandomPage\((\d*?)\)\&__GT__;/&MacroRandompage($1)/gei;

    return $txt;
}

sub MacroRandompage() {
    my ($count) = @_;
    my @pageList = &AllPagesList();
    my ($txt);

    srand($Now);
    while ($count-- > 0) {
        $txt .= &GetPageLink($pageList[int(rand($#pageList + 1))]) . " ";
    }
    return $txt;
}

1;

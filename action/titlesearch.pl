# titlesearch action
# 1)
#   wiki.pl/action=titlesearch&string=STRING
#   : search the pages whose names include STRING
# 2)
#   wiki.pl/action=titlesearch&parent=PAGENAME
#   : search the subpages of PAGENAME


sub action_titlesearch {
    my $string = &GetParam('string');
    my $parent = &GetParam('parent');
    my @result_string = ();
    my @result_parent = ();

    if (($string eq '') && ($parent eq '')) {
        &DoIndex();
        return;
    }


    if ($string ne '') {
        print &GetHeader('', &QuoteHtml(Ts('Title Search for : %s', $string)), '');
        print '<br>';
        &PrintPageList(&SearchTitle($string));
    } else {
        print &GetHeader('', &QuoteHtml(Ts('Subpage Search for : %s', $parent)), '');
        print '<br>';
        &PrintPageList(&SearchTitle("^$parent(/|\$)"));
    }

    print &GetCommonFooter();
}

1;

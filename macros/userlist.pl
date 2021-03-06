sub userlist {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;userlist\&__GT__;/&MacroUserList()/gei;

    return $txt;
}

sub MacroUserList {
    my (@userlist, $result);
    opendir(USERLIST, $UserDir);
    @userlist = readdir(USERLIST);
    close(USERLIST);
    shift @userlist;
    shift @userlist;
    @userlist = sort @userlist;
    foreach my $usernumber (0..(@userlist-1)) {
        @userlist[$usernumber] =~ s/(.*)\.db/($1)/gei;
        @userlist[$usernumber] = &StorePageOrEditLink("@userlist[$usernumber]", "@userlist[$usernumber]") . "<br>";
    }

    $result = "@userlist";
    
    return $result;
}

1;

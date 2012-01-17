sub adminonly {
    my ($txt) = @_;

    $txt =~ s/&__LT__;adminonly&__GT__;(.*?)&__LT__;\/adminonly&__GT__;/&MacroAdminOnly($1)/geis;

    return $txt;
}

sub MacroAdminOnly {
    my ($blocktext) = @_;

    $blocktext =~ s/^(\r?\n)(.*?)(\r?\n)$/$2/geis;

    if (&UserIsAdmin()) {
        return "$blocktext";
    } else {
        return "";
    }
}

1;

sub goto {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;goto\((.*?)\)\&__GT__;/&MacroGoto($1)/gei;

    return $txt;
}

sub MacroGoto {
    my ($string) = @_;
    $string = &RemoveLink($string);
    return &GetGotoForm($string);
}

1;

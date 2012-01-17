sub time {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;time\&__GT__;/&MacroTime()/gei;

    return $txt;
}

sub MacroTime() { return &CalcTime(time); }

1;

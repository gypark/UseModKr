sub datetime {
    my ($txt) = @_;

    $txt =~ s/\&__LT__;DateTime\&__GT__;/&MacroDateTime()/gei;

    return $txt;
}

sub MacroDateTime { return &CalcDay(time) . " " . &CalcTime(time); }

1;

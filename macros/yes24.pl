sub yes24 {
    my ($txt) = @_;

    $txt =~ s/&__LT__;yes24\(([0-9]+)(?:,([SML]))?\)&__GT__;/&MacroYes24($1, $2)/gei;

    return $txt;
}

sub MacroYes24 {
    my ($id, $size) = @_;
    $size //= "M";
    $size = uc($size);
    return qq|<a href="https://www.yes24.com/Product/Goods/$id"><img class="yes24 yes24-$size" src="https://image.yes24.com/goods/$id/$size"></a>|;
}

1;

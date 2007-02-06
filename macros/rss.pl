# <rss([옵션])>
# action=rss[&옵션] 의 형태로 링크 반환

sub rss {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;rss\((.*?)\)&__GT__;/&MacroRss($1)/gei;

	return $txt;
}

sub MacroRss {
	use strict;
	my ($arg) = @_;
	my $txt;

	if ($arg ne "") {
		$arg = "&".$arg;
	}

	$txt = &ScriptLink("action=rss$arg",
			"<img align='absmiddle' src='$IconDir/xml_rss.gif'> Get RSS of Entire Wiki");

	return $txt;
}

1;

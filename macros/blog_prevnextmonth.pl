# <blog_prevnextmonth>
# 이전 달과 다음 달로 가는 링크를 만듦

sub blog_prevnextmonth {
	my ($txt) = @_;

	$txt =~ s/&__LT__;blog_prevnextmonth&__GT__;/&MacroBlogPrevNextMonth()/gei;

	return $txt;
}

sub MacroBlogPrevNextMonth {
	use strict;

	if ($OpenPageName =~ m|^(.*/)?(\d{4})-(\d{2})$|) {
		my ($mainpage, $year, $month) = ($1, $2, $3);
		my ($prev_year, $prev_month) = ($year, $month - 1);
		my ($next_year, $next_month) = ($year, $month + 1);
		if ($prev_month <= 0) {
			$prev_year--;
			$prev_month = 12;
		} elsif ($next_month >= 13) {
			$next_year++;
			$next_month = 1;
		}
		if ($prev_month < 10) {
			$prev_month = "0" . $prev_month;
		}
		if ($next_month < 10) {
			$next_month = "0" . $next_month;
		}

		my $prev_page = "$mainpage$prev_year-$prev_month";
		my $next_page = "$mainpage$next_year-$next_month";

		my $shortCutUrl = "$ScriptName".&ScriptLinkChar();
		my $txt;
		$txt = "<CENTER>".
			"<b>&lt;&lt;&lt;</b>&nbsp;&nbsp; ".
			&GetPageOrEditLink($next_page).
			" [p]".
			" &nbsp;&nbsp<b>|</b> ".T('Monthly View')." <b>|</b>&nbsp;&nbsp; ".
			&GetPageOrEditLink($prev_page).
			" [n]".
			" &nbsp;&nbsp;<b>&gt;&gt;&gt;</b>".
			"</CENTER>";

		$txt .= <<EOF;
<script>
<!--
key['p'] = "${shortCutUrl}$next_page";
key['n'] = "${shortCutUrl}$prev_page";
-->
</script>
EOF
		return $txt;
	} else {
		return "";
	}
}

1;

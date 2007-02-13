sub includeday {
	my ($txt) = @_;

### includeday 매크로
 	$txt =~ s/(^|\n)(<includeday\(([^,\n]+,)?([-+]?\d+)\)>)([\r\f]*\n)/$1 . &MacroIncludeDay($2, $3, $4) . $5/geim;
### includedays 매크로
 	$txt =~ s/(^|\n)(<includedays\(([^,\n]+,)?([-+]?\d+),([-+]?\d+)\)>)([\r\f]*\n)/$1 . &MacroIncludeDay($2, $3, $4, $5) . $6/geim;

	return $txt;
}

sub MacroIncludeDay {
	my ($itself, $mainpage, $day_offset, $num_days) = @_;
	my $page = "";
	my $temp;
	my $result = "";

	my ($sign, $num);
	if ($num_days =~ /([-+]?(\d+))/) {
		$num = $2;
		$sign = $1 / $num if ($num != 0);
	} else {
		$num = -1;
	}

	# main page 처리
	if ($mainpage ne "") {
		$temp = $mainpage;
		$temp =~ s/,$//;
		$temp =~ s/^\[\[(.*)\]\]$/$1/;

# include 는 다른 마크업보다 먼저 처리되기 때문에 아래 단락은 필요 없다
#		$temp = &RemoveLink($temp);
#		$temp = &FreeToNormal($temp);
#		if (&ValidId($temp) ne "") {
#			return $itself;
#		}

		$temp =~ s/\/.*$//;
		$mainpage = $temp . "/";
	}

	# 날짜의 변위 계산 
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	my $maximum_count = 100;
	while (($num != 0) && ($maximum_count > 0)) {
		$temp = $Now + ($day_offset * 86400);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($temp+$TimeZoneOffset);

		$page = $mainpage . ($year + 1900) . "-";

		if ($mon + 1 < 10) {
			$page .= "0";
		}
		$page .= ($mon + 1) . "-";

		if ($mday < 10) {
			$page .= "0";
		}
		$page .= "$mday";

		$temp = &MacroInclude($page);
		if ($num == -1) {
			$result .= $temp;
			last;
		} else {
			if ($temp ne "") {
				$num--;
				$result .= $temp . "\n";
			}
			$day_offset += $sign;
		}
		$maximum_count--;
	}

	return $result;
}

1;

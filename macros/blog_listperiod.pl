# <blog_listperiod(목차페이지,시작날짜,끝날짜[,날짜출력방식])>
# 목차페이지를 읽어서 시작날짜부터 끝날짜까지의 페이지의 목록을 출력

sub blog_listperiod {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;blog_listperiod\(([^,]+),([\d-]+),([\d-]+)(,([-+]?\d))?\)\&__GT__;/&MacroBlogListPeriod($1,$2,$3,$5)/gei;

	return $txt;
}

sub MacroBlogListPeriod {
	use strict;
	my ($tocpage, $startdate, $enddate, $showdate) = @_;

	# 라이브러리 읽음
	my ($MacrosDir, $MyMacrosDir) = ("./macros/", "./mymacros/");
	if (-f "$MyMacrosDir/blog_library.pl") {
		require "./$MyMacrosDir/blog_library.pl";
	} elsif (-f "$MacrosDir/blog_library.pl") {
		require "./$MacrosDir/blog_library.pl";
	} else {
		return "<font color='red'>blog_library.pl not found</font>";
	}

	# 목차페이지로부터 목차리스트를 얻어냄
	my ($status, $toc_mainpage, @tocitem_List) = &BlogReadToc($tocpage);
	if (!$status) {
		return "$toc_mainpage";
	}

	# 조건에 맞는 리스트를 구성
	($status, @tocitem_List) = &BlogGetListPeriod($startdate, $enddate, @tocitem_List);
	if (!$status) {
		return "@tocitem_List";
	}

	# 리스트의 각 페이지를 목록 출력
	my $txt;
	$txt = "<UL>";
	my ($page, $pagename, $date, $pageid);
	foreach my $item (@tocitem_List) {
		if ($item =~ /^(.+)$FS1(.*)$FS1(.+)$/) {
			($page, $pagename, $date) = ($1, $2, $3);
		}
		$pageid = $page;
		$pageid =~ s|^/|$toc_mainpage/|;
		$pageid = &FreeToNormal($pageid);
		$page = $pagename if ($pagename);
		if ($showdate == 0) {
			$txt .= "<LI>".&GetPageOrEditLink($pageid,$page);
		} elsif ($showdate < 0) {
			$txt .= "<LI>($date) ".&GetPageOrEditLink($pageid,$page);
		} else {
			$txt .= "<LI>".&GetPageOrEditLink($pageid,$page)." ($date)";
		}
	}
	$txt .= "</UL>";

	return $txt;
}

1;

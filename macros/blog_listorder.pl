# <blog_listorder(목차페이지,시작순서,끝순서[,날짜출력방식])>
# 목차페이지를 읽어서 시작순서부터 끝순서까지의 페이지의 목록을 출력

sub blog_listorder {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;blog_listorder\(([^,]+),([-+]?\d+),([-+]?\d+)(,([-+]?\d))?\)\&__GT__;/&MacroBlogListOrder($1,$2,$3,$5)/gei;

	return $txt;
}

sub MacroBlogListOrder {
	use strict;
	my ($tocpage, $start, $end, $showdate) = @_;

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
	($status, @tocitem_List) = &BlogGetListOrder($start, $end, @tocitem_List);
	if (!$status) {
		return "@tocitem_List";
	}

	# 리스트의 각 페이지를 목록 출력
	my $txt;
	$txt = "<UL>";
	my ($page, $date, $pageid);
	foreach my $item (@tocitem_List) {
		if ($item =~ /^(.+)!(.+)$/) {
			($page, $date) = ($1, $2);
		}
		$pageid = $page;
		$pageid =~ s|^/|$toc_mainpage/|;
		$pageid = &FreeToNormal($pageid);
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

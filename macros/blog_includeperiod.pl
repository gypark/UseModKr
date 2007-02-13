# <blog_includeperiod(목차페이지,시작날짜,끝날짜)>
# 목차페이지를 읽어서 시작날짜부터 끝날짜까지의 페이지를 include한다.

sub blog_includeperiod {
	my ($txt) = @_;

	$txt =~ s/<blog_includeperiod\(([^,]+),([\d-]+),([\d-]+)\)>/&MacroBlogIncludePeriod($1,$2,$3)/geim;

	return $txt;
}

sub MacroBlogIncludePeriod {
	use strict;
	my ($tocpage, $startdate, $enddate) = @_;

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

	# 리스트의 각 페이지를 읽어서 include함
	my $txt;
	my ($page, $date);
	foreach my $item (@tocitem_List) {
		if ($item =~ /^(.+)$FS1(.*)$FS1(.+)$/) {
			($page, $date) = ($1, $3);
		}
		$page =~ s|^/|$toc_mainpage/|;
		$page = &FreeToNormal($page);
		$txt .= &MacroInclude($page);
	}

	return $txt;
}

1;

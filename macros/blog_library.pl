# blog_library.pl
# blog_*** 매크로 시리즈들이 공통으로 사용하는 함수들을 모아 둔 라이브러리


# param: 목차페이지
# return: ($status, $page, @list);
#  $status : 성공하면 1, 실패하면 0
#  $page : 성공하면 목차페이지의 상위페이지 이름, 실패하면 에러메시지
#  @list : 목차페이지로부터 읽은 목차 리스트
sub BlogReadToc($tocpage) {
	use strict;
	my ($tocpage) = @_;

	# 목차페이지 이름 분석
	$tocpage = &FreeToNormal(&RemoveLink($tocpage));
	if (my $temp = &ValidId($tocpage)) {
		return (0, "<font color='red'>$temp</font>");
	}

	my ($toc_mainpage, $toc_subpage);
	if ($tocpage =~ m|(.*)/(.*)|) {
		($toc_mainpage, $toc_subpage) = ($1,$2);
	} else {
		$toc_mainpage = $tocpage;
	}

	# 페이지 목록 읽음
	my ($fname, $status, $data);
	$fname = &GetPageFile($tocpage);
	if (!(-f $fname)) {
		return (0, "<font color='red'>No such page: $tocpage</font>");
	}

	($status, $data) = &ReadFile($fname);
	if (!$status) {
		return (0, "<font color='red'>Error in read pagefile: $tocpage</font>");
	}

	my %temp_Page = split(/$FS1/, $data, -1);
	my %temp_Section = split(/$FS2/, $temp_Page{'text_default'}, -1);
	my %temp_Text = split(/$FS3/, $temp_Section{'data'}, -1);
	my $tocpage_Text = $temp_Text{'text'};

	# 라인 별로 분리
	my @tocpage_Lines = split('\n',$tocpage_Text);
	my @tocitem_List;

	# 유효한 라인만 추출
	foreach my $line (@tocpage_Lines) {
		if ($line =~ m/^* (\[\[.+?\]\] \d+-\d+-\d+)\s*$/) {
			push(@tocitem_List, $1);
		}
	}

	return (1, $toc_mainpage, @tocitem_List);
}


# param: 시작순서, 끝순서, 목차리스트
# return: ($status, @list)
#  $status : 성공하면 1, 실패하면 0
#  @list : 성공하면 시작순서부터 끝순서까지의 리스트. 실패하면 에러메시지
sub BlogGetListOrder {
	use strict;
	my ($start, $end, @tocitem_List) = @_;

	if (($start == 0) || ($end == 0)) {
		return (0, "<font color='red'>Invalid parameter: 0</font>");
	}

	if ($start > 0) {
		$start--;
	} else {
		$start = $#tocitem_List + $start + 1;
	}
	if ($end > 0) {
		$end--;
	} else {
		$end = $#tocitem_List + $end + 1;
	}
	$start = 0 if ($start < 0);
	$start = $#tocitem_List if ($start > $#tocitem_List);
	$end = 0 if ($end < 0);
	$end = $#tocitem_List if ($end > $#tocitem_List);

	if ($start <= $end) {
		@tocitem_List = @tocitem_List[$start .. $end];
	} else {
		@tocitem_List = reverse(@tocitem_List[$end .. $start]);
	}

	my @list;
	my ($page, $date);
	foreach my $item (@tocitem_List) {
		if ($item =~ /\[\[(.+?)\]\] (\d+)-(\d+)-(\d+)/) {
			$page = $1;
			$date = sprintf("%4d-%02d-%02d",$2,$3,$4);
			push(@list, "$page!$date");
		}
	}
 	return ("1", @list);
}


# param: 시작날짜, 끝날짜, 목차리스트
# return: ($status, @list)
#  $status : 성공하면 1, 실패하면 0
#  @list : 성공하면 시작날짜부터 끝날짜까지의 리스트. 실패하면 에러메시지
sub BlogGetListPeriod {
	use strict;
	my ($startdate, $enddate, @tocitem_List) = @_;

	if ($startdate =~ /^(\d{4})-(\d{1,2})-(\d{1,2})$/) {
		$startdate = sprintf("%4d%02d%02d",$1,$2,$3);
	} else {
 		return (0,"<font color='red'>Invalid parameter: $startdate</font>");
	}
	if ($enddate =~ /^(\d+)-(\d+)-(\d+)$/) {
		$enddate = sprintf("%4d%02d%02d",$1,$2,$3);
	} else {
 		return (0,"<font color='red'>Invalid parameter: $enddate</font>");
	}

	my @list;
	my ($page, $date);
	foreach my $item (@tocitem_List) {
		if ($item =~ /\[\[(.+?)\]\] (\d+)-(\d+)-(\d+)/) {
			$page = $1;
			$date = sprintf("%4d%02d%02d",$2,$3,$4);
			last if ($date < $startdate);
			if ($date <= $enddate) {
				$date = sprintf("%4d-%02d-%02d",$2,$3,$4);
				push(@list, "$page!$date");
			}
		}
	}
	return (1, @list);
}

1;

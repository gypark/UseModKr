sub action_blog_rss {
	use strict;
	my $listpage = &GetParam("listpage","");
	my $blogpage = &GetParam("blogpage","");
	my $num_items = 15;			# xml파일에 포함되는 글 갯수
	my $update_period = 60;		# xml파일 갱신 주기(단위:분). 0이면 항상 새로 생성

	my $xml = "";

	my $cachefile = $blogpage."_".$listpage;
	$cachefile =~ s/(\W)/uc sprintf "_%02x", ord($1)/eg;
	$cachefile = "$TempDir/rss_$cachefile.xml";

# cache 파일이 있고 마지막 갱신 이후 $update_period(분)이 지나지 않은 경우 
	if (-f $cachefile) {
		my $mtime = (stat($cachefile))[9];
		if (($Now - $mtime) < ($update_period * 60)) {
			my ($status, $data) = &ReadFile($cachefile);
			if ($status) {
				$xml = $data;
			}
		}
	}

# xml을 새로 생성함
	if ($xml eq "") {
		my ($rssHeader, $rssBody, $rssFooter);

		my ($title, $description, $link, $pubDate, $language);
# 사이트 제목
		$title = &QuoteHtml($SiteName);
# 사이트 설명
		$description = &QuoteHtml($SiteDescription);
# 사이트 링크
		$FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
		$QuotedFullUrl = &QuoteHtml($FullUrl);
		$link = $QuotedFullUrl;
		$link .= &ScriptLinkChar() . $blogpage if ($blogpage);
# xml작성 시각
		$pubDate = &BlogRssGetPubDate($Now);
# 언어 - how to detect?
		$language = "ko";

# rss header 생성
		$rssHeader = <<RSS;
<?xml version="1.0" encoding="$HttpCharset" ?>
<rss version="2.0">
<channel>
<title>$title</title>
<link>$link</link>
<description>$description</description>
<pubDate>$pubDate</pubDate>
<language>$language</language>
RSS

# rss footer 생성
		$rssFooter = <<RSS;
</channel>
</rss>
RSS

# header와 footer사이의 body 생성
		$rssBody = &BlogRssGetItems($listpage, $num_items);

# 전체 xml 생성
		$xml = $rssHeader.
			$rssBody.
			$rssFooter;

# cache 파일에 저장
		&WriteStringToFile($cachefile, $xml);
	}

# 최종 출력
	print "Content-type: text/xml\n\n";
	print $xml;

	return;
}


# param: 목차페이지, 아이템 갯수
# return: $txt
#  $txt : Rss 파일의 <item>...</item>항목들
sub BlogRssGetItems {
	use strict;
	my ($tocpage, $num_items) = @_;

	# 라이브러리 읽음
	my ($MacrosDir, $MyMacrosDir) = ("./macros/", "./mymacros/");
	if (-f "$MyMacrosDir/blog_library.pl") {
		require "./$MyMacrosDir/blog_library.pl";
	} elsif (-f "$MacrosDir/blog_library.pl") {
		require "./$MacrosDir/blog_library.pl";
	} else {
		return "";
	}

	# 목차페이지로부터 목차리스트를 얻어냄
	my ($status, $toc_mainpage, @tocitem_List) = &BlogReadToc($tocpage);
	if (!$status) {
		return "";
	}

	# 조건에 맞는 리스트를 구성
	($status, @tocitem_List) = &BlogGetListOrder(1, $num_items, @tocitem_List);
	if (!$status) {
		return "";
	}

	&OpenPage($tocpage);
	&OpenDefaultText();
	my $tocpage_author = $Section{'username'};

	# 리스트의 각 페이지를 읽어서 item 형식으로 만들어 반환함
	my $txt;

	my ($title, $description, $link, $pubDate, $category, $author);
	my ($page, $pagename, $date, $pageid);
	foreach my $item (@tocitem_List) {
		if ($item =~ /^(.+)$FS1(.*)$FS1(.+)$/) {
			($page, $pagename, $date) = ($1, $2, $3);
		}
		$pageid = $page;
		$pageid =~ s|^/|$toc_mainpage/|;
		$pageid = &FreeToNormal($pageid);

# 페이지가 존재하지 않으면 통과
		next if (not -f &GetPageFile($pageid));

		&OpenPage($pageid);
		&OpenDefaultText();

# 제목
		$title = $page;
# 내용
		$description = $Text{'text'};
		$description =~ s/<noinclude>.*?<\/noinclude>//igs;
		$description = &QuoteHtml($description);
		$description =~ s/\n/<br \/>\n/g;
# 링크
		$link = $QuotedFullUrl.&ScriptLinkChar().&EncodeUrl($pageid);
# 작성시각
		$pubDate = &BlogRssGetPubDate($Page{'tscreate'});
# 카테고리 - 대책없음
		$category = "";
# 작성자 - 편법으로, list 페이지의 작성자를 각 글의 작성자로 간주
		$author = &QuoteHtml($tocpage_author);

		$txt .= <<ITEM
<item>
<title>$title</title>
<description>$description</description>
<link>$link</link>
<pubDate>$pubDate</pubDate>
<category>$category</category>
<author>$author</author>
</item>
ITEM
	}

	return $txt;
}


# param: timestamp값
# return: $pubDate
#  $pubDate : <pubDate>항목 안에 들어갈 날짜와 시각 포맷
sub BlogRssGetPubDate {
	my ($ts) = @_;

	my @dow = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
	my @month = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($ts);
	my $pubDate = sprintf("%3s, %02d %3s %04d %02d:%02d:%02d +%02d00",
			$dow[$wday], $mday, $month[$mon], $year+1900, $hour, $min, $sec, $RssTimeZone);

	return $pubDate;
}

1;

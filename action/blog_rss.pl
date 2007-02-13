# blog_rss 액션

my @ChannelField = ('title','link','description','language',
		'copyright','manageingEditor','webMaster','pubDate',
		'lastBuildDate','category','generator','docs','could',
		'ttl','image','rating','textInput','skipHours','skipDays');
my @ItemField = ('title','link','description','author','category',
		'comments','enclosure','guid','pubDate','source');
my %NeedCdata = map { $_ => 1 } ('description');	# CDATA 로 묶어 줘야 할 필드
my (%RssChannelField, %RssItemFieldInList, %RssItemField, $ListPageAuthor);

sub action_blog_rss {
	use strict;
	my $listpage = &GetParam("listpage","");		# 참조할 목차 페이지
	my $blogpage = &GetParam("blogpage","");		# RSS의 link항목에 들어갈 페이지
	my $num_items = &GetParam("items",15);			# xml파일의 item 갯수

	my $xml = "";

	my $cachefile = $listpage."__".$blogpage."__".$num_items;
	$cachefile =~ s/(\W)/uc sprintf "_%02x", ord($1)/eg;
	$cachefile = "$TempDir/rss_$cachefile.xml";

	if (-f $cachefile) {
		# cache 파일의 마지막 수정 시각 이후에 사이트에 변동이 없는 경우
		# cache 파일을 읽어서 출력
		my $cache_mtime = (stat($cachefile))[9];
		my $rclog_mtime = (stat($RcFile))[9];
		if ($cache_mtime > $rclog_mtime) {
			my ($status, $data) = &ReadFile($cachefile);
			if ($status) {
				$xml = $data;
			}
		}
	}

	if ($xml eq "") {
		# xml을 새로 생성함
		my ($rssHeader, $rssBody, $rssFooter);

# 채널 정보의 디폴트 값을 먼저 설정
# 사이트 제목
		$RssChannelField{'title'} = &QuoteHtml($SiteName);
# 사이트 링크
		$FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
		$QuotedFullUrl = &QuoteHtml($FullUrl);
		$RssChannelField{'link'} = $QuotedFullUrl;
 		$RssChannelField{'link'} .= &ScriptLinkChar() . $blogpage if ($blogpage);
# 사이트 설명
		$RssChannelField{'description'} = $SiteDescription;
# 언어 - how to detect?
		$RssChannelField{'language'} = "ko";
# xml작성 시각
		$RssChannelField{'pubDate'} = &BlogRssGetPubDate($Now);

# 리스트 페이지에 사용자가 정의한 값을 읽어서 덮어 씀
		&OpenPage($listpage);
		&OpenDefaultText;
		$ListPageAuthor = $Section{'username'};
		&BlogRssGetUserDefinedValue($Text{'text'}, "list");

# rss header 생성
		$rssHeader = <<EOF;
<?xml version="1.0" encoding="$HttpCharset" ?>
<rss version="2.0">
<channel>
EOF
		foreach my $field (@ChannelField) {
			if ($RssChannelField{$field} ne "") {
				$rssHeader .= 
					"<$field>".
					(($NeedCdata{$field})?("<![CDATA[".$RssChannelField{$field}."]]>"):($RssChannelField{$field})).
					"</$field>".
					"\n";
			}
		}

# rss footer 생성
		$rssFooter = <<EOF;
</channel>
</rss>
EOF

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

	# 리스트의 각 페이지를 읽어서 item 형식으로 만들어 반환함
	my $txt;

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

# 아이템 필드 초기화
		%RssItemField = %RssItemFieldInList;

# 아이템 정보의 디폴트 값을 먼저 설정
		&OpenPage($pageid);
		&OpenDefaultText();
# 제목
		$RssItemField{'title'} = $page;
# 링크
		$RssItemField{'link'} = $QuotedFullUrl.&ScriptLinkChar().&EncodeUrl($pageid);
# 내용
		my $description = $Text{'text'};
		$description =~ s/<noinclude>.*?<\/noinclude>//igs;
		$description =~ s/<blog_rss>.*?<\/blog_rss>//igs;
		$description =~ s/\n/<br \/>\n/g;
 		$RssItemField{'description'} = $description;
# 작성자 - 목차 페이지에 명시되어 있으면 그 값 사용.
#          없으면 목차 페이지의 마지막 수정자의 아이디를 사용.
		if (not $RssItemField{'author'}) {
			$RssItemField{'author'} = $ListPageAuthor;
		}
# 카테고리 - 대책없음
# 		$RssItemField{'category'} = "";
# 작성시각
		$RssItemField{'pubDate'} = &BlogRssGetPubDate($Page{'tscreate'});

# 포스트 페이지에 사용자가 정의한 값을 읽어서 덮어 씀
		&BlogRssGetUserDefinedValue($Text{'text'});

		$txt .= "<item>\n";
		foreach my $field (@ItemField) {
			if ($RssItemField{$field} ne "") {
				$txt .=
					"<$field>".
					(($NeedCdata{$field})?"<![CDATA[".$RssItemField{$field}."]]>":$RssItemField{$field}).
					"</$field>".
					"\n";
			}
		}
		$txt .= "</item>\n";

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


# param: 텍스트[,출처]
# 텍스트에서 <blog_rss> </blog_rss> 부분을 찾아서 파싱하여 전역변수에 저장
sub BlogRssGetUserDefinedValue {
	my ($text, $where) = @_;
	my ($text_channel, $text_item);

	my $text_blog;
	while ($text =~ /<blog_rss>(.+?)<\/blog_rss>/igs) {
		$text_blog .= $1;
	}
	while ($text_blog =~ /<channel>(.+?)<\/channel>/igs) {
		$text_channel .= $1;
	}
	while ($text_channel =~ s/<item>(.+?)<\/item>//igs) {
		$text_item .= $1;
	}

	while ($text_channel =~ /<(.+?)>(.+?)<\/\1>/gs) {
		$RssChannelField{$1} = $2;
	}
	while ($text_item =~ /<(.+?)>(.+?)<\/\1>/gs) {
		if ($where eq "list") {
			$RssItemFieldInList{$1} = $2;
		} else {
			$RssItemField{$1} = $2;
		}
	}
}

1;

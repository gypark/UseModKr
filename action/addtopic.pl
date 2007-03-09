# See http://jof4002.net/?UseModWiki소스수정/주절주절에쉽게올리기
#     http://gypark.pe.kr/wiki/UseModWiki소스수정/웹페이지링크쉽게올리기

use strict;

sub action_addtopic {
########## 자기 위키에 맞춰서 바꿔 줄 부분
	my ($title_only, $title_with_text, $guide_msg);
	# 텍스트 필드에 자동으로 채워지는 형태
	$title_only      = '[$url $title]';				# 선택한 텍스트가 없는 경우
	$title_with_text = '[$url $text -- $title]';	# 있는 경우

	$guide_msg =				# 입력폼 상단에 나올 안내문
		"웹사이트 링크는 [http://www.usemod.com UseModWiki] 형식으로 하면 됩니다.";
##########

	$EmbedWiki = 1;

	# 필요한 데이타를 쿼리스트링으로부터 가져옴
	my ($id, $up, $url, $title, $text, $macro);
	$id    = &GetParam("id", "");
	$up    = &GetParam("up", "");
	$url   = &GetParam("url", "");
	$title = &GetParam("title", "");
	$text  = &GetParam("text", "");
	$macro  = &GetParam("m", 3);

	# 그 외 출력할 때 사용될 변수들
	my ($header_msg, $ccode, $idvalue, $name_field, $default_text, $comment_field);
	my ($threadindent, $long);

	# 매크로 종류
	if ($macro == 1) {		# comments
		($threadindent, $long) = ("", "0");
	} elsif ($macro == 2) {	# longcomments
		($threadindent, $long) = ("", "1");
	} else {				# thread
		($threadindent, $long) = ("0", "1");
	}

	# 인코딩 관련 처리들
	$guide_msg = &guess_and_convert($guide_msg);
	$header_msg = "$id 페이지에 올리기";
	$header_msg = &guess_and_convert($header_msg);
	# 위키에서 UTF-8이 아닌 인코딩을 사용하는 경우는 변환
	if ($HttpCharset !~ /utf-8|utf8/i) {
		$id = &convert_encode($id, "UTF-8", $HttpCharset);
		$title = &convert_encode($title, "UTF-8", $HttpCharset);
		$text = &convert_encode($text, "UTF-8", $HttpCharset);
	}

	# ccode
	$ccode = &simple_crypt(length($id).substr(&CalcDay($Now),5));

	# 사용자 이름 필드에 채워넣을 값
	if (&LoginUser()) {
		$idvalue = "[[$UserID]]";
	}
	$name_field = $q->textfield(-name=>"name",
								-class=>"comments",
								-size=>"15",
								-maxlength=>"80",
								-default=>"$idvalue");

	# 입력폼에 채워넣을 기본 텍스트
	$text =~ s/^\s*//;
	$text =~ s/\s*$//;
	if ($text eq "") {
		eval '$default_text = "'.$title_only.'";';
	} else {
		eval '$default_text = "'.$title_with_text.'";';
	}

	$comment_field = &GetTextArea("comment", $default_text, 7, 80);

	# html 출력
	print &GetHeader("", $header_msg, "");

	print 
		$q->h2($header_msg).
		"<DIV class='threadnew'>".
		$guide_msg.
		$q->startform(-name=>"comments",-method=>"POST",-action=>"$ScriptName",
				-enctype=>"application/x-www-form-urlencoded",
				-accept_charset=>"$HttpCharset").
		&GetHiddenValue("action","comments").
		&GetHiddenValue("id","$id").
		&GetHiddenValue("pageid","$id").
		&GetHiddenValue("up","$up").
		&GetHiddenValue("ccode","$ccode") .
		&GetHiddenValue("long","$long").
		&GetHiddenValue("threadindent","$threadindent").
		T('Name') . ": ".
		$name_field . "&nbsp;".
		T('Comment') . ":<br>".
		$comment_field . "&nbsp;" .
		$q->submit(-name=>"Submit",-value=>T("Submit")).
		$q->endform.
		"</DIV>";

	print &GetCommonFooter();

	return;
}

1;

sub action_comments {
	my $id = &GetParam("id", "");	
	my $pageid = &GetParam("pageid", "");
	my $name = &GetParam("name", "");
	my $newcomments = &GetParam("comment", "");
	my $up   = &GetParam("up", "");
	my ($timestamp) = CalcDay($Now) . " " . CalcTime($Now);
	my $string;
	my $long = &GetParam("long", "");

	&ValidIdOrDie($id);
	
	# thread
	my $threadindent = &GetParam("threadindent", "");
	my $abs_up = abs($up);
	my ($threshold1, $threshold2) = (100000000, 1000000000);
	
	if ($newcomments =~ /^\s*$/) {
		&ReBrowsePage($pageid, "", 0);
		return;
	}
		
	$name = &GetRemoteHost(0) if ($name eq "");
	$name =~ s/,/./g;
	$newcomments = &QuoteHtml($newcomments);

	&OpenPage($id);
	&OpenDefaultText();
	$string = $Text{'text'};

	if ($threadindent ne '') {		# thread
		$newcomments =~ s/^\s*//g;
		$newcomments =~ s/\s*$//g;
		$newcomments =~ s/(\n)\s*(\r?\n)/$1$2/g;
		$newcomments =~ s/(\r?\n)/ \\\\$1/g;

		my ($comment_head, $comment_tail) = ("", "");
		my $newup;

		if (($abs_up >= 100) && ($abs_up <= $threshold2)) {	# 커멘트 권한 상속
			$newup = $Now - $threshold2;
		} else {
			$newup = $Now;
		}

		$comment_tail = "<thread($id,$newup," . ($threadindent+1) . ")>";

		if ($threadindent >= 1) {
			for (1 .. $threadindent) {
				$comment_head .= ":";
			}
			$comment_head .= " ";
		} else {	# 새글
			$comment_head = "<thread>\n";
			$comment_tail .= "\n</thread>";
		}

		if (($up > 0) && ($up < $threshold1)) {		# 위로 달리는 새글
			$string =~ s/(\<thread\($id,$up(,\d+)?\)\>)/$comment_head$newcomments <mysign($name,$timestamp)>\n$comment_tail\n\n$1/;
		} else {									# 리플 or 아래로 달리는 새글
			$string =~ s/(\<thread\($id,$up(,\d+)?\)\>)/$1\n\n$comment_head$newcomments <mysign($name,$timestamp)>\n$comment_tail/;
		}
	} elsif ($long) {				# longcomments
		$newcomments =~ s/^\s*//g;
		$newcomments =~ s/\s*$//g;
		$newcomments =~ s/(\n)\s*(\r?\n)/$1$2/g;
		$newcomments =~ s/(\r?\n)/ \\\\$1/g;

		if ($up > 0) {
			$string =~ s/(\<longcomments\($id,$up\)\>)/\n$newcomments <mysign($name,$timestamp)>\n$1/;
		} else {
			$string =~ s/(\<longcomments\($id,$up\)\>)/$1\n$newcomments <mysign($name,$timestamp)>\n/;
		}
	} else {						# comments
		$newcomments =~ s/(----+)/<nowiki>$1<\/nowiki>/g;
		if ($up > 0) {
			$string =~ s/\<comments\($id,$up\)\>/* ''' $name ''' : $newcomments - <small>$timestamp<\/small>\n\<comments\($id,$up\)\>/;
		} else {
			$string =~ s/\<comments\($id,$up\)\>/\<comments\($id,$up\)\>\n* ''' $name ''' : $newcomments - <small>$timestamp<\/small>/;
		}
	}

	if (((!&UserCanEdit($id,1)) && (($abs_up < 100) || ($abs_up > $threshold2))) || (&UserIsBanned())) {		# 에디트 불가
		$pageid = "";
	}

	DoPostMain($string, $id, "*", $Section{'ts'}, 0, 0, $pageid);
	return;
}

1;

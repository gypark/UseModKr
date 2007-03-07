# replacetext action
# 일괄치환
sub action_replacetext {
	print &GetHeader("", T('Replace strings in all pages'), "");
	return  if (!&UserIsAdminOrError());

	my ($old, $new, $ignoreCase, $evaluate, $test);
	$oldStr = &GetParam("old", "");
	$newStr = &GetParam("new", "");
	$ignoreCase = &GetParam("p_ignore", "0");
	$ignoreCase = "1" if ($ignoreCase eq "on");
	$regular = &GetParam("p_regular", "0");
	$regular = "1" if ($regular eq "on");
	$evaluate = &GetParam("p_evaluate", "0");
	$evaluate = "1" if ($evaluate eq "on");
	$test = &GetParam("p_test", "0");
	$test = "1" if ($test eq "on");

# 폼 출력
	print &GetFormStart();
	print &GetHiddenValue("action", "replacetext"),"\n";
	print "Use Perl regular expression for text replacement.\n";
	print "<p><b>Old string:</b><br>\n";
	print $q->textfield(-name=>"old",-size=>"100",-maxlength=>"255",-default=>"$oldStr");
	print "<br>\n";
	print $q->checkbox(-name=>"p_ignore", -override=>1, -checked=>$ignoreCase,
						-label=>T('Ignore case'));
	print $q->checkbox(-name=>"p_regular", -override=>1, -checked=>$regular,
						-label=>T('Use regular expression'));

	print "\n<p><b>New string:</b><br>\n";
	print $q->textfield(-name=>"new",-size=>"100",-maxlength=>"255",-default=>"$newStr"). "\n";
	print "<br>\n";
	print $q->checkbox(-name=>"p_evaluate", -override=>1, -checked=>$evaluate,
						-label=>T('Evaluate'));

	print "<p>";
	print $q->submit(-name=>'Replace'), "\n";
	print $q->checkbox(-name=>"p_test", -override=>1, -checked=>1,
								-label=>T('Just test'));
	print $q->endform;

# old string 값이 없는 경우. 제일 처음 불렸을 때 등
	if ($oldStr eq '') {
		print &GetCommonFooter();
		return;
	}


	if ($test) {
		print "<p>Just test ...<br>\n";
	} else {
		print "<p>Search & replace ...<br>\n";
	}

	my ($page, $num);
	$num = 0;

	$oldStr = "\Q$oldStr\E" if (not $regular);
	$oldStr = "(?i)$oldStr" if ($ignoreCase);

	foreach $page (&AllPagesList()) {		# 모든 페이지 검사
		&OpenPage($page);
		&OpenDefaultText();
		my $newText = $Text{'text'};
		my $match = 0;

# 치환 시도
		if ($evaluate) {
			$match = ($newText =~ s/$oldStr/$newStr/goee);
		} else {
			$match = ($newText =~ s/$oldStr/$newStr/go);
		}

# 치환되는 것이 있는 경우
		if ($newText ne $Text{'text'}) {
			$num++;
			print "[$num] Processing $page ... $match string(s) were found.<br>";
			print &DiffToHTML(&GetDiff($Text{'text'}, $newText))."<br>";

			if (!$test) {	# 테스트 모드가 아닐 때는 저장
				DoPostMain($newText, $page, "*", $Section{'ts'}, 0, 1, "!!");
			}
		}
	}

	print "Completed.";
	print &GetCommonFooter();
}

1;

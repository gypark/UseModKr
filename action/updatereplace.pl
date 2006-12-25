# updatereplacedtext action
# 금지단어
sub action_updatereplace {
	print &GetHeader("", T('Replacing strings in all pages'), "");
	return  if (!&UserIsAdminOrError());

	my ($old, $new, $ignoreCase);
	$oldStr = &GetParam("old", "");
	$newStr = &GetParam("new", "");
	$ignoreCase = &GetParam("p_ignore", "0");
	$ignoreCase = "1" if ($ignoreCase eq "on");

	if ($oldStr eq '') {
		print T('Old string is empty');
		print &GetCommonFooter();
		return;
	}

	print "<p>Replace \"".
		"<b>$oldStr</b>".
		"\" to \"".
		"<b>$newStr</b>".
		"\".<br>\n";

	my ($page, $num);
	$num = 0;
	foreach $page (&AllPagesList()) {
		&OpenPage($page);
		&OpenDefaultText();
		my $newText = $Text{'text'};

		if ($ignoreCase) {
			$newText =~ s/$oldStr/$newStr/ig;
		} else {
			$newText =~ s/$oldStr/$newStr/g;
		}

		if ($newText ne $Text{'text'}) {
# 치환
			$num++;
			print "[$num] Processing $page ...<br>\n";

			DoPostMain($newText, $page, "*", $Section{'ts'}, 0, 1, "!!");
		}
	}

	print "Completed.";
	print &GetCommonFooter();
}

1;

# updatebannedtext action
# 금지단어
sub action_updatebannedtext {
	my ($newList, $fname);

	print &GetHeader("", T('Updating Banned text'), "");
	return  if (!&UserIsAdminOrError());
	$fname = "$DataDir/bantext";
	$newList = &GetParam("bantext", "#Empty file");
	if ($newList eq "") {
		print "<p>Empty banned text or error.";
		print "<p>Resubmit with at least one space character to remove.";
	} elsif ($newList =~ /^\s*$/s) {
		unlink($fname);
		print "<p>Removed banned text";
	} else {
		&WriteStringToFile($fname, $newList);
		print "<p>Updated banned text";
	}
	print &GetCommonFooter();
}

1;

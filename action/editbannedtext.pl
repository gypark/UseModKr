# editbannedtext action
# 금지단어
sub action_editbannedtext {
	my ($banList, $status);

	print &GetHeader("", T('Editing Banned text'), "");
	return if (!&UserIsAdminOrError());

	($status, $banList) = &ReadFile("$DataDir/bantext");
	$banList = "" if (!$status);
	print &GetFormStart();
	print &GetHiddenValue("edit_bantext",1),"\n";
	print &GetHiddenValue("action", "updatebannedtext"),"\n";
	print "<b>Banned text list:</b><br>\n";
	print "<p>Each entry is either a commented line (starting with #), ",
		"or text.";
	print "<p>Example:<br>",
		"# blocks text 'spam.com'<br>",
		"spam\\.com\$<p>";
	print &GetTextArea('bantext', $banList, 12, 50);
	print "<br>", $q->submit(-name=>'Save'), "\n";
	print $q->endform;
	print &GetCommonFooter();
}
	
1;

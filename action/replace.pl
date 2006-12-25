# replace action
# 금지단어
sub action_replace {
	print &GetHeader("", T('Replace strings in all pages'), "");
	return if (!&UserIsAdminOrError());

	print &GetFormStart();
	print &GetHiddenValue("action", "updatereplace"),"\n";
	print "Use Perl regular expression for text replacement.";
	print "<p><b>Old string:</b><br>";
	print $q->textfield(-name=>"old",-size=>"100",-maxlength=>"255",-default=>"");
	print "<br>";
	print $q->checkbox(-name=>"p_ignore", -override=>1, -checked=>0,
						-label=>T('Ignore case'));

	print "<p><b>New string:</b><br>";
	print $q->textfield(-name=>"new",-size=>"100",-maxlength=>"255",-default=>"");

	print "<p>", $q->submit(-name=>'Replace'), "\n";
	print $q->endform;
	print &GetCommonFooter();
}
	
1;

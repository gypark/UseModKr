sub action_blog_newpost {
	use strict;
	my $id = &GetParam("id","");
	my $pageid = &GetParam("pageid","");
	my $title = &GetParam("title","");
	my $date = &GetParam("date","");

	$title =~ s/^\s*//g;
	$title =~ s/\s*$//g;
	$title = "[[/$title]]";

	if ($date =~ /^(\d+)-(\d+)-(\d+)$/) {
		$date = sprintf("%4d-%02d-%02d",$1,$2,$3);
	}

	&OpenPage($id);
	&OpenDefaultText();
	my $string = $Text{'text'};

	$string =~ s/(<blog_newpost\($id\)>)/$1\n* $title $date/;

	if (!&UserCanEdit($id,1)) {
		$pageid = "";
	}

	&DoPostMain($string, $id, "*", $Section{'ts'}, 0, 0, $pageid);
	return;
}

1;

sub action_trackback {
	use strict;
	my $id = &GetParam("id","");
	my $normal_id = $id;

	my $url = &GetParam('url');
	my $title = &GetParam('title', $url);
	my $blog_name = &GetParam('blog_name');
	my $excerpt = &GetParam('excerpt');
	if (length($excerpt) > 255) {
		$excerpt = substr($excerpt, 0, 252);
		$excerpt =~ s/(([\x80-\xff].)*)[\x80-\xff]?$/$1/;
		$excerpt .= "...";
	}
	$excerpt =~ s/(\r?\n)/ /g;
	$excerpt = &QuoteHtml($excerpt);
	$excerpt = "<nowiki>$excerpt</nowiki>";

	if ($FreeLinks) {
		$normal_id = &FreeToNormal($id);
	}

	if ($url eq '') {
		&SendTrackbackResponse("1", "No URL (url)");
	} elsif ($id eq '') {
		&SendTrackbackResponse("1", "No Pagename (id)");
	} elsif (!&PageCanReceiveTrackbackPing($normal_id)) {
		&SendTrackbackResponse("1", "Invalid Pagename (Page is missing, or Trackback is not allowed)");
	} elsif (my $bannedText = &TextIsBanned($blog_name.$url.$title.$excerpt)) {
		&SendTrackbackResponse("1", "[$bannedText] is a Banned text");
	} else {
		&OpenPage($normal_id);
		&OpenDefaultText();
		my $string = $Text{'text'};
		my $macro = "\<trackbackreceived\>";
		if (!($string =~ /$macro/)) {
			$string .= "\n$macro\n";
		}
		my $timestamp = &CalcDay($Now) . " " . &CalcTime($Now);
		my $newtrackbackreceived = "* " .
			&Ts('Trackback from %s', "'''<nowiki>$blog_name</nowiki>'''") .
			" $timestamp\n" .
			"** " . &T('Title:') . " [$url $title]\n" .
			"** " . &T('Content:') . " $excerpt";
		$string =~ s/($macro)/$newtrackbackreceived\n$1/;
		&DoPostMain($string, $id, &T('New Trackback Received'), $Section{'ts'}, 0, 0, "!!");
		&SendTrackbackResponse(0, "");
	}
}

sub SendTrackbackResponse {
	my ($code, $message) = @_;

	if ($code == 0) {
		print <<END;
Content-Type: application/xml; charset: iso-8859-1\n
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>0</error>
</response>
END
	} else {
		print <<END;
Content-Type: application/xml; charset: iso-8859-1\n
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>$code</error>
<message>$message</message>
</response>
END
	}
}

1;

sub action_trackback {
	use strict;
	my $id = &GetParam("id","");
	my $normal_id = $id;

	my $url = &GetParam('url');
	my $title = &GetParam('title', $url);
	my $blog_name = &GetParam('blog_name');
	my $excerpt = &GetParam('excerpt');

# 블로그 지원을 위한 꽁수
	my ($blogrcpage, $blogrccomment);
	if ($id =~ m/(.+)(\/|%2f|%2F)(.+)/) {
		$blogrcpage = "$1/BlogRc";
	} else {
		$blogrcpage = "BlogRc";
	}
	if (-f &GetPageFile($blogrcpage)) {
		$blogrccomment = $excerpt;
	} else {
		$blogrcpage = "";
	}

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

# 블로그 지원을 위한 꽁수
		if ($blogrcpage) {
			$blogrccomment =~ s/(\r?\n)/ /g;
			$blogrccomment =~ s/\[/{/g;
			$blogrccomment =~ s/\]/}/g;
			if (length($blogrccomment) > 33) {
				$blogrccomment = substr($blogrccomment, 0, 30);
				$blogrccomment =~ s/(([\x80-\xff].)*)[\x80-\xff]?$/$1/;
				$blogrccomment .= "...";
			}
			$blogrccomment = &QuoteHtml($blogrccomment);
			$blogrccomment =~ s/----+/---/g;
			$blogrccomment =~ s/^ *//;
			$blogrccomment = "T) $blogrccomment";

			my ($fname, $status, $data);
			$fname = &GetPageFile($blogrcpage);
			if (-f $fname) {
				($status, $data) = &ReadFile($fname);
				if ($status) {
					my %temp_Page = split(/$FS1/, $data, -1);
					my %temp_Section = split(/$FS2/, $temp_Page{'text_default'}, -1);
					my %temp_Text = split(/$FS3/, $temp_Section{'data'}, -1);
					my $blogrc_Text = $temp_Text{'text'};

					my $date = &CalcDayNow();
					if ($date =~ /(\d+)-(\d+)-(\d+)/) {
						$date = sprintf("%4d-%02d-%02d",$1,$2,$3);
					}
					if ($blogrc_Text =~ /^\*/m) {
						$blogrc_Text =~ s/^\*/* [[$id|$blogrccomment]] $date\n*/m;
					} else {
						$blogrc_Text .= "\n* [[$id|$blogrccomment]] $date";
					}
					my $backup = $Section{'ts'};
					&DoPostMain($blogrc_Text, $blogrcpage, "", $temp_Section{'ts'}, 0, 1, "!!");
					$Section{'ts'} = $backup;
				}
			}
		}

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

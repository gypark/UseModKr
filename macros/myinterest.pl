sub myinterest {
	my ($txt) = @_;

	$txt =~ s/(\&__LT__;myinterest(\(([^\n]+)\))?\&__GT__;)/&MacroMyInterest($1, $3)/gei;

	return $txt;
}

sub MacroMyInterest {
	my ($itself, $username) = (@_);
	my ($data, $status, @pages);
	my (%tempUserData, %tempUserInterest);
	my $txt = "";

	if ($username eq "") {
		if (&GetParam('username') eq "") {
			return "";
		} else {
			$username = &GetParam('username');
		}
	}

	%tempUserData = ();
	($status, $data) = &ReadFile(&UserDataFilename($username));
	if (!$status) {
		return "";
	}
	%tempUserData = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
	%tempUserInterest = split(/$FS2/, $tempUserData{'interest'}, -1);
	
	@pages = sort (keys (%tempUserInterest));

	foreach (@pages) {
		$txt .= ".... "  if ($_ =~ m|/|);
		$txt .= &GetPageOrEditLink($_)."<br>";
	}

	return $txt;
}

1;

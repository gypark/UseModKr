$MacroFunc{"index"} = \&index;

my $MyIndexCounter;
my %MyIndexEntry;
my %MyIndexAlias;

sub index {
	my ($txt) = @_;
	my $index;

	$MyIndexCounter = 0;

	$txt =~ s/&__LT__;index\((.+?)\)&__GT__;/&MacroIndex($1)/gei;

	if ($MyIndexCounter > 0) {
		$index = "<DIV class='wordindex'>";
		$index .= &T('Index:')."<BR>";

		my $tablecolumn = 4;
		my $column = 0;

		$index .= "<TABLE style='border:none; width=100%;' width='100%'>";
		foreach my $key (sort {uc($a) cmp uc($b)} keys %MyIndexAlias) {
			$column++;
			$column = 1 if ($column > $tablecolumn);

			$index .= "<TR>" if ($column == 1);
			$index .= "<TD style='vertical-align:top; border:none; border-top:1px solid gray; padding: 10px'>";

			my @aliases = split (/\n/, $MyIndexAlias{$key});
			my $title = shift @aliases;

			$index .= "$key&nbsp;&nbsp;&nbsp;";
			$index .= "$MyIndexEntry{$key}";
			if (@aliases) {
				foreach my $aliaskey (sort {uc($a) cmp uc($b)} @aliases) {
					$title = $aliaskey;
					$title =~ s/^(.+)::://;
					$index .= "<BR>&nbsp;&nbsp;$title&nbsp;&nbsp;&nbsp;";
					$index .= "$MyIndexEntry{$aliaskey}";
				}
			}

			my $remain = join(", ", sort {uc($a) cmp uc($b)} @aliases);

			$index .= "</TD>";
			$index .= "</TR>" if ($column == $tablecolumn);
		}
		while ($column != $tablecolumn) {
			$column++;
			$index .= "<TD style='border:none;'>&nbsp;</TD>";
		}

		$index .= "</TABLE>";

		$index .= "</DIV>";

		$txt .= $index;
	}

	return $txt;
}

sub MacroIndex {
	my ($word) = @_;
	my $temp;
	my $txt;
	my ($key, $pword);

	$word = &RemoveLink($word);

	if ($word =~ /^(.+):::(.+)$/) {
		($key, $pword) = ($1, $2);
		$word = $key if ($key eq $pword);
	} else {
		$key = $word;
		$pword = $word;
	}

	if (! defined $MyIndexAlias{$key}) {
		$MyIndexAlias{$key} .= "$key\n";
	}

	if ($MyIndexAlias{$key} !~ /^\Q$word\E$/m) {
		$MyIndexAlias{$key} .= "$word\n";
	}

	$MyIndexCounter++;

	if (defined $MyIndexEntry{$word}) {
		$temp = ", ";
	}

	$temp .= "<A class='wordindex' name='INDEX_$MyIndexCounter' href='#INDEXR_$MyIndexCounter'>$MyIndexCounter</A>";
	$MyIndexEntry{$word} .= $temp;

	$txt = "<A class='wordindex' name='INDEXR_$MyIndexCounter' href='#INDEX_$MyIndexCounter'>".
		$pword.
		"</A>";

	return $txt;
}

1;

use strict;

my $MyIndexCounter;
my %MyIndexHash;

# %MyIndexHash is "hash of hash of array"
# %MyIndexHash = (
# 		"word1" => {
# 				"word1"  => [ num1 link, num2 link ],             <-- <index(word1)> or <index(word1:::word1)>
# 				"alias1" => [ num1 link, num2 link, num3 link ],  <-- <index(word1:::alias1)>
# 				"alias2" => [ num1 link ],
# 		},
# 		"word2" => {
# 				...
# 		},
# 		...
# )

sub index {
	my ($txt) = @_;
	my $index;

	$MyIndexCounter = 0;

	$txt =~ s/&__LT__;(?:index|ix)\((.+?)\)&__GT__;/&MacroIndex($1)/gei;

	return if ($MyIndexCounter == 0);

	$index = "<DIV class='wordindex'>";
	$index .= &T('Index:')."<BR>";

	my $tablecolumn = 4;		# 한 행에 4열
	my $column = 0;

	$index .= "<TABLE style='border:none; width=100%;' width='100%'>";

	foreach my $key (sort {lc($a) cmp lc($b)} keys %MyIndexHash) {
		$column++;
		$column = 1 if ($column > $tablecolumn);

		$index .= "<TR>" if ($column == 1);
		$index .= "<TD style='vertical-align:top; border:none; border-top:1px solid gray; padding: 10px'>";

		# main keyword
		$index .= "$key&nbsp;&nbsp;&nbsp;";
		$index .= join(', ', @{$MyIndexHash{"$key"}{"$key"}}) if defined @{$MyIndexHash{"$key"}{"$key"}};

		# aliases
		foreach my $aliaskey (sort {lc($a) cmp lc($b)} keys %{$MyIndexHash{"$key"}}) {
			next if ($aliaskey eq $key);

			$index .= "<BR>&nbsp;&nbsp;$aliaskey&nbsp;&nbsp;&nbsp;";
			$index .= join(', ', @{$MyIndexHash{"$key"}{"$aliaskey"}});
		}

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

	return $txt;
}

sub MacroIndex {
	my ($word) = @_;
	my $txt;
	my ($key, $pword);


	$word = &RemoveLink($word);

	if ($word =~ /^(.+):::(.+)$/) {
		($key, $pword) = ($1, $2);
	} else {
		$key = $word;
		$pword = $word;
	}

# 본문 하단에 출력될 인덱스 화면을 위해 저장
	$MyIndexCounter++;
	push @{$MyIndexHash{"$key"}{"$pword"}},
		"<A class='wordindex' name='INDEX_$MyIndexCounter' href='#INDEXR_$MyIndexCounter'>$MyIndexCounter</A>";

# 매크로 있던 곳에 치환된 링크
	$txt = "<A class='wordindex' name='INDEXR_$MyIndexCounter' href='#INDEX_$MyIndexCounter'>".
		$pword.
		"</A>".
		"<SPAN class='wordindex'>($MyIndexCounter)</SPAN>";

	return $txt;
}

1;

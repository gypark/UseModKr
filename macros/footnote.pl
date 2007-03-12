use strict;

my $MyFootnoteCounter;
my @MyFootnotes;
my %SaveNumFootnote;

sub footnote {
	my ($txt) = @_;

	$MyFootnoteCounter = 0;
	$txt =~ s/(&__LT__;footnote\(([^\n]+?)\)&__GT__;)/&MacroFootnote($2)/gei;

	# 본문 하단에 각주 출력
	if ($MyFootnoteCounter > 0) {
		map { s/_MARK_// } @MyFootnotes;
		$txt .= "<DIV class='footnote'>".
			"\n" . T('Footnote') . ": <br>\n".
			join('', @MyFootnotes). "</DIV>";
	}

	return $txt;
}

sub MacroFootnote {
	my ($note) = @_;

	$MyFootnoteCounter++;
	my $number = "<A name='FN_$MyFootnoteCounter' href='#FNR_$MyFootnoteCounter'>$MyFootnoteCounter</A>.";
	if (defined $SaveNumFootnote{$note}) {
		# 동일한 내용의 각주가 이미 있다면 그 각주에다가 새 번호 삽입
		$MyFootnotes[$SaveNumFootnote{$note}] =~ s/_MARK_/$number _MARK_/;
	} else {
		# 새로운 내용의 각주 추가
		push @MyFootnotes,
			 $number.
			" _MARK_$note".
			"<br>\n";
		$SaveNumFootnote{$note} = $#MyFootnotes;
	}
	return "<A class='footnote' name='FNR_$MyFootnoteCounter' href='#FN_$MyFootnoteCounter'>$MyFootnoteCounter</A>";
}

1;

$MacroFunc{"footnote"} = \&footnote;

my $MyFootnoteCounter;
my $MyFootnotes;

sub footnote {
	my ($txt) = @_;

	$MyFootnoteCounter = 0;
	$MyFootnotes = "\n" . T('Footnote') . ": <br>\n";
	$txt =~ s/(&__LT__;footnote\(([^\n]+?)\)&__GT__;)/&MacroFootnote($2)/gei;
	if ($MyFootnoteCounter > 0) {
		$txt .= "<DIV class='footnote'>" .  $MyFootnotes .  "</DIV>";
	}

	return $txt;
}

sub MacroFootnote {
	my ($note) = @_;

	$MyFootnoteCounter++;
	$MyFootnotes .= "<A name='FN_$MyFootnoteCounter' href='#FNR_$MyFootnoteCounter'>$MyFootnoteCounter</A>" .
					". $note" .
					"<br>\n";
	return "<A class='footnote' name='FNR_$MyFootnoteCounter' href='#FN_$MyFootnoteCounter'>$MyFootnoteCounter</A>";
}

1;

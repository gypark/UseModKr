sub history {
	my ($txt) = @_;

	$txt =~ s/\&__LT__;history\((.*?)\)\&__GT__;/&MacroHistory($1)/gei;

	return $txt;
}

sub MacroHistory {
	my ($n) = @_;
	my ($html, $i);

	&OpenPage($DocID);
	&OpenDefaultText();

	$html = "<form action='$ScriptName' METHOD='GET'>";
	$html .= "<input type='hidden' name='action' value='browse'/>";
	$html .= "<input type='hidden' name='diff' value='1'/>";
	$html .= "<input type='hidden' name='id' value='$DocID'/>";
	$html .= "<table border='0' cellpadding=0 cellspacing=0 width='90%'><tr>";
	$html .= &GetHistoryLine($DocID, $Page{'text_default'}, 0, 0);

	&OpenKeptRevisions('text_default');
	$i = 0;
	foreach (reverse sort {$a <=> $b} keys %KeptRevisions) {
		if (++$i > $n) {
			$html .= "<tr><td align='center'><input type='submit' value='" 
					. T('Compare') . "'/>  </td><td>&nbsp;</td></table></form>\n";
			return $html;
		}
		next  if ($_ eq "");  # (needed?)
		$html .= &GetHistoryLine($DocID, $KeptRevisions{$_}, 0, $i);
	}
	$html .= "<tr><td align='center'><input type='submit' value='"
				. T('Compare') . "'/>  </td><td>&nbsp;</td></table></form>\n";
	return $html;
}

1;

# <showintermap>
# intermap 파일의 내용을 출력함

sub showintermap {
	my ($txt) = @_;

	$txt =~ s/&__LT__;showintermap&__GT__;/&MacroShowInterMap()/gei;

	return $txt;
}

sub MacroShowInterMap() {
	my ($status, $data) = &ReadFile($InterFile);

	if ($status) {
		$data =~ s/(#.*)/&StoreRaw("<SPAN style='color: blue;'>$1<\/SPAN>")/ge;
		$data =~ s/\|([^\|\n]+\.$ImageExtensions)/ <IMG class='inter' src='$InterIconDir\/$1' alt='$1'>/g;
		$data =~ s/\|([^\|\n]+)/ <SPAN style='color: green;'>$1<\/SPAN>/g;
		$data =~ s/\|//g;
		$data = &RestoreSavedText($data);
	} else {
		$data = "Can't read intermap file";
	}

	return &StoreRaw("<PRE class='code'>\n".$data."</PRE>"); 
}

1;

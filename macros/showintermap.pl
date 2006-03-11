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
		$data =~ s/\|(\S+)/ <IMG class='inter' src='$InterIconDir\/$1' alt='$1'>$2/gm;
	} else {
		$data = "Can't read intermap file";
	}

	return &StoreRaw("<PRE class='code'>\n".$data."</PRE>"); 
}

1;

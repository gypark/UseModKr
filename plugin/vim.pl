# vim plugin
# 박원규님의 MoniWiki 의 vim.php 의 코드를 흉내내었음.
# 
# usage :
# {{{#!vim sh|c|sh|.. [number]
# some codes
# }}}

sub plugin_vim {
    my ($content, @opt) = @_;
	my $vim = "vim";		# PATH of vim
	my $tohtml = "syntax/2html.vim";
	my $text;
	my $status;

	my @syntax = ("php","c","python","jsp","sh","cpp",
          "java","ruby","forth","fortran","perl",
          "haskell","lisp","st","objc","tcl","lua",
          "asm","masm","tasm","make",
          "awk","docbk","diff","html","tex","vim",
          "xml","dtd","sql","conf","config","nosyntax","apache");
	my %syntax = map { $_ => 1 } @syntax;

	my $type = "nosyntax";
	foreach my $opt (@opt) {
		if ($syntax{$opt}) {
			$type = $opt;
		} elsif ($opt eq "number") {
			$option='+"set number" ';
		}

	}

# html파일의 이름 결정
	my $hash;
	my $hasMD5 = eval "require Digest::MD5;";
	if ($hasMD5) {
		$hash = Digest::MD5::md5_base64($content.join('',@opt));
	} else {
		$hash = crypt($content.join('',@opt), $HashKey);
	}
	$hash =~ s/(\W)/uc sprintf "%%%02x", ord($1)/eg;

	my $hashhtml = "$hash.html";
	my $VimDir = "$UploadDir/vim";

	if (-f "$VimDir/$hashhtml" && not -z "$VimDir/$hashhtml") {
		# 이미 생성되어 캐쉬에 있음
	} else {
		&CreateDir($UploadDir);
		&CreateDir($VimDir);

		my $hashdir = "$TempDir/$hash";
		if (not -d $hashdir) {
			mkdir($hashdir, 0775) or return "[Unable to create $hash dir]";
		}

		my $pwd = `pwd`;
		$pwd =~ s/(.*)(\n|\r)*/$1/;

		chdir ($hashdir);
		
# html 생성
		my $tmpi = "$hash.in";
		my $tmpo = "$hash.out";
		open (OUT, ">$tmpi") or return "[Unable to open $tmpi file]";
		print OUT  $content;
		close(OUT);

		open SAVEOUT, ">&STDOUT";
		open SAVEERR, ">&STDERR";
		open STDOUT, ">hash.log";
		open STDERR, ">&STDOUT";

		qx($vim -T xterm -e -s $tmpi +"syntax on" +"set syntax=$type" $option +"ru! $tohtml" +"wq! $tmpo" +q);

		close STDOUT;
		close STDERR;
		open STDOUT, ">&SAVEOUT";
		open STDERR, ">&SAVEERR";

# html 가공 및 옮김
		($status, $text) = &ReadFile("$tmpo");
		if (!$status) {
			return undef;
		}
		$text =~ s/<title>.*title>|<\/?head>|<\/?html>|<meta.*>|<\/?body.*>//g;
		$text =~ s/<pre>/<pre class='syntax' style='font-family:FixedSys,monospace;color:#c0c0c0;background-color:black'>/g;

		chdir($pwd);
		open (OUT, ">$VimDir/$hashhtml") or return "[Unable to open $hashhtml file]";
		print OUT  $text;
		close(OUT);

		unlink (glob("$hashdir/*")) or return "[unlink fail]";
		rmdir ($hashdir) or return "[rmdir fail]";
	}

	($status, $text) = &ReadFile("$VimDir/$hashhtml");
	if (!$status) {
		return undef;
	}

    return $text;
}

1;

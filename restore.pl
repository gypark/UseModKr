#!/usr/bin/perl

# CGI script to copy directory for restoration
# by gypark (raymundo@kebi.com)
# 2003-03-10

# 다른 곳에 백업해둔 위키 데이타를 nobody 의 권한으로 복사하여 복원하는 스크립트입니다.
# 스크립트의 퍼미션을 755 로 변경한 후 웹브라우저를 통해 실행하세요.

umask 0;

# 파라메터 저장
if ($ENV{'QUERY_STRING'} ne "") {
	@pairs = split(/&/, $ENV{'QUERY_STRING'});
} else {
	$buffer = "";
	read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	chomp $buffer;
	@pairs = split(/&/, $buffer);
}

foreach (@pairs) {
	($name, $value) = split(/=/, $_);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
	$param{$name} = $value;
}

# 구동
if (defined($param{'source'}) && defined($param{'dest'})) {
	print_header();
	if (copy_dir($param{'source'}, $param{'dest'})) {
		print "<p><b>성공적으로 데이타를 복사했습니다.</b>";
	} else {
		print "<p><b>데이타 복사에 실패했습니다.</b>";
		print_form();
		print_footer();
	}
	exit;
} else {
	print_header();
	print_form();
	print_footer();
	exit;
}


sub print_header {
	print "Content-type: text/html\n\n";
	print <<END_OF_FILE;
<html>
<head>
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=EUC-KR">
<title>restore the files to nobody's permission</title>
</head>
<body>
디렉토리를 복사해 주는 스크립트 입니다.<br>
웹브라우저를 통해서 CGI 로 실행을 하면,<br>
자신이 백업해 둔 위키데이타 디렉토리를 복사하여<br>
nobody 소유의 디렉토리와 화일로 만들어 줍니다.<br>
<p>
<hr>
END_OF_FILE
}

sub print_form {
	print <<END_OF_FILE;
<form method="post" action="restore.pl" name="form_input">
<p>
스크립트의 경로: $0<br>\n
<p>
보관된 데이타 디렉토리의 경로 : <input type="text" name="source" size="60" value="$param{'source'}" /><br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (예: /home/foo/backup/data)<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (이 디렉토리가 시스템에 존재해야 합니다)<br>\n
<p>
복원할 데이타 디렉토리의 경로 : <input type="text" name="dest" size="60" value="$param{'dest'}" /><br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (예: /home/foo/public_html/cgi-bin/wiki/data)<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (이 디렉토리가 시스템에 존재하고, 퍼미션이 777로 되어 있으며,<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  디렉토리 안에 다른 화일이나 디렉토리가 없어야 합니다)<br>\n
<p>
<input type="submit" name="copy" value="복사" />
</form>
END_OF_FILE
}

sub print_footer {
	print <<END_OF_FILE;
</body>
</html>
END_OF_FILE
}

sub copy_dir {
	my ($source, $dest) = @_;

	if ($source eq "") {
		print "<p><b>원본 디렉토리의 경로를 입력하세요</b>";
		return 0;
	}
	if ($dest eq "") {
		print "<p><b>복사할 대상 디렉토리의 경로를 입력하세요</b>";
		return 0;
	}
	if (!(-d $source)) {
		print "<p><b>원본 경로가 존재하지 않거나, 디렉토리가 아닙니다</b>";
		return 0;
	}
	if (!(-d $dest)) {
		print "<p><b>대상 경로가 존재하지 않거나, 디렉토리가 아닙니다</b>";
		return 0;
	}
	if (!(-w $dest)) {
		print "<p><b>대상 경로의 퍼미션이 올바르지 않습니다</b>";
		return 0;
	}
	opendir(DIR, $dest);
	my @files = readdir(DIR);
	if ($#files != 1) {
		print "<p><b>대상 디렉토리가 비어 있지 않습니다</b>";
		return 0;
	}
	print "<p><b>데이타 복사를 시작합니다.</b>";
	if (copy_dir_recursive($source, $dest)) {
		return 1;
	} else {
		return 0;
	}

}

sub copy_dir_recursive {
	my ($source, $dest) = @_;
	if (!opendir (SOURCEDIR, "$source")) {
		print "<p><b>$source 디렉토리를 여는 데 실패했습니다: $!</b>" ; 
		return 0; 
	}
	my @sourcefiles = readdir(SOURCEDIR);
	closedir SOURCEDIR;

	print "<br>enter [$source] ...";
	foreach my $file (@sourcefiles) {
		next if (($file eq ".") || ($file eq ".."));
		if (-d "$source/$file") {
			mkdir ("$dest/$file", 0775) or die "$dest/$file 디렉토리 생성 실패 : $!";
			copy_dir_recursive("$source/$file", "$dest/$file");
		} else {
			my $content;
			print "<br>copying [$file] to [$dest] ...";
			open (SRCFILE, "<$source/$file");
			open (DESTFILE, ">$dest/$file");
			while ($content = <SRCFILE>) {
				print DESTFILE $content;
			}
			close (SRCFILE);
			close (DESTFILE);
		}
	}
	return 1;
}

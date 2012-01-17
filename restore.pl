#!/usr/bin/perl

# CGI script to copy directory for restoration
# by gypark (gypark@gmail.com)
# 2003-03-10

# 다른 곳에 백업해둔 위키 데이타를 nobody 의 권한으로 복사하여 복원하는 스크립트입니다.
# 스크립트의 퍼미션을 755 로 변경한 후 웹브라우저를 통해 실행하세요.

use strict;
umask 0;

use vars qw(%param @pairs);

# 파라메터 저장
if ($ENV{'QUERY_STRING'} ne "") {
    @pairs = split(/&/, $ENV{'QUERY_STRING'});
} else {
    my $buffer = "";
    read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    chomp $buffer;
    @pairs = split(/&/, $buffer);
}

foreach (@pairs) {
    my ($name, $value) = split(/=/, $_);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
    $param{$name} = $value;
}

# 구동
if ($param{'action'} eq "data") {
    print_header();
    if (copy_dir($param{'source'}, $param{'dest'})) {
        print "<p><b>성공적으로 데이타를 복사했습니다.</b>";
        print_footer();
    } else {
        print "<p><b>데이타 복사에 실패했습니다.</b>";
        print_form();
        print_footer();
    }
    exit;
} elsif ($param{'action'} eq "upload") {
    print_header();
    if (convert_upload($param{'uploaddir'})) {
        print "<p><b>파일명 변경에 성공했습니다.</b>";
        print_footer();
    } else {
        print "<p><b>파일명 변경에 실패했습니다.</b>";
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
    print "Content-type: text/html; charset=UTF-8\n\n";
    print <<END_OF_FILE;
<html>
<head>
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<title>UseModWiki ext버전 데이타,파일관리 스크립트</title>
</head>
<body>
위키 데이타 디렉토리와 업로드 디렉토리를 관리해 주는 스크립트 입니다.<br>
<p>
END_OF_FILE
}

sub print_form {
    print <<END_OF_FILE;
<hr>
<h2>데이타 디렉토리 복사</h2>
<p>
자신이 백업해 둔 위키데이타 디렉토리를 복사하여<br>
nobody 소유의 디렉토리와 화일로 만들어 줍니다.<br>
<form method="post" action="restore.pl" name="form_input">
<p>
이 스크립트의 경로: $0<br>\n
<p>
보관된 데이타 디렉토리의 경로 : <input type="text" name="source" size="60" value="$param{'source'}" /><br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (예: /home/foo/backup/data)<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (이 디렉토리가 시스템에 존재해야 합니다)<br>\n
<p>
복원할 데이타 디렉토리의 경로 : <input type="text" name="dest" size="60" value="$param{'dest'}" /><br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (예: /home/foo/public_html/cgi-bin/wiki/data)<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (이 디렉토리가 시스템에 존재하고, 퍼미션이 2777로 되어 있으며,<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  디렉토리 안에 다른 화일이나 디렉토리가 없어야 합니다)<br>\n
<p>
페이지 이름과 내용의 인코딩 변환: 
<select name="encode_convert">
<option value="none" selected="selected">변환하지 않음</option>
<option value="EUC-KR,UTF-8">EUC-KR -> UTF-8  로 변환</option>
<option value="UTF-8,EUC-KR">UTF-8  -> EUC-KR 로 변환</option>
</select>
<p>
페이지의 FS(필드 구분자) 변환: 
<select name="fs_convert">
<option value="none" selected="selected">변환하지 않음</option>
<option value="7f,1e">ext1.* -> ext2.* 형식으로 변환</option>
<option value="1e,7f">ext2.* -> ext1.* 형식으로 변환</option>
</select>
<p>
<input type="hidden" name="action" value="data" />
<input type="submit" name="copy" value="복사" />
</form>
<hr>
<h2>업로드 디렉토리 파일명 인코딩 변환</h2>
<form method="post" action="restore.pl" name="form_input">
<p>
업로드 디렉토리의 경로 : <input type="text" name="uploaddir" size="60" value="$param{'source'}" /><br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (예: /home/foo/public_html/cgi-bin/wiki/upload)<br>\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (이 디렉토리가 시스템에 존재해야 합니다)<br>\n
<p>
인코딩 변환: 
<select name="filename_convert">
<option value="EUC-KR,UTF-8">EUC-KR -> UTF-8  로 변환</option>
<option value="UTF-8,EUC-KR">UTF-8  -> EUC-KR 로 변환</option>
</select>
<p>
<input type="hidden" name="action" value="upload" />
<input type="submit" name="copy" value="변환" />
</form>
<hr>
END_OF_FILE
}

sub print_footer {
    print <<END_OF_FILE;
</body>
</html>
END_OF_FILE
}

sub convert_upload {
    my ($uploaddir) = @_;
    if ($uploaddir eq "") { 
        print "<p><b>업로드 디렉토리의 경로를 입력하세요</b>";
        return 0;
    }
    if (!(-d $uploaddir)) {
        print "<p><b>업로드 디렉토리가 존재하지 않거나, 디렉토리가 아닙니다</b>";
        return 0;
    }
    my ($from, $to) = split(/,/, $param{'filename_convert'});
    foreach my $file (glob("$uploaddir/*")) {
        my $destfile = &convert_encode($file, $from, $to);
        print " rename $file -> $destfile<br>\n";
        if (!rename($file, $destfile)) {
            print "<b> 이름 변경 실패</b><br>\n";
            return 0;
        }
    }
    return 1;
}

sub copy_dir {
    my ($source, $dest) = @_;

# 파라메터 체크
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

# 변환 관련 파라메터
    my ($from, $to, $FSold, $FSnew) = ("", "", "", "");
    if ($param{'encode_convert'} ne "none") {
        ($from, $to) = split(/,/, $param{'encode_convert'});
    }
    my %FS = ('7f' => "\x7f", '1e' => "\x1e");
    if ($param{'fs_convert'} ne "none") {
        ($FSold, $FSnew) = split(/,/, $param{'fs_convert'});
        $FSold = $FS{$FSold};
        $FSnew = $FS{$FSnew};
    }

# 복사
    print "<p><b>데이타 복사를 시작합니다.</b>";
    if (copy_dir_recursive($source, $dest, $from, $to, $FSold, $FSnew)) {
        return 1;
    } else {
        return 0;
    }
}

sub copy_dir_recursive {
    my ($source, $dest, $from, $to, $FSold, $FSnew) = @_;
    if (!opendir (SOURCEDIR, "$source")) {
        print "<p><b>$source 디렉토리를 여는 데 실패했습니다: $!</b>" ; 
        return 0; 
    }
    my @sourcefiles = readdir(SOURCEDIR);
    closedir SOURCEDIR;

    print "<br>enter [$source] ...\n";
    foreach my $file (@sourcefiles) {
        next if (($file eq ".") || ($file eq ".."));
        if (-d "$source/$file") {
            my $destfile = $file;
            if ($from ne "") {      # 디렉토리 이름 컨버트
                $destfile = &convert_encode($destfile, $from, $to);
            }
            mkdir ("$dest/$destfile", 0775) or die "$dest/$destfile 디렉토리 생성 실패 : $!";
            copy_dir_recursive("$source/$file", "$dest/$destfile", $from, $to, $FSold, $FSnew);
        } else {
            my $content;
            open (SRCFILE, "<$source/$file");

            my $destfile = $file;
            if ($from ne "") {      # 파일이름 컨버트
                $destfile = &convert_encode($destfile, $from, $to);
            }
            print "<br>&nbsp;&nbsp;copy [$file] to [$destfile] ...\n";
            open (DESTFILE, ">$dest/$destfile");
            while ($content = <SRCFILE>) {
# 내용 중 $FS부터 변환
                if ($FSold ne "") {
                    $content =~ s/$FSold/$FSnew/g;
                }
# 나머지 내용 utf-8로 변환
                if ($from ne "") {
                    $content = &convert_encode($content, $from, $to);
                }
                print DESTFILE $content;
            }
            close (SRCFILE);
            close (DESTFILE);
        }
    }
    return 1;
}

sub convert_encode {
    my ($str, $from, $to) = @_;

    eval { require Encode; };
    unless($@) {
        $str = Encode::encode($to, Encode::decode($from, $str));
    } else {
        eval { require Text::Iconv; };
        unless($@) {
            my $converter = Text::Iconv->new($from, $to);
            $str = $converter->convert($str);
        }
    }
    return $str;
}


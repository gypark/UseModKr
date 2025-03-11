# vim plugin
# 박원규님의 MoniWiki 의 vim.php 의 코드를 흉내내었음.
# 
# usage :
# {{{#!vim sh|c|sh|.. [number]
# some codes
# }}}

use strict;

sub plugin_vim {
    my ($content, @opt) = @_;
    my $vim = "vim";        # PATH of vim
    my $tohtml = "syntax/2html.vim";
    my $text;
    my $status;
    my $option;

    my $type = "nosyntax";
    foreach my $opt (@opt) {
        if ($opt eq "number") {
            $option='+"set number" ';
        } elsif ($opt =~ /^\w+$/) {
            $type = $opt;
        }
    }
    $content =~ s/\r//g;

# html파일의 이름 결정
    require Digest::MD5;
    my $hash = Digest::MD5::md5_hex($content.join('',@opt));

    my $hashhtml = "$hash.html";
    my $VimDir = "$UploadDir/vim";

    if (-f "$VimDir/$hashhtml") {
        # 이미 생성되어 캐쉬에 있음
        ($status, $text) = &ReadFile("$VimDir/$hashhtml");

        return $text if $status;
    }

    # 캐쉬에 없거나, 읽는 데 실패하면 새로 작성
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

    qx($vim -T xterm \\
            -e -s \\
            $tmpi \\
            +"set enc=$HttpCharset" \\
            +"syntax on" \\
            +"set syntax=$type" \\
            $option \\
            +"let html_use_css=1" \\
            +"ru! $tohtml" \\
            +"wq! $tmpo" \\
            +q);

    close STDOUT;
    close STDERR;
    open STDOUT, ">&SAVEOUT";
    open STDERR, ">&SAVEERR";

    # html 가공 및 옮김
    ($status, $text) = &ReadFile("$tmpo");
    if (!$status) {
        return undef;
    }
    $text =~ s'.*(?=^<style)''sm;
    $text =~ s'^</head>\n<body>\n''sm;
    $text =~ s'^<pre>$'<pre class="vim">'m;
    $text =~ s'\n</body>\n</html>.*''sm;
    $text =~ s'^pre \{[^}]+}\n(?=.*^</style>$)''sm;
    $text =~ s'^body \{[^}]+}\n(?=.*^</style>$)''sm;

    $text = font2span($text);

    chdir($pwd);

    # 캐쉬에 저장
    if (open my $out, '>', "$VimDir/$hashhtml") {
        print {$out} $text;
        close $out;
    }

    unlink (glob("$hashdir/*")) or return "[unlink fail]";
    rmdir ($hashdir) or return "[rmdir fail]";

    return $text;
}

sub font2span {
    my $html = shift;

    my @colors = $html =~ m/color="#([^"]+)"/g;
    my %colorMap;
    $colorMap{$_}++ for @colors;
    @colors = keys %colorMap;

    my $style = "<style type=\"text/css\">\n";
    for my $color (@colors) {
        $style .= "._$color { color: #$color }\n";
    }

    $style .= "</style>\n";
    $html = $style . $html;
    $html =~ s/font color="#/span class="_/g;
    $html =~ s/\/font/\/span/g;
    return $html;
}

1;

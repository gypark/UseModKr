# latex plugin
# http://www.codecogs.com/latex/eqneditor.php 이용
#
# usage :
#  1) inline:
#    $$ equation $$ - inline
#      or
#    {{{#!latex inline
#     equation
#    }}}
# 
#  2) display:
#    \[ equation \]
#      or
#    {{{#!latex
#     equation       - display
#    }}}

use strict;
use warnings;

sub plugin_latex {
    my ($content, @opt) = @_;
    my $img;
    my $class;

    # 캐시 저장할 이미지 파일명
    require Digest::MD5;
    my $hash = Digest::MD5::md5_hex($content.join('',@opt));
    my $imgfile = "$hash.png";

    # 저장할 디렉토리
    my $dir = "$UploadDir/latex";
    my $url = "$UploadUrl/latex";

    # 옵션 inline 처리
    if ( $opt[0] eq 'inline' ) {
        $content = '\inline '.$content;
        $class   = 'latexinline';
    }
    else {
        $class   = 'latexdisplay';
    }

    # 반환할 이미지 태그
    my $alt = "latex equation";
    my $img_cached = qq(<img src="$url/$imgfile" class="$class" alt="$alt">);

    # 캐시에 있으면 주소 반환
    if ( -f "$dir/$imgfile" ) {
        return $img_cached;
    }

    # 캐시에 없으면 새로 구성

    $content =~ s/\r?\n/ /g;
    my $src       = "http://latex.codecogs.com/gif.latex?$content";
    my $img_latex = qq(<img src="$src" class="$class" alt="$alt">);

    # LWP::Simple이 없으면 ditaa.org의 주소를 바로 반환 - 느리다
    if ( not eval { require LWP::Simple } ) {
        return $img_latex;
    }

    # 캐시 디렉토리에 저장하고 주소 반환
    eval {
        CreateDir($UploadDir);
        CreateDir($dir);
    };
    return $img_latex if $@;

    my $res = LWP::Simple::getstore($src, "$dir/$imgfile");
    if ( $res eq "200" ) {
        return $img_cached;
    }
    else {
        return $img_latex;
    }
}

1;

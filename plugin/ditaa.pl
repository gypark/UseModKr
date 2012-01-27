# ditaa plugin
# http://ditaa.org/ditaa/
# http://www.asciiflow.com/
#
# usage :
# {{{#!ditaa
# text art
# }}}

sub plugin_ditaa {
    my ($content, @opt) = @_;
    my $img;

    # 캐시 저장할 이미지 파일명
    require Digest::MD5;
    my $hash = Digest::MD5::md5_hex($content);
    my $imgfile = "$hash.png";

    # 저장할 디렉토리
    my $dir = "$UploadDir/ditaa";
    my $url = "$UploadUrl/ditaa";

    # 반환할 이미지 태그
    my $alt = "ditaa diagram";
    my $img_cached = qq(<img src="$url/$imgfile" alt="$alt">);

    # 캐시에 있으면 주소 반환
    if ( -f "$dir/$imgfile" ) {
        return $img_cached;
    }

    # 캐시에 없으면 새로 구성

    my $enc       = EncodeUrl($content);
    my $ditaa     = "http://ditaa.org/ditaa/render?grid=$enc";
    my $img_ditaa = qq(<img src="$ditaa" alt="$alt">);

    # LWP::Simple이 없으면 ditaa.org의 주소를 바로 반환 - 느리다
    if ( not eval { require LWP::Simple } ) {
        return $img_ditaa;
    }

    # 캐시 디렉토리에 저장하고 주소 반환
    CreateDir($UploadDir);
    CreateDir($dir);

    my $res = LWP::Simple::getstore($ditaa, "$dir/$imgfile");
    if ( $res eq "200" ) {
        return $img_cached;
    }
    else {
        return $img_ditaa;
    }
}

1;

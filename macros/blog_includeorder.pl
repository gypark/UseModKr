# <blog_includeorder(목차페이지,시작순서,끝순서)>
# 목차페이지를 읽어서 시작순서부터 끝순서까지의 페이지를 include한다.

sub blog_includeorder {
    my ($txt) = @_;

    $txt =~ s/(^|\n)<blog_includeorder\(([^,]+),([-+]?\d+),([-+]?\d+)\)>([\r\f]*\n)/$1.&MacroBlogIncludeOrder($2,$3,$4).$5/geim;

    return $txt;
}

sub MacroBlogIncludeOrder {
    use strict;
    my ($tocpage, $start, $end) = @_;

    # 라이브러리 읽음
    my ($MacrosDir, $MyMacrosDir) = ("./macros/", "./mymacros/");
    if (-f "$MyMacrosDir/blog_library.pl") {
        require "./$MyMacrosDir/blog_library.pl";
    } elsif (-f "$MacrosDir/blog_library.pl") {
        require "./$MacrosDir/blog_library.pl";
    } else {
        return "<font color='red'>blog_library.pl not found</font>";
    }

    # 목차페이지로부터 목차리스트를 얻어냄
    my ($status, $toc_mainpage, @tocitem_List) = &BlogReadToc($tocpage);
    if (!$status) {
        return "$toc_mainpage";
    }

    # 조건에 맞는 리스트를 구성
    ($status, @tocitem_List) = &BlogGetListOrder($start, $end, @tocitem_List);
    if (!$status) {
        return "@tocitem_List";
    }

    # 리스트의 각 페이지를 읽어서 include함
    my $txt;
    my ($page, $date);
    foreach my $item (@tocitem_List) {
        if ($item =~ /^(.+)$FS1(.*)$FS1(.+)$/) {
            ($page, $date) = ($1, $3);
        }
        $page =~ s|^/|$toc_mainpage/|;
        $page = &FreeToNormal($page);
        $txt .= &MacroInclude($page);
    }

    return $txt;
}

1;

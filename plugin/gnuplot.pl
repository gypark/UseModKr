# usage :
# {{{#!gnuplot
# plot sin(x)
# }}}
#
# {{{#!gnuplot
# plot "data1.dat"
# ##FILE:data1.dat
# 1    2
# 2    3
# 3    3.5
# }}}

use strict;
use warnings;

sub plugin_gnuplot {
    my ($content, @opt) = @_;
    my $plt = $content;
    my $log = '';

    my $gnuplot = "gnuplot";        # PATH of gnuplot;

# 그림 파일의 이름 결정
    require Digest::MD5;
    my $hash = Digest::MD5::md5_hex($content);

    my $hashimage = "$hash.png";
    my $GnuplotDir = "$UploadDir/gnuplot";
    my $GnuplotUrl = "$UploadUrl/gnuplot";

    my $imgpath = "<img src='$GnuplotUrl/$hashimage' alt='gnuplot'>";
    if (-f "$GnuplotDir/$hashimage") {
        # 이미 생성되어 캐쉬에 있음
        return $imgpath;
    }

    &CreateDir($UploadDir);
    &CreateDir($GnuplotDir);

    my $hashdir = "$TempDir/$hash";
    if (not -d $hashdir) {
        mkdir($hashdir, 0775) or return "[Unable to create $hash dir]";
    }

    my $pwd = `pwd`;
    $pwd =~ s/(.*)(\n|\r)*/$1/;

# 입력 텍스트 중 파일을 분리하여 저장
    my @blocks = split(/\n##FILE:/, $content);
    $plt = shift @blocks;
    
    foreach my $block (@blocks) {
        if ($block =~ /^(\S+)\n((.|\n)*)$/) {
            my ($filename, $filetext) = ($1, $2);
            &WriteStringToFile("$hashdir/$filename", $filetext);
        }
    }

# for security (code from MoniWiki)
    $plt = "\n".$plt."\n";
    $plt =~ s/^\s*![^\n]+$//gim;    # strip shell commands
    $plt =~ s/[ ]+/ /gi;
    $plt =~ s/^\s*set?\s+(t|o).*$//gim;

    my $input = << "EOT";
set size 0.5,0.6
set term png
set out '$hashimage'
$plt
EOT

    &WriteStringToFile("$hashdir/gnuplot.dat", $input);

    chdir ($hashdir);
    
    open SAVEOUT, ">&STDOUT";
    open SAVEERR, ">&STDERR";
    open STDOUT, ">hash.log";
    open STDERR, ">&STDOUT";

# 그림 생성
    qx($gnuplot gnuplot.dat);

    close STDOUT;
    close STDERR;
    open STDOUT, ">&SAVEOUT";
    open STDERR, ">&SAVEERR";

# 그림 옮김
    chdir($pwd);
    if (-f "$hashdir/$hashimage" && not -z "$hashdir/$hashimage") {
        my $png = &ReadFile("$hashdir/$hashimage");
        &WriteStringToFile("$GnuplotDir/$hashimage", $png);
    } else {
        $log = &ReadFile("$hashdir/hash.log");
        $log = "[Error retrieving image from hashdir]\n$log";

    }
    unlink (glob("$hashdir/*")) or return "[unlink fail]";
    rmdir ($hashdir) or return "[rmdir fail]";

    if ($log ne '') {
        return "<pre>\n$log\n</pre>";
    }
    return $imgpath;
}

1;


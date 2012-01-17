use strict;

my $MyFootnoteCounter;
my @MyFootnotes;
my %SaveNumFootnote;

sub footnote {
    my ($txt) = @_;

    $MyFootnoteCounter = 0;
    $txt =~ s/(&__LT__;footnote\(([^\n]+?)\)&__GT__;)/&MacroFootnote($2)/gei;

    # 본문 하단에 각주 출력
    if ($MyFootnoteCounter > 0) {
        map { s/_MARK_// } @MyFootnotes;
        $txt .= "<DIV class='footnote'>".
            "\n" . T('Footnote') . ": <br>\n".
            join('', @MyFootnotes). "</DIV>";
    }

    return $txt;
}

sub MacroFootnote {
    my ($note) = @_;

    $MyFootnoteCounter++;
    my $number = "<A name='FN_$MyFootnoteCounter' href='#FNR_$MyFootnoteCounter'>$MyFootnoteCounter</A>.";

    # URL이 있을 경우 동일한 내용이란 걸 파악하기 위해서, Restore를 해 줘야 함
    my $note_restored = &RestoreSavedText($note);   # 내용 비교는 이 변수를 사용

    if (defined $SaveNumFootnote{$note_restored}) {
        # 동일한 내용의 각주가 이미 있다면 그 각주에다가 새 번호 삽입
        $MyFootnotes[$SaveNumFootnote{$note_restored}] =~ s/_MARK_/$number _MARK_/;
    } else {
        # 새로운 내용의 각주 추가
        push @MyFootnotes,
             $number.
            " _MARK_$note".
            "<br>\n";
        $SaveNumFootnote{$note_restored} = $#MyFootnotes;
    }
    return "<A class='footnote' name='FNR_$MyFootnoteCounter' href='#FN_$MyFootnoteCounter'>$MyFootnoteCounter</A>";
}

1;

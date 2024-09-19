#!/usr/bin/perl
# UseModWiki version 0.92K2 (2001-12-27)
# Copyright (C) 2000-2001 Clifford A. Adams
#    <caadams@frontiernet.net> or <usemod@usemod.com>
# Based on the GPLed AtisWiki 0.3  (C) 1998 Markus Denker
#    <marcus@ira.uka.de>
# ...which was based on
#    the LGPLed CVWiki CVS-patches (C) 1997 Peter Merel
#    and The Original WikiWikiWeb  (C) Ward Cunningham
#        <ward@c2.com> (code reused with permission)
# Email and ThinLine options by Jim Mahoney <mahoney@marlboro.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA
package UseModWiki;
use strict;
BEGIN { unshift @INC, ( "." ); }

use Encode;
use vars qw($ConfigFile $WikiVersion $WikiRelease $HashKey);
### 환경설정 파일의 경로
$ConfigFile  = "./config.pl";             # path of config file

$WikiVersion = "0.92K3-ext2.40b";
$WikiRelease = "2024-08-30";
$HashKey = "salt"; # 2-character string

local $| = 1;  # Do not buffer output (localized for mod_perl)

# Configuration/constant variables:
use vars qw(@RcDays @HtmlPairs @HtmlSingle
    $TempDir $LockDir $DataDir $HtmlDir $UserDir $KeepDir $PageDir
    $InterFile $RcFile $RcOldFile $IndexFile $FullUrl $SiteName $HomePage
    $LogoUrl $RcDefault $IndentLimit $RecentTop $EditAllowed $UseDiff
    $UseSubpage $UseCache $RawHtml $LogoLeft
    $KeepDays $HtmlTags $HtmlLinks $UseDiffLog $KeepMajor $KeepAuthor
    $FreeUpper $EmailNotify $SendMail $EmailFrom $FastGlob $EmbedWiki
    $ScriptTZ $BracketText $UseAmPm $UseIndex $UseLookup
    $RedirType $AdminPass $EditPass $NetworkFile $BracketWiki
    $FreeLinks $WikiLinks $AdminDelete $FreeLinkPattern $RCName $RunCGI
    $ShowEdits $LinkPattern $InterLinkPattern $InterSitePattern
    $UrlProtocols $UrlPattern $ImageExtensions $RFCPattern $ISBNPattern
    $FS $FS1 $FS2 $FS3 $CookieName $SiteBase $StyleSheetUrl $NotFoundPg
    $FooterNote $EditNote $MaxPost $NewText $NotifyDefault $HttpCharset);

### 패치를 위해 추가된 환경설정 변수
use vars qw(
    $UserGotoBar $UserGotoBar2 $UserGotoBar3 $UserGotoBar4
    $SOURCEHIGHLIGHT @SRCHIGHLANG $EditNameLink
    $LogoPage $CheckTime $LinkDir $IconUrl $CountDir $UploadDir $UploadUrl
    $HiddenPageFile $TemplatePage
    $InterWikiMoniker $SiteDescription $RssLogoUrl $RssDays $RssTimeZone
    $SlashLinks $InterIconUrl $JavaScriptUrl
    $UseLatex $UserHeader $OekakiJarUrl @UrlEncodingGuess $UrlPrefix
    $TwitterID $TwitterPass $TwitterPrefix
    $TwitterConsumerKey $TwitterConsumerSecret $TwitterAccessToken $TwitterAccessTokenSecret
    );

use vars qw($DocID $ImageTag $ClickEdit $UseEmoticon $EmoticonUrl $EditPagePos);        # luke
use vars qw($TableOfContents @HeadingNumbers $NamedAnchors $AnchoredLinkPattern);
use vars qw($TableTag $TableMode);

# Note: $NotifyDefault is kept because it was a config variable in 0.90
# Other global variables:
use vars qw(%Page %Section %Text %InterSite %SaveUrl %SaveNumUrl
    %KeptRevisions %UserCookie %SetCookie %UserData %IndexHash %Translate
    %LinkIndex $InterSiteInit $SaveUrlIndex $SaveNumUrlIndex $MainPage
    $OpenPageName @KeptList @IndexList $IndexInit
    $q $Now $UserID $TimeZoneOffset $ScriptName );

### 패치를 위해 추가된 내부 전역 변수
use vars qw(%RevisionTs $FS_lt $FS_gt $StartTime $Sec_Revision $Sec_Ts
    $ViewCount $AnchoredFreeLinkPattern %UserInterest %HiddenPage
    $pageid $IsPDA $QuotedFullUrl %MacroFile $UseShortcut
    $UseShortcutPage $SectionNumber $AnchorPattern $GotoTextFieldId);

umask 0;

# <toc>용 목차
$TableOfContents = "";
# 단축키
$UseShortcut = 1;
$UseShortcutPage = 1;

# The "main" program, called at the end of this script file.
sub DoWikiRequest {

### 처리 시간 측정
if ($CheckTime) {
    if ( eval { require Time::HiRes } ) {
        Time::HiRes->import( qw/ gettimeofday tv_interval / );
        $StartTime = [gettimeofday()];
    }
    else {
        $CheckTime = 0;
    }
}

### oekaki
    if (($ENV{'QUERY_STRING'} eq "action=oekaki&mode=save") ||
            ($ENV{'PATH_INFO'} eq "/action=oekaki&mode=save")) {
        &OekakiSave();
        return;
    }

### QUERY_STRING이 %-인코딩된 형태로 오는 경우
### guess를 해도 ascii로 판정되기 때문에 변환이 안 된다.
### 이 시점에서 디코딩하여 복원함
### 쿼리에 엠퍼센드 등이 인코딩되어 있는 경우에 문제가 됨 - 일단 보류
#   $ENV{'QUERY_STRING'} =~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge;

### slashlinks 처리
    if ($SlashLinks && (length($ENV{'PATH_INFO'}) > 1)) {
        $ENV{'QUERY_STRING'} .= '&' if ($ENV{'QUERY_STRING'});
        $ENV{'QUERY_STRING'} .= substr($ENV{'PATH_INFO'}, 1);
    }

### QUERY_STRING 또는 PATH_INFO가 utf-8이 아닌 인코딩인 경우
    $ENV{'QUERY_STRING'} = guess_and_convert($ENV{'QUERY_STRING'});

    &InitLinkPatterns();
    if (!&DoCacheBrowse()) {
        &InitRequest() or return;
        if (!&DoBrowseRequest()) {
            &DoOtherRequest();
        }
    }
}

# == Common and cache-browsing code ====================================
sub InitLinkPatterns {
    my ($UpperLetter, $LowerLetter, $AnyLetter, $LpA, $LpB, $QDelim);

    # Field separators are used in the URL-style patterns below.
#  $FS  = "\xb3";      # The FS character is a superscript "3"
    $FS  = "\x1e";      # by gypark. from oddmuse
    $FS1 = $FS . "1";   # The FS values are used to separate fields
    $FS2 = $FS . "2";   # in stored hashtables and other data structures.
    $FS3 = $FS . "3";   # The FS character is not allowed in user data.
### added by gypark
    $FS_lt = $FS . "lt";
    $FS_gt = $FS . "gt";

    $UpperLetter = "[A-Z";
    $LowerLetter = "[a-z";
    $AnyLetter   = "[A-Za-z";
### 라틴 문자 지원
#   $UpperLetter .= "\xc0-\xde";
#   $LowerLetter .= "\xdf-\xff";
#   $AnyLetter   .= "\x80-\xff";
    $AnyLetter   .= "_0-9";
    $UpperLetter .= "]"; $LowerLetter .= "]"; $AnyLetter .= "]";
#   $AnyLetter   = "(?:[A-Za-z_0-9]|(?:[\xc2-\xdf][\x80-\xbf]))";

    # Main link pattern: lowercase between uppercase, then anything
    $LpA = $UpperLetter . "+" . $LowerLetter . "+" . $UpperLetter
                 . $AnyLetter . "*";
    # Optional subpage link pattern: uppercase, lowercase, then anything
    $LpB = $UpperLetter . "+" . $LowerLetter . "+" . $AnyLetter . "*";

    if ($UseSubpage) {
        # Loose pattern: If subpage is used, subpage may be simple name
        $LinkPattern = "((?:(?:$LpA)?\\/$LpB)|$LpA)";
        # Strict pattern: both sides must be the main LinkPattern
        # $LinkPattern = "((?:(?:$LpA)?\\/)?$LpA)";
    } else {
        $LinkPattern = "($LpA)";
    }
    $QDelim = '(?:"")?';     # Optional quote delimiter (not in output)
    $LinkPattern .= $QDelim;

    # Inter-site convention: sites must start with uppercase letter
    # (Uppercase letter avoids confusion with URLs)
    $InterSitePattern = $UpperLetter . $AnyLetter . "+";
    $InterLinkPattern = "((?:$InterSitePattern:[^\\]\\s\"<>$FS]+)$QDelim)";

    # free link [[pagename]]
    if ($FreeLinks) {
        # Note: the - character must be first in $AnyLetter definition
        $AnyLetter = "[-,.()' _0-9A-Za-z\x80-\xff]";
    }
    if ($UseSubpage) {
        $FreeLinkPattern = "((?:(?:$AnyLetter+)?\\/)?$AnyLetter+)";
    } else {
        $FreeLinkPattern = "($AnyLetter+)";
    }
    $FreeLinkPattern .= $QDelim;

    # anchored link
    $AnchorPattern = '#([0-9A-Za-z\x80-\xff]+)';
    $AnchoredLinkPattern = $LinkPattern . $AnchorPattern . $QDelim if $NamedAnchors;
    $AnchoredFreeLinkPattern = $FreeLinkPattern . $AnchorPattern . $QDelim if $NamedAnchors;

    # Url-style links are delimited by one of:
    #   1.  Whitespace                           (kept in output)
    #   2.  Left or right angle-bracket (< or >) (kept in output)
    #   3.  Right square-bracket (])             (kept in output)
    #   4.  A single double-quote (")            (kept in output)
    #   5.  A $FS (field separator) character    (kept in output)
    #   6.  A double double-quote ("")           (removed from output)
    $UrlProtocols = 'http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|mms|mmst|prospero|telnet|gopher|irc';
    $UrlProtocols .= '|file' if $NetworkFile;
    $UrlPattern = "((?:(?:$UrlProtocols):[^\\]\\s\"<>$FS]+)$QDelim)";
    $ImageExtensions = "(gif|jpg|png|bmp|jpeg|GIF|JPG|PNG|BMP|JPEG)";
    $RFCPattern = "RFC\\s?(\\d+)";
    $ISBNPattern = "ISBN:?([0-9-xX]{10,})";
}

# Simple HTML cache
sub DoCacheBrowse {
    my ($query, $idFile, $text);

    return 0  if (!$UseCache);
    $query = $ENV{'QUERY_STRING'};
    if (($query eq "") && ($ENV{'REQUEST_METHOD'} eq "GET")) {
### LogoPage 가 있으면 이것을 embed 형식으로 출력
        if ($LogoPage eq "") {
            $query = $HomePage;  # Allow caching of home page.
        } else {
            $query = $LogoPage;
        }
    }

### LogoPage 가 있으면 이것을 embed 형식으로 출력
    return 0 if ($query eq $LogoPage);

    if (!($query =~ /^$LinkPattern$/)) {
        if (!($FreeLinks && ($query =~ /^$FreeLinkPattern$/))) {
            return 0;  # Only use cache for simple links
        }
    }
    $idFile = &GetHtmlCacheFile($query);
    if (-f $idFile) {
        local $/ = undef;   # Read complete files
        open my $in, '<', $idFile or return 0;
        $text = <$in>;
        close $in;
        print $text;
        return 1;
    }
    return 0;
}

sub GetHtmlCacheFile {
    my ($id) = @_;

    return $HtmlDir . "/" . &GetPageDirectory($id) . "/$id.htm";
}

sub GetPageDirectory {
    my ($id) = @_;

    if ($id =~ /^([a-zA-Z])/) {
        return uc($1);
    }
    return "other";
}

sub T {
    my ($text) = @_;

    if (1) {   # Later make translation optional?
        if (defined($Translate{$text}) && ($Translate{$text} ne ''))  {
            return $Translate{$text};
        }
    }
    return $text;
}

sub Ts {
    my ($text, $string) = @_;

    $text = T($text);
    $text =~ s/\%s/$string/;
    return $text;
}

# == Normal page-browsing and RecentChanges code =======================
use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub InitRequest {
    my @ScriptPath = split('/', "$ENV{SCRIPT_NAME}");

    $CGI::POST_MAX = $MaxPost;
### file upload
#   $CGI::DISABLE_UPLOADS = 1;  # no uploads
    $CGI::DISABLE_UPLOADS = 0;

### slashlinks 처리
#   if ($SlashLinks && (length($ENV{'PATH_INFO'}) > 1)) {
#       $ENV{'QUERY_STRING'} .= '&' if ($ENV{'QUERY_STRING'});
#       $ENV{'QUERY_STRING'} .= substr($ENV{'PATH_INFO'}, 1);
#   }
# slahslink 관련 패치이나, POST 에서 에러가 난다 - 일단 보류
#   if   ($ENV{'REQUEST_METHOD'} eq 'GET') {
#       $q = new CGI($ENV{'QUERY_STRING'});
#   } elsif($ENV{'REQUEST_METHOD'} eq 'POST') {
#       read (STDIN, $q, $ENV{'CONTENT_LENGTH'});
#       $q = new CGI($q);
#   }
    $q = new CGI;
#####
    $q->autoEscape(undef);

### file upload
    my $cgi_error = $q->cgi_error();
    if (defined $cgi_error and $cgi_error =~ m/^413/) {
        print $q->redirect(-url=>"http:$ENV{SCRIPT_NAME}".&ScriptLinkChar()."action=upload&error=3");
        exit 1;
    }
    $UploadUrl = "http:$UploadDir" if ($UploadUrl eq "");

    $Now = time;                     # Reset in case script is persistent
    $ScriptName = pop(@ScriptPath);  # Name used in links
### slashlinks 처리
    if ($SlashLinks) {
        my $numberOfSlashes = ($ENV{'PATH_INFO'} =~ tr[/][/]);
        $ScriptName = ('../' x $numberOfSlashes) . $ScriptName;
    }
    $ScriptName = $FullUrl if ($FullUrl ne '');
#####
    $IndexInit = 0;                  # Must be reset for each request
    $InterSiteInit = 0;
    %InterSite = ();
    $MainPage = ".";       # For subpages only, the name of the top-level page
    $OpenPageName = "";    # Currently open page
    &CreateDir($DataDir);  # Create directory if it doesn't exist
    if (!-d $DataDir) {
        &ReportError(Ts('Could not create %s', $DataDir) . ": $!");
        return 0;
    }
    &InitCookie();         # Reads in user data

### hide page
    my ($status, $data) = &ReadFile($HiddenPageFile);
    if ($status) {
        %HiddenPage = split(/$FS1/, $data, -1);
    }

    return 1;
}

sub InitCookie {
    %SetCookie = ();
    $TimeZoneOffset = 0;
    undef $q->{'.cookies'};  # Clear cache if it exists (for SpeedyCGI)
    %UserCookie = $q->cookie($CookieName);
    $UserCookie{'userid'} = DecodeUrl($UserCookie{'userid'});
    $UserID = $UserCookie{'userid'};
    &LoadUserData($UserID);
    if (($UserData{'userid'} ne $UserCookie{'userid'})      ||
            ($UserData{'randkey'} ne $UserCookie{'randkey'})) {
        $UserID = 113;
        %UserData = ();   # Invalid.  Later consider warning message.
        # 사용자 데이터와 쿠키가 일치하지 않을 때 쿠키도 날려버리자.
        $SetCookie{'userid'} = '';
        $SetCookie{'expire'} = 0;
        $SetCookie{'randkey'} = '';
    }
    if ($UserData{'tzoffset'} != 0) {
        $TimeZoneOffset = $UserData{'tzoffset'} * (60 * 60);
    }
}

sub DoBrowseRequest {
    my ($id, $action, $text);

    if (!$q->param) {             # No parameter

### LogoPage 가 있으면 이것을 embed 형식으로 출력
#       &BrowsePage($HomePage);
        if ($LogoPage eq "") {
            &BrowsePage($HomePage);
        } else {
            $EmbedWiki = 1;
            &BrowsePage($LogoPage);
        }

        return 1;
    }
    $id = &GetParam('keywords', '');

### pda clip by gypark
    $IsPDA = &GetParam("pda", "");
    $EmbedWiki = 1 if ($IsPDA);

    if ($id) {                    # Just script?PageName
### QUERY_STRING 이 utf-8이 아닌 인코딩인 경우
        $id = guess_and_convert($id);

        if ($FreeLinks && (!-f &GetPageFile($id))) {
            $id = &FreeToNormal($id);
        }
        if (($NotFoundPg ne '') && (!-f &GetPageFile($id))) {
            $id = $NotFoundPg;
        }
        $DocID = $id;
        &BrowsePage($id)  if &ValidIdOrDie($id);
        return 1;
    }
    $action = lc(&GetParam('action', ''));
    $id = &GetParam('id', '');

### QUERY_STRING 이 utf-8이 아닌 인코딩인 경우
    $id = guess_and_convert($id);
    $q->param('id', $id);

    $DocID = $id;
    if ($action eq 'browse') {
        if ($FreeLinks && (!-f &GetPageFile($id))) {
            $id = &FreeToNormal($id);
        }
        if (($NotFoundPg ne '') && (!-f &GetPageFile($id))) {
            $id = $NotFoundPg;
        }

### id 가 NULL 일 경우 홈으로 이동
        if ($id eq '') {
            $id = $HomePage;
        }

        &BrowsePage($id)  if &ValidIdOrDie($id);
        return 1;
    } elsif ($action eq 'rc') {

### pda clip by gypark
#       &BrowsePage(T($RCName));
        if ($IsPDA) {
            my $temp_id = T("$RCName");
            print &GetHeader($temp_id, &QuoteHtml($temp_id), "");
            &DoRc(1);
            print $q->end_html;
        } else {
            &BrowsePage(T($RCName));
        }

        return 1;
    } elsif ($action eq 'random') {
        &DoRandom();
        return 1;
    } elsif ($action eq 'history') {
        $ClickEdit = 0;                             # luke added
        &DoHistory($id)   if &ValidIdOrDie($id);
        return 1;
    }
    return 0;  # Request not handled
}

sub BrowsePage {
    my ($id) = @_;
    my ($fullHtml, $oldId, $allDiff, $showDiff, $openKept);
    my ($revision, $goodRevision, $diffRevision, $newText);

### comments from Jof
    $pageid = $id;

### hide page
    if (&PageIsHidden($id)) {
        print &GetHeader($id, &QuoteHtml($id), $oldId);
        print Ts('%s is a hidden page', $id);
        print &GetCommonFooter();
        return;
    }

    &OpenPage($id);
    &OpenDefaultText();
### page count
    $ViewCount = &GetPageCount($id) if (-f &GetPageFile($id));

    $openKept = 0;
    $revision = &GetParam('revision', '');
    $revision =~ s/\D//g;           # Remove non-numeric chars
    $goodRevision = $revision;      # Non-blank only if exists
    if ($revision ne '') {
        &OpenKeptRevisions('text_default');
        $openKept = 1;
        if (!defined($KeptRevisions{$revision})) {
            $goodRevision = '';
        } else {
            &OpenKeptRevision($revision);
        }
    }

### 매크로가 들어간 페이지의 편집가이드 문제 해결
    $Sec_Revision = $Section{'revision'};
    $Sec_Ts = $Section{'ts'};

    $newText = $Text{'text'};     # For differences
    # Handle a single-level redirect
    $oldId = &GetParam('oldid', '');
    if (($oldId eq '') && (substr($Text{'text'}, 0, 10) eq '#REDIRECT ')) {
        $oldId = $id;
        if (($FreeLinks) && ($Text{'text'} =~ /\#REDIRECT\s+\[\[.+\]\]/)) {
            ($id) = ($Text{'text'} =~ /\#REDIRECT\s+\[\[(.+)\]\]/);
            $id = &FreeToNormal($id);
        } else {
            ($id) = ($Text{'text'} =~ /\#REDIRECT\s+(\S+)/);
        }
        if (&ValidId($id) eq '') {
            # Later consider revision in rebrowse?
            &ReBrowsePage($id, $oldId, 0);
            return;
        } else {  # Not a valid target, so continue as normal page
            $id = $oldId;
            $oldId = '';
        }
    }

    $MainPage = $id;
    $MainPage =~ s|/.*||;  # Only the main page name (remove subpage)
    $fullHtml = &GetHeader($id, &QuoteHtml($id), $oldId);

    if ($revision ne '') {
        # Later maybe add edit time?
        if ($goodRevision ne '') {
            $fullHtml .= '<b>' . Ts('Showing revision %s', $revision) . "</b><br>";
        } else {
            $fullHtml .= '<b>' . Ts('Revision %s not available', $revision)
                                     . ' (' . T('showing current revision instead')
                                     . ')</b><br>';
        }
    }
    $allDiff  = &GetParam('alldiff', 0);
    if ($allDiff != 0) {
        $allDiff = &GetParam('defaultdiff', 1);
    }
    if ((($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName))
            && &GetParam('norcdiff', 1)) {
        $allDiff = 0;  # Only show if specifically requested
    }
    $showDiff = &GetParam('diff', $allDiff);
    if ($UseDiff && $showDiff) {
        $diffRevision = $goodRevision;
        $diffRevision = &GetParam('diffrevision', $diffRevision);
        # Later try to avoid the following keep-loading if possible?
        &OpenKeptRevisions('text_default')  if (!$openKept);

### 최근변경내역에 북마크 기능 도입
        if ($showDiff == 5) {
            if (&LoginUser()) {
                $diffRevision = $Page{'revision'} - 1;
                my $userBookmark = &GetParam('bookmark',-1);
                while (($diffRevision > 1) &&
                    (defined($RevisionTs{$diffRevision})) &&
                    ($RevisionTs{$diffRevision} > $userBookmark)) {
                    $diffRevision--;
                }
            }
            $showDiff = &GetParam("defaultdiff", 1);
        }

        $fullHtml .= &GetDiffHTML($showDiff, $id, $diffRevision, "$revision", $newText);
        $fullHtml .= "<hr>\n";
    }

    if ($EditPagePos >= 2) {
        $fullHtml .= &GetEditGuide($id, $goodRevision);     # luke added
    }

    $fullHtml .= &WikiToHTML($Text{'text'});
    # $fullHtml .= "<hr  noshade size=1>\n"  if (!&GetParam('embed', $EmbedWiki));
    if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)) {

        if (&GetParam("sincelastvisit", 0)) {
            my $cookie1 = $q->cookie(
                -name   => $CookieName . "-RC",
                -value  => time(),
                -expires => '+60d');
            print "Set-Cookie: $cookie1\r\n";
        }

        print $fullHtml;
        &DoRc(1);
#       print "<HR class='footer'>\n"  if (!&GetParam('embed', $EmbedWiki));
        print &GetFooterText($id, $goodRevision);
        return;
    }
    $fullHtml .= &GetFooterText($id, $goodRevision);
    print $fullHtml;
    return  if ($showDiff || ($revision ne ''));  # Don't cache special version

### redirect 로 옮겨가는 경우에는 cache 생성을 하지 않게 함
#   &UpdateHtmlCache($id, $fullHtml)  if $UseCache;
    &UpdateHtmlCache($id, $fullHtml)  if ($UseCache && ($oldId eq ''));
###
}

sub ReBrowsePage {
    my ($id, $oldId, $isEdit) = @_;
    $id = &EncodeUrl($id);
    $oldId = &EncodeUrl($oldId);


    if ($oldId ne "") {   # Target of #REDIRECT (loop breaking)
        print &GetRedirectPage("action=browse&id=$id&oldid=$oldId",
                                                     $id, $isEdit);
    } else {
        print &GetRedirectPage($id, $id, $isEdit);
    }
}

sub DoRc {
### rss from usemod1.0
    my ($rcType) = @_;
    my $showHTML;

    my ($fileData, $rcline, $daysago, $lastTs, $ts, $idOnly);
    my (@fullrc, $status, $oldFileData, $firstTs, $errorText);
    my $starttime = 0;
    my $showbar = 0;

### rss from usemod1.0
    if (0 == $rcType) {
        $showHTML = 0;
    } else {
        $showHTML = 1;
    }

### pda clip by gypark
    if ($IsPDA) {
        $daysago = &GetParam("days", 0);
        $daysago = 7 if ($daysago == 0);
        $starttime = $Now - ((24*60*60)*$daysago);
        print "<h2>$SiteName : " .
            Ts('Updates in the last %s day' . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
    } else {

        if (&GetParam("sincelastvisit", 0)) {
            $starttime = $q->cookie($CookieName ."-RC");
        } elsif (&GetParam("from", 0)) {
            $starttime = &GetParam("from", 0);

### rss from usemod1.0
#       print "<h2>" . Ts('Updates since %s', &TimeToText($starttime))
#                   . "</h2>\n";
            if ($showHTML) {
                print "<h2>" . Ts('Updates since %s', &TimeToText($starttime))
                            . "</h2>\n";
            }
###
        } else {
            $daysago = &GetParam("days", 0);
            $daysago = &GetParam("rcdays", 0)  if ($daysago == 0);
            if ($daysago) {
                $starttime = $Now - ((24*60*60)*$daysago);

### rss from usemod1.0
#           print "<h2>" . Ts('Updates in the last %s day'
#                        . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
                if ($showHTML) {
                    print "<h2>" . Ts('Updates in the last %s day'
                                 . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
                }
###
                # Note: must have two translations (for "day" and "days")
                # Following comment line is for translation helper script
                # Ts('Updates in the last %s days', '');
            }
        }
        if ($starttime == 0) {
### rss from usemod1.0
#       $starttime = $Now - ((24*60*60)*$RcDefault);
#       print "<h2>" . Ts('Updates in the last %s day'
#           . (($RcDefault != 1)?"s":""), $RcDefault) . "</h2>\n";
            if (0 == $rcType) {
                $starttime = $Now - ((24*60*60)*$RssDays);
            } else {
                $starttime = $Now - ((24*60*60)*$RcDefault);
            }
            if ($showHTML) {
                print "<h2>" . Ts('Updates in the last %s day'
                    . (($RcDefault != 1)?"s":""), $RcDefault) . "</h2>\n";
            }
###
            # Translation of above line is identical to previous version
        }
    }

    # Read rclog data (and oldrclog data if needed)
    ($status, $fileData) = &ReadFile($RcFile);
    $errorText = "";
    if (!$status) {
        # Save error text if needed.
        $errorText = '<p><strong>' . Ts('Could not open %s log file', $RCName)
                                 . ":</strong> $RcFile<p>"
                                 . T('Error was') . ":\n<pre>$!</pre>\n" . '<p>'
        . T('Note: This error is normal if no changes have been made.') . "\n";
    }
    @fullrc = split(/\n/, $fileData);
    $firstTs = 0;
    if (@fullrc > 0) {  # Only false if no lines in file
        ($firstTs) = split(/$FS3/, $fullrc[0]);
    }
    if (($firstTs == 0) || ($starttime <= $firstTs)) {
        ($status, $oldFileData) = &ReadFile($RcOldFile);
        if ($status) {
            @fullrc = split(/\n/, $oldFileData . $fileData);
        } else {
            if ($errorText ne "") {  # could not open either rclog file
                print $errorText;
                print "<p><strong>"
                            . Ts('Could not open old %s log file', $RCName)
                            . ":</strong> $RcOldFile<p>"
                            . T('Error was') . ":\n<pre>$!</pre>\n";
                return;
            }
        }
    }
    $lastTs = 0;

### hide page
    for (my $i = $#fullrc; $i >= 0; $i--) {
        my ($ts, $page) = split(/$FS3/, $fullrc[$i]);
        $lastTs = $ts, last if not PageIsHidden($page);
    }
    $lastTs++  if (($Now - $lastTs) > 5);  # Skip last unless very recent

    $idOnly = &GetParam("rcidonly", "");
### rss from usemod1.0
    if ($idOnly && $showHTML) {
###
        print '<b>(' . Ts('for %s only', &ScriptLink($idOnly, $idOnly))
                    . ')</b><br>';
    }
### pda clip by gypark
    if (!($IsPDA)) {
### rss from usemod1.0
        if ($showHTML) {
            foreach my $i (@RcDays) {
                print " | "  if $showbar;
                $showbar = 1;
                print &ScriptLink("action=rc&days=$i",
                    Ts('%s day' . (($i != 1)?'s':''), $i));
                    # Note: must have two translations (for "day" and "days")
                    # Following comment line is for translation helper script
                    # Ts('%s days', '');
            }

### 최근변경내역에 북마크 기능 도입
            if (!&LoginUser()) {
                print "<br>" . &ScriptLink("action=rc&from=$lastTs",
                    T('List new changes starting from'));
                print " " . &TimeToText($lastTs) . "<br>\n";
            } else {
                my $bookmark = &GetParam('bookmark',-1);
                print "<br>" . &ScriptLink("action=bookmark&time=$Now",
                        T('Update my bookmark timestamp')." [m]");
                print " (".
                    Ts('currently set to %s', &TimeToText($bookmark)).
                    ")<br>\n";
            }
        }
    }

    # Later consider a binary search?
    my $i = 0;
    while ($i < @fullrc) {  # Optimization: skip old entries quickly
        ($ts) = split(/$FS3/, $fullrc[$i]);
        if ($ts >= $starttime) {
            $i -= 1000  if ($i > 0);
            last;
        }
        $i += 1000;
    }
    $i -= 1000  if (($i > 0) && ($i >= @fullrc));
    for (; $i < @fullrc ; $i++) {
        ($ts) = split(/$FS3/, $fullrc[$i]);
        last if ($ts >= $starttime);
    }
### rss from usemod1.0
    if ($i == @fullrc && $showHTML) {
        print '<br><strong>' . Ts('No updates since %s',
                    &TimeToText($starttime)) . "</strong><br>\n";
    } else {
        splice(@fullrc, 0, $i);  # Remove items before index $i
        # Later consider an end-time limit (items older than X)
### rss from usemod1.0
        if (0 == $rcType) {
            print &GetRcRss(@fullrc);
        } else {
            print &GetRcHtml(@fullrc);
        }
    }
    if ($showHTML) {
        print '<p>' . Ts('Page generated %s', &TimeToText($Now)), "<br>\n";
    }
}

sub GetRcHtml {
    my @outrc = @_;
    my ($html, $date, $sum, $edit, $count, $newtop, $author);
    my ($showedit, $inlist, $link, $all, $idOnly);
### RcOldFile 버그 수정
#   my ($ts, $oldts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);
    my ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);

    my ($tEdit, $tChanges, $tDiff);
    my %extra = ();
    my %changetime = ();
    my %pagecount = ();

    $tEdit    = T('(edit)');    # Optimize translations out of main loop
    $tDiff    = T('(diff)');
    $tChanges = T('changes');
    $showedit = &GetParam("rcshowedit", $ShowEdits);
    $showedit = &GetParam("showedit", $showedit);

### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
    my $num_items = &GetParam("items", 0);
    my $num_printed = 0;
### 최근변경내역에 북마크 기능 도입
    my $bookmark;
    my $bookmarkuser = &GetParam('username', "");
    my ($rcnew, $rcupdated, $rcdiff, $rcdeleted, $rcinterest) = (
            "<img style='border:0' src='$IconUrl/rc-new.gif'>",
            "<img style='border:0' src='$IconUrl/rc-updated.gif'>",
            "<img style='border:0' src='$IconUrl/rc-diff.gif'>",
            "<img style='border:0' src='$IconUrl/rc-deleted.gif'>",
### 관심 페이지
            "<img style='border:0' src='$IconUrl/rc-interest.gif' alt='".T('Interesting Page')."'>",
    );
    $bookmark = &GetParam('bookmark',-1);

    if ($showedit != 1) {
        my @temprc = ();
        foreach my $rcline (@outrc) {
            ($ts, $pagename, $summary, $isEdit, $host) = split(/$FS3/, $rcline);
            if ($showedit == 0) {  # 0 = No edits
                push(@temprc, $rcline)  if (!$isEdit);
            } else {               # 2 = Only edits
                push(@temprc, $rcline)  if ($isEdit);
            }
        }
        @outrc = @temprc;
    }

### summary 개선 by gypark
    my %all_summary;

    $all = &GetParam("rcall", 0);
    $all = &GetParam("all", $all);
    $newtop = &GetParam("rcnewtop", $RecentTop);
    $newtop = &GetParam("newtop", $newtop);
    $idOnly = &GetParam("rcidonly", "");
####

    # Later consider folding into loop above?
    # Later add lines to assoc. pagename array (for new RC display)
    foreach my $rcline (@outrc) {
### summary 개선 by gypark
#       ($ts, $pagename) = split(/$FS3/, $rcline);
        ($ts, $pagename, $summary) = split(/$FS3/, $rcline);
####

### 최근변경내역에 북마크 기능 도입
#       $pagecount{$pagename}++;
### summary 개선 by gypark
#       $pagecount{$pagename}++ if ($ts > $bookmark);
        if ($ts > $bookmark) {
            $pagecount{$pagename}++;
            if (&LoginUser() && !($all)) {
                if (($summary ne "") && ($summary ne "*")) {
                    $summary = &QuoteHtml($summary);
                    $all_summary{$pagename} = "[$summary]<br>" . $all_summary{$pagename};
                }
            }
        }

        $changetime{$pagename} = $ts;
    }
    $date = "";
    $inlist = 0;
### 최근 변경 내역을 테이블로 출력
### pda clip 기능 추가
#   $html = "";
    if ($IsPDA) {
        $html = "";
    } else {
        $html = "<TABLE class='rc'>";
    }
###

### summary 개선 by gypark
#   $all = &GetParam("rcall", 0);
#   $all = &GetParam("all", $all);
#   $newtop = &GetParam("rcnewtop", $RecentTop);
#   $newtop = &GetParam("newtop", $newtop);
#   $idOnly = &GetParam("rcidonly", "");
####

    @outrc = reverse @outrc if ($newtop);
### commented by gypark
### RcOldFile 버그 수정
#   ($oldts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
#       = split(/$FS3/, $outrc[0]);
#   $oldts += 1;

    foreach my $rcline (@outrc) {
        ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
            = split(/$FS3/, $rcline);
        # Later: need to change $all for new-RC?
        next  if ((!$all) && ($ts < $changetime{$pagename}));
        next  if (($idOnly ne "") && ($idOnly ne $pagename));
### hide page
        next if (&PageIsHidden($pagename));
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
        $num_printed++;
        last if (($num_items > 0) && ($num_printed > $num_items));
### commented by gypark
### RcOldFile 버그 수정
#       next  if ($ts >= $oldts);
#       $oldts = $ts;

        # print $ts . " " . $pagename . "<br>\n";
        %extra = split(/$FS2/, $extraTemp, -1);
        if ($date ne &CalcDay($ts)) {
            $date = &CalcDay($ts);
            if ($inlist) {

### commented by gypark
### 최근 변경 내역을 테이블로 출력
### pda clip 기능 추가
#               $html .= "</UL>\n";
                $html .= "</UL>\n" if ($IsPDA);

                $inlist = 0;
            }
### 최근변경내역에 북마크 기능 도입
### 최근 변경 내역을 테이블로 출력 패치도 같이 적용
### pda clip 기능 추가
#           $html .= "<p><strong>" . $date . "</strong><p>\n";
            if ($IsPDA) {
                $html .= "<p><strong>" . $date . "</strong><p>\n";
            } else {
                $html .= "<TR class='rc'><TD colspan='6' class='rcblank'>&nbsp;</TD></TR>".
                    "<TR class='rc'>".
                    "<TD colspan=6 class='rcdate'><b>" . $date . "</b>";
                if ($bookmarkuser eq "") {
                    $html .= "</TD></TR>\n";
                } else {
                    $html .= "  [" .&ScriptLink("action=bookmark&time=$ts",T('set bookmark')) ."]"
                        . "</TD></TR>\n";
                }
            }
        }
        if (!$inlist) {
### commented by gypark
### 최근 변경 내역을 테이블로 출력
### pda clip 기능 추가
#           $html .= "<UL>\n";
            $html .= "<UL>\n" if ($IsPDA);

            $inlist = 1;
        }
        $host = &QuoteHtml($host);
        if (defined($extra{'name'}) && defined($extra{'id'})) {
### pda clip by gypark
#           $author = &GetAuthorLink($host, $extra{'name'}, $extra{'id'});
            if ($IsPDA) {
                $author = &GetPageLink($extra{'name'});
            } else {
                $author = &GetAuthorLink($host, $extra{'name'}, $extra{'id'});
            }
        } else {
            $author = &GetAuthorLink($host, "", 0);
        }
        $sum = "";
        if (($summary ne "") && ($summary ne "*")) {
            $summary = &QuoteHtml($summary);
### 최근 변경 내역을 테이블로 출력
#           $sum = "<strong>[$summary]</strong> ";
            $sum = "[$summary]";
###
        }
        $edit = "";
        $edit = "<em>$tEdit</em> "  if ($isEdit);
        $count = "";
        if ((!$all) && ($pagecount{$pagename} > 1)) {
            $count = "($pagecount{$pagename} ";
            if (&GetParam("rcchangehist", 1)) {
                $count .= &GetHistoryLink($pagename, $tChanges);
            } else {
                $count .= $tChanges;
            }
            $count .= ") ";
        }
        $link = "";
        if ($UseDiff && &GetParam("diffrclink", 1)) {
### 최근변경내역에 북마크 기능 도입
#           $link .= &ScriptLinkDiff(4, $pagename, $tDiff, "") . "  ";
            if (!(-f &GetPageFile($pagename))) {
                $link .= &GetHistoryLink($pagename, $rcdeleted);
            } elsif (($bookmarkuser eq "") || ($ts <= $bookmark)) {
                $link .= &ScriptLinkDiff(4, $pagename, $rcdiff, "") . "  ";
            } elsif ($extra{'tscreate'} > $bookmark) {
                $link .= $rcnew . "  ";
            } else {
                $link .= &ScriptLinkDiffRevision(5, $pagename, "", $rcupdated) . "  ";
            }
        }
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
### pda clip 기능 추가
#       $link .= &GetPageLink($pagename);
#       $html .= "<li>$link ";
#       # Later do new-RC looping here.
#       $html .=  &CalcTime($ts) . " $count$edit" . " $sum";
#       $html .= ". . . . . $author\n";  # Make dots optional?
#   }
#   $html .= "</UL>\n" if ($inlist);
        if (!($IsPDA)) {
            $html .= "<TR class='rc'>"
                . "<TD class='rc'>"
### 관심 페이지
                . ((defined ($UserInterest{$pagename}))?"$rcinterest":"&nbsp;&nbsp;")
                . "</TD>"
                . "<TD class='rc'>$link </TD>"
                . "<TD class='rcpage'>" . &GetPageOrEditLink($pagename) . "</TD>"
                . "<TD class='rctime'>" . &CalcTime($ts) . "</TD>"
                . "<TD class='rccount'>$count$edit</TD>"
                . "<TD class='rcauthor'>$author</TD></TR>\n";
### summary 개선 by gypark
#           if ($sum ne "") {
#                   . "<TD colspan=4 class='rcsummary'>&nbsp;&nbsp;$sum</TD></TR>\n";
#           }
            if ($all_summary{$pagename} ne "") {
                $html .= "<TR class='rc'><TD colspan=2 class='rc'></TD>"
                    . "<TD colspan=4 class='rcsummary'>$all_summary{$pagename}</TD></TR>\n";
            } elsif ($sum ne "") {
                $html .= "<TR class='rc'><TD colspan=2 class='rc'></TD>"
                    . "<TD colspan=4 class='rcsummary'>$sum</TD></TR>\n";
            }
####
        } else {
            $link = &GetPageLink($pagename);
            $html .= "<li>$link ... ";
            # Later do new-RC looping here.
            $html .=  &CalcTime($ts) . " - $author $sum\n";
        }
    }
    if ($IsPDA) {
        $html .= "</UL>\n";
    } else {
        $html .= "</table>";
    }

    return $html;
}

sub DoRandom {
    my ($id, @pageList);

    @pageList = &AllPagesList();  # Optimize?
    $id = $pageList[int(rand($#pageList + 1))];
    &ReBrowsePage($id, "", 0);
}

sub DoHistory {
    my ($id) = @_;
    my ($html, $canEdit, $row, $newText);

### hide page
    if (&PageIsHidden($id)) {
        print &GetHeader("",&QuoteHtml(Ts('History of %s', $id)), "");
        print Ts('%s is a hidden page', $id);
        print &GetCommonFooter();
        return;
    }

    print &GetHeader("",&QuoteHtml(Ts('History of %s', $id)), "") . "<br>";
    &OpenPage($id);
    &OpenDefaultText();
    $canEdit = 0;  # Turn off direct "Edit" links
    $canEdit = &UserCanEdit($id,1);
    if ( $UseDiff ) {
        print <<FORMEOF ;
            <form action='$ScriptName' METHOD='GET'>
            <input type='hidden' name='action' value='browse'/>
            <input type='hidden' name='diff' value='1'/>
            <input type='hidden' name='id' value='$id'/>
            <table border='0' cellpadding=0 cellspacing=0 width='90%'><tr>
FORMEOF
    }
    $html = &GetHistoryLine($id, $Page{'text_default'}, $canEdit, $row++);
    &OpenKeptRevisions('text_default');
    foreach (reverse sort {$a <=> $b} keys %KeptRevisions) {
        next  if ($_ eq "");  # (needed?)
        $html .= &GetHistoryLine($id, $KeptRevisions{$_}, $canEdit, $row++);
    }
    print $html;
    if( $UseDiff ) {
        my $label = T('Compare');
        print "<tr><td align='center'><input type='submit' value='$label'/>  </td><td>&nbsp;</td></table></form>\n";
        print "<hr>\n";
        print &GetDiffHTML( &GetParam('defaultdiff',1), $id, '', '', $newText );
    }

    print &GetCommonFooter();
}

sub GetHistoryLine {
    my ($id, $section, $canEdit, $row) = @_;
    my ($html, $expirets, $rev, $summary, $host, $user, $uid, $ts, $minor);
    my (%sect, %revtext);

    %sect = split(/$FS2/, $section, -1);
    %revtext = split(/$FS3/, $sect{'data'});
    $rev = $sect{'revision'};
    $summary = $revtext{'summary'};
    if ((defined($sect{'host'})) && ($sect{'host'} ne '')) {
        $host = $sect{'host'};
    } else {
        $host = $sect{'ip'};
        $host =~ s/\d+$/xxx/;      # Be somewhat anonymous (if no host)
    }
    $user = $sect{'username'};
    $uid = $sect{'id'};
    $ts = $sect{'ts'};
    $minor = '';
    $minor = '<i>' . T('(edit)') . '</i> '  if ($revtext{'minor'});
    $expirets = $Now - ($KeepDays * 24 * 60 * 60);

    if ($UseDiff) {
        my ($c1, $c2);
        $c1 = 'checked="checked"' if 1 == $row;
        $c2 = 'checked="checked"' if 0 == $row;
        $html .= "<tr><td align='center'><input type='radio' name='diffrevision' value='$rev' $c1/> ";
        $html .= "<input type='radio' name='revision' value='$rev' $c2/></td><td>";
    }
    if (0 == $row) { # current revision
### History 화면에서, 제일 마지막 revision 은 revision 번호 대신
### "현재 버전" 이라고 나오게 함
#       $html .= &GetPageLinkText($id, Ts('Revision %s', $rev)) . ' ';
        $html .= &GetPageLinkText($id, Ts('Current Revision', $rev)) . ' ';
###
        if ($canEdit) {
            $html .= "&lt;- ". &GetEditLink($id, T('Edit')) . ' ';
        }
    } else {
        $html .= &GetOldPageLink('browse', $id, $rev, Ts('Revision %s', $rev)) . ' ';
        if ($canEdit) {
            $html .= "&lt;- ". &GetOldPageLink('edit',   $id, $rev, T('Edit')) . ' ';
        }
    }
    $html .= ". . . . " . $minor . &TimeToText($ts) . " ";
    $html .= T('by') . ' ' . &GetAuthorLink($host, $user, $uid) . " ";
    if (defined($summary) && ($summary ne "") && ($summary ne "*")) {
        $summary = &QuoteHtml($summary);   # Thanks Sunir! :-)
        $html .= "<b>[$summary]</b> ";
    }
    $html .= $UseDiff ? "</tr>\n" : "<br>\n";
    return $html;
}

# ==== HTML and page-oriented functions ====
sub ScriptLinkChar {
    if ($SlashLinks) {
        return '/';
    }
    return '?';
}

sub ScriptLink {
    my ($action, $text) = @_;
    my $rel;

    if ($action =~ /action=(.+?)\b/i) {
        if ((lc($1) ne "index") && (lc($1) ne "rc")) {
            $rel = 'rel="nofollow"';
        }
    } elsif ($action =~ /search=/i) {
        $rel = 'rel="nofollow"';
    }

    return "<a $rel href=\"$ScriptName" . &ScriptLinkChar() . "$action\">$text</a>";
}

sub ScriptLinkClass {
    my ($action, $text, $class) = @_;
    my $rel;

    if ($action =~ /action=(.+?)\b/i) {
        if ((lc($1) ne "index") && (lc($1) ne "rc")) {
            $rel = 'rel="nofollow"';
        }
    }

    my $data_editlink = '';
    if ($class eq 'wikipagelink') {
        my $editlink = $ScriptName . ScriptLinkChar() . "action=edit&id=$action";
        $data_editlink = qq|data-editlink="$editlink"|;
    }

    return "<a $rel href=\"$ScriptName" . &ScriptLinkChar() . "$action\" class=\"$class\" $data_editlink>$text</a>";
}

sub HelpLink {
    my ($id, $text) = @_;
    my $url = "$ScriptName".&ScriptLinkChar()."action=help&index=$id";

### 작성 취소 시 확인
#   return "<a href=\"javascript:help('$url')\">$text</a>";
    return "<a onclick=\"closeok=true;\" href=\"javascript:help('$url')\">$text</a>";
}

sub GetPageLink {
    my ($id) = @_;

    return &GetPageLinkText($id, $id);
}

sub GetPageLinkText {
    my ($id, $name) = @_;

    $id =~ s|^/|$MainPage/|;
    if ($FreeLinks) {
        $id = &FreeToNormal($id);
        $name =~ s/_/ /g;
    }
### pda clip by gypark
    if ($IsPDA) {
        return  &ScriptLink("action=browse&pda=1&id=$id", $name);
    }

    return &ScriptLinkClass($id, $name, 'wikipagelink');
}

sub GetEditLink {
    my ($id, $name) = @_;

    if ($FreeLinks) {
        $id = &FreeToNormal($id);
        $name =~ s/_/ /g;
    }
    return &ScriptLinkClass("action=edit&id=$id", $name, 'wikipageedit');
}

sub GetOldPageParameters {
    my ($kind, $id, $revision) = @_;

    $id = &FreeToNormal($id) if $FreeLinks;
    return "action=$kind&id=$id&revision=$revision";
}

sub GetOldPageLink {
    my ($kind, $id, $revision, $name) = @_;

    $name =~ s/_/ /g if $FreeLinks;
    return &ScriptLink(&GetOldPageParameters($kind, $id, $revision), $name);
}

sub GetPageOrEditAnchoredLink {
    my ($id, $anchor, $name) = @_;
    my (@temp, $exists);

    if ($name eq "") {
        $name = $id;
        if ($FreeLinks) {
            $name =~ s/_/ /g;
        }
    }
    $id =~ s|^/|$MainPage/|;
    if ($FreeLinks) {
        $id = &FreeToNormal($id);
    }
    $exists = 0;
    if ($UseIndex) {
        if (!$IndexInit) {
            @temp = &AllPagesList();          # Also initializes hash
        }
        $exists = 1  if ($IndexHash{$id});
    } elsif (-f &GetPageFile($id)) {      # Page file exists
        $exists = 1;
    }
    if ($exists) {
        $id = "$id#$anchor" if $anchor;
        $name = "$name#$anchor" if $anchor && $NamedAnchors != 2;
        return &GetPageLinkText($id, $name);
    }
    if ($FreeLinks && !$EditNameLink) {
        if ($name =~ m| |) {  # Not a single word
            $name = "[$name]";  # Add brackets so boundaries are obvious
        }
    }
    if ($EditNameLink) {
        return &GetFirstCharLink($id, $name);
    } else {
        return $name . &GetEditLink($id,"?");
    }
}

# 첫 글자에 링크를 거는 함수
sub GetFirstCharLink {
    my ($id, $name) = @_;

    my ($mainpage, $slash, $page) = ($name =~ m/(?:(.*)(\/))?(.+)/);
    my ($first, $last) = &split_string($page, 1);

    return $mainpage . &GetEditLink($id,$slash.$first) . $last;
}

sub GetPageOrEditLink {
    my ($id, $name) = @_;
    return &GetPageOrEditAnchoredLink( $id, "", $name );
}

sub GetSearchLink {
    my ($id) = @_;
    my $name = $id;

    $id =~ s|.+/|/|;   # Subpage match: search for just /SubName
    if ($FreeLinks) {
        $name =~ s/_/ /g;  # Display with spaces
        $id =~ s/_/+/g;    # Search for url-escaped spaces
    }
    return &ScriptLink("search=$id", $name);
}

### 역링크 추가
sub GetReverseLink {
    my ($id, $name) = @_;
    $name = $id if ($name eq "");

    if ($FreeLinks) {
        $name =~ s/_/ /g;  # Display with spaces
    }
    return &ScriptLink("action=reverse&id=$id", $name);
}

sub GetPrefsLink {
    return &ScriptLink("action=editprefs", T('Preferences'));
}

sub GetRandomLink {
    return &ScriptLink("action=random", T('Random Page'));
}

sub ScriptLinkDiff {
    my ($diff, $id, $text, $rev) = @_;

    $rev = "&revision=$rev"  if ($rev ne "");
    $diff = &GetParam("defaultdiff", 1)  if ($diff == 4);
    return &ScriptLink("action=browse&diff=$diff&id=$id$rev", $text);
}

sub ScriptLinkDiffRevision {
    my ($diff, $id, $rev, $text) = @_;

    $rev = "&diffrevision=$rev"  if ($rev ne "");
    $diff = &GetParam("defaultdiff", 1)  if ($diff == 4);
    return &ScriptLink("action=browse&diff=$diff&id=$id$rev", $text);
}

sub ScriptLinkTitle {
    my ($action, $text, $title) = @_;

    if ($FreeLinks) {
        $action =~ s/ /_/g;
    }
    return "<a href=\"$ScriptName" . &ScriptLinkChar() . "$action\" title=\"$title\">$text</a>";
}

sub GetAuthorLink {
    my ($host, $userName, $uid) = @_;
    my ($html, $title, $userNameShow);

    if (!&UserIsAdmin()) {
        $host =~ s/\d+$/xxx/;
    }

    $userNameShow = $userName;
    if ($FreeLinks) {
        $userName     =~ s/ /_/g;
        $userNameShow =~ s/_/ /g;
    }
    if (&ValidId($userName) ne "") {  # Invalid under current rules
        $userName = "";  # Just pretend it isn't there.
    }
    # Later have user preference for link titles and/or host text?
    if (($uid ne "") && ($userName ne "")) {
        $html = &ScriptLinkTitle($userName, $userNameShow,
                        Ts('ID %s', $uid) . ' ' . Ts('from %s', $host));
    } else {
        $html = $host;
    }
    return $html;
}

sub GetHistoryLink {
    my ($id, $text) = @_;

    if ($FreeLinks) {
        $id =~ s/ /_/g;
    }
    return &ScriptLink("action=history&id=$id", $text);
}

sub GetHeader {
    my ($id, $title, $oldId) = @_;
    my $header = "";
    my $logoImage = "";
    my $result = "";
    my $embed = &GetParam('embed', $EmbedWiki);
    my $altText = T('[Home]');

    $result = &GetHttpHeader();
    if ($FreeLinks) {
        $title =~ s/_/ /g;   # Display as spaces
    }
    $result .= &GetHtmlHeader("$title : $SiteName", $title);
### pda clip by gypark
    if ($IsPDA) {
        $result .= "<h1>$title</h1>\n<hr>";
    }

    return $result  if ($embed);

    if ($oldId ne '') {
        my $topMsg .= '('.Ts('redirected from %s',&GetEditLink($oldId, $oldId)).')  ';
        $result .= $q->h3($topMsg);
    }

    if ((!$embed) && ($LogoUrl ne "")) {
        $logoImage = "IMG class='logoimage' src=\"$LogoUrl\" alt=\"$altText\" border=0";
        if (!$LogoLeft) {
            $logoImage .= " align=\"right\"";
        }
        $header = "<a accesskey=\"w\" href=\"$ScriptName\"><$logoImage></a>";
    }
    if ($id ne '') {
### 역링크 개선
#       $result .= $q->h1($header . &GetSearchLink($id));
        $result .= $q->h1({-class=>"pagename"}, $header . &GetReverseLink($id));
    } else {
        $result .= $q->h1({-class=>"actionname"}, $header . $title);
    }

### page 처음에 bottom 으로 가는 링크를 추가
    $result .= "\n<div class=\"gobottom\" align=\"right\"><a accesskey=\"z\" name=\"PAGE_TOP\" href=\"#PAGE_BOTTOM\">". T('Bottom')." [b]" . "</a></div>\n";

    if (&GetParam("toplinkbar", 1)) {
        # Later consider smaller size?
        $result .= &GetGotoBar($id);
    }

    return $result;
}

sub GetHttpHeader {
    my $cookie;
    my $t;

    $t = gmtime;
    if (defined($SetCookie{'userid'})) {
### 로긴할 때 자동 로그인 여부 선택
#       $cookie = "$CookieName="
#                       . "rev&" . $SetCookie{'rev'}
#                       . "&id&" . $SetCookie{'id'}
#                       . "&randkey&" . $SetCookie{'randkey'};
#       $cookie .= ";expires=Fri, 08-Sep-2010 19:48:23 GMT";

        $cookie = "$CookieName="
            . "expire&" . $SetCookie{'expire'}
            . "&rev&"   . $SetCookie{'rev'}
            . "&userid&"    . EncodeUrl($SetCookie{'userid'})
            . "&randkey&" . $SetCookie{'randkey'}
            . ";";
### slashlinks 지원 - 로긴,로그아웃시에 쿠키의 path를 동일하게 해줌
        my $cookie_path = $q->url(-absolute=>1);
        if ((my $postfix = $q->script_name()) eq $cookie_path) {    # mod_rewrite 가 사용되지 않은 경우
            $cookie_path =~ s/[^\/]*$//;                            # 스크립트 이름만 제거
        } else {                                        # mod_rewrite
            if ((my $postfix = $q->path_info()) ne '') {    # wiki.pl/ 로 rewrite 된 경우
                $cookie_path =~ s/$postfix$//;
            } else {                                        # wiki.pl? 로 rewrite 된 경우
                my $postfix = $q->query_string();
                $cookie_path =~ s/$postfix$//;
            }
        }
        $cookie .= "path=$cookie_path;";

        if ($SetCookie{'expire'} eq "1") {
            $cookie .= "expires=Tue, 31-Dec-2050 23:59:59 GMT";
        }

        if ($HttpCharset ne '') {
            return $q->header(-cookie=>$cookie,
                -pragma=>"no-cache",
                -cache_control=>"no-cache",
                -last_modified=>"$t",
                -expires=>"+10s",
                -type=>"text/html; charset=$HttpCharset");
        }
        return $q->header(-cookie=>$cookie);
    }
    if ($HttpCharset ne '') {
        return $q->header(-type=>"text/html; charset=$HttpCharset",
            -pragma=>"no-cache",
            -cache_control=>"no-cache",
            -last_modified=>"$t",
            -expires=>"+10s");
    }
    return $q->header();
}

sub GetHtmlHeader {
    my ($title, $id) = @_;
    my ($dtd, $bgcolor, $html, $bodyExtra);

    if ($FreeLinks) {
        $id = &FreeToNormal($id);
    }

    $html = '';
    $dtd = '-//IETF//DTD HTML//EN';
    $bgcolor = 'white';  # Later make an option
    $html = qq(<!DOCTYPE HTML PUBLIC "$dtd">\n);
    $title = QuoteHtml($title);
    $html .= "<HTML><HEAD><TITLE>$title</TITLE>\n";

    if ($SiteBase ne "") {
        $html .= qq(<BASE HREF="$SiteBase">\n);
    }
    if ($StyleSheetUrl ne '') {
        $html .= qq(<LINK REL="stylesheet" HREF="$StyleSheetUrl">\n);
    }
    # Insert other header stuff here (like inline style sheets?)

### 헤더 출력 개선
    $html .= qq(<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=$HttpCharset">\n);
    $html .= qq(<META HTTP-EQUIV="Content-Script-Type" CONTENT="text/javascript">\n);
    $html .= qq|<link rel="alternate" type="application/rss+xml" title="$SiteName" href="http://$ENV{SERVER_NAME}$ENV{SCRIPT_NAME}${\(&ScriptLinkChar())}action=rss">\n|;
    $html .= qq(<script src="$JavaScriptUrl" language="javascript" type="text/javascript" charset="UTF-8"></script>);
    $html .= "\n";

### RobotsMetaTag
    my $action = lc(&GetParam('action',''));
    my $search = &GetParam('search','').&GetParam('dosearch','');
    if (
            ($search eq "") &&          # not search result
            ($action eq "" ||           # regular page browse
             $action eq "rc" ||         # recent changes
             $action eq "index")        # page list
       ) {
        $html .= "<META NAME='robots' CONTENT='index,follow'/>\n";
    } else {
        $html .= "<META NAME='robots' CONTENT='noindex,nofollow'/>\n";
    }

### rel=canonical head
    my $full_url = ($FullUrl ne '')?$FullUrl:$q->url(-full => 1);
    my $canonical eq '';
    if ( ($action eq '' or $action eq 'browse') and $id ne '' ) {
        $canonical = $full_url.ScriptLinkChar().$id;
    }
    elsif ( $action eq 'rc' or $action eq 'bookmark' ) {
        $canonical = $full_url.ScriptLinkChar().T($RCName);
    }
# history나 diff화면에서 표준 링크 지정. 이건 조금 과한가
#     elsif ( (my $id_param = GetParam('id', '')) ne '' ) {
#         $canonical = $full_url.ScriptLinkChar().$id_param;
#     }
    $html .= qq|<link rel="canonical" href="$canonical" />\n| if $canonical;

### 사용자 정의 헤더
    $html .= $UserHeader;
    $html .= "\n";

    $bodyExtra = '';
    if ($bgcolor ne '') {
        $bodyExtra = qq( BGCOLOR="$bgcolor");
    }

    if ($ClickEdit) {
        my $revision = GetParam('revision','');
        if ( $revision ne '' ) {
            $bodyExtra .= qq| ondblclick="location.href='$ScriptName${\(&ScriptLinkChar())}action=edit&id=$id&revision=$revision'" |;
        }
        else {
            $bodyExtra .= qq| ondblclick="location.href='$ScriptName${\(&ScriptLinkChar())}action=edit&id=$id'" |;
        }
    }

### 작성 취소시 확인
    if (
            (&GetParam("oldtime", "") ne "") ||
            ((lc(&GetParam("action","")) eq "edit") && (&UserCanEdit($id,1)))
       ) {
        my $close_string = T('If you leave current page, the contents you are writing will not be stored.');
        $bodyExtra .= qq( onbeforeunload="chk_close(event, '$close_string');" );
    }

### 단축키
    my $headExtra;
    if ($UseShortcut) {
        my $shortCutUrl = "$ScriptName".&ScriptLinkChar();
        my $shortCutLogin = (&LoginUser()?"logout":"login&pageid=$pageid");
        my $shortCutHome = &FreeToNormal($HomePage);

        $headExtra .= <<EOH;
<script>
<!--
var key = new Array();

key['f'] = "${shortCutUrl}$shortCutHome";
key['i'] = "${shortCutUrl}action=index";
key['r'] = "${shortCutUrl}action=rc";
key['l'] = "${shortCutUrl}action=$shortCutLogin";

key['t'] = "#PAGE_TOP";
key['b'] = "#PAGE_BOTTOM";

EOH
        # 2024.05.10 - 스크립트에 박혀 있는 이 링크 때문에 amazonbot이 계속 time값을 바꾸며 크롤링한다.
        # 로그인한 유저에게만 보이도록 수정
        if (LoginUser()) {
            $headExtra .= <<EOH;
key['m'] = "${shortCutUrl}action=bookmark&time=$Now";

EOH
        }

        if ($UseShortcutPage) {
            my $shortCutId = $q->param('id');
            $shortCutId = $id if ($shortCutId eq '');
            my $shortCutRevision = &GetParam('revision','');

            $headExtra .= <<EOH;
key['e'] = "${shortCutUrl}action=edit&id=$shortCutId";
key['v'] = "${shortCutUrl}action=edit&id=$shortCutId&revision=$shortCutRevision";
key['h'] = "${shortCutUrl}action=history&id=$shortCutId";
key['d'] = "${shortCutUrl}action=browse&diff=5&id=$shortCutId";

EOH
        }

        $headExtra .= <<EOH;
document.onkeypress = GetKeyStroke;
-->
</script>
EOH
    }
    $html .= $headExtra;

    # Insert any other body stuff (like scripts) into $bodyExtra here
    # (remember to add a space at the beginning to separate from prior text)
    $html .= "</HEAD><BODY $bodyExtra>\n";
    return $html;
}

sub GetEditGuide {
    my ($id, $rev) = @_;
    my $result = "\n<HR class='footer'>\n<DIV class='editguide'>";
#       print "<HR class='footer'>\n"  if (!&GetParam('embed', $EmbedWiki));

### 관리자가 페이지를 볼 때는 하단에 수정 금지 여부를 알려주고 금지 설정/해제를 할 수 있게 함
    if (&UserIsAdmin()) {
        if (-f &GetLockedPageFile($id)) {
            $result .= T('(locked)') . " | ";
        }
        $result .= &ScriptLink("action=pagelock&set=1&id=" . $id, T('lock'));
        $result .= " | " . &ScriptLink("action=pagelock&set=0&id=" . $id, T('unlock'));
### hide page by gypark
        $result .= " | ";
        if (defined($HiddenPage{$id})) {
            $result .= T('(hidden)') . " | ";
        }
        $result .= &ScriptLink("action=pagehide&set=1&id=" . $id, T('hide'));
        $result .= " | " . &ScriptLink("action=pagehide&set=0&id=". $id, T('unhide'));
    }

### 매크로가 들어간 페이지의 편집가이드 문제 해결
    if ($Sec_Revision > 0) {

        $result .= '<br>';
        if ($rev eq '') {  # Only for most current rev
            $result .= T('Last edited');
        } else {
            $result .= T('Edited');
        }
### 매크로가 들어간 페이지의 편집가이드 문제 해결
#       $result .= ' ' . &TimeToText($Section{ts});
        $result .= ' ' . &TimeToText($Sec_Ts);
    }
    if ($UseDiff) {
        $result .= ' ' . &ScriptLinkDiff(4, $id, T('(diff [d])'), $rev);
    }

    $result .= '<br>';
### page count
    $result .= Ts('%s hit' . (($ViewCount > 1)?'s':'') , $ViewCount)." | " if ($ViewCount ne "");

### %-encoded permalink
    $result .= '<a href="' . $q->url(-path=>1) . '" title="'
               . T('Use this URL if you need a url-encoded address of this page')
               . '">Permalink</a> | ';

### 관심 페이지
    if (&LoginUser()) {
        if (defined($UserInterest{$id})) {
            $result .= &ScriptLink("action=interest&mode=remove&id=$id", T('Remove from interest list'));
        } else {
            $result .= &ScriptLink("action=interest&mode=add&id=$id", T('Add to my interest list'));
        }
        $result .= " | ";
    }
    $result .= &GetHistoryLink($id, T('History')." [h]");
    if ($rev ne '') {
        $result .= ' | ';
        $result .= &GetPageLinkText($id, T('View current revision'));
    }

    $result .= ' | ';

    if (&UserCanEdit($id, 1)) {
        if ($rev ne '') {
            $result .= &GetOldPageLink('edit',   $id, $rev,
                         Ts('Edit revision %s of this page', $rev)." [v]");
        } else {
            $result .= &GetEditLink($id, T('Edit text of this page')." [e]");
        }
    } else {
### view action 추가
#       $result .= T('This page is read-only');
        if ($rev ne '') {
            $result .= &GetOldPageLink('edit',   $id, $rev,
                         Ts('View revision %s of this page', $rev));
        } else {
            $result .= &GetEditLink($id, T('View text of this page'));
        }
    }
    $result .= "</DIV>";

    return $result;
}

sub GetFooterText {
    my ($id, $rev) = @_;
    my $result = '';

    if (&GetParam('embed', $EmbedWiki)) {
        return $q->end_html;
    }

    if ($EditPagePos eq 1 or $EditPagePos eq 3) {
        $result .= &GetEditGuide($id, $rev);
    }

    if ($DataDir =~ m|/tmp/|) {
        $result .= '<br><b>' . T('Warning') . ':</b> '
                             . Ts('Database is stored in temporary directory %s',
                                        $DataDir) . '<br>';
    }
    $result .= "<HR class='footer'>";
    $result .= &GetMinimumFooter();
    return $result;
}

sub GetCommonFooter {
    return "<HR class='footer'>" .  &GetMinimumFooter();
}

sub GetMinimumFooter {
    my $result = '';
    if ($FooterNote ne '') {
        $result .= T($FooterNote);  # Allow local translations
    }

### 처리 시간 측정
    $result .= "\n<DIV class='footer'>";
    if ($CheckTime) {
        $result .= "<i>" . sprintf("%8.3f",&tv_interval($StartTime)) . " sec </i>";
    }
    $result .= "<a accesskey=\"x\" name=\"PAGE_BOTTOM\" href=\"#PAGE_TOP\">" . T('Top')." [t]" . "</a></DIV>\n" . $q->end_html;

    return $result;
}

sub GetFormStart {
### form 에 이름을 넣을 수 있도록 함
#   return $q->start_form("POST", "$ScriptName", "application/x-www-form-urlencoded");

    my ($name) = @_;

    if ($name eq '') {
        return $q->start_form("POST", "$ScriptName", "application/x-www-form-urlencoded");
    } else {
        return $q->start_form(-method=>"POST", -action=>"$ScriptName", -enctype=>"application/x-www-form-urlencoded" ,-name=>"$name") ;
    }
}

sub GetGotoBar {
    my ($id) = @_;
    my ($main, $bar_menu, $bar_user, $bar_search);

# gotobar_menu
    $bar_menu .= "<DIV class='gotobar_menu'>\n";
    $bar_menu .= "<UL>\n";
    $bar_menu .= "<LI>"
                . &GetPageLink($HomePage).&GetPageLinkText($HomePage, "[f]")
                . "</LI>\n";
    $bar_menu .= "<LI>"
                . &GetPageLink(T($RCName)).&ScriptLink("action=rc", "[r]")
                . "</LI>\n";
    $bar_menu .= "<LI>"
                . &ScriptLink("action=index", T('Index')."[i]")
                . "</LI>\n";
    if ($id =~ m|/|) {
### subpage 의 경우, 상위페이지 이름 앞에 아이콘 표시
        $main = $id;
        $main =~ s|/.*||;  # Only the main page name (remove subpage)
        $bar_menu .= "<LI>"
                    . "<img src=\"$IconUrl/parentpage.gif\" border=\"0\" alt=\""
                    . T('Main Page:') . " $main\" align=\"absmiddle\">"
                    . &GetPageLink($main)
                    . "</LI>\n";
    }
    if ($UserGotoBar ne '') {
        $bar_menu .= "<LI>" . $UserGotoBar . "</LI>\n";
    }
    foreach ($UserGotoBar2, $UserGotoBar3, $UserGotoBar4) {
        if ($_ ne '') {
            $bar_menu .= "<LI>" . $_ . "</LI>\n";
        }
    }
    if (&GetParam("linkrandom", 0)) {
        $bar_menu .= "<LI>" . &GetRandomLink() . "</LI>\n";
    }
    $bar_menu .= "<LI>"
                . &ScriptLink("action=links", T('Links'))
                . "</LI>\n";
    if (&UserIsAdmin()) {
        $bar_menu .= "<LI>"
                    . &ScriptLink("action=adminmenu", T('Admin'))
                    . "</LI>\n";
    }
    $bar_menu .= "</UL>";
    $bar_menu .= "</DIV>\n";

# gotobar_user
    $bar_user .= "<DIV class='gotobar_user'>\n";
    $bar_user .= "<UL>\n";
    if (!&LoginUser()) {
        $bar_user .= "<LI>"
                    . &ScriptLink("action=login&pageid=$pageid", T('Login')."[l]")
                    . "</LI>\n";
    }
    else {
        $bar_user .= "<LI>"
                    . &GetPageLink(&GetParam('username')) . "</LI>\n"
                    . "<LI>"
                    . &GetPrefsLink() . " | "
                    . &ScriptLink("action=logout", T('Logout'). "[l]")
                    . "</LI>\n";
    }
    $bar_user .= "</UL>";
    $bar_user .= "</DIV>\n";

# gotobar_search, goto
    $bar_search .= "<DIV class='gotobar_search'>\n";
    $bar_search .= "<UL>\n";
    $bar_search .= "<LI>" . &GetGotoForm() . "</LI>\n";

    $bar_search .= "<LI>" . &GetSearchForm() . "</LI>\n";
    $bar_search .= "</UL>";
    $bar_search .= "</DIV>\n";

    my $gotobar_script = <<EOF;
<script>
<!--
gotobar_init();
-->
</script>
EOF

    return
        "<DIV class='gotobar'>"
        . $bar_search
        . $bar_user
        . $bar_menu
        . "</DIV>"
        . $gotobar_script
        . "<HR class='gotobar'>\n"
        ;
}

sub GetGotoForm {
    my ($not_macro, $string);
    if (@_) {
        ($string) = @_;
    } else {
        $not_macro = 1;
    }

    my $result;
    my $location_prefix = $ScriptName . &ScriptLinkChar();
    my $param_backup = $q->param("id");
    $q->param("id", "$string");
    $GotoTextFieldId++;

    $result =
        $q->start_form(
                -name           => ($not_macro?"goto_form":""),
                -method         => "POST",
                -action         => "$ScriptName",
                -enctype        => "application/x-www-form-urlencoded",
                -accept_charset => "$HttpCharset",
                -onSubmit       =>
                        "document.location.href = "
                        . "'$location_prefix'+document.getElementById('goto_$GotoTextFieldId')"
                        . ".value.replace(/\\s*\$/,'').replace(/ /g,'_');"
                        . "return false;"
                        ,
                )
        . "\n"
        . &GetHiddenValue("action", "browse")
        . "\n"
        . $q->textfield(
                -name   => ($not_macro?"goto_text":""),
                -id     => "goto_$GotoTextFieldId",
                -class  => "goto",
                -size   => "30",
                -value  => "$string",
                -accesskey => ($not_macro?"g":""),
                -title  => ($not_macro?T("Go")."(Alt + g)":""),
                -tabindex => ($not_macro?"1000":""),
                # IE&FF
                -onKeyup=> ( $not_macro?
                                "getTitleIndex('$ScriptName')"
                                :
                                ""
                            ),
                # FF에서 처음에 한글로 입력을 시작할 때
                # up,down 키로 목록과 필드를 오갈때
                -onKeydown=> ( $not_macro?
                                "goto_text_keydown(this,event); "
                                . "getTitleIndex('$ScriptName')"
                                :
                                ""
                            ),
                )
        . " "
        . $q->submit(
                -class  => "goto",
                -name   => "Submit",
                -value  => T("Go"),
                -tabindex => ($not_macro?"1002":""),
                )

        # 자동 완성 목록이 나올 DIV
        . ($not_macro? "<BR>\n"
            . "<DIV id=\"goto_list\" style=\"display:none;\">\n"
            . $q->popup_menu(
                    -name     => "goto_select",
                    -size     => "15",
                    -tabindex => "1001",
                    -onBlur   => "goto_list_blur(this,true,true);_goto_field.select()",
                    -onChange => "goto_list_blur(this,true,false);",
                    -values   => ["-- Loading page list... --"],
                    -onKeydown=> "return goto_list_keydown(this,event);",
                )
            . "</DIV>\n"
            :
            ""
          )

        . $q->end_form
        ;

    $q->param("id", $param_backup);
    return $result;
}

sub GetSearchForm {
    my ($result);

### 단축키 alt-s 지정
    my $checked = &GetParam("context","");
    $result =
        &GetFormStart("search_form")
        . &GetHiddenValue("dosearch", 1)
        . $q->textfield(
                -name   => "search",
                -class  => "search",
                -size   => "30",
                -accesskey => "s",
                -title  => T("Search")."(Alt + s)",
                )
        . $q->checkbox(
                -name       => 'context',
                -checked    => ($checked)?1:'',
                -value      => 'on',
                -label      => T('Context'),
            )
        . " "
        . $q->submit(
                -class  => "search",
                -name   => "Submit",
                -value  => T("Search"),
                )
        . $q->end_form
        ;

    return $result;
}

sub GetRedirectPage {
    my ($newid, $name, $isEdit) = @_;
    my ($url, $html);
    my ($nameLink);

    # Normally get URL from script, but allow override.
    $FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
    $url = $FullUrl . &ScriptLinkChar() . $newid;

    # 섹션 단위 편집을 했다면 이 시점에 section 파라메터가 있다. 화면을 표시할 때 해당 섹션으로 이동
    my $section = GetParam('section');
    if (defined $section and $section > 0) {
        $url .= "#S_$section";
    }
    $nameLink = "<a href=\"$url\">$name</a>";
    if ($RedirType < 3) {
        if ($RedirType == 1) {             # Use CGI.pm
            # NOTE: do NOT use -method (does not work with old CGI.pm versions)
            # Thanks to Daniel Neri for fixing this problem.
            $html = $q->redirect(-uri=>$url);
        } else {                           # Minimal header
            $html  = "Status: 302 Moved\n";
            $html .= "Location: $url\n";
            $html .= "Content-Type: text/html\n";  # Needed for browser failure
            $html .= "\n";
        }
        $html .= "\n" . Ts('Your browser should go to the %s page.', $newid);
        $html .= ' ' . Ts('If it does not, click %s to continue.', $nameLink);
    } else {
        if ($isEdit) {
            $html  = &GetHeader('', T('Thanks for editing...'), '');
            $html .= Ts('Thank you for editing %s.', $nameLink);
        } else {
            $html  = &GetHeader('', T('Link to another page...'), '');
        }
        $html .= "\n<p>";
        $html .= Ts('Follow the %s link to continue.', $nameLink);
        $html .= &GetMinimumFooter();
    }
    return $html;
}

# ==== Common wiki markup ====
sub WikiToHTML {
    my ($pageText) = @_;

    $TableMode = 0;
    %SaveUrl = ();
    %SaveNumUrl = ();
    $SaveUrlIndex = 0;
    $SaveNumUrlIndex = 0;
    $pageText =~ s/$FS//g;              # Remove separators (paranoia)
### include 매크로 안에서 위키태그를 작동하게 함
    $pageText = &MacroIncludeSubst($pageText);

    if ($RawHtml) {
        ### {{{ }}} 내의 <html> 태그는 스킵
        while ($pageText =~ s/^{{{((?:.(?!}}}))+?)<(html>)(.+?)}}}/{{{$1$FS_lt$2$3}}}/igms) { }
        $pageText =~ s/<html>(.*?)<\/html>/StoreRaw($1)/isge;
        $pageText =~ s/$FS_lt/</gi;
    }
### {{{ }}} 처리를 위해, 본문 소스는 특별하게 Quote 한다
#   $pageText = &QuoteHtml($pageText);
    $pageText = &QuoteHtmlForPageContent($pageText);

### {{{ }}} 처리를 위해서, 줄 끝에 오는 백슬래쉬 두개와 하나도 임시태그를 거쳐 변환시킨다
#   $pageText =~ s/\\\\ *\r?\n/<BR>/g;      # double backslash for forced <BR> - comes in handy for <LI>
#   $pageText =~ s/\\ *\r?\n/ /g;           # Join lines with backslash at end

    $pageText =~ s/\\\\ *\r?\n/&__DOUBLEBACKSLASH__;/g;     # double backslash for forced <BR> - comes in handy for <LI>
    $pageText =~ s/\\ *\r?\n/&__SINGLEBACKSLASH__;/g;           # Join lines with backslash at end
###
    $pageText = &CommonMarkup($pageText, 1, 0);   # Multi-line markup # line wraped. luke
    $pageText = &WikiLinesToHtml($pageText);      # Line-oriented markup

    $pageText =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
    $pageText =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore nested saved text

    while (@HeadingNumbers) {
        pop @HeadingNumbers;
        $TableOfContents .= "</dd></dl>\n\n";
    }
### WikiHeading 개선 from Jof
    $pageText =~ s/&__LT__;toc&__GT__;/<a name="toc"><\/a>$TableOfContents/i;
    $pageText =~ s/&__LT__;toc&__GT__;/$TableOfContents/gi;

### {{{ }}} 처리를 위해 추가. 임시 태그를 원래대로 복원
    $pageText =~ s/&__DOUBLEBACKSLASH__;/<BR>\n/g;
    $pageText =~ s/&__SINGLEBACKSLASH__;/ /g;
    $pageText =~ s/&__LT__;/&lt;/g;
    $pageText =~ s/&__GT__;/&gt;/g;
    $pageText =~ s/&__AMP__;/&amp;/g;
    $pageText =~ s/$FS_lt/&lt;/g;
    $pageText =~ s/$FS_gt/&gt;/g;

    return &RestoreSavedText($pageText);
}

sub CommonMarkup {
    my ($text, $useImage, $doLines) = @_;
    local $_ = $text;

    if ($doLines < 2) { # 2 = do line-oriented only
### {{{ }}} 처리
        s/^{{{\r?\n(.*?)\n}}}\r?$/StoreRaw(qq|<pre class="code">\n|) . StoreCodeRaw($1) . StoreRaw("\n<\/pre>")/igesm;
### plugin 처리
        s/^{{{#!(\w+( .+?)?)\r?\n(.*?)\n}}}\r?$/StorePlugin($1,$3)/igesm;
### {{{lang|n|t }}} 처리
        s/^{{{(\w+)(\|(n|\d+|n\d+|\d+n))?\r?\n(.*?)\r?\n}}}\r?$/StoreRaw(qq|<pre class="syntax">\n|) . StoreSyntaxHighlight($1, $3, $4) . StoreRaw("\n<\/pre>")/igesm;

### <raw> 태그 - quoting 도 하지 않는다
        s/\&__LT__;raw\&__GT__;(([^\n])*?)\&__LT__;\/raw\&__GT__;/&StoreCodeRaw($1)/ige;

        # The <nowiki> tag stores text with no markup (except quoting HTML)
        s/\&__LT__;nowiki\&__GT__;((.|\n)*?)\&__LT__;\/nowiki\&__GT__;/&StoreRaw($1)/ige;
        # The <pre> tag wraps the stored text with the HTML <pre> tag
        s/\&__LT__;pre\&__GT__;((.|\n)*?)\&__LT__;\/pre\&__GT__;/&StorePre($1, "pre")/ige;
        s/\&__LT__;code\&__GT__;((.|\n)*?)\&__LT__;\/code\&__GT__;/&StorePre($1, "code")/ige;

### LaTeX 지원
        if ($UseLatex) {
            s/\\\[((.|\n)*?)\\\]/&StoreRaw(&MakeLaTeX("\$"."$1"."\$", "display"))/ige;
            s/\$\$((.|\n)*?)\$\$/&StoreRaw(&MakeLaTeX("\$"."$1"."\$", "inline"))/ige;
        }
        else {
            s/\$\$(.*?)\$\$/StorePlugin('latex inline', $1)/ges;
            s/\\\[(.*?)\\\]/StorePlugin('latex',        $1)/ges;
        }

### anchor 에 한글 사용
#       s/\[\#(\w+)\]/&StoreHref(" name=\"$1\"")/ge if $NamedAnchors;
# anchor 정리 - 2012.01.06
        s/\[\[$AnchorPattern\|([^\]]+)\]\]/StoreHref("href=\"#$1\"", $2)/ge if $NamedAnchors;
        s/\[\[$AnchorPattern\]\]/StoreHref("href=\"#$1\"", $1)/ge if $NamedAnchors;

        s/\[$AnchorPattern\|([^\]]+)\]/StoreHref("name=\"$1\"", $2)/geo;
        s/\[$AnchorPattern\]/StoreHref("name=\"$1\"")/ge if $NamedAnchors;

        if ($HtmlTags) {
            foreach my $t (@HtmlPairs) {
                s/\&__LT__;$t(\s[^<>]+?)?\&__GT__;(.*?)\&__LT__;\/$t\&__GT__;/<$t$1>$2<\/$t>/gis;
            }
            foreach my $t (@HtmlSingle) {
                s/\&__LT__;$t(\s[^<>]+?)?\&__GT__;/<$t$1>/gi;
            }
        } else {
            # Note that these tags are restricted to a single line
            s/\&__LT__;b\&__GT__;(.*?)\&__LT__;\/b\&__GT__;/<b>$1<\/b>/gi;
            s/\&__LT__;i\&__GT__;(.*?)\&__LT__;\/i\&__GT__;/<i>$1<\/i>/gi;
            s/\&__LT__;strong\&__GT__;(.*?)\&__LT__;\/strong\&__GT__;/<strong>$1<\/strong>/gi;
            s/\&__LT__;em\&__GT__;(.*?)\&__LT__;\/em\&__GT__;/<em>$1<\/em>/gi;
        }
        s/\&__LT__;tt\&__GT__;(.*?)\&__LT__;\/tt\&__GT__;/<tt>$1<\/tt>/gis;  # <tt> (MeatBall)
        if ($HtmlLinks) {
            s/\&__LT__;A(\s[^<>]+?)\&__GT__;(.*?)\&__LT__;\/a\&__GT__;/&StoreHref($1, $2)/gise;
        }
        if ($FreeLinks) {
            # Consider: should local free-link descriptions be conditional?
            # Also, consider that one could write [[Bad Page|Good Page]]?
            s/\[\[$FreeLinkPattern\|([^\]]+)\]\]/&StorePageOrEditLink($1, $2)/geo;
            s/\[\[$FreeLinkPattern\]\]/&StorePageOrEditLink($1, "")/geo;
### 한글페이지에 anchor 사용
            s/\[\[$AnchoredFreeLinkPattern\|([^\]]+)\]\]/&StoreBracketAnchoredLink($1, $2, $3)/geos if $NamedAnchors;
            s/\[\[$AnchoredFreeLinkPattern\]\]/&StoreRaw(&GetPageOrEditAnchoredLink($1, $2, ""))/geos if $NamedAnchors;
#####
        }
        if ($BracketText) {  # Links like [URL text of link]
            # 텍스트 부분에 \]라고 써서 대괄호 자체를 표기할 수 있게 수정
            s/\[$UrlPattern\s+((?:\\\]|[^\]])+?)\]/&StoreBracketUrl($1, $2)/geos;
            s/\[$InterLinkPattern\s+([^\]]+?)\]/&StoreBracketInterPage($1, $2)/geos;
            if ($WikiLinks && $BracketWiki) {  # Local bracket-links
                s/\[$LinkPattern\s+([^\]]+?)\]/&StoreBracketLink($1, $2)/geos;
                s/\[$AnchoredLinkPattern\s+([^\]]+?)\]/&StoreBracketAnchoredLink($1, $2, $3)/geos if $NamedAnchors;
            }
        }

        if ($useImage) {
            $_ = &EmoticonSubst($_);            # luke added
        }

### img macro from Jof
        s/\&__LT__;img\(([^,\n\s]*?)\)\&__GT__;/&MacroImgTag($1,0,0,'','')/gei;
        s/\&__LT__;img\(([^,\n\s]*?),(\d+?),(\d+?)\)\&__GT__;/&MacroImgTag($1,$2,$3,'','')/gei;
        s/\&__LT__;img\(([^,\n\s]*?),(\d+?),(\d+?),([^,\n]*?)\)\&__GT__;/&MacroImgTag($1,$2,$3,$4,'')/gei;
        s/\&__LT__;img\(([^,\n\s]*?),(\d+?),(\d+?),([^,\n]*?),([^,\n\s]*?)\)\&__GT__;/&MacroImgTag($1,$2,$3,$4,$5)/gei;
####

        s/\[$UrlPattern\]/&StoreBracketUrl($1, "")/geo;
        s/\[$InterLinkPattern\]/&StoreBracketInterPage($1, "")/geo;
### 개별적인 IMG: 태그
        s/IMG:([^<>\n]*)\n?$UrlPattern/&StoreImgUrl($1, $2, $useImage)/geo;
###
        s/$UrlPattern/&StoreUrl($1, $useImage)/geo;
### InterWiki 로 적힌 이미지 처리
#       s/$InterLinkPattern/&StoreInterPage($1)/geo;
        s/$InterLinkPattern/&StoreInterPage($1, $useImage)/geo;
###

        if ($WikiLinks) {
            s/$AnchoredLinkPattern/&StoreRaw(&GetPageOrEditAnchoredLink($1, $2, ""))/geo if $NamedAnchors;
            s/$LinkPattern/&GetPageOrEditLink($1, "")/geo;
        }

        s/$RFCPattern/StoreRFC($1)/geo;
        s/$ISBNPattern/StoreISBN($1)/geo;
        s/CD:\s*(\d+)/StoreHotTrack($1)/geo;

        $_ = &MacroSubst($_);               # luke added

        # ---- <hr>
        s/(-{4,})/'<hr noshade style="height:' . ( length($1)>8 ? 5 : length($1)-3 ) . 'px">'/ge;

    }
    if ($doLines) { # 0 = no line-oriented, 1 or 2 = do line-oriented
        # The quote markup patterns avoid overlapping tags (with 5 quotes)
        # by matching the inner quotes for the strong pattern.
        s/('*)'''(.*?)'''/$1<strong>$2<\/strong>/g;
        s/''(.*?)''/<em>$1<\/em>/g;
        s/(^|\n)\s*(\=+)\s+([^\n]+)\s+\=+/&WikiHeading($1, $2, $3)/geo;
### table 내 셀 별로 정렬
#       s/((\|\|)+)/"<\/TD><TD COLSPAN=\"" . (length($1)\/2) . "\">"/ge if $TableMode;

# rowspan 을 vvv.. 로 표현하는 경우 (차후에 다시 고려할 예정)
#       my %td_align = ("&__LT__;", "left", "&__GT__;", "right", "|", "center");
#       s/((\|\|)*)(\|(&__LT__;|&__GT__;|\|)(v*))/"<\/TD><TD align=\"$td_align{$4}\" COLSPAN=\""
#               . ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"".(length($5)+1):"") . "\">"/ge if $TableMode;
# rowspan 을 v3 으로 표현하는 경우
        my %td_align = ("&__LT__;", "left", "&__GT__;", "right", "|", "center");
        s/((\|\|)*)(\|(&__LT__;|&__GT__;|\|)((v(\d*))?))/"<\/TD><TD align=\"$td_align{$4}\" COLSPAN=\""
            . ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"" . ((length($7))?"$7":"2"):"") . "\">"/ge if $TableMode;
    }

    return $_;
}

# luke added

sub EmoticonSubst {

    my ($txt) = @_;

    if ($UseEmoticon) {
        my ($e, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8);

        $e1 = $EmoticonUrl . "/emoticon-ambivalent.gif ";
        $e2 = $EmoticonUrl . "/emoticon-laugh.gif ";
        $e3 = $EmoticonUrl . "/emoticon-sad.gif ";
        $e4 = $EmoticonUrl . "/emoticon-smile.gif ";
        $e5 = $EmoticonUrl . "/emoticon-surprised.gif ";
        $e6 = $EmoticonUrl . "/emoticon-tongue-in-cheek.gif ";
        $e7 = $EmoticonUrl . "/emoticon-unsure.gif ";
        $e8 = $EmoticonUrl . "/emoticon-wink.gif ";

        $txt =~ s/(\s)\^[oO_\-]*\^[;]*/$1$e2/g;
        $txt =~ s/(\s)-[_]+-[;]*/$1$e7/g;
        $txt =~ s/(\s)o\.O([^A-z])/$1$e5$2/g;
        $txt =~ s/(\s)\*\.\*/$1$e5/g;
        $txt =~ s/(\s)\=\.\=[;]*/$1$e7/g;
        $txt =~ s/(\s)\:-[sS]([^A-z])/$1$e7$2/g;

        $txt =~ s/(\s)\:[-]*D([^A-z])/$1$e2$2/g;
        $txt =~ s/(\s)\:[-]*\(([^A-z])/$1$e3$2/g;
        $txt =~ s/(\s)\:[-]*\)([^A-z])/$1$e4$2/g;
        $txt =~ s/(\s)\:[-]*[oO]([^A-z])/$1$e5$2/g;
        $txt =~ s/(\s)\:[-]*[pP]([^A-z])/$1$e6$2/g;
        $txt =~ s/(\s)\;[-]*\)([^A-z])/$1$e8$2/g;
    }

    return $txt;
}

sub MacroSubst {
    my ($txt) = @_;

### <UploadedFiles>
    $txt =~ s/(\&__LT__;uploadedfiles\&__GT__;)/&MacroUploadedFiles($1)/gei;
### <comments(숫자)>
    # 페이지 이름을 쓰지 않음
    $txt =~ s/(&__LT__;(long)?comments\()([-+]?\d+)(\)&__GT__;)/$1$pageid,$3$4/gi;

    $txt =~ s/(\&__LT__;comments\(([^,]+),([-+]?\d+)\)&__GT__;)/&MacroComments($1,$2,$3)/gei;
### <noinclude> </noinclude> from Jof
    $txt =~ s/\&__LT__;(\/)?noinclude\&__GT__;//gei;
### <longcomments(숫자)>
    $txt =~ s/(\&__LT__;longcomments\(([^,]+),([-+]?\d+)\)&__GT__;)/&MacroComments($1,$2,$3,1)/gei;
### <memo(제목)></memo> from Jof
    $txt =~ s/(&__LT__;memo\(([^\n]+?)\)&__GT__;((.)*?)&__LT__;\/memo&__GT__;)/&MacroMemo($1, $2, $3)/geis;
###

### 매크로 모듈화
    my $macroname;
    my ($MacrosDir, $MyMacrosDir) = ("./macros/", "./mymacros/");
    foreach my $dir ($MacrosDir, $MyMacrosDir) {
        foreach my $macrofile (glob("$dir/*.pl")) {
            if ($macrofile =~ m|$dir/([^/]*).pl|) {
                $macroname = $1;
                $MacroFile{"$macroname"} = $macrofile;
            }
        }
    }

    foreach my $macro (sort keys %MacroFile) {
        if ($txt =~ /(&__LT__;|<)$macro/i) {
            require "$MacroFile{$macro}";
            $txt = &{\&$macro}($txt);
        }
    }

    return $txt;
}


### added by gypark
sub RemoveLink {
    my ($string) = @_;

    $string = &RestoreSavedText($string);
    $string =~ s/<a[^>]+?href[^>]+?>(\?<\/a>)?//ig;
    $string =~ s/<\/a>//ig;

    return $string;
}

### include 매크로 안에서 위키태그를 작동하게 함
sub MacroIncludeSubst {
    my ($txt) = @_;

### #TEMPLATE
    if (substr($txt, 0, 10) eq '#TEMPLATE ') {
        my ($template_line, $template_id);
        if (($FreeLinks) && ($txt =~ /\#TEMPLATE\s+\[\[.+\]\]/)) {
            ($template_line, $template_id) = ($txt =~ /(\#TEMPLATE\s+\[\[(.+)\]\])/);
            $template_id = &FreeToNormal($template_id);
        } else {
            ($template_line, $template_id) = ($txt =~ /(\#TEMPLATE\s+(\S+))/);
        }
        if (&ValidId($template_id) eq '') {
            $txt =~ s/\Q$template_line\E//;
            $txt = &ApplyDynamicTemplate($template_id, $pageid, $txt);
        } else {  # Not a valid target, so continue as normal page
            # 할 거 없음
        }
    }

    $txt =~ s/(^|\n)<include\((.*)\)>([\r\f]*\n)/$1 . &MacroInclude($2) . $3/geim;
### toc 를 포함하지 않는 includenotoc 매크로 추가
    $txt =~ s/(^|\n)<includenotoc\((.*)\)>([\r\f]*\n)/$1 . &MacroInclude($2, "notoc") . $3/geim;

### include 매크로 시리즈 모듈화
    my $macroname;
    my ($MacrosDir, $MyMacrosDir) = ("./macros/", "./mymacros/");
    foreach my $dir ($MacrosDir, $MyMacrosDir) {
        foreach my $macrofile (glob("$dir/*include*.pl")) {
            if ($macrofile =~ m|$dir/([^/]*).pl|) {
                $macroname = $1;
                $MacroFile{"$macroname"} = $macrofile;
            }
        }
    }

    foreach my $macro (sort keys %MacroFile) {
        if ($txt =~ /(&__LT__;|<)$macro/i) {
            require "$MacroFile{$macro}";
            $txt = &{\&$macro}($txt);
        }
    }

    return $txt;
}

### #TEMPLATE
sub ApplyDynamicTemplate {
    my ($template_id, $id, $id_text) = @_;

    my $fname = &GetPageFile($template_id);
    if (!(-f $fname)) {
        return $id_text;
    }

    my ($status, $data) = &ReadFile($fname);
    if (!$status) {
        return $id_text;
    }

    $id_text =~ s/^\s*//s;
    $id_text =~ s/\s*$//s;

    my %temp_Page = split(/$FS1/, $data, -1);
    my %temp_Section = split(/$FS2/, $temp_Page{'text_default'}, -1);
    my %temp_Text = split(/$FS3/, $temp_Section{'data'}, -1);
    my $text = &TemplateMacroSubst($id, $temp_Text{'text'});

# 섹션 단위 편집 - 동적 템플릿에 사용될 때는 하지 않음 - 작업하다 말아서 어떤 맥락이었는지
# 기억이 안 남... 일단 주석 처리 한 채로 submit (2008.8.5)
#   $text =~ s/((^|\n)[\ \t\f]*\=+[\ \t\f]+[^\n]+)([\ \t\f]+\=+)/$1${FS}noedit$FS$3/go;
    $text =~ s/<template_text>/$id_text/;

    return $text;
}


### img from Jof
sub MacroImgTag {
    my ($url,$width,$height,$caption,$float) = @_;
    my ($s_width,$s_height,$s_tag,$s_divstyle,$s_caption,$return);

    $s_width    = " width=\"$width\"" if ( $width>0 );
    $s_height   = " height=\"$height\"" if ( $height>0 );
    $s_tag      = " title=\"$url\"";
    $s_divstyle = " style=\"float:$float;\"" if ($float ne '');
    $s_caption  = "<br><span class=\"imgcaption\">$caption</span>" if ($caption ne '');

    if ($url =~ /$InterLinkPattern/)
    {
        my $id = $url;
        my ($name, $site, $remotePage, $punct, $image);

        ($id, $punct) = &SplitUrlPunct($id);

        $name = $id;
        ($site, $remotePage) = split(/:/, $id, 2);
        $url = &GetSiteUrl($site);
        if ($url ne "")
        {
            $remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML

            if ($url =~ /\|/) {
                ($url, $image) = split(/\|/, $url, 2);
            }
            $url .= $remotePage;
        }
    }

    if ($width > 0 or $height > 0)
    {
        $return     = "<a href=\"$url\"><img src=\"$url\" $s_width $s_height $s_tag border=\"1\" style=\"margin:5px;\"></a>";
    }
    else
    {
        $return     = "<img src=\"$url\" $s_tag border=\"1\" style=\"margin:5px;\">";
    }
    if (($caption ne '') or ($float ne ''))
    {
        $return = "<div align=\"center\" $s_divstyle>$return$s_caption</div>";
    }
    return &StoreRaw($return);
}

### comments from Jof
sub MacroMemo {
    my ($itself, $title, $text, $class) = @_;

    $class = "memo" if ($class eq '');
    $title = &RemoveLink($title);

    return qq|<button class="memo-toggle">$title</button>|
        . qq|<div class="memo-area $class" style="display:none;">$text</div>|;

}

sub MacroComments {
    my ($itself,$id,$up,$long,$threadindent) = @_;
    my $idvalue;
    my $temp;
    my $txt;
    my $abs_up = abs($up);
    my ($threshold1, $threshold2) = (100000000, 1000000000);

    $temp = $id;
    $temp =~ s/,$//;
    $temp = &RemoveLink($temp);
    $temp = &FreeToNormal($temp);
    if (&ValidId($temp) ne "") {
        return $itself;
    }
    $id = "$temp";

    if (&LoginUser()) {
        $idvalue = "[[$UserID]]";
    }

    my ($hidden_long, $readonly_true, $readonly_style, $readonly_msg);
    my ($name_field, $comment_field);
    my $submit_button;

# CCode
    my $ccode = &simple_crypt(length($id).substr(&CalcDay($Now),5));

    if ($long) {
        $hidden_long = &GetHiddenValue("long","1") . "<br>";
    }

    if (((!&UserCanEdit($id,1)) && (($abs_up < 100) || ($abs_up > $threshold2))) || (&UserIsBanned())) {        # 에디트 불가
        $readonly_true = "true";
        $readonly_style = "background-color: #f0f0f0;";
        $readonly_msg = T('Comment is not allowed');
        $name_field = $q->textfield(-name=>"name",
                                    -class=>"comments",
                                    -size=>"15",
                                    -maxlength=>"80",
                                    -readonly=>"$readonly_true",
                                    -style=>"$readonly_style",
                                    -default=>"$idvalue");
        if ($long) {        # longcomments
            $comment_field = $q->textarea(-name=>"comment",
                                    -class=>"comments",
                                    -rows=>"7",
                                    -cols=>"80",
                                    -readonly=>"$readonly_true",
                                    -style=>"$readonly_style",
                                    -default=>"$readonly_msg");
        } else {            # comments
            $comment_field = $q->textfield(-name=>"comment",
                                            -class=>"comments",
                                            -size=>"60",
                                            -readonly=>"$readonly_true",
                                            -style=>"$readonly_style",
                                            -default=>"$readonly_msg");
        }
        $submit_button = "";
    } else {                                            # 에디트 가능
        $name_field = $q->textfield(-name=>"name",
                                    -class=>"comments",
                                    -size=>"15",
                                    -maxlength=>"80",
                                    -default=>"$idvalue");
        if ($long) {        # longcomments
            $comment_field = $q->textarea(-name=>"comment",
                                    -class=>"comments",
                                    -rows=>"7",
                                    -cols=>"80"
                                    -default=>"");
        } else {            # comments
            $comment_field = $q->textfield(-name=>"comment",
                                            -class=>"comments",
                                            -size=>"60",
                                            -default=>"");
        }
        $submit_button = $q->submit(-name=>"Submit",-value=>T("Submit"));
    }

    my $spambot_trap =
        "<DIV style='display:none;'>"
        . "Homepage: "
        . $q->textfield(-name=>"homepage",
                        -class=>"comments",
                        -size=>"10",
                        -maxlength=>"80",
                        -default=>"")
        . "</DIV>";

    # Twitter
    my $twitter = "";
    if ( UserIsAdmin() and $TwitterID ) {
        $twitter = $q->checkbox(-name=>'twitter_comment', -checked=>0, -label=>T('Twitter')."($TwitterID)"). "\n";
    }

    $txt =
        $q->start_form(-name=>"comments",-method=>"POST",-action=>"$ScriptName") .
        &GetHiddenValue("action","comments") .
        &GetHiddenValue("id",$id) .
        &GetHiddenValue("pageid",$pageid) .
        &GetHiddenValue("up","$up") .
        &GetHiddenValue("ccode","$ccode") .
        (($threadindent ne '')?&GetHiddenValue("threadindent",$threadindent):"") .
        T('Name') . ": " .
        $name_field . "&nbsp;" .
        $spambot_trap .
        T('Comment') . ": " .
        $hidden_long .
        $comment_field . "&nbsp;" .
        $twitter .
        $submit_button .
        $q->end_form;

    if ($threadindent ne '') {
        if ($threadindent >= 1) {   # "새글쓰기"도 감추고 싶다면 1 대신 0으로 할 것
            my $memotitle = ($threadindent == 0)?T('Write New Thread'):T('Write Comment');
            $txt = &MacroMemo("", $memotitle, $txt, "threadmemo");
        } else {
            $txt = T('Write New Thread') . $txt;
        }
    }

    return $txt;
}

### UploadedFiles
sub MacroUploadedFiles {
    my ($itself) = (@_);
    my (@files, %filesize, %filemtime, $size, $totalSize);
    my $txt;
    my $uploadsearch = "<img style='border:0' src='$IconUrl/upload-search.gif'>";
    my $canDelete = &UserIsAdmin();

    if (!(-e $UploadDir)) {
        &CreateDir($UploadDir);
    }

    opendir (DIR, "$UploadDir") || die Ts('cant opening %s', $UploadDir) . ": $!";
    @files = grep { !/^\.\.?$/ } readdir(DIR);
    close (DIR);

    $totalSize = 0;
    foreach (@files) {
        $filesize{$_} = (-s "$UploadDir/$_");
        $totalSize += $filesize{$_};
        $filemtime{$_} = ($Now - (-M "$UploadDir/$_") * 86400);
    }

    @files = sort {
        $filemtime{$b} <=> $filemtime{$a}
                ||
                $a cmp $b
    } @files;

    my ( @dirs, @p_files );
    foreach my $f ( @files ) {
        if ( -d "$UploadDir/$f" ) {
            push @dirs, $f;
        }
        else {
            push @p_files, $f;
        }
    }

    $txt = $q->start_form("post","$ScriptName","");
    $txt .= "<input type='hidden' name='action' value='deleteuploadedfiles'>";
    $txt .= "<input type='hidden' name='pagename' value='$OpenPageName'>";

    $txt .= "<TABLE class='uploadedfiles'>";
    $txt .= "<TR class='uploadedfiles'>";
    if ($canDelete) {
        $txt .= "<TH class='uploadedfiles'><b>".T('Delete')."</b></TH>";
    }
    $txt .= "<TH class='uploadedfiles'><b>".T('File Name')."</b></TH>".
        "<TH class='uploadedfiles'><b>".T('Size (byte)')."</b></TH>".
        "<TH class='uploadedfiles'><b>".T('Date')."</b></TH>";
    $txt .= "</TR>\n";


    foreach (@dirs, @p_files) {
        $txt .= "<TR class='uploadedfiles'>";
        if ($canDelete) {
            $txt .= "<TD class='uploadedfiles' align='center'>";
            $txt .= "<input type='checkbox' name='files' value='$_'></input> ";
            $txt .= "</TD>";
        }
        $txt .= "<TD class='uploadedfiles'>";
        $txt .= &GetReverseLink("Upload:$_", $uploadsearch) . " ";
        if ( -d "$UploadDir/$_" ) {
            $txt .= "$_/";
        }
        else {
            $txt .= "<a href='$UploadUrl/$_'>$_</a>";
        }
        $txt .= "</TD>";

        $size = $filesize{$_};
        while ($size =~ m/(\d+)(\d{3})((,\d{3})*$)/) {
            $size = "$1,$2$3";
        }
        $txt .= "<TD class='uploadedfiles' align='right'>$size</TD>";
        $txt .= "<TD class='uploadedfiles'>".&TimeToText($filemtime{$_})."</TD>";
        $txt .= "</TR>\n";
    }
    $txt .= "<TR class='uploadedfiles'>";
    $txt .= "<TD class='uploadedfiles'>&nbsp;</TD>" if ($canDelete);
    $txt .= "<TD class='uploadedfiles'>";
    $txt .= "<b>". Ts('Total %s files', ($#files + 1))."</b>";
    $txt .= "</TD>";
    while ($totalSize =~ m/(\d+)(\d{3})((,\d{3})*$)/) {
        $totalSize = "$1,$2$3";
    }
    $txt .= "<TD class='uploadedfiles' align='right'>";
    $txt .= "<b>$totalSize</b>";
    $txt .= "</TD>";
    $txt .= "<TD class='uploadedfiles'>&nbsp;</TD></TR>\n";

    $txt .= "</TABLE>";
    $txt .= $q->submit(T('Delete Checked Files')) if ($canDelete);
    $txt .= $q->end_form;
    return $txt;

}

sub MacroInclude {
    my ($name, $opt) = @_;

    if ($OpenPageName eq $name) { # Recursive Include 방지
        return "";
    }

    $name =~ s/^\[\[(.*)\]\]$/$1/;
    $name =~ s|^/|$MainPage/|;
    $name = &FreeToNormal($name);

    my $fname = &GetPageFile($name);    # 존재하지 않는 파일이면 그냥 리턴
    if (!(-f $fname)) {
        return "";
    }

### hide page
    if (&PageIsHidden($name)) {
        return "";
    }

    my $data = &ReadFileOrDie($fname);
    my %SubPage = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields

    if (!defined($SubPage{"text_default"})) {
        return "";
    }

    my %SubSection = split(/$FS2/, $SubPage{"text_default"}, -1);
    my %TextInclude = split(/$FS3/, $SubSection{'data'}, -1);
    my $txt = $TextInclude{'text'};

# #TEMPLATE
    $txt =~ s/^#TEMPLATE\s+(\[\[.+\]\]|\S+)//;
    # includenotoc 의 경우
    $txt =~ s/<toc>/$FS_lt."toc".$FS_gt/gei if ($opt eq "notoc");
    # noinclude 처리 from Jof
    $txt =~ s/<noinclude>(.)*?<\/noinclude>//igs;

    # comments 시리즈의 경우 페이지 아이디를 추가해줌
    $txt =~ s/(<(long)?comments\()([-+]?\d+)(\)>)/$1$name,$3$4/gi;
    $txt =~ s/(<thread\()([-+]?\d+(,\d+)?)(\)>)/$1$name,$2$4/gi;

# 섹션 단위 편집 - include 될 때는 하지 않음
    $txt =~ s/((^|\n)[\ \t\f]*\=+[\ \t\f]+[^\n]+)([\ \t\f]+\=+)/$1${FS}noedit$FS$3/go;

    return $txt;
}

# end

sub WikiLinesToHtml {
    my ($pageText) = @_;
    my ($pageHtml, @htmlStack, $code, $depth, $oldCode);
    my ($tag);

### added by gypark
    my %td_align = ("&__LT__;", "left", "&__GT__;", "right", "|", "center");

    @htmlStack = ();
    $depth = 0;
    $pageHtml = "";
    foreach (split(/\n/, $pageText)) {  # Process lines one-at-a-time
        $_ .= "\n";
        if (s/^(\;+)([^:]+\:?)\:/<dt>$2<dd>/) {
            $code = "DL";
            $depth = length $1;
        } elsif (s/^(\:+)/<dt><dd>/) {
            $code = "DL";
            $depth = length $1;
        } elsif (s/^(\*+)/<li>/) {
            $code = "UL";
            $depth = length $1;
        } elsif (s/^(\#+)/<li>/) {
            $code = "OL";
            $depth = length $1;
        } elsif (/^[ \t].*\S/) {
            $code = "PRE";
            $depth = 1;
###############
### replaced by gypark
### table 내 셀 별로 정렬
#       } elsif (s/^((\|\|)+)(.*)\|\|\s*$/"<TR VALIGN='CENTER' ALIGN='CENTER'><TD colspan='" . (length($1)\/2) . "'>$3<\/TD><\/TR>\n"/e) {
#           $code = 'TABLE';
#           $TableMode = 1;
#           $depth = 1;

# rowspan 을 vvv.. 로 표현하는 경우 (차후에 다시 고려할 예정)
#       } elsif (s/^((\|\|)*)(\|(&__LT__;|&__GT__;|\|)(v*))(.*)\|\|\s*$/"<TR VALIGN='CENTER' ALIGN='CENTER'>"
#               . "<TD align=\"$td_align{$4}\" colspan=\""
#               . ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"".(length($5)+1):"") . "\">"
#               . $6 . "<\/TD><\/TR>\n"/e) {
#           $code = 'TABLE';
#           $TableMode = 1;
#           $depth = 1;

        } elsif (s/^((\|\|)*)(\|(&__LT__;|&__GT__;|\|)((v(\d*))?))(.*)\|\|\s*$/"<TR VALIGN='CENTER' ALIGN='CENTER'>"
                . "<TD align=\"$td_align{$4}\" colspan=\""
                . ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"" . ((length($7))?"$7":"2"):"") . "\">"
                . $8 . "<\/TD><\/TR>\n"/e) {
            $code = 'TABLE';
            $TableMode = 1;
            $depth = 1;

###
###############
        } elsif (/^IMG:(.*)$/) {        # luke added
            StoreImageTag($1);
            $_ = "";
        } elsif (/^TABLE:(.*)$/) {      # luke added
            StoreTableTag($1);
            $_ = "";
        } else {
            $depth = 0;
        }

        while (@htmlStack > $depth) {   # Close tags as needed
        #  $pageHtml .=  "</" . pop(@htmlStack) . ">\n";        -- deleted luke
            $tag = pop(@htmlStack);                             # added luke
            if ($tag eq "TABLE") {
### 줄 중간 || 문제 해결
### from Jof4002's patch
#               $pageHtml .=  "</TR>\n";
#               $tag = "table"

                $TableMode = 0;
###
            };
            $pageHtml .=  "</" . $tag . ">\n";                  # added end luke
        }
        if ($depth > 0) {
            $depth = $IndentLimit  if ($depth > $IndentLimit);
            if (@htmlStack) {  # Non-empty stack
                $oldCode = pop(@htmlStack);
                if ($oldCode ne $code) {
### 줄 중간 || 문제 해결
### from Jof4002's patch
                    if ($oldCode eq "TABLE") {
                        $TableMode = 0;
                    }
###
                    $pageHtml .= "</$oldCode><$code>\n";
                }
                push(@htmlStack, $code);
            }
            while (@htmlStack < $depth) {
                push(@htmlStack, $code);
                if ($code eq "TABLE") {                 # added luke
                    $pageHtml .= "<TABLE $TableTag >\n";
                } else {
                    $pageHtml .= "<$code>\n";
                };                                      # added luke
                # $pageHtml .= "<$code>\n";             # deleted luke
            }
        }
        s!^\s*$!<p></p>\n!;                        # Blank lines become <p> tags
        $pageHtml .= &CommonMarkup($_, 1, 2);  # Line-oriented common markup
    }
    while (@htmlStack > 0) {       # Clear stack
        $pageHtml .=  "</" . pop(@htmlStack) . ">\n";
    }


    return $pageHtml;
}

sub QuoteHtml {
    my ($html) = @_;

    $html =~ s/&/&amp;/g;
    $html =~ s/</&lt;/g;
    $html =~ s/>/&gt;/g;
    $html =~ s/&amp;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references

    return $html;
}

### {{{ }}} 처리를 위해 본문 처리시에는 Quote 를 다르게 함
sub QuoteHtmlForPageContent {
    my ($html) = @_;

    $html =~ s/&/&__AMP__;/g;
    $html =~ s/</&__LT__;/g;
    $html =~ s/>/&__GT__;/g;
    $html =~ s/&__AMP__;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references

    return $html;
}

sub StoreInterPage {
    my ($id, $useImage) = @_;

    my ($link, $extra);

    ($link, $extra) = &InterPageLink($id, $useImage);

    # Next line ensures no empty links are stored
    $link = &StoreRaw($link)  if ($link ne "");
    return $link . $extra;
}

sub InterPageLink {
    my ($id, $useImage) = @_;
    my ($name, $site, $remotePage, $url, $punct);

    ($id, $punct) = &SplitUrlPunct($id);

    $name = $id;
    ($site, $remotePage) = split(/:/, $id, 2);
    $url = &GetSiteUrl($site);
### interwiki 아이콘
    my ($image, $url_main, $encoding);
    ($url, $image, $encoding) = split(/\|/, $url);
    $url_main = $url;
###
    return ("", $id . $punct)  if ($url eq "");
    $remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML

### intermap 에 인코딩 지정
#   $url .= $remotePage;
    my $encoded_page = $remotePage;
    if (($encoding ne "") && (lc($encoding) ne lc($HttpCharset))) {
        $encoded_page = &convert_encode($encoded_page, $HttpCharset, $encoding);
    }
    $encoded_page = &EncodeUrl($encoded_page) if ($site !~ /^(Upload|Local|LocalWiki)$/);
    $url .= $encoded_page;

### InterWiki 로 적힌 이미지 처리
### from Jof's patch
    if ($useImage && ($url =~ /^(http:|https:|ftp:).+\.$ImageExtensions$/)) {
        $url = $1 if ($url =~ /^https?:(.*)/ && $1 !~ /^\/\//);
        return ("<img $ImageTag src=\"$url\" alt=\"$id\">", $punct);
    }

### interwiki 아이콘
#   return ("<a href=\"$url\">$name</a>", $punct);
    my $link_html = '';
    if (!($image)) {
        $image = "default-inter.gif";
    }
    if (!($image =~ m/\//)) {
        $image = "$InterIconUrl/$image";
    }
    $link_html = "<A class='inter' href='$url_main'>" .
                "<IMG class='inter' src='$image' alt='$site:' title='$site:'>" .
                "</A>";
    $link_html .= "<A class='inter' href='$url' title='$id'>$remotePage</A>";
    return ($link_html, $punct);
}

sub StoreBracketInterPage {
    my ($id, $text) = @_;
    my ($site, $remotePage, $url, $index);

    ($site, $remotePage) = split(/:/, $id, 2);
    $remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML
    $url = &GetSiteUrl($site);
### interwiki 아이콘
    my ($image, $url_main, $encoding);
    ($url, $image, $encoding) = split(/\|/, $url);
    $url_main = $url;
###

    if ($text ne "") {
        return "[$id $text]"  if ($url eq "");
    } else {
        return "[$id]"  if ($url eq "");
        $text = &GetBracketUrlIndex($id);
    }

### intermap 에 인코딩 지정
#   $url .= $remotePage;
    my $encoded_page = $remotePage;
    if (($encoding ne "") && (lc($encoding) ne lc($HttpCharset))) {
        $encoded_page = &convert_encode($encoded_page, $HttpCharset, $encoding);
    }
    $encoded_page = &EncodeUrl($encoded_page) if ($site !~ /^(Upload|Local|LocalWiki)$/);
    $url .= $encoded_page;

    return StoreRaw( qq(<a class="inter" href="$url" title="$id">[$text]</a>) );
}

sub GetBracketUrlIndex {
    my ($id) = @_;
    my ($index, $key);

    # Consider plain array?
    if ($SaveNumUrl{$id} > 0) {
        return $SaveNumUrl{$id};
    }
    $SaveNumUrlIndex++;  # Start with 1
    $SaveNumUrl{$id} = $SaveNumUrlIndex;
    return $SaveNumUrlIndex;
}

sub GetSiteUrl {
    my ($site) = @_;
    my ($data, $url, $status);

    if (!$InterSiteInit) {
        $InterSiteInit = 1;
### file upload
        ($status, $data) = &ReadFile($InterFile);
        if ($status) {
### intermap에 #을 사용한 주석 추가 지원
            %InterSite = map { s/\s*#.*//; split /\s+/; } grep { s/^\s*//; /^[^#]/ } split /\n/, $data;
        }
        if (!defined($InterSite{'Upload'})) {
### interwiki 아이콘
            $InterSite{'Upload'} = "$UploadUrl\/|default-upload.gif";
        }

### Local, LocalWiki 인터위키 from usemod 1.0
### interwiki 아이콘 같이 적용
        if (!defined($InterSite{'LocalWiki'})) {
            $InterSite{'LocalWiki'} = $ScriptName . &ScriptLinkChar() . "|default-local.gif";
        }
        if (!defined($InterSite{'Local'})) {
            $InterSite{'Local'} = $ScriptName . &ScriptLinkChar() . "|default-local.gif";
        }

    }
    $url = $InterSite{$site}  if (defined($InterSite{$site}));
    return $url;
}

sub StoreRaw {
    my ($html) = @_;

    $SaveUrl{++$SaveUrlIndex} = $html;
    return $FS . $SaveUrlIndex . $FS;
}

### 몇 가지 함수들 추가
### {{{ }}} 처리를 위해
sub StoreCodeRaw {
    my ($html) = @_;

#   $html =~ s/&__LT__;/</g;
#   $html =~ s/&__GT__;/>/g;
#   $html =~ s/&__AMP__;/&/g;

#   $html =~ s/&__AMP__;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references

    $html =~ s/&([#a-zA-Z0-9]+);/&amp;$1;/g;
    $html =~ s/&__DOUBLEBACKSLASH__;/\\\\\n/g;
    $html =~ s/&__SINGLEBACKSLASH__;/\\\n/g;
    $html =~ s/&__LT__;/&lt;/g;
    $html =~ s/&__GT__;/&gt;/g;
    $html =~ s/&__AMP__;/&amp;/g;

    return &StoreRaw($html);

}

### {{{lang }}} 처리를 위해
sub StoreSyntaxHighlight {
    my ($lang, $opt , @code) = @_;

    my %LANG;
    foreach (@SRCHIGHLANG) {
        $LANG{$_} = "1";
    }

    if (!((-x "$SOURCEHIGHLIGHT") && defined($LANG{$lang}))) {
        return &StoreCodeRaw(@code);
    }

    my ($option) = " -fhtml -s$lang ";
    if ($opt =~ s/n//) {
        $option .= " -n ";
    }
    if ($opt ne "") {
        $option .= " -t$opt ";
    }

    my (@html) = `$SOURCEHIGHLIGHT $option << "EnDoFwIkIcOdE"
@code
EnDoFwIkIcOdE`;

# source-highlight 출력물 앞뒤의 버전정보, pre 태그, tt 태그를 뺀다
    my $html = join($FS1, @html);
    $html =~ s/^<!-- Generator: GNU source-highlight.*?-->//s;
    $html =~ s/^.*?<pre>.*?<tt>//s;
    $html =~ s/<\/tt>.*?<\/pre>(\r?\n)*$//s;
    $html =~ s/(\r?\n)*?$//s;
    @html = split(/$FS1/, $html);

    my $result = "";
    foreach my $line (@html) {
        $line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__DOUBLEBACKSLASH__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1\\\\\n$6/g;
        $line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__SINGLEBACKSLASH__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1\\\n$6/g;
        $line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__GT__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1&gt;$6/g;
        $line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__LT__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1&lt;$6/g;
        $line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__AMP__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1&amp;$6/g;

        $result .= &StoreRaw($line);

    }
    return $result;
}

### 외부 plugin 지원
sub StorePlugin {
    my ($command, $content) = @_;
    my $name;
    my @opt;
    my $plugin_file = "";;

    $command = &UnquoteHtmlForPageContent($command);

    @opt = split (/\s/, $command);
    $name = shift @opt;

    my ($PluginDir, $MyPluginDir) = ("./plugin/", "./myplugin/");
    if (-f "$MyPluginDir/$name.pl") {
        $plugin_file = "$MyPluginDir/$name.pl";
    } elsif (-f "$PluginDir/$name.pl") {
        $plugin_file = "$PluginDir/$name.pl";
    }

    if ($plugin_file eq "") {   # 플러그인이 없음
        return &StoreRaw("\n<PRE class='code'>").
            &StoreRaw("\n<font color='red'>No such plugin found: $name</font>\n").
            &StoreCodeRaw($content).
            &StoreRaw("\n<\/PRE>") . "\n";
    }

    my $loadplugin = eval "require '$plugin_file'";

    if (not $loadplugin) {      # 플러그인 로드에 실패
        return &StoreRaw("\n<PRE class='code'>").
            &StoreRaw("\n<font color='red'>Failed to load plugin: $name</font>\n").
            &StoreCodeRaw($content).
            &StoreRaw("\n<\/PRE>") . "\n";
    }

    my $func = "plugin_$name";
    my $content_unquoted = &UnquoteHtmlForPageContent($content);
    my $txt = &{\&$func}($content_unquoted, @opt);
    if (not defined $txt) {     # 플러그인이 undef 반환
        return &StoreRaw("\n<PRE class='code'>").
            &StoreRaw("\n<font color='red'>Error occurred while processing: $name</font>\n").
            &StoreCodeRaw($content).
            &StoreRaw("\n<\/PRE>") . "\n";
    }

    return &StoreRaw($txt);
}

### 글을 작성한 직후에 수행되는 매크로들
sub ProcessPostMacro {
    my ($string, $id) = @_;

    ### 여기에 사용할 매크로들을 나열한다
    $string = &PostMacroMySign($string);

    return $string;
}

### <mysign> 매크로 처리
sub PostMacroMySign {
    my ($string) = @_;
    my ($timestamp) = &TimeToText($Now);
    my ($author) = &GetParam('username');

    if ($author ne "") {
    # 이 시점에서 [[ ]] 를 붙이는 것이 옳은가 확인할 것
        $author = "[[$author]]";
    } else {
        $author = &GetRemoteHost(0);
    }
    # 여기서는 그냥 mysign(이름,시간)으로만 변경
    $string =~ s/<mysign>([\r\f]*\n)/<mysign($author,$timestamp)>$1/gim;

    return $string;
}

sub StorePre {
    my ($html, $tag) = @_;

    return &StoreRaw("<$tag>" . $html . "</$tag>");
}

sub UnquoteHtmlForPageContent {
    my ($html) = @_;
    $html =~ s/&__GT__;/>/g;
    $html =~ s/&__LT__;/</g;
    $html =~ s/&__AMP__;/&/g;
    $html =~ s/&__DOUBLEBACKSLASH__;/\\\\\n/g;
    $html =~ s/&__SINGLEBACKSLASH__;/\\\n/g;
    return $html;
}

### LaTeX 지원
sub MakeLaTeX {
    my ($latex,  $type) = @_;

    $latex = &UnquoteHtmlForPageContent($latex);

    # 그림파일의 이름은 텍스트를 해슁하여 결정
    require Digest::MD5;
    my $hash = Digest::MD5::md5_hex($latex);

    # 기본값 설정
    my $hashimage = "$hash.png";
    my $imgpath = "";
    my $LatexDir = "$UploadDir/latex";
    my $LatexUrl = "$UploadUrl/latex";
    my $TemplateFile = "$DataDir/latex.template";

    # 디렉토리 생성
    &CreateDir($UploadDir);
    &CreateDir($LatexDir);

    if (-f "$LatexDir/$hashimage" && not -z "$LatexDir/$hashimage") {
        # 이미 생성되어 캐쉬에 있음
    } else {
        # 새로 생성해야 됨
        my $hashdir = "$TempDir/$hash";
        my $DefaultTemplate = << 'EOT';
\documentclass[12pt]{amsart}

% Your can use the desire symbol packages
% Of course, MikTeX needs to be able to get the
% package that you specify
\usepackage{mathptmx,bm,calrsfs}

% "sboxit" puts two marks on top and bottom of the math
% equation for ImageMagick to cut out the image
\def\sboxit#1{%
\setbox0=\hbox{#1}\hbox{\vbox{\hsize=\wd0\hrule height1pt width2pt%
\hbox{\vrule width0pt\kern0pt\vbox{%
\vspace{1pt}\noindent\unhbox0\vspace{1pt}}%
\kern1pt\vrule width0pt}\hrule height1pt width2pt}}}
\mathchardef\gt="313E % type $a\gt b$ instead of $a > b$
\mathchardef\lt="313C % type $a\lt b$ instead of $a < b$

\pagestyle{empty}
\begin{document}
\thispagestyle{empty}

% the first hbox make the depth of the equation right
\sboxit{\hbox to 0pt{\phantom{g}}<math>}

\end{document}
EOT

        if (not -d $hashdir) {
            mkdir($hashdir,0775) or return "[Unable to create $hash dir]";
        }

        if (not -f $TemplateFile) {
            &WriteStringToFile($TemplateFile, $DefaultTemplate);
        }

        my $template = &ReadFile($TemplateFile);

        $template =~ s/<math>/$latex/ige;

        my $pwd = `pwd`;
        $pwd =~ s/(.*)((\n|\r)*)?/$1/;

        chdir ($hashdir);

        # 원본 tex 생성
        open my $outfile, '>', 'srender.tex';
        print $outfile $template;
        close $outfile;

        open my $saveout, '>&', STDOUT;
        open my $saveerr, '>&', STDERR;
        open STDOUT, '>' , 'hash.log';
        open STDERR, '>&', STDOUT;

        # 그림 생성
        qx(latex -interaction=nonstopmode srender.tex);
        qx(dvips srender.dvi);
        qx(convert -transparent "white" -density 100x100 -trim -shave 0x2 srender.ps $hashimage);

        close STDOUT;
        close STDERR;
        open STDOUT, '>&', $saveout;
        open STDERR, '>&', $saveerr;

        # upload 경로 그림 옮김
        chdir($pwd);
        if (-f "$hashdir/$hashimage" && not -z "$hashdir/$hashimage") {
            my $png = &ReadFile("$hashdir/$hashimage");
            &WriteStringToFile("$LatexDir/$hashimage", $png);
        } else {
            return "[Error retrieving image from hashdir]";
        }
        unlink (glob("$hashdir/*")) or return "[[unlink fail]]";
        rmdir ($hashdir) or return "[[rmdir fail]]";
    }

    # IMG 태그 출력
    if ($type eq "inline") {
        $imgpath = qq(<img src="$LatexUrl/$hashimage" class="latexinline" alt="\$$latex\$">);
    } elsif ($type eq "display") {
        $imgpath = qq(<img src="$LatexUrl/$hashimage" class="latexdisplay" alt="$latex">);
    }
    return $imgpath;
}

sub StoreHref {
    my ($anchor, $text) = @_;

#   return "<a" . &StoreRaw($anchor) . ">$text</a>";
    return StoreRaw("<a $anchor>$text</a>");
}

sub StoreUrl {
    my ($name, $useImage) = @_;
    my ($link, $extra);

    ($link, $extra) = &UrlLink($name, $useImage);
    # Next line ensures no empty links are stored
    $link = &StoreRaw($link)  if ($link ne "");
    return $link . $extra;
}

### 개별적인 IMG: 태그
sub StoreImgUrl {
    my ($imgTag, $name, $useImage) = @_;
    my ($link, $extra);

    $ImageTag = $imgTag;
    ($link, $extra) = &UrlLink($name, $useImage);
    # Next line ensures no empty links are stored
    $link = &StoreRaw($link)  if ($link ne "");
    $ImageTag = "";
    return $link . $extra;
}

sub UrlLink {
    my ($rawname, $useImage) = @_;
    my ($name, $punct);

    ($name, $punct) = &SplitUrlPunct($rawname);
    if ($NetworkFile && $name =~ m|^file:|) {
        # Only do remote file:// links. No file:///c|/windows.
        if ($name =~ m|^file://[^/]|) {
            return ("<a href=\"$name\">$name</a>", $punct);
        }
        return $rawname;
    }
    # Restricted image URLs so that mailto:foo@bar.gif is not an image
    if ($useImage && ($name =~ /^(http:|https:|ftp:).+\.$ImageExtensions$/)) {
        $name = $1 if ($name =~ /^https?:(.*)/ && $1 !~ /^\/\//);
### 이미지에 alt 태그를 넣어 원래 주소를 보임
        return ("<img $ImageTag src=\"$name\" alt=\"$name\">", $punct);
    }
### 상대 경로로 적힌 URL 을 제대로 처리
    my $protocol;
    ($protocol, $name) = ($1, $2) if ($name =~ /^(https?:)(.*)/ && $2 !~ /^\/\//);

    return ( qq(<a class="outer" href="$name">$protocol$name</a>), $punct );
}

sub StoreBracketUrl {
    my ($url, $text) = @_;

    $url = $1 if ($url =~ /^https?:(.*)/ && $1 !~ /^\/\//);
    if ($text eq "") {
        $text = &GetBracketUrlIndex($url);
    }
    else {
        # 텍스트 부분에 \] 라고 쓴 건 ]로 되돌림
        $text =~ s/\\\]/]/g;
    }
    return StoreRaw( qq(<a class="outer" href="$url">[$text]</A>) );
}

sub StoreBracketLink {
    my ($name, $text) = @_;

    return &StoreRaw(&GetPageLinkText($name, "[$text]"));
}

sub StoreBracketAnchoredLink {
    my ($name, $anchor, $text) = @_;

    return &StoreRaw(&GetPageLinkText("$name#$anchor", "[$text]"));
}

sub StorePageOrEditLink {
    my ($page, $name) = @_;

    if ($FreeLinks) {
        $page =~ s/^\s+//;      # Trim extra spaces
        $page =~ s/\s+$//;
        $page =~ s|\s*/\s*|/|;  # ...also before/after subpages
    }
    $name =~ s/^\s+//;
    $name =~ s/\s+$//;
    return &StoreRaw(&GetPageOrEditLink($page, $name));
}

sub StoreRFC {
    my ($num) = @_;

    return &StoreRaw(&RFCLink($num));
}

sub RFCLink {
    my ($num) = @_;

    return "<a href=\"http://www.faqs.org/rfcs/rfc${num}.html\">RFC $num</a>";
}

# luke add begin

sub StoreImageTag {
    my ($x) = @_;
    $ImageTag = $x;
    return "";
}

sub StoreTableTag {
    my ($x) = @_;
    $TableTag = $x;
    return "";
}

sub StoreHotTrack {
    my ($id) = @_;

    return "<a href=\"http://www.hottracks.co.kr/cgi-bin/hottracks.storefront/Product/View/$id\">" .
        "<img src=\"http://image.hottracks.co.kr/hottracks/cdimg/$id.jpg\" alt=\"$id\"></a>";
}

# luke add end

sub StoreISBN {
    my ($num) = @_;

    return StoreRaw(ISBNLink($num));
}

# 13자리 ISBN을 10자리로 변환
sub isbn13to10 {
    my $isbn13 = shift;
    my $isbn10 = substr($isbn13, 3, 9);

    my $checksum = 0;
    my $weight = 10;
    foreach my $c ( split //, $isbn10 ) {
        $checksum += $c * $weight;
        $weight--;
    }

    $checksum = 11 - ( $checksum % 11 );
    if ( $checksum == 10 ) {
        $isbn10 .= 'X';
    }
    elsif ( $checksum == 11 ) {
        $isbn10 .= '0';
    }
    else {
        $isbn10 .= $checksum;
    }

    return $isbn10;
}

sub ISBNLink {
    my ($rawnum) = @_;

    my $num = $rawnum;
    my $rawprint = $rawnum;
    $rawprint =~ s/ +$//;
    $num =~ s/[- ]//g;

    # 숫자 자릿수 체크 - 13자리면 10자리로 변환
    if (length($num) == 13) {
        $num = isbn13to10($num);
    }
    elsif (length($num) != 10) {
        return "ISBN $rawnum";
    }

    # 책표지가 없을 때 사용할 아이콘
    my ($noCoverIcon, $iconNum) = ("$IconUrl/isbn-nocover.jpg", ($num % 5));
    $noCoverIcon = "$IconUrl/isbn-nocover-$iconNum.jpg"
        if (-f "$IconUrl/isbn-nocover-$iconNum.jpg");

    my ( $link, $cover );

    # 국내 서적
    if ($num =~ /^(89|60)/) {
        # 일단 커버는 없고, 링크도 고정된 형태로 가정
        $cover = $noCoverIcon;
        $link = "http://www.aladin.co.kr/shop/wproduct.aspx?ISBN=$num";

        if ( eval { require WebService::Aladdin } ) {
            # WebService::Aladdin 모듈이 있다면 그걸 사용하여 커버 주소와 링크 추출
            my $p     = WebService::Aladdin->new();
            my $data;
            if ( eval { $data  = $p->product($num) } ) {
                $cover = $data->{cover};
                $link  = $data->{link};
            }
        }
        elsif ( eval { require LWP::Simple } ) {
            # LWP::Simple 모듈이 있다면 알라딘 홈페이지에 들어가서 커버 주소 추출
            my $html = LWP::Simple::get($link);
            if ($html =~ m'property="og:image"\s+content="(.+?)"'s) {
                $cover = $1;
            }
        }
    }
    # 일본 서적
    elsif ($num =~ /^4/) {
        $link  = "http://bookweb.kinokuniya.co.jp/guest/cgi-bin/wshosea.cgi?W-ISBN=$num";
        $cover = "http://bookweb.kinokuniya.co.jp/imgdata/$num.jpg";
    }
    # 그 외 서적 - 아마존
    else {
        $link  = "http://www.amazon.com/exec/obidos/ISBN=$num";
        $cover = "http://images.amazon.com/images/P/$num.01.MZZZZZZZ.gif";
    }

    return StoreHref( qq/href="$link"/,
                      qq/<IMG class="isbn" src="$cover" onError='src="$noCoverIcon"' alt="/
                      . T('Go to the on-line bookstore') . qq/ ISBN:$rawprint">/
                    );
}

sub SplitUrlPunct {
    my ($url) = @_;
    my ($punct);

    if ($url =~ s/\"\"$//) { return ($url, "");   # Delete double-quote delimiters here
    }
    $punct = "";
### 한글이 포함된 인터위키에서 일부 한글을 인식하지 못하는 문제 해결
#   ($punct) = ($url =~ /([^a-zA-Z0-9\/\xc0-\xff]+)$/);
#   $url =~ s/([^a-zA-Z0-9\/\xc0-\xff]+)$//;

    ($punct) = ($url =~ /([^a-zA-Z0-9\/\x80-\xff]+)$/);
    $url =~ s/([^a-zA-Z0-9\/\x80-\xff]+)$//;
###
    return ($url, $punct);
}

sub StripUrlPunct {
    my ($url) = @_;
    my ($junk);

    ($url, $junk) = &SplitUrlPunct($url);
    return $url;
}

sub WikiHeadingNumber {
    my ($depth,$text) = @_;
    my ($anchor, $number);
    return '' unless --$depth > 0;  # Don't number H1s because it looks stupid

    while (scalar @HeadingNumbers < ($depth-1)) {
        push @HeadingNumbers, 1;
        $TableOfContents .= '<dl><dt> </dt><dd>';
        }
    if (scalar @HeadingNumbers < $depth) {
        push @HeadingNumbers, 0;
        $TableOfContents .= '<dl><dt> </dt><dd>';
    }
    while (scalar @HeadingNumbers > $depth) {
        pop @HeadingNumbers;
        $TableOfContents .= "</dd></dl>\n\n";
    }
    $HeadingNumbers[$#HeadingNumbers]++;
    $number = (join '.', @HeadingNumbers) . '. ';

    # Remove embedded links. THIS IS FRAGILE!
    $text = &RestoreSavedText($text);
    $text =~ s/\<a\s.*?\>\?\<\/a\>//si; # No such page syntax
    $text =~ s/\<a\s.*?\>(.*?)\<\/a\>/$1/si;

    # Cook anchor by canonicalizing $text.
###############
### replaced by gypark
### <toc> 사용에 있어서 헤드라인 문자열의 끝단어가 같으면 제대로 toc 링크가
### 되지 않는 버그 해결
### from http://host9.swidc.com/~ncc1701/wiki/wiki.cgi?FAQ

#   $anchor = $text;
#   $anchor =~ s/\<.*?\>//g;
#   $anchor =~ s/\W/_/g;
#   $anchor =~ s/__+/_/g;
#   $anchor =~ s/^_//;
#   $anchor =~ s/_$//;
#   $anchor = '_' . (join '_', @HeadingNumbers) unless $anchor; # Last ditch effort

    $anchor = 'H_' . (join '_', @HeadingNumbers);

###
###############


### <toc> 개선
#   $TableOfContents .= $number . &ScriptLink("$OpenPageName#$anchor",$text) . "</dd>\n<dt> </dt><dd>";
    $TableOfContents .= $number . "<a href=\"#$anchor\">" . $text . "</a></dd>\n<dt> </dt><dd>";

### WikiHeading 개선 from Jof
#   return &StoreHref(" name=\"$anchor\"") . $number;
    return &StoreHref("name='$anchor' href='#toc'",$number);
}

sub WikiHeading {
    my ($pre, $depth, $text) = @_;

    $depth = length($depth);
    $depth = 6  if ($depth > 6);
#   $text =~ s/^#\s+/&WikiHeadingNumber($depth,$')/e; # $' == $POSTMATCH
    $text =~ s/^#\s+(.*)/&WikiHeadingNumber($depth,$1).$1/e;
### 섹션 단위 편집
#   return $pre . "<H$depth>$text</H$depth>\n";
    my $edit_section = '';
    if ($text =~ s/${FS}noedit$FS//) {  # include 된 내용의 경우는 스킵
    }
    elsif (&GetParam('revision', '') eq '') {
        $SectionNumber++;
        if (
            UserCanEdit($pageid, 1)
            and
            $depth != 1
            and
            GetParam("action") !~ /help|preview/i
            and
            !GetParam("embed", $EmbedWiki)
           )
        {
            $edit_section = '<SPAN class="editsection">['.
                &ScriptLink("action=edit&id=$pageid&section=$SectionNumber",&T("edit")).
                ']</SPAN>';
        }
    }
    # HeadingNumber를 붙이는지 여부와 무관하게, 섹션 단위 편집 후 해당 섹션으로 이동하기 위한 앵커
    my $anchorSectionNumber = StoreHref(qq|name="S_$SectionNumber"|,'');
    return $pre . "$anchorSectionNumber<H$depth>$edit_section$text</H$depth>\n";
######
}

sub RestoreSavedText
{
    my ($text) = @_;
    $text =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
    $text =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore nested saved text
    return $text;
}

# ==== Difference markup and HTML ====
sub GetDiffHTML {
    my ($diffType, $id, $revOld, $revNew, $newText) = @_;
    my ($html, $diffText, $diffTextTwo, $priorName, $links, $usecomma);
    my ($major, $minor, $author, $useMajor, $useMinor, $useAuthor, $cacheName);

    $links = "(";
    $usecomma = 0;
    $major  = &ScriptLinkDiff(1, $id, T('major diff'), "");
    $minor  = &ScriptLinkDiff(2, $id, T('minor diff'), "");
    $author = &ScriptLinkDiff(3, $id, T('author diff'), "");
    $useMajor  = 1;
    $useMinor  = 1;
    $useAuthor = 1;
    if ($diffType == 1) {
        $priorName = T('major');
        $cacheName = 'major';
        $useMajor  = 0;
    } elsif ($diffType == 2) {
        $priorName = T('minor');
        $cacheName = 'minor';
        $useMinor  = 0;
    } elsif ($diffType == 3) {
        $priorName = T('author');
        $cacheName = 'author';
        $useAuthor = 0;
    }
    if ($revOld ne "") {
        # Note: OpenKeptRevisions must have been done by caller.
        # Later optimize if same as cached revision
        $diffText = &GetKeptDiff($newText, $revOld, 1);  # 1 = get lock
        if ($diffText eq "") {
            $diffText = T('(The revisions are identical or unavailable.)');
        }
    } else {
        $diffText  = &GetCacheDiff($cacheName);
    }
    $useMajor  = 0  if ($useMajor  && ($diffText eq &GetCacheDiff("major")));
    $useMinor  = 0  if ($useMinor  && ($diffText eq &GetCacheDiff("minor")));
    $useAuthor = 0  if ($useAuthor && ($diffText eq &GetCacheDiff("author")));
    $useMajor  = 0  if ((!defined(&GetPageCache('oldmajor'))) ||
                                            (&GetPageCache("oldmajor") < 1));
    $useAuthor = 0  if ((!defined(&GetPageCache('oldauthor'))) ||
                                            (&GetPageCache("oldauthor") < 1));
    if ($useMajor) {
        $links .= $major;
        $usecomma = 1;
    }
    if ($useMinor) {
        $links .= ", "  if ($usecomma);
        $links .= $minor;
        $usecomma = 1;
    }
    if ($useAuthor) {
        $links .= ", "  if ($usecomma);
        $links .= $author;
    }
    if (!($useMajor || $useMinor || $useAuthor)) {
        $links .= T('no other diffs');
    }
    $links .= ")";

    if ((!defined($diffText)) || ($diffText eq "")) {
        $diffText = T('No diff available.');
    }
    if ($revOld ne "") {
        my $currentRevision = T('Current Revision');
        $currentRevision = Ts('Revision %s', $revNew) if $revNew;
### 번역의 편의를 위하여
        my $fromRevision = Ts('Revision %s', $revOld);
###
        $html = '<b>'
            . Ts('(Difference from %s', $fromRevision) . " " . Ts('to %s)', $currentRevision)
            . "</b>\n$links<br>" . &DiffToHTML($diffText);
    } else {
        if (($diffType != 2) &&
                ((!defined(&GetPageCache("old$cacheName"))) ||
                 (&GetPageCache("old$cacheName") < 1))) {
            $html = '<b>'
                . Ts('No diff available--this is the first %s revision.',
                $priorName) . "</b>\n$links<hr>";
        } else {
            $html = '<b>'
                    . Ts('Difference (from prior %s revision)', $priorName)
                    . "</b>\n$links<br>" . &DiffToHTML($diffText) . "<hr>\n";
        }
    }

### {{{ }}} 처리를 위해 추가. 임시 태그를 원래대로 복원
### diff 화면에서도 \\ 와 \ 처리를 해 주는 게 나을려나?
    $html =~ s/&__LT__;/&lt;/g;
    $html =~ s/&__GT__;/&gt;/g;
    $html =~ s/&__AMP__;/&amp;/g;

    return $html;
}

sub GetCacheDiff {
    my ($type) = @_;
    my ($diffText);

    $diffText = &GetPageCache("diff_default_$type");
    $diffText = &GetCacheDiff('minor')  if ($diffText eq "1");
    $diffText = &GetCacheDiff('major')  if ($diffText eq "2");
    return $diffText;
}

# Must be done after minor diff is set and OpenKeptRevisions called
sub GetKeptDiff {
    my ($newText, $oldRevision, $lock) = @_;
    my (%sect, %data, $oldText);

    $oldText = "";
    if (defined($KeptRevisions{$oldRevision})) {
        %sect = split(/$FS2/, $KeptRevisions{$oldRevision}, -1);
        %data = split(/$FS3/, $sect{'data'}, -1);
        $oldText = $data{'text'};
    }
    return ""  if ($oldText eq "");  # Old revision not found
    return &GetDiff($oldText, $newText, $lock);
}

sub GetDiff {
    my ($old, $new, $lock) = @_;
    my ($diff_out, $oldName, $newName);

    &CreateDir($TempDir);
    $oldName = "$TempDir/old_diff";
    $newName = "$TempDir/new_diff";
    if ($lock) {
        &RequestDiffLock() or return "";
        $oldName .= "_locked";
        $newName .= "_locked";
    }
    &WriteStringToFile($oldName, $old);
    &WriteStringToFile($newName, $new);
### diff 출력 개선
#   $diff_out = `diff $oldName $newName`;
    $diff_out = `diff -u $oldName $newName`;
    if ($diff_out eq "") {
        $diff_out = `diff $oldName $newName`;
    }

    &ReleaseDiffLock()  if ($lock);
    $diff_out =~ s/\\ No newline.*\n//g;   # Get rid of common complaint.
    # No need to unlink temp files--next diff will just overwrite.
    return $diff_out;
}

### diff 출력 개선
sub DiffToHTML {
    my ($html) = @_;
    if ($html =~ /^---/) {
        return &DiffToHTMLunified($html);
    } else {
        return &DiffToHTMLplain($html);
    }
}

### diff 출력 개선
# sub DiffToHTML {
sub DiffToHTMLplain {
###
    my ($html) = @_;
    my ($tChanged, $tRemoved, $tAdded);

    $tChanged = T('Changed:');
    $tRemoved = T('Removed:');
    $tAdded   = T('Added:');
    $html =~ s/\n--+//g;
    # Note: Need spaces before <br> to be different from diff section.
    $html =~ s/(^|\n)(\d+.*c.*)/$1 <br><strong>$tChanged $2<\/strong><br>/g;
    $html =~ s/(^|\n)(\d+.*d.*)/$1 <br><strong>$tRemoved $2<\/strong><br>/g;
    $html =~ s/(^|\n)(\d+.*a.*)/$1 <br><strong>$tAdded $2<\/strong><br>/g;
    $html =~ s/\n((<.*\n)+)/&ColorDiff($1,"ffffaf")/ge;
    $html =~ s/\n((>.*\n)+)/&ColorDiff($1,"cfffcf")/ge;
    return $html;
}

### diff 출력 개선
sub DiffToHTMLunified {
    my ($html) = @_;
    my (@lines, $result, $row, $td_class, $in_table, $output_exist);

    @lines = split("\n", $html);
    shift(@lines);
    shift(@lines);

    $output_exist = 0;
    $in_table = 0;
    foreach my $line (@lines) {
        $row = "";

        $line =~ s/&/&amp;/g;
        $line =~ s/</&lt;/g;
        $line =~ s/>/&gt;/g;

        if ($line =~ /^@@ (.*)@@.*$/) {
            if ($in_table) {
                $in_table = 0;
                $result .= "</TABLE>\n";
            }
            $result .= "\n<br><TABLE class='diff'>\n";
            $output_exist = 1;
            $in_table = 1;
            $row = $1;
            $td_class = "diffrange";
        } elsif ($line =~ /^ (.*)$/) {
            $row = $1;
            $row =~ s/ /&nbsp;/g;
            $td_class = "diff";
        } elsif ($line =~ /^-(.*)$/) {
            $row = $1;
            $row =~ s/ /&nbsp;/g;
            $td_class = "diffremove";
        } elsif ($line =~ /^\+(.*)$/) {
            $row = $1;
            $row =~ s/ /&nbsp;/g;
            $td_class = "diffadd";
        }
        $result .= "<TR><TD class='$td_class'>$row</TD></TR>\n";
    }
    $result .= "</TABLE>\n" if ($output_exist);
    return $result;
}

sub ColorDiff {
    my ($diff, $color) = @_;

    $diff =~ s/(^|\n)[<>]/$1/g;
    $diff = &QuoteHtml($diff);
    # Do some of the Wiki markup rules:
    %SaveUrl = ();
    %SaveNumUrl = ();
    $SaveUrlIndex = 0;
    $SaveNumUrlIndex = 0;
    $diff =~ s/$FS//g;
    $diff =  &CommonMarkup($diff, 0, 1);      # No images, all patterns
    $diff =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
    $diff =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore nested saved text
    $diff =~ s/\r?\n/<br>/g;
    return "<table width=\"95\%\" bgcolor=#$color><tr><td>\n" . $diff
                 . "</td></tr></table>\n";
}

# ==== Database (Page, Section, Text, Kept, User) functions ====
sub OpenNewPage {
    my ($id) = @_;

    %Page = ();
    $Page{'version'} = 3;      # Data format version
    $Page{'revision'} = 0;     # Number of edited times
    $Page{'tscreate'} = $Now;  # Set once at creation
    $Page{'ts'} = $Now;        # Updated every edit
}

sub OpenNewSection {
    my ($name, $data) = @_;

    %Section = ();
    $Section{'name'} = $name;
    $Section{'version'} = 1;      # Data format version
    $Section{'revision'} = 0;     # Number of edited times
    $Section{'tscreate'} = $Now;  # Set once at creation
    $Section{'ts'} = $Now;        # Updated every edit
    $Section{'ip'} = $ENV{REMOTE_ADDR};
    $Section{'host'} = '';        # Updated only for real edits (can be slow)
    $Section{'id'} = $UserID;
    $Section{'username'} = &GetParam("username", "");
    $Section{'data'} = $data;
    $Page{$name} = join($FS2, %Section);  # Replace with save?
}

sub OpenNewText {
    my ($name) = @_;  # Name of text (usually "default")
    %Text = ();
    # Later consider translation of new-page message? (per-user difference?)
    if ($NewText ne '') {
        $Text{'text'} = T($NewText);
    } else {
        $Text{'text'} = T('Describe the new page here.') . "\n";
    }

### template page
    if (($TemplatePage) && (&GetParam("action","") eq "edit")) {
        my $temp;
        $temp = &GetTemplatePageText(&GetParam("id",""));
        if ($temp ne "") {
            $Text{'text'} = $temp;
        }
    }
###
    $Text{'text'} .= "\n"  if (substr($Text{'text'}, -1, 1) ne "\n");
    $Text{'minor'} = 0;      # Default as major edit
    $Text{'newauthor'} = 1;  # Default as new author
    $Text{'summary'} = '';
    &OpenNewSection("text_$name", join($FS3, %Text));
}

sub GetPageFile {
    my ($id) = @_;

    return $PageDir . "/" . &GetPageDirectory($id) . "/$id.db";
}

sub OpenPage {
    my ($id) = @_;
    my ($fname, $data);

    if ($OpenPageName eq $id) {
        return;
    }
    %Section = ();
    %Text = ();
    $fname = &GetPageFile($id);
    if (-f $fname) {
        $data = &ReadFileOrDie($fname);
        %Page = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
    } else {
        &OpenNewPage($id);
    }
    if ($Page{'version'} != 3) {
        &UpdatePageVersion();
    }
    $OpenPageName = $id;
}

sub OpenSection {
    my ($name) = @_;

    if (!defined($Page{$name})) {
        &OpenNewSection($name, "");
    } else {
        %Section = split(/$FS2/, $Page{$name}, -1);
    }
}

sub OpenText {
    my ($name) = @_;

    if (!defined($Page{"text_$name"})) {
        &OpenNewText($name);
    } else {
        &OpenSection("text_$name");
        %Text = split(/$FS3/, $Section{'data'}, -1);
    }
}

sub OpenDefaultText {
    &OpenText('default');
}

# Called after OpenKeptRevisions
sub OpenKeptRevision {
    my ($revision) = @_;

    %Section = split(/$FS2/, $KeptRevisions{$revision}, -1);
    %Text = split(/$FS3/, $Section{'data'}, -1);
}

sub GetPageCache {
    my ($name) = @_;

    return $Page{"cache_$name"};
}

# Always call SavePage within a lock.
sub SavePage {
    my $file = &GetPageFile($OpenPageName);

    $Page{'revision'} += 1;    # Number of edited times
    $Page{'ts'} = $Now;        # Updated every edit
    &CreatePageDir($PageDir, $OpenPageName);
    &WriteStringToFile($file, join($FS1, %Page));
}

sub SaveSection {
    my ($name, $data) = @_;

    $Section{'revision'} += 1;   # Number of edited times
    $Section{'ts'} = $Now;       # Updated every edit
    $Section{'ip'} = $ENV{REMOTE_ADDR};
    $Section{'id'} = $UserID;
    $Section{'username'} = &GetParam("username", "");
    $Section{'data'} = $data;
    $Page{$name} = join($FS2, %Section);
}

sub SaveText {
    my ($name) = @_;

    &SaveSection("text_$name", join($FS3, %Text));
}

sub SaveDefaultText {
    &SaveText('default');
}

sub SetPageCache {
    my ($name, $data) = @_;

    $Page{"cache_$name"} = $data;
}

sub UpdatePageVersion {
    &ReportError(T('Bad page version (or corrupt page).'));
}

sub KeepFileName {
    return $KeepDir . "/" . &GetPageDirectory($OpenPageName)
                 . "/$OpenPageName.kp";
}

sub SaveKeepSection {
    my $file = &KeepFileName();
    my $data;

### 페이지 삭제 시에 keep 화일은 보존해 둠
#   return  if ($Section{'revision'} < 1);  # Don't keep "empty" revision
    if ($Section{'revision'} < 1) {
        if (-f $file) {
            unlink($file) || die "error while removing obsolete keep file [$file]";
        }
        return;
    }

    $Section{'keepts'} = $Now;
    $data = $FS1 . join($FS2, %Section);
    &CreatePageDir($KeepDir, $OpenPageName);
    &AppendStringToFile($file, $data);
}

sub ExpireKeepFile {
    my ($fname, $data, @kplist, %tempSection, $expirets);
    my ($anyExpire, $anyKeep, $expire, %keepFlag, $sectName, $sectRev);
    my ($oldMajor, $oldAuthor);

    $fname = &KeepFileName();
    return  if (!(-f $fname));
    $data = &ReadFileOrDie($fname);
    @kplist = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
    return  if (length(@kplist) < 1);  # Also empty
    shift(@kplist)  if ($kplist[0] eq "");  # First can be empty
    return  if (length(@kplist) < 1);  # Also empty
    %tempSection = split(/$FS2/, $kplist[0], -1);
    if (!defined($tempSection{'keepts'})) {
#   die("Bad keep file." . join("|", %tempSection));
        return;
    }
    $expirets = $Now - ($KeepDays * 24 * 60 * 60);
    return  if ($tempSection{'keepts'} >= $expirets);  # Nothing old enough

    $anyExpire = 0;
    $anyKeep   = 0;
    %keepFlag  = ();
    $oldMajor  = &GetPageCache('oldmajor');
    $oldAuthor = &GetPageCache('oldauthor');
    foreach (reverse @kplist) {
        %tempSection = split(/$FS2/, $_, -1);
        $sectName = $tempSection{'name'};
        $sectRev = $tempSection{'revision'};
        $expire = 0;
        if ($sectName eq "text_default") {
            if (($KeepMajor  && ($sectRev == $oldMajor)) ||
                    ($KeepAuthor && ($sectRev == $oldAuthor))) {
                $expire = 0;
            } elsif ($tempSection{'keepts'} < $expirets) {
                $expire = 1;
            }
        } else {
            if ($tempSection{'keepts'} < $expirets) {
                $expire = 1;
            }
        }
        if (!$expire) {
            $keepFlag{$sectRev . "," . $sectName} = 1;
            $anyKeep = 1;
        } else {
            $anyExpire = 1;
        }
    }

    if (!$anyKeep) {  # Empty, so remove file
        unlink($fname);
        return;
    }
    return  if (!$anyExpire);  # No sections expired
    open my $out, '>', $fname or die Ts('cant write %s', $fname).": $!";
    foreach (@kplist) {
        %tempSection = split(/$FS2/, $_, -1);
        $sectName = $tempSection{'name'};
        $sectRev = $tempSection{'revision'};
        if ($keepFlag{$sectRev . "," . $sectName}) {
            print {$out} $FS1, $_;
        }
    }
    close $out;
}

sub OpenKeptList {
    my ($fname, $data);

    @KeptList = ();
    $fname = &KeepFileName();
    return  if (!(-f $fname));
    $data = &ReadFileOrDie($fname);
    @KeptList = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
}

sub OpenKeptRevisions {
    my ($name) = @_;  # Name of section
    my ($fname, $data, %tempSection);

    %KeptRevisions = ();
    &OpenKeptList();
### 최근변경내역에 북마크 기능 도입
    %RevisionTs = ();

    foreach (@KeptList) {
        %tempSection = split(/$FS2/, $_, -1);
        next  if ($tempSection{'name'} ne $name);
        $KeptRevisions{$tempSection{'revision'}} = $_;
### 최근변경내역에 북마크 기능 도입
        $RevisionTs{$tempSection{'revision'}} = $tempSection{'ts'};

    }
}

sub LoadUserData {
    my ($data, $status);

    %UserData = ();
    ($status, $data) = &ReadFile(&UserDataFilename($UserID));
    if (!$status) {
        $UserID = 112;  # Could not open file.  Later warning message?
        return;
    }
    %UserData = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
### 관심 페이지
    %UserInterest = split(/$FS2/, $UserData{'interest'}, -1);

# rename cookie 'id' to 'userid'
    if ( not exists $UserData{'userid'} and exists $UserData{'id'} ) {
        $UserData{'userid'} = $UserData{'id'};
        delete $UserData{'id'};
        SaveUserData();
    }
}

sub UserDataFilename {
    my ($id) = @_;

    return $UserDir . "/" . "$id.db";
}

# ==== Misc. functions ====
sub ReportError {
    my ($errmsg) = @_;

    print $q->header(-charset=>"$HttpCharset"), "<H2>", $errmsg, "</H2>", $q->end_html;
}

sub ValidId {
    my ($id) = @_;

    if (length($id) > 120) {
        return Ts('Page name is too long: %s', $id);
    }
    if ($id =~ m| |) {
        return Ts('Page name may not contain space characters: %s', $id);
    }
    if ($UseSubpage) {
        if ($id =~ m|.*/.*/|) {
            return Ts('Too many / characters in page %s', $id);
        }
        if ($id =~ /^\//) {
            return Ts('Invalid Page %s (subpage without main page)', $id);
        }
        if ($id =~ /\/$/) {
            return Ts('Invalid Page %s (missing subpage name)', $id);
        }
    }
    if ($FreeLinks) {
        $id =~ s/ /_/g;
        if (!$UseSubpage) {
            if ($id =~ /\//) {
                return Ts('Invalid Page %s (/ not allowed)', $id);
            }
        }
        if (!($id =~ m|^$FreeLinkPattern$|)) {
            return Ts('Invalid Page %s', $id);
        }
        if ($id =~ m|\.db$|) {
            return Ts('Invalid Page %s (must not end with .db)', $id);
        }
        if ($id =~ m|\.lck$|) {
            return Ts('Invalid Page %s (must not end with .lck)', $id);
        }
        return "";
    } else {
        if (!($id =~ /^$LinkPattern$/)) {
            return Ts('Invalid Page %s', $id);
        }
    }
    return "";
}

sub ValidIdOrDie {
    my ($id) = @_;
    my $error;

    $error = &ValidId($id);
    if ($error ne "") {
        &ReportError($error);
        return 0;
    }
    return 1;
}

sub UserCanEdit {
    my ($id, $deepCheck) = @_;

    return 1  if (&UserIsAdmin());
### hide page
    if (($id ne "") && (&PageIsHidden($id))) {
        return 0;
    }

    # Optimized for the "everyone can edit" case (don't check passwords)
    if (($id ne "") && (-f &GetLockedPageFile($id))) {
        return 1  if (&UserIsAdmin());  # Requires more privledges
        # Later option for editor-level to edit these pages?
        return 0;
    }
    if (!$EditAllowed) {
        return 1  if (&UserIsEditor());
        return 0;
    }
    if (-f "$DataDir/noedit") {
        return 1  if (&UserIsEditor());
        return 0;
    }
    if ($deepCheck) {   # Deeper but slower checks (not every page)
        return 0  if (&UserIsBanned());
        return 1  if (&UserIsEditor());
    }
    return 1;
}

sub UserIsBanned {
    my ($host, $ip, $data, $status);

    ($status, $data) = &ReadFile("$DataDir/banlist");
    return 0  if (!$status);  # No file exists, so no ban
    $data =~ s/\r//g;
    $ip = $ENV{'REMOTE_ADDR'};
    $host = &GetRemoteHost(0);
    foreach (split(/\n/, $data)) {
        next  if ((/^\s*$/) || (/^#/));  # Skip empty, spaces, or comments
        return 1  if ($ip   =~ /$_/i);
        return 1  if ($host =~ /$_/i);
    }
    return 0;
}

sub UserIsAdmin {
    my (@pwlist, $userPassword);

    return 0  if ($AdminPass eq "");
    $userPassword = &GetParam("adminpw", "");
    return 0  if ($userPassword eq "");
    foreach (split(/\s+/, $AdminPass)) {
        next  if ($_ eq "");
### 암호를 암호화해서 저장
### from Bab2's patch
#       return 1  if ($userPassword eq $_);
        return 1  if (crypt($_, $userPassword) eq $userPassword);
    }
    return 0;
}

sub UserIsEditor {
    my (@pwlist, $userPassword);

    return 1  if (&UserIsAdmin());             # Admin includes editor
    return 0  if ($EditPass eq "");
    return 1  if (&LoginUser() and ($EditPass eq "LOGIN"));
    $userPassword = &GetParam("adminpw", "");  # Used for both
    return 0  if ($userPassword eq "");
    foreach (split(/\s+/, $EditPass)) {
        next  if ($_ eq "");
### 암호를 암호화해서 저장
### from Bab2's patch
#       return 1  if ($userPassword eq $_);
        return 1  if (crypt($_, $userPassword) eq $userPassword);
    }
    return 0;
}

sub GetLockedPageFile {
    my ($id) = @_;

    return $PageDir . "/" . &GetPageDirectory($id) . "/$id.lck";
}

sub RequestLockDir {
    my ($name, $tries, $wait, $errorDie) = @_;
    my ($lockName, $n);

    &CreateDir($TempDir);
    $lockName = $LockDir . $name;
    $n = 0;
    while (mkdir($lockName, 0555) == 0) {
        if ($! != 17) {
            die(Ts('can not make %s', $LockDir) . ": $!\n")  if $errorDie;
            return 0;
        }
        return 0  if ($n++ >= $tries);
        sleep($wait);
    }
    return 1;
}

sub ReleaseLockDir {
    my ($name) = @_;
    rmdir($LockDir . $name);
}

sub RequestLock {
    # 10 tries, 3 second wait, die on error
    return &RequestLockDir("main", 10, 3, 1);
}

sub ReleaseLock {
    &ReleaseLockDir('main');
}

sub ForceReleaseLock {
    my ($name) = @_;
    my $forced;

    # First try to obtain lock (in case of normal edit lock)
    # 5 tries, 3 second wait, do not die on error
    $forced = !&RequestLockDir($name, 5, 3, 0);
    &ReleaseLockDir($name);  # Release the lock, even if we didn't get it.
    return $forced;
}

sub RequestCacheLock {
    # 4 tries, 2 second wait, do not die on error
    return &RequestLockDir('cache', 4, 2, 0);
}

sub ReleaseCacheLock {
    &ReleaseLockDir('cache');
}

sub RequestDiffLock {
    # 4 tries, 2 second wait, do not die on error
    return &RequestLockDir('diff', 4, 2, 0);
}

sub ReleaseDiffLock {
    &ReleaseLockDir('diff');
}

# Index lock is not very important--just return error if not available
sub RequestIndexLock {
    # 1 try, 2 second wait, do not die on error
    return &RequestLockDir('index', 1, 2, 0);
}

sub ReleaseIndexLock {
    &ReleaseLockDir('index');
}

sub ReadFile {
    my ($fileName) = @_;
    my ($data);
    local $/ = undef;   # Read complete files

    if ( open(my $in, '<', $fileName)) {
        $data = <$in>;
        close $in;
        return (1, $data);
    }
    return (0, "");
}

sub ReadFileOrDie {
    my ($fileName) = @_;
    my ($status, $data);

    ($status, $data) = &ReadFile($fileName);
    if (!$status) {
        die(Ts('Can not open %s', $fileName) . ": $!");
    }
    return $data;
}

sub WriteStringToFile {
    my ($file, $string) = @_;

    open(my $out, '>', $file) or die(Ts('cant write %s', $file) . ": $!");
    print {$out} $string;
    close $out;
}

sub AppendStringToFile {
    my ($file, $string) = @_;

    open(my $out, '>>', $file) or die(Ts('cant write %s', $file) . ": $!");
    print {$out} $string;
    close $out;
}

sub CreateDir {
    my ($newdir) = @_;

### 디렉토리 생성에 실패할 경우 에러 출력
#   mkdir($newdir, 0775)  if (!(-d $newdir));
    if (!(-d $newdir)) {
        mkdir($newdir, 0775) or die(Ts('cant create directory %s', $newdir) . ": $!");
    }
###
}

sub CreatePageDir {
    my ($dir, $id) = @_;
    my $subdir;

    &CreateDir($dir);  # Make sure main page exists
    $subdir = $dir . "/" . &GetPageDirectory($id);
    &CreateDir($subdir);
    if ($id =~ m|([^/]+)/|) {
        $subdir = $subdir . "/" . $1;
        &CreateDir($subdir);
    }
}

sub UpdateHtmlCache {
    my ($id, $html) = @_;
    my $idFile;

    $idFile = &GetHtmlCacheFile($id);
    &CreatePageDir($HtmlDir, $id);
    if (&RequestCacheLock()) {
        &WriteStringToFile($idFile, $html);
        &ReleaseCacheLock();
    }
}

sub GenerateAllPagesList {
    my (@pages, @dirs, @pageFiles, @subpageFiles);

    @pages = ();
    if ($FastGlob) {
        # The following was inspired by the FastGlob code by Marc W. Mengel.
        # Thanks to Bob Showalter for pointing out the improvement.
        opendir(PAGELIST, $PageDir);
        @dirs = readdir(PAGELIST);
        closedir(PAGELIST);
        @dirs = sort(@dirs);
        foreach my $dir (@dirs) {
            next  if (($dir eq '.') || ($dir eq '..'));
            opendir(PAGELIST, "$PageDir/$dir");
            @pageFiles = readdir(PAGELIST);
            closedir(PAGELIST);
            foreach my $id (@pageFiles) {
                next  if (($id eq '.') || ($id eq '..'));
                if (substr($id, -3) eq '.db') {
                    push(@pages, substr($id, 0, -3));
                } elsif (substr($id, -4) ne '.lck') {
                    opendir(PAGELIST, "$PageDir/$dir/$id");
                    @subpageFiles = readdir(PAGELIST);
                    closedir(PAGELIST);
                    foreach my $subId (@subpageFiles) {
                        if (substr($subId, -3) eq '.db') {
                            push(@pages, "$id/" . substr($subId, 0, -3));
                        }
                    }
                }
            }
        }
    } else {
        # Old slow/compatible method.
        @dirs = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z other);
        foreach my $dir (@dirs) {
            if (-e "$PageDir/$dir") {  # Thanks to Tim Holt
                while (glob("$PageDir/$dir/*.db $PageDir/$dir/*/*.db")) {
                    s|^$PageDir/||;
                    m|^[^/]+/(\S*).db|;
                    push(@pages, $1);
                }
            }
        }
    }
    my @sorted_list = sort @pages;
    return @sorted_list;
}

sub AllPagesList {
    my ($rawIndex, $refresh, $status);

    if (!$UseIndex) {
### hide page by gypark
#       return &GenerateAllPagesList();
        return &GetNotHiddenPages(&GenerateAllPagesList());
###
    }
    $refresh = &GetParam("refresh", 0);
    if ($IndexInit && !$refresh) {
        # Note for mod_perl: $IndexInit is reset for each query
        # Eventually consider some timestamp-solution to keep cache?
### hide page by gypark
#       return @IndexList;
        return &GetNotHiddenPages(@IndexList);
###
    }
    if ((!$refresh) && (-f $IndexFile)) {
        ($status, $rawIndex) = &ReadFile($IndexFile);
        if ($status) {
            %IndexHash = split(/\s+/, $rawIndex);
            @IndexList = sort(keys %IndexHash);
            $IndexInit = 1;
### hide page by gypark
#           return @IndexList;
            return &GetNotHiddenPages(@IndexList);
###
        }
        # If open fails just refresh the index
    }
    @IndexList = ();
    %IndexHash = ();
    @IndexList = &GenerateAllPagesList();
    foreach (@IndexList) {
        $IndexHash{$_} = 1;
    }
    $IndexInit = 1;  # Initialized for this run of the script
    # Try to write out the list for future runs
    &RequestIndexLock() or return @IndexList;
    &WriteStringToFile($IndexFile, join(" ", %IndexHash));
    &ReleaseIndexLock();
### hide page by gypark
#   return @IndexList;
    return &GetNotHiddenPages(@IndexList);
###
}

sub CalcDay {
    my ($ts) = @_;

    $ts += $TimeZoneOffset;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($ts);

    return ($year + 1900) . "-" . ($mon+1) . "-" . $mday; # luke added

    return ("January", "February", "March", "April", "May", "June",
                    "July", "August", "September", "October", "November",
                    "December")[$mon]. " " . $mday . ", " . ($year+1900);
}

sub CalcDayNow {
    return CalcDay($Now);
}

sub CalcTime {
    my ($ts) = @_;
    my ($ampm, $mytz);

    $ts += $TimeZoneOffset;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($ts);

    $mytz = "";
    if (($TimeZoneOffset == 0) && ($ScriptTZ ne "")) {
        $mytz = " " . $ScriptTZ;
    }
    $ampm = "";
    if ($UseAmPm) {
        $ampm = " am";
        if ($hour > 11) {
            $ampm = " pm";
            $hour = $hour - 12;
        }
        $hour = 12   if ($hour == 0);
    }
    $min = "0" . $min   if ($min<10);
    return $hour . ":" . $min . $ampm . $mytz;
}


sub TimeToText {
    my ($t) = @_;

    return &CalcDay($t) . " " . &CalcTime($t);
}

sub GetParam {
    my ($name, $default) = @_;
    my $result;

    $result = $q->param($name);
### POST 로 넘어올 경우의 데이타 처리
    if (!defined($result)) {
        $result = $q->url_param($name);
    }
    if (!defined($result)) {
        if (defined($UserData{$name})) {
            $result = $UserData{$name};
        } else {
            $result = $default;
        }
    }
    return $result;
}

sub GetHiddenValue {
    my ($name, $value) = @_;

    $q->param($name, $value);
    return $q->hidden($name);
}

sub GetRemoteHost {
    my ($doMask) = @_;
    my ($rhost, $iaddr);

    $rhost = $ENV{REMOTE_HOST};
    if ($UseLookup && ($rhost eq "")) {
        # Catch errors (including bad input) without aborting the script
        eval 'use Socket; $iaddr = inet_aton($ENV{REMOTE_ADDR});'
                 . '$rhost = gethostbyaddr($iaddr, AF_INET)';
    }
    if ($rhost eq "") {
        $rhost = $ENV{REMOTE_ADDR};
        $rhost =~ s/\d+$/xxx/  if ($doMask);      # Be somewhat anonymous
    }
    return $rhost;
}

sub FreeToNormal {
    my ($id) = @_;

    $id =~ s/ /_/g;
    $id = ucfirst($id);
    if (index($id, '_') > -1) {  # Quick check for any space/underscores
        $id =~ s/__+/_/g;
        $id =~ s/^_//;
        $id =~ s/_$//;
        if ($UseSubpage) {
            $id =~ s|_/|/|g;
            $id =~ s|/_|/|g;
        }
    }
    if ($FreeUpper) {
        # Note that letters after ' are *not* capitalized
        if ($id =~ m|[-_.,\(\)/][a-z]|) {    # Quick check for non-canonical case
            $id =~ s|([-_.,\(\)/])([a-z])|$1 . uc($2)|ge;
        }
    }
    return $id;
}
#END_OF_BROWSE_CODE

# == Page-editing and other special-action code ========================
# luke added

sub DoPreview {
    $ClickEdit = 0;
    print &GetHttpHeader();
    print &GetHtmlHeader(T('Preview') . " : $SiteName", "Preview");
### 미리보기에서 <mysign> 등의 preprocessor 사용
#   print &WikiToHTML(&GetParam("text", undef));

    my ($textPreview) = &GetParam("text", undef);
    $MainPage = &GetParam("id", ".");
    $MainPage =~ s|/.*||;
    print &WikiToHTML(&ProcessPostMacro($textPreview));
}

### 도움말 별도의 화일로 분리
sub DoHelp {
    my $idx = &GetParam("index", "");

    require mod_edithelp;
    use vars  qw(@HelpItem @HelpText);
    my $title = T("$HelpItem[$idx]");
    my $text;

    $text = "== $title ==\n";
    $text .= $HelpText[$idx];

    $ClickEdit = 0;
    $UseEmoticon = 1;
    print &GetHttpHeader();
    print &GetHtmlHeader(T('Editing Help :'). " $title", "$title");
    print &WikiToHTML($text);
}

sub DoOtherRequest {
    my ($id, $action, $text, $search);

    $ClickEdit = 0;                                 # luke added
    $UseShortcutPage = 0;       # 단축키
    $action = &GetParam("action", "");
    $id = &GetParam("id", "");
    if ($action ne "") {
        $action = lc($action);
### action 모듈화
        my $action_file = "";
        my ($MyActionDir, $ActionDir) = ("./myaction/", "./action/");
        if (-f "$MyActionDir/$action.pl") {
            $action_file = "$MyActionDir/$action.pl";
        } elsif (-f "$ActionDir/$action.pl") {
            $action_file = "$ActionDir/$action.pl";
        }

        if ($action_file ne "") {
            my $loadaction = eval "require '$action_file'";

            if (not $loadaction) {      # action 로드 실패
                $UseShortcut = 0;
                &ReportError(Ts('Fail to load action: %s', $action));
                return;
            }

            my $func = "action_$action";
            &{\&$func}();
            return;
        }
###
        if ($action eq "edit") {
            $UseShortcut = 0;   # 단축키
            &DoEdit($id, 0, 0, "", 0)  if &ValidIdOrDie($id);
        } elsif ($action eq "unlock") {
            &DoUnlock();
        } elsif ($action eq "index") {
            &DoIndex();
### titleindex action 추가
### from Bab2's patch
        } elsif ($action eq "titleindex") {
            $UseShortcut = 0;
            &DoTitleIndex();
###
        } elsif ($action eq "help") {               # luke added
            $UseShortcut = 0;
            &DoHelp();                              # luke added
        } elsif ($action eq "preview") {            # luke added
            $UseShortcut = 0;
            &DoPreview();                           # luke added
        } elsif ($action eq "links") {
            &DoLinks();
        } elsif ($action eq "maintain") {
            &DoMaintain();
        } elsif ($action eq "pagelock") {
            &DoPageLock();
        } elsif ($action eq "editlock") {
            &DoEditLock();
        } elsif ($action eq "editprefs") {
            &DoEditPrefs();
        } elsif ($action eq "editbanned") {
            &DoEditBanned();
        } elsif ($action eq "editlinks") {
            &DoEditLinks();
        } elsif ($action eq "login") {
            &DoEnterLogin();
        } elsif ($action eq "logout") {
            &DoLogout();
        } elsif ($action eq "newlogin") {
            $UserID = "";
            &DoEditPrefs();  # Also creates new ID
        } elsif ($action eq "version") {
            &DoShowVersion();
### 최근변경내역에 북마크 기능 도입
        } elsif ($action eq "bookmark") {
            &DoBookmark();
### file upload
        } elsif ($action eq "upload") {
            $UseShortcut = 0;
            &DoUpload();
### oekaki
        } elsif ($action eq "oekaki") {
            $UseShortcut = 0;
            &DoOekaki();
### 관심 페이지
        } elsif ($action eq "interest") {
            &DoInterest();
### UploadedFiles 매크로
        } elsif ($action eq "deleteuploadedfiles") {
            &DoDeleteUploadedFiles();
### hide page by gypark
        } elsif ($action eq "pagehide") {
            &DoPageHide();
### rss from usemod1.0
        } elsif ($action eq "rss") {
            $UseShortcut = 0;
            &DoRss();
###
        } else {
            # Later improve error reporting
            $UseShortcut = 0;
            &ReportError(Ts('Invalid action parameter %s', $action));
        }
        return;
    }
    if (&GetParam("edit_prefs", 0)) {
        &DoUpdatePrefs();
        return;
    }
    if (&GetParam("edit_ban", 0)) {
        &DoUpdateBanned();
        return;
    }
    if (&GetParam("enter_login", 0)) {
        &DoLogin();
        return;
    }
    if (&GetParam("edit_links", 0)) {
        &DoUpdateLinks();
        return;
    }
    $search = &GetParam("search", "");
    if (($search ne "") || (&GetParam("dosearch", "") ne "")) {
        &DoSearch($search);
        return;
    }
    # Handle posted pages
    if (&GetParam("oldtime", "") ne "") {
        $id = &GetParam("title", "");
        $UseShortcut = 0;
        &DoPost()  if &ValidIdOrDie($id);
        return;
    }
    # Later improve error message
    &ReportError(T('Invalid URL.'));
}

sub DoEdit {
    my ($id, $isConflict, $oldTime, $newText, $preview) = @_;
    my ($header, $editRows, $editCols, $userName, $revision, $oldText);
    my ($summary, $isEdit, $pageTime);

### view action 추가
    my $canEdit = &UserCanEdit($id,1);

    # Consider sending a new user-ID cookie if user does not have one
    &OpenPage($id);
    &OpenDefaultText();
    $pageTime = $Section{'ts'};
    $header = Ts('Editing %s', $id);
### view action 추가
    $header = Ts('Viewing %s', $id) if (!$canEdit);

    # Old revision handling
    $revision = &GetParam('revision', '');
    $revision =~ s/\D//g;  # Remove non-numeric chars
    if ($revision ne '') {
        &OpenKeptRevisions('text_default');
        if (!defined($KeptRevisions{$revision})) {
            $revision = '';
            # Later look for better solution, like error message?
        } else {
            &OpenKeptRevision($revision);
            $header = Ts('Editing revision %s of', $revision) . " $id";
### view action 추가
            $header = Ts('Viewing revision %s of', $revision) . " $id" if (!$canEdit);
###
        }
    }
    $oldText = $Text{'text'};
    if ($preview && !$isConflict) {
        $oldText = $newText;
    }
### 섹션 단위 편집 - 편집할 때
    my $section = &GetParam('section', 0);
    if ($section >= 1) {
        my $temp_text;
        my (@h_depth, @h_pos);
        my $num = 0;

        $temp_text = $oldText;

        # {{{ }}} 등 헤드라인이 올 수 없는 것들을 먼저 제외
        %SaveUrl = ();
        $SaveUrlIndex = 0;
        $temp_text = &store_raw_codes($temp_text);

        # 남은 텍스트에서 헤드라인들의 목록을 뽑는다
        while ($temp_text =~ /(^[ \t]*(\=+)\s+[^\n]+\s+\=+\s*$)/gm) {
            $num++;
            $h_pos[$num] = pos($temp_text) - length($1);        # 각 섹션의 시작 포지션
            $h_depth[$num] = length($2);

            # summary 를 해당 섹션 제목으로
            if ($num == $section) {
                my $h_str = $1;
                $h_str =~ /^[ \t]*\=+\s+(#\s+)?([^\n]+)\s+\=+\s*$/;
                $h_str = $2;
                $h_str =~ s/"/&quot;/g;
                $q->param("summary", "$h_str - ".&GetParam("summary", ""));
            }
        }
        $num++;
        $h_pos[$num] = length($temp_text);
        $h_depth[$num] = 1;

        # 같은 depth 의 다음 헤드라인을 찾음
        my $next;
        for ($next = $section+1; ($next <= $#h_depth) && ($h_depth[$section] < $h_depth[$next]); $next++) {}

        # 수정할 섹션의 텍스트만 추출
        my $offset = $h_pos[$section];
        my $length = $h_pos[$next] - $offset;
        $temp_text = substr($temp_text, $offset, $length);

        # 제외했던 내용 복원
        $temp_text = &RestoreSavedText($temp_text);
        %SaveUrl = ();
        $SaveUrlIndex = 0;

        # $oldText 바꿔치기
        $oldText = $temp_text;
        $header .= " ". &T('(section)');
    }
#####
    $editRows = &GetParam("editrows", 20);
    $editCols = &GetParam("editcols", 65);
    print &GetHeader('', &QuoteHtml($header), '');
### hide page
    if (&PageIsHidden($id)) {
        print Ts('%s is a hidden page', $id);
        print &GetCommonFooter();
        return;
    }

### view action 추가
    if (!$canEdit) {
        if (&UserIsBanned()) {
            print T('Editing not allowed: user, ip, or network is blocked.');
            print "<p>";
            print T('Contact the wiki administrator for more information.');
        } else {
            print Ts('Editing not allowed: %s is read-only.', $id);
        }
        print "<br>\n";
    }

### view action 추가
#   if ($revision ne '') {
    if ($canEdit && ($revision ne '')) {
###
        print "\n<b>"
                . Ts('Editing old revision %s.', $revision) . "  "
        . T('Saving this page will replace the latest revision with this text.')
                . '</b><br>'
    }

### view action 추가
#   if ($isConflict) {
    if ($canEdit && $isConflict) {
###
        $editRows -= 10  if ($editRows > 19);
        print "\n<H1>" . T('Edit Conflict!') . "</H1>\n";
        if ($isConflict>1) {
            # The main purpose of a new warning is to display more text
            # and move the save button down from its old location.
            print "\n<H2>" . T('(This is a new conflict)') . "</H2>\n";
        }
        print "<p><strong>",
                    T('Someone saved this page after you started editing.'), " ",
                    T('The top textbox contains the saved text.'), " ",
                    T('Only the text in the top textbox will be saved.'),
                    "</strong><br>\n",
                    T('Scroll down to see your edited text.'), "<br>\n";
        print T('Last save time:'), ' ', &TimeToText($oldTime),
                    " (", T('Current time is:'), ' ', &TimeToText($Now), ")<br>\n";
    }

    # luke added

#   w.document.getElementById('form_edit').elements['text'].value = window.document.getElementById('form_edit').elements['text'].value;
#   w.document.getElementById('form_edit').submit();
    print qq|
<script language="javascript" type="text/javascript">
<!--
function preview()
{
    var w = window.open("", "Preview", "width=640,height=480,resizable=1,statusbar=1,scrollbars=1");
    w.focus();

    var body = '<html><head><title>Wiki Preview</title><meta http-equiv="Content-Type" content="text/html; charset=$HttpCharset"></head>';
    body += '<body><form method="post" action="$ScriptName" accept-charset="$HttpCharset" name="form_edit">';
    body += '<input type="hidden" name="id" value="$id">';
    body += '<input type="hidden" name="action" value="preview"><input type=hidden name="text"></form></body></html>';

    w.document.open();
    w.document.charset = '$HttpCharset';
    w.document.write(body);
    w.document.close();
    w.document.form_edit.text.value = window.document.form_edit.text.value;
    w.document.form_edit.submit();
}
function help(s)
{
    var w = window.open(s, "Help", "width=500,height=400, resizable=1, scrollbars=1");
    closeok = false;
    w.focus();
}
//-->
</script>
|;

###############
### added by gypark
### file upload
    print qq|
<script language="javascript" type="text/javascript">
<!--
function upload()
{
    var w = window.open("$ScriptName${\(&ScriptLinkChar())}action=upload", "upload", "width=640,height=250,resizable=1,statusbar=1,scrollbars=1");
    w.focus();
}
//-->
</script>
|;

### view action 추가
    if ($canEdit) {
        print T('Editing Help :') . "&nbsp;";
### 도움말 별도의 화일로 분리

#   print &HelpLink(1, T('Make Page')) . " | ";
#   ...
#   print &HelpLink(5, T('Emoticon')) . "<br>\n";
        use vars qw(@HelpItem);
        require mod_edithelp;

        foreach (0 .. $#HelpItem) {
            print &HelpLink($_, T("$HelpItem[$_]"));
            print " | " if ($_ ne $#HelpItem);
        }
        print "<br>\n";
    }

### 편집모드에 들어갔을때 포커스가 편집창에 있도록 한다
#   print &GetFormStart();
    print $q->start_form(-method=>"POST", -action=>"$ScriptName", -enctype=>"application/x-www-form-urlencoded",
            -name=>"form_edit", -onSubmit=>"closeok=true; return true;");
### view action 추가
    if ($canEdit) {
        print &GetHiddenValue("title", $id), "\n",
                    &GetHiddenValue("oldtime", $pageTime), "\n",
                    &GetHiddenValue("oldconflict", $isConflict), "\n";
        if ($revision ne "") {
            print &GetHiddenValue("revision", $revision), "\n";
        }
# ECode
        my $ecode = &simple_crypt(length($id).substr(&CalcDay($Now),5));
        print &GetHiddenValue("ecode","$ecode")."\n";
# spambot trap
        my $spambot_trap =
            "<DIV style='display:none;'>"
            . "Homepage: "
            . $q->textfield(-name=>"homepage",
                            -class=>"comments",
                            -size=>"10",
                            -maxlength=>"80",
                            -default=>"")
            . "</DIV>";
        print $spambot_trap;

### 섹션 단위 편집
        if ($section >= 1) {
            print &GetHiddenValue("section", $section)."\n";
        }
#####
        print &GetTextArea('text', $oldText, $editRows, $editCols);
        print qq|<div data-url="$ScriptName" id="autocomplete-box" style="display:none;"></div>|;

        $summary = &GetParam("summary", "*");
        print "<p>", T('Summary:') . " ",
                    $q->textfield(-name=>'summary',
                                    -default=>$summary, -override=>1,
                                    -size=>60, -maxlength=>200);

        if (&GetParam("recent_edit") eq "on") {
            print "<br>", $q->checkbox(-name=>'recent_edit', -checked=>1,
                                 -label=>T('This change is a minor edit.'));
        } else {
            print "<br>", $q->checkbox(-name=>'recent_edit',
                                 -label=>T('This change is a minor edit.'));
        }

        # Twitter
        if ( UserIsAdmin() and $TwitterID ) {
            print "<br>", $q->checkbox(-name=>'twitter_edit', -checked=>0, -label=>T('Twitter')."($TwitterID)"), "\n";
        }

        if ($EmailNotify) {
            print "&nbsp;&nbsp;&nbsp;" .
                     $q->checkbox(-name=> 'do_email_notify',
                -label=>Ts('Send email notification that %s has been changed.', $id));
        }
        print "<br>";
        if ($EditNote ne '') {
            print T($EditNote) . '<br>';  # Allow translation
        }
### 단축키
#       print $q->submit(-name=>'Save', -value=>T('Save')), "\n";
        print $q->submit(-accesskey=>'r', -name=>'Save', -value=>T('Save')." [alt+r]"), "\n";
        $userName = &GetParam("username", "");
        if ($userName ne "") {
            print ' (', T('Your user name is'), ' ',
                        &GetPageLink($userName) . ') ';
        } else {
            print ' (', Ts('Visit %s to set your user name.', &GetPrefsLink()), ') ';
        }
### 미리보기 버튼에 번역함수 적용
        print q(<input accesskey="p" type="button" name="prev1" value=").
            T('Popup Preview')." [alt+p]" .
            q(" onclick="javascript:preview();">); # luke added

### file upload
        print " ".q(<input accesskey="u" type="button" name="prev1" value=").
            T('Upload File')." [alt+u]" .
            q(" onclick="javascript:upload();">);
        if ($isConflict) {
            print "\n<br><hr noshade size=1><p><strong>", T('This is the text you submitted:'),
                    "</strong><p>",
                    &GetTextArea('newtext', $newText, $editRows, $editCols),
                    "<p>\n";
### conflict 발생시 양쪽의 입력을 비교
            my $conflictdiff = &GetDiff($oldText, $newText, 1);
            $conflictdiff = T('No diff available.') if ($conflictdiff eq "");
            print "\n<br><hr noshade size=1><p><strong>",
                T('This is the difference between the saved text and your text:'),
                "</strong><p>",
                &DiffToHTML($conflictdiff),
                "<p>\n";
        }
### view action 추가
    } else {
        print $q->textarea(-class=>'view', -accesskey=>'i', -name=>'text',
                -default=>$oldText, -rows=>$editRows, -columns=>$editCols,
                -override=>1, -style=>'width:100%', -wrap=>'virtual',
                -readonly=>'true');
    }
###
    print "<hr class='footer'>\n";
    if ($preview) {
        print "<h2>", T('Preview:'), "</h2>\n";
        if ($isConflict) {
            print "<b>",
                        T('NOTE: This preview shows the revision of the other author.'),
                        "</b><hr noshade size=1>\n";
        }
        $MainPage = $id;
        $MainPage =~ s|/.*||;  # Only the main page name (remove subpage)
        print &WikiToHTML($oldText) . "<hr noshade size=1>\n";
        print "<h2>", T('Preview only, not yet saved'), "</h2>\n";
    }
### 편집 화면 아래에 편집을 취소하고 원래 페이지로 돌아가는 링크 추가
    print Ts('Return to %s' , &GetPageLink($id)) . " | ";

    print &GetHistoryLink($id, T('View other revisions')) . "<br>\n";
    # print &GetGotoBar($id);
    print $q->end_form;
### 편집모드에 들어갔을때 포커스가 편집창에 있도록 한다
    print "\n<script language=\"JavaScript\" type=\"text/javascript\">\n"
        . "<!--\n"
        . "previous_text = document.form_edit.text.value;\n"
        . (($isConflict)?"conflict = true;\n":"")
        . "document.form_edit.text.focus();\n"
        . "//-->\n"
        . "</script>\n";

    print &GetMinimumFooter();
}

sub GetTextArea {
    my ($name, $text, $rows, $cols) = @_;
### &lt; 와 &gt; 가 들어가 있는 페이지를 수정할 경우 자동으로 부등호로 바뀌어 버리는 문제를 해결
    $text =~ s/(<!--.*?-->)/&StoreRaw($1)/ges;
    $text =~ s/(\&)/\&amp;/g;
    $text = &RestoreSavedText($text);
    if (&GetParam("editwide", 1)) {
        return $q->textarea(-accesskey=>'i', -id=>$name, -name=>$name, -default=>$text,
                                                -rows=>$rows, -columns=>$cols, -override=>1,
                                                -style=>'width:100%', -wrap=>'virtual');
    }
    return $q->textarea(-accesskey=>'i', -id=>$name, -name=>$name, -default=>$text,
                                            -rows=>$rows, -columns=>$cols, -override=>1,
                                            -wrap=>'virtual');
}

sub DoEditPrefs {
    my ($check, $recentName, %labels);

    $recentName = $RCName;
    $recentName =~ s/_/ /g;
    print &GetHeader('', T('Editing Preferences'), "");
    print &GetFormStart();
    print GetHiddenValue("edit_prefs", 1), "\n";
    if ($UserID eq "") {
        print GetHiddenValue("new_login", 1), "\n";
    }
    print '<b>' . T('User Information:') . "</b>\n";
    print '<br>' . T('UserName:') . ' ', &GetFormText('username', "", 20, 50);
    print ' ' . T('(blank to remove, or valid page name)');
    print '<br>' . T('Set Password:') . ' ',
                $q->password_field(-name=>'p_password', -value=>'*',
                                                     -size=>15, -maxlength=>50),
                ' ', T('(blank to remove password)'), '<br>(',
                T('Passwords allow sharing preferences between multiple systems.'),
                ' ', T('Passwords are completely optional.'), ')';
    if ($AdminPass ne '') {
        print '<br>', T('Administrator Password:'), ' ',
                    $q->password_field(-name=>'p_adminpw', -value=>'*',
                                                         -size=>15, -maxlength=>50),
                    ' ', T('(blank to remove password)'), '<br>',
                    T('(Administrator passwords are used for special maintenance.)');
    }
    if ($EmailNotify) {
        print "<br>";
        print &GetFormCheck('notify', 1,
                    T('Include this address in the site email list.')), ' ',
                    T('(Uncheck the box to remove the address.)');
        print '<br>', T('Email Address:'), ' ',
                    &GetFormText('email', "", 30, 60);
    }
    print "<hr noshade size=1><b>".T($recentName).":</b>\n";
    print '<br>', T('Default days to display:'), ' ',
                &GetFormText('rcdays', $RcDefault, 4, 9);
    print "<br>", &GetFormCheck('rcnewtop', $RecentTop,
                                                T('Most recent changes on top'));
    print "<br>", &GetFormCheck('rcall', 0,
                                                T('Show all changes (not just most recent)'));
    %labels = (0=>T('Hide minor edits'), 1=>T('Show minor edits'),
               2=>T('Show only minor edits'));
    print '<br>', T('Minor edit display:'), ' ';
    print $q->popup_menu(-name=>'p_rcshowedit',
                                             -values=>[0,1,2], -labels=>\%labels,
                                             -default=>&GetParam("rcshowedit", $ShowEdits));
    print "<br>", &GetFormCheck('rcchangehist', 1,
                                                            T('Use "changes" as link to history'));
    if ($UseDiff) {
        print '<hr noshade size=1><b>', T('Differences:'), "</b>\n";
        print "<br>", &GetFormCheck('diffrclink', 1,
                                                            Ts('Show (diff) links on %s', T($recentName)));
        print "<br>", &GetFormCheck('alldiff', 0,
                                                                T('Show differences on all pages'));
        print "  (",  &GetFormCheck('norcdiff', 1,
                                                                Ts('No differences on %s', T($recentName))), ")";
        %labels = (1=>T('Major'), 2=>T('Minor'), 3=>T('Author'));
        print '<br>', T('Default difference type:'), ' ';
        print $q->popup_menu(-name=>'p_defaultdiff',
                                                 -values=>[1,2,3], -labels=>\%labels,
                                                 -default=>&GetParam("defaultdiff", 1));
    }
    print '<hr noshade size=1><b>', T('Misc:'), "</b>\n";
    # Note: TZ offset is added by TimeToText, so pre-subtract to cancel.
    print '<br>', T('Server time:'), ' ', &TimeToText($Now-$TimeZoneOffset);
    print '<br>', T('Time Zone offset (hours):'), ' ',
                &GetFormText('tzoffset', 0, 4, 9);
    print '<br>', &GetFormCheck('editwide', 1,
                                                T('Use 100% wide edit area (if supported)'));
    print '<br>',
                T('Edit area rows:'), ' ', &GetFormText('editrows', 20, 4, 4),
                ' ', T('columns:'),   ' ', &GetFormText('editcols', 65, 4, 4);

    print '<br>', &GetFormCheck('toplinkbar', 1,
                            T('Show link bar on top'));
    print '<br>', &GetFormCheck('linkrandom', 0,
                                                T('Add "Random Page" link to link bar'));
    print '<br>', $q->submit(-name=>'Save', -value=>T('Save')), "\n";
    print "<hr class='footer'>\n";
    print $q->end_form;
    print &GetMinimumFooter();
}

sub GetFormText {
    my ($name, $default, $size, $max) = @_;
    my $text = &GetParam($name, $default);

    return $q->textfield(-name=>"p_$name", -default=>$text,
                                             -override=>1, -size=>$size, -maxlength=>$max);
}

sub GetFormCheck {
    my ($name, $default, $label) = @_;
    my $checked = (&GetParam($name, $default) > 0);

    return $q->checkbox(-name=>"p_$name", -override=>1, -checked=>$checked,
                                            -label=>$label);
}

sub DoUpdatePrefs {
    my ($username, $password);

### 암호를 암호화해서 저장
### from Bab2's patch
    my $hashpass = "";

    # All link bar settings should be updated before printing the header
    &UpdatePrefCheckbox("toplinkbar");
### 빈 페이지 링크 스타일을 환경 설정에서 결정
### from Bab2's patch
    &UpdatePrefCheckbox("linkstyle");

    &UpdatePrefCheckbox("linkrandom");
    print &GetHeader('',T('Saving Preferences'), '');
    print '<br>';

### 아이디 첫글자를 대문자로 변환
#   $UserID = &GetParam("p_username",  "");
#   $username = &GetParam("p_username",  "");
    $UserID = &FreeToNormal(&GetParam("p_username",  ""));
    $username = &FreeToNormal(&GetParam("p_username",  ""));
### 다른 사용자의 환경설정 변경을 금지
    my ($status, $data) = &ReadFile(&UserDataFilename($UserID));
    if ($status) {
        if ((!(&UserIsAdmin)) && ($UserData{'userid'} ne $UserID)) {
            print T('Error: Can not update prefs. That ID already exists and does not match your ID.'). '<br>';
            print &GetCommonFooter();
            return;
        }
    }

    if ($FreeLinks) {
        $username =~ s/^\[\[(.+)\]\]/$1/;  # Remove [[ and ]] if added
        $username =  &FreeToNormal($username);
        $username =~ s/_/ /g;
    }

### 아이디 항목을 공란으로 놓지 못하게 하고, 최소 4자 이상이어야 하도록 제한
### based on Bab2's patch
#   if ($username eq "") {
#       print T('UserName removed.'), '<br>';
#       undef $UserData{'username'};
#   } elsif ((!$FreeLinks) && (!($username =~ /^$LinkPattern$/))) {
#       print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
#   } elsif ($FreeLinks && (!($username =~ /^$FreeLinkPattern$/))) {
#       print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
#   } elsif (length($username) > 50) {  # Too long
#       print T('UserName must be 50 characters or less. (not saved)'), "<br>\n";
    if (length($username) < 4) {
        print T('UserName must be 4 characters or more. (not saved)'), "<br>\n";
        $UserID = 0;
        print &ScriptLink("action=editprefs", T('Try Again'));
        print &GetCommonFooter();
        return;
    } elsif ((!$FreeLinks) && (!($username =~ /^$LinkPattern$/))) {
        print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
        $UserID = 0;
        print &ScriptLink("action=editprefs", T('Try Again'));
        print &GetCommonFooter();
        return;
    } elsif ($FreeLinks && (!($username =~ /^$FreeLinkPattern$/))) {
        print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
        $UserID = 0;
        print &ScriptLink("action=editprefs", T('Try Again'));
        print &GetCommonFooter();
        return;
    } elsif (length($username) > 50) {  # Too long
        print T('UserName must be 50 characters or less. (not saved)'), "<br>\n";
        $UserID = 0;
        print &ScriptLink("action=editprefs", T('Try Again'));
        print &GetCommonFooter();
        return;
###
###############
    } else {
        print Ts('UserName %s saved.', $username), '<br>';
        $UserData{'username'} = $username;
    }
    $password = &GetParam("p_password",  "");
### 암호를 암호화해서 저장
### from Bab2's patch
    $hashpass = crypt($password, $HashKey);
    if ($password eq "") {
        print T('Password removed.'), '<br>';
        undef $UserData{'password'};
    } elsif ($password ne "*") {
        print T('Password changed.'), '<br>';
### 암호를 암호화해서 저장
### from Bab2's patch
#       $UserData{'password'} = $password;
        $UserData{'password'} = $hashpass;
    }
    if ($AdminPass ne "") {
        $password = &GetParam("p_adminpw",  "");
### 암호를 암호화해서 저장
### from Bab2's patch
        $hashpass = crypt($password, $HashKey);
        if ($password eq "") {
            print T('Administrator password removed.'), '<br>';
            undef $UserData{'adminpw'};
        } elsif ($password ne "*") {
            print T('Administrator password changed.'), '<br>';
### 암호를 암호화해서 저장
### from Bab2's patch
#           $UserData{'adminpw'} = $password;
            $UserData{'adminpw'} = $hashpass;
            if (&UserIsAdmin()) {
                print T('User has administrative abilities.'), '<br>';
            } elsif (&UserIsEditor()) {
                print T('User has editor abilities.'), '<br>';
            } else {
                print T('User does not have administrative abilities.'), ' ',
                            T('(Password does not match administrative password(s).)'),
                            '<br>';
            }
        }
    }
    if ($EmailNotify) {
        &UpdatePrefCheckbox("notify");
        &UpdateEmailList();
    }
    &UpdatePrefNumber("rcdays", 0, 0, 999999);
    &UpdatePrefCheckbox("rcnewtop");
    &UpdatePrefCheckbox("rcall");
    &UpdatePrefCheckbox("rcchangehist");
    &UpdatePrefCheckbox("editwide");
    if ($UseDiff) {
        &UpdatePrefCheckbox("norcdiff");
        &UpdatePrefCheckbox("diffrclink");
        &UpdatePrefCheckbox("alldiff");
        &UpdatePrefNumber("defaultdiff", 1, 1, 3);
    }
    &UpdatePrefNumber("rcshowedit", 1, 0, 2);
    &UpdatePrefNumber("tzoffset", 0, -999, 999);
    &UpdatePrefNumber("editrows", 1, 1, 999);
    &UpdatePrefNumber("editcols", 1, 1, 999);
    print T('Server time:'), ' ', &TimeToText($Now-$TimeZoneOffset), '<br>';
    $TimeZoneOffset = &GetParam("tzoffset", 0) * (60 * 60);
    print T('Local time:'), ' ', &TimeToText($Now), '<br>';

    $UserData{'userid'} = $UserID;

# 새로 ID를 만들었을 때의 추가 데이터
    if (GetParam("new_login", 0) == 1) {
        $UserData{'randkey'} = int(rand(1000000000));
        $UserData{'rev'} = 1;
        $UserData{'createtime'} = $Now;
        $UserData{'createip'} = $ENV{REMOTE_ADDR};
    }

    &SaveUserData();
    print '<b>', T('Preferences saved.'), '</b>';
    print &GetCommonFooter();
}

# add or remove email address from preferences to $DatDir/emails
sub UpdateEmailList {
    my (@old_emails);

    local $/ = "\n";  # don't slurp whole files in this sub.
    if (my $new_email = $UserData{'email'} = &GetParam("p_email", "")) {
        my $notify = $UserData{'notify'};
        if (-f "$DataDir/emails") {
            open(my $notify, '<', "$DataDir/emails")
                or die(Ts('Could not read from %s:', "$DataDir/emails") . " $!\n");
            @old_emails = <$notify>;
            close $notify;
        } else {
            @old_emails = ();
        }
        my $already_in_list = grep /$new_email/, @old_emails;
        if ($notify and (not $already_in_list)) {
            &RequestLock() or die(T('Could not get mail lock'));
            open(my $notify, '>>', "$DataDir/emails")
                or die(Ts('Could not append to %s:', "$DataDir/emails") . " $!\n");
            print {$notify} $new_email, "\n";
            close $notify;
            &ReleaseLock();
        }
        elsif ((not $notify) and $already_in_list) {
            &RequestLock() or die(T('Could not get mail lock'));
            open(my $notify, '>', "$DataDir/emails")
                or die(Ts('Could not overwrite %s:', "$DataDir/emails") . " $!\n");
            foreach (@old_emails) {
                print {$notify} "$_" unless /$new_email/;
            }
            close $notify;
            &ReleaseLock();
        }
    }
}

sub UpdatePrefCheckbox {
    my ($param) = @_;
    my $temp = &GetParam("p_$param", "*");

    $UserData{$param} = 1  if ($temp eq "on");
    $UserData{$param} = 0  if ($temp eq "*");
    # It is possible to skip updating by using another value, like "2"
}

sub UpdatePrefNumber {
    my ($param, $integer, $min, $max) = @_;
    my $temp = &GetParam("p_$param", "*");

    return  if ($temp eq "*");
    $temp =~ s/[^-\d\.]//g;
    $temp =~ s/\..*//  if ($integer);
    return  if ($temp eq "");
    return  if (($temp < $min) || ($temp > $max));
    $UserData{$param} = $temp;
    # Later consider returning status?
}

### titleindex action 추가
### from Bab2's patch
sub DoTitleIndex {
    my (@list);
    my $charset = &GetParam("charset", "$HttpCharset");

    print "Content-type: text/plain; charset=$charset\n\n";

    @list = &AllPagesList();
    if ($charset ne $HttpCharset) {
        @list = split(/!/, &convert_encode(join('!',@list), "$HttpCharset", "$charset"));
    }
    foreach my $page (@list) {
        print $page."\n";
    }
}

sub DoIndex {
    print &GetHeader('', T('Index of all pages'), '');
    print '<br>';
    &PrintPageList(&AllPagesList());
    print &GetCommonFooter();
}

sub DoEnterLogin {
    print &GetHeader('', T('Login'), "");
### 사용자 아이디를 입력하는 란에 포커스를 준다
#   print &GetFormStart();
    print &GetFormStart("form_login");

    print &ScriptLink("action=newlogin", T('Create new UserName') . "<br>");
    print &GetHiddenValue('enter_login', 1), "\n";
    print &GetHiddenValue('pageid', &GetParam("pageid"));
    print '<br>', T('UserName:'), ' ',
                $q->textfield(-name=>'p_userid', -value=>'',
                                            -size=>15, -maxlength=>50);
    print '<br>', T('Password:'), ' ',
                $q->password_field(-name=>'p_password', -value=>'',
                                                     -size=>15, -maxlength=>50);
### 로긴할 때 자동 로그인 여부 선택
### from Bab2's patch
    print '<br>', &GetFormCheck('expire', 0, T('Keep login information'));

    print '<br>', $q->submit(-name=>'Login', -value=>T('Login')), "\n";
    print "<hr class='footer'>\n";
    print $q->end_form;

### 사용자 아이디를 입력하는 란에 포커스를 준다
    print "\n<script language=\"JavaScript\" type=\"text/javascript\">\n"
        . "<!--\n"
        . "document.form_login.p_userid.focus();\n"
        . "//-->\n"
        . "</script>\n";
###
    print &GetMinimumFooter();
}

sub DoLogin {
    my ($uid, $password, $success);

    $success = 0;
### 아이디 첫글자를 무조건 대문자로 변환
#   $uid = &GetParam("p_userid", "");
    $uid = &FreeToNormal(&GetParam("p_userid", ""));
    $password = &GetParam("p_password",  "");
    if (($password ne "") && ($password ne "*")) {
        $UserID = $uid;

        &LoadUserData();
### 암호를 암호화해서 저장
### from Bab2's patch
        if (defined($UserData{'password'}) &&
                (crypt($password, $UserData{'password'}) eq $UserData{'password'})) {
### 로긴할 때 자동 로그인 여부 선택
### from Bab2's patch
            my $expire_mode = &UpdatePrefCheckbox("expire");
            if ($expire_mode eq "") {
                $SetCookie{'expire'} = 1;
            } else {
                $SetCookie{'expire'} = $expire_mode;
            }

            $SetCookie{'userid'} = $uid;
            $SetCookie{'randkey'} = $UserData{'randkey'};
            $SetCookie{'rev'} = 1;
            $success = 1;
        }
        else {
            $SetCookie{'userid'} = "";
### 잘못된 아이디를 넣었을 때의 처리 추가
### from Bab2's patch
            $UserID = "";
            &LoadUserData();
        }
    }

    if ($success) {
        %UserCookie = %SetCookie;
        if (&GetParam("pageid","") ne "") {
            BrowsePage(&GetParam("pageid"));
            return;
        }
        print &GetHeader('', T('Login completed'), '');
        print Ts('Login for user ID %s complete.', $uid);
    }
    else {
        print &GetHeader('', T('Login failed'), '');
        print Ts('Login for user ID %s failed.', $uid);
        %UserCookie = %SetCookie;
        $UserID = "";
        print "<br>" . &ScriptLink("action=login", T('Try Again'));
    }

    if (&GetParam("pageid","") ne "") {
        print "<BR>" . Ts( 'Return to %s' , &GetPageLink(&GetParam("pageid")) );
    }

    print "<hr class='footer'>\n";
    print &GetMinimumFooter();
}

sub DoLogout {
    $SetCookie{'userid'} = "";
    $SetCookie{'randkey'} = $UserData{'randkey'};
    $SetCookie{'rev'} = 1;

    my $tempUserID = $UserID;
    %UserCookie = %SetCookie;
    $UserID = "113";

    print &GetHeader('', T('Logout Results'), '');

    print Ts('Logout for user ID %s complete.', $tempUserID);

    print "<hr class='footer'>\n";
    print $q->end_form;
    print &GetMinimumFooter();
}

# Later get user-level lock
sub SaveUserData {
    my ($userFile, $data);
### 설치 후 처음으로 사용자 아이디를 만들 때 에러가 나는 것을 해결
    &CreateDir($UserDir);
    $userFile = &UserDataFilename($UserID);
    $data = join($FS1, %UserData);
    &WriteStringToFile($userFile, $data);
}

sub DoSearch {
    my ($string) = @_;
    my @x;

    if ($string eq '') {
        &DoIndex();
        return;
    }
    print &GetHeader('', &QuoteHtml(Ts('Search for: %s', $string)), '');
    print '<br>';

# 검색어에 정규표현식 에러가 나는 경우는 quote하여 검색
    eval { "" =~ /$string/i; };
    if ($@) {
        $string = "\Q$string\E";
    }

    @x = &SearchTitleAndBody($string);
#   &PrintPageList(@x);
    if (&GetParam("context", "")) {
        &PrintSearchResults($string, @x);
    } else {
        &PrintPageList(@x);
    }

### 검색 결과 하단에 새 페이지 만들기 항상 출력
#   if ($#x eq -1) {
    $string = &FreeToNormal($string) if ($FreeLinks);
    if ((&ValidId($string) eq "") && (not -f &GetPageFile($string))) {
        print "<hr>";
###
        print &ScriptLink("action=edit&id=$string", Ts('Create a new page : %s', $string));
    }

    print &GetCommonFooter();
}

# Print search results with context
# based on UseMod:WikiPatches/BetterSearchOutput
sub PrintSearchResults {
    my ($searchstring, @results) = @_;
    my ($output);

    my ($pageText, $t, $j, $jsnippet, $start, $end) ;
    my ($snippetlen, $maxsnippets) = ( 100, 5 ) ; #  these seem nice.
    if (&GetParam("context") =~ /^(\d+)$/) {
        $maxsnippets = $1;
    }

# TOC 출력
    my %hash;
    map { push( @{$hash{GetPageDirectoryExt($_)}}, $_); } @results;
    print $q->a({-name=>"TOC"}), "<h2>", Ts('%s pages found:', ($#results + 1)), "</h2>\n";
    print $q->p( map { "| ". $q->a({-href=>"#$_"}, $_); } sort keys %hash);
    print "\n";

    foreach my $title (sort keys %hash) {
        print $q->h2($q->a({-name=>$title, -href=>"#TOC"}, $title)), "\n";

        foreach my $name (@{$hash{$title}}) {
#  get the page, filter it, remove all tags (since we're presenting in
#  plaintext, not HTML, a la google(tm)).
            &OpenPage($name);
            &OpenDefaultText();
            $pageText = $Text{'text'};
            foreach my $t (@HtmlPairs, "pre", "nowiki", "code" ) {
                $pageText =~ s/\<$t(\s[^<>]+?)?\>(.*?)\<\/$t\>/$2/gis;
            }
            foreach my $t (@HtmlSingle) {
                $pageText =~ s/\<$t(\s[^<>]+?)?\>//gi;
            }
            $pageText = &QuoteHtml($pageText);
            $pageText =~ s/$FS//g;  # Remove separators (paranoia)
            $pageText =~ s/[\s]+/ /g;  #  Shrink whitespace
            $pageText =~ s/([-_=\\*\\.]){10,}/$1$1$1$1$1/g ; # e.g. shrink "----------"

#  entry header
            $output = "";
            $output .= "... "  if ($name =~ m|/|);
            $output .= "<SPAN class='searchresultpagename'>". &GetPageLink($name) ."</SPAN><BR>\n";
#  entry trailer
#           $output .= "<br><i><font size=-1>"
            $output .= "<SPAN class='searchresultpageinfo'>"
            . int((length($pageText)/1024)+1) . "KB - "
            . T("Last edited") . &TimeToText($Section{ts})
            . "</SPAN><br>\n" ;

            $output .= "<BLOCKQUOTE class='searchresultcontext'>";

#  show a snippet from the top of the document
            $j = index( $pageText, " ", $snippetlen ) ;  #  end on word boundary
            $t = substr($pageText, 0, $j);
            $t =~ s/($searchstring)/<SPAN class='highlight'>$1<\/SPAN>/gi ;
            $output .= $t . " <b>...</b> " ;
            $pageText = substr( $pageText, $j ) ;  #  to avoid rematching

#  search for occurrences of searchstring
            $jsnippet = 0 ;
            while ( $jsnippet < $maxsnippets
            &&  $pageText =~ m/($searchstring)/i ) {  #  captures match as $1
                $jsnippet++ ;  #  paranoid about looping
                if ( ($j = index( $pageText, $1 )) > -1 ) {  #  get index of match
#  get substr containing (start of) match, ending on word boundaries
                    $start = index( $pageText, " ", $j-($snippetlen/2) ) ;
                    $start = 0  if ( $start == -1 ) ;
                    $end = index( $pageText, " ", $j+($snippetlen/2) ) ;
                    $end = length( $pageText )  if ( $end == -1 ) ;
                    $t = substr( $pageText, $start, $end-$start ) ;
#  highlight occurrences and tack on to output stream.
                    $t =~ s/($searchstring)/<SPAN class='highlight'>$1<\/SPAN>/gi ;
                    $output .= $t . " <b>...</b> " ;
#  truncate text to avoid rematching the same string.
                    $pageText = substr( $pageText, $end ) ;
                }
            }

            $output .= "</BLOCKQUOTE><br>\n";

            print $output ;
        }
    }
}

### 페이지 이름을 인자로 받아서 디렉토리명을 반환
### GetPageDirectory 함수의 확장.
sub GetPageDirectoryExt {
    my ($id) = @_;

# Number and Alphabet index
    if ($id =~ /^([0-9])/) { return "0"; }
    if ($id =~ /^([a-zA-Z])/) { return uc($1); }

# Korean index
    my @i_korean = (        # "가" "나" ... "하"
        "\x{AC00}", "\x{B098}", "\x{B2E4}", "\x{B77C}", "\x{B9C8}",
        "\x{BC14}", "\x{C0AC}", "\x{C544}", "\x{C790}", "\x{CC28}",
        "\x{CE74}", "\x{D0C0}", "\x{D30C}", "\x{D558}"
    );

# Japanese index
    my @i_japanese = (      # "ぁ" "ァ"
        "\x{3041}", "\x{30A1}"
    );

# Any other characters for TOC here...
#   my @i_other_lang = ( "\x{unicode number}", ... );
# It would be appreciated if anyone inform me (gypark@gmail.com) about his/her language


# Directory index of all languages, and the "print form" of that index:
# For example:
#   "나" (\x{B098}) would be returned if $id is "난초" (begins with \x{B09C})
#   "others"        would be returned if $id begins with Thai character (\x{0E**})
#
# Insert @i_other_lang into @index and @index_print, but be careful of the position
#   so that all elements of @index are sorted in ascending order
#   and that they match those of @index_print.
    my @index = (
            "\x{0000}",
            @i_japanese,
            "\x{3100}",
            @i_korean,
            "\x{D7B0}",
         );
    my @index_print = (
            "others",           # \x{0000}- (except Number and Alphabet)
            @i_japanese,        # \x{3041}-
            "others",           # \x{3100}-
            @i_korean,          # \x{AC00}-
            "others"            # \x{D7B0}-
         );

# Now, find the index character for $id
    my $id_uni = decode("$HttpCharset", $id);
    for (my $i=0; $i <= $#index; $i++) {
        if (($index[$i] le $id_uni) &&
                (($i == $#index) || ($id_uni lt $index[$i+1]))) {
            my $retval = $index_print[$i];
            if (Encode::is_utf8($retval)) {
                $retval = encode($HttpCharset, $retval);
            }
            return $retval;
        }
    }

    return "others!"; # must not reach here
}

### new PrintPageList subroutine. source is based on OddMuse:Index_Extension
sub PrintPageList {
    my @pages = @_;
    my %hash;

    map { push( @{$hash{GetPageDirectoryExt($_)}}, $_); } @pages;

# TOC 출력
    print $q->a({-name=>"TOC"}), "<h2>", Ts('%s pages found:', ($#pages + 1)), "</h2>\n";
    print $q->p( map { "| ". $q->a({-href=>"#$_"}, $_); } sort keys %hash);
    print "\n";

# 페이지 목록 출력
    foreach my $title (sort keys %hash) {
        print $q->h2($q->a({-name=>$title, -href=>"#TOC"}, $title)), "\n";
        foreach my $pagename (@{$hash{$title}}) {
            print ".... " if ($pagename =~ m|/|);
            print &GetPageLink($pagename);
            if (&UserIsAdmin()) {
### 관리자의 인덱스 화면에서는 잠긴 페이지를 별도로 표시
                print " | ";
                if (-f &GetLockedPageFile($pagename)) {
                    print T('(locked)')." ";
                    print &ScriptLink("action=pagelock&set=0&id=" . $pagename, T('unlock'));
                } else {
                    print &ScriptLink("action=pagelock&set=1&id=" . $pagename, T('lock'));
                }
### hide page
                print " | ";
                if (defined($HiddenPage{$pagename})) {
                    print T('(hidden)')." ";
                    print &ScriptLink("action=pagehide&set=0&id=" . $pagename, T('unhide'));
                } else {
                    print &ScriptLink("action=pagehide&set=1&id=" . $pagename, T('hide'));
                }
            }
#
            print "<BR>\n";
        }
    }
}

sub DoLinks {
    print &GetHeader('', &QuoteHtml(T('Full Link List')), '');
    print "<pre>\n";  # Extra lines to get below the logo
    &PrintLinkList(&GetFullLinkList());
    print "</pre><HR class='footer'>\n";
    print &GetMinimumFooter();
}

sub PrintLinkList {
    my ($names, $editlink);
    my ($link, $extra, @links, %pgExists);

    %pgExists = ();
    foreach my $page (&AllPagesList()) {
        $pgExists{$page} = 1;
    }
    $names = &GetParam("names", 1);
    $editlink = &GetParam("editlink", 0);
    foreach my $pagelines (@_) {
        @links = ();
### full link list 개선
        my @pages = split(' ', $pagelines);
        foreach my $page (@pages) {
            if ($page =~ /\:/) {  # URL or InterWiki form
                if ($page =~ /$UrlPattern/) {
                    ($link, $extra) = &UrlLink($page);
                } else {
                    ($link, $extra) = &InterPageLink($page);
                }
            } else {
                if ($pgExists{$page}) {
                    $link = &GetPageLink($page);
### full link list 개선
                } elsif ($page =~ /^\// && $pgExists{(split ('/',$pages[0]))[0].$page}) {
                    ($link, $extra) = &GetPageLinkText((split ('/',$pages[0]))[0].$page, $page);
                } else {
                    $link = $page;
                    if ($editlink) {
                        $link .= &GetEditLink($page, "?");
                    }
                }
            }
            push(@links, $link);
        }
        if (!$names) {
            shift(@links);
        }
        print join(' ', @links), "\n";
    }
}

sub GetFullLinkList {
### GetFullLinkList 에 인자처리 기능 추가
    my ($opt) = @_;
    my %args = (            # default 값
            "unique" , 1,
            "sort", 1,
            "page", 1,
            "inter", 0,
            "url", 0,
            "exists", 2,
            "empty", 0,
            "search", "",
            "reverse", ""
    );
    foreach my $opt_item (split('&',$opt)) {
        if ($opt_item =~ /^(.+)=(.+)$/) {
            $args{$1} = $2;
        }
    }

### 역링크 검색 옵션 추가
#   my ($name, $unique, $sort, $exists, $empty, $link, $search);
    my ($unique, $sort, $exists, $empty, $search, $reverse);

    my ($pagelink, $interlink, $urllink);
    my (@found, @links, @newlinks, @pglist, %pgExists, %seen);

### GetFullLinkList 에 인자처리 기능 추가
#   $unique = &GetParam("unique", 1);
#   $sort = &GetParam("sort", 1);
#   $pagelink = &GetParam("page", 1);
#   $interlink = &GetParam("inter", 0);
#   $urllink = &GetParam("url", 0);
#   $exists = &GetParam("exists", 2);
#   $empty = &GetParam("empty", 0);
#   $search = &GetParam("search", "");
    $unique = &GetParam("unique", $args{"unique"});
    $sort = &GetParam("sort", $args{"sort"});
    $pagelink = &GetParam("page", $args{"page"});
    $interlink = &GetParam("inter", $args{"inter"});
    $urllink = &GetParam("url", $args{"url"});
    $exists = &GetParam("exists", $args{"exists"});
    $empty = &GetParam("empty", $args{"empty"});
    $search = &GetParam("search", $args{"search"});

### 역링크 기능 추가
    $reverse = &GetParam("reverse", $args{"reverse"});

    if (($interlink == 2) || ($urllink == 2)) {
        $pagelink = 0;
    }

    %pgExists = ();
    @pglist = &AllPagesList();
    foreach my $name (@pglist) {
        $pgExists{$name} = 1;
    }
    %seen = ();
    foreach my $name (@pglist) {
        @newlinks = ();
        if ($unique != 2) {
            %seen = ();
        }
### 링크 목록을 별도로 관리
#       @links = &GetPageLinks($name, $pagelink, $interlink, $urllink);
        @links = &GetPageLinksFromFile($name, $pagelink, $interlink, $urllink);

        foreach my $link (@links) {
            $seen{$link}++;
            if (($unique > 0) && ($seen{$link} != 1)) {
                next;
            }

            my $link2 = $link;
            $link2 = (split ('/',$name))[0]."$link" if ($link =~ /^\//);
            if (($exists == 0) && ($pgExists{$link2} == 1)) {
                next;
            }
            if (($exists == 1) && ($pgExists{$link2} != 1)) {
                next;
            }
            if (($search ne "") && !($link =~ /$search/)) {
                next;
            }
### 역링크 기능 추가
            if ($reverse ne "") {
                my ($mainpage, $subpage) = ("", "");
                if ($reverse =~ /(.+)\/(.+)/) {
                    ($mainpage, $subpage) = ($1, $2);
                }
                if (!((split('/',$name))[0] eq $mainpage && $link eq "\/$subpage") && !($link eq $reverse)) {
                    next;
                }
            }

            push(@newlinks, $link);
        }
        @links = @newlinks;
        if ($sort) {
            @links = sort(@links);
        }
        unshift (@links, $name);
        if ($empty || ($#links > 0)) {  # If only one item, list is empty.
            push(@found, join(' ', @links));
        }
    }
    return @found;
}

sub GetPageLinks {
    my ($name, $pagelink, $interlink, $urllink) = @_;
    my ($text, @links);

    @links = ();
    &OpenPage($name);
    &OpenDefaultText();
    $text = $Text{'text'};
### {{{ }}} 내의 내용은 링크로 간주하지 않음
    $text = store_raw_codes($text);

    if ($interlink) {
        $text =~ s/''+/ /g;  # Quotes can adjacent to inter-site links
        $text =~ s/$InterLinkPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
    } else {
        $text =~ s/$InterLinkPattern/ /g;
    }
    if ($urllink) {
        $text =~ s/''+/ /g;  # Quotes can adjacent to URLs
        $text =~ s/$UrlPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
    } else {
        $text =~ s/$UrlPattern/ /g;
    }
    if ($pagelink) {
        if ($FreeLinks) {
            my $fl = $FreeLinkPattern;
            $text =~ s/\[\[$fl\|[^\]]+\]\]/push(@links, &FreeToNormal($1)), ' '/ge;
            $text =~ s/\[\[$fl\]\]/push(@links, &FreeToNormal($1)), ' '/ge;
            $text =~ s/\[\[$AnchoredFreeLinkPattern\|([^\]]+)\]\]/push(@links, &FreeToNormal($1)), ' '/ge;
            $text =~ s/\[\[$AnchoredFreeLinkPattern\]\]/push(@links, &FreeToNormal($1)), ' '/ge;
        }
        if ($WikiLinks) {
            $text =~ s/$LinkPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
        }
    }
    return @links;
}

### comments from Jof
sub DoPost {
    my $string = &GetParam("text", undef);
    my $id = &GetParam("title", "");
    my $summary = &GetParam("summary", "");
    my $oldtime = &GetParam("oldtime", "");
    my $oldconflict = &GetParam("oldconflict", "");
# ECode
    my $ecode = &GetParam("ecode","");
    my ($code_today, $code_yesterday);
    $code_today = &simple_crypt(length($id).substr(&CalcDay($Now),5));
    $code_yesterday = &simple_crypt(length($id).substr(&CalcDay($Now - 86400),5));

    if (($ecode ne $code_today) && ($ecode ne $code_yesterday)) { # spam
        &ReportError("SPAM editing");
        return;
    }
    my $trap = &GetParam("homepage", "");
    if ($trap ne "") {
        &ReportError("SPAM editting caught in trap");
        return;
    }
###
    DoPostMain($string, $id, $summary, $oldtime, $oldconflict, 0);
    return;
}
###

### comments from Jof
# sub DoPost {
#   my ($editDiff, $old, $newAuthor, $pgtime, $oldrev, $preview, $user);
#   my $string = &GetParam("text", undef);
#   my $id = &GetParam("title", "");
#   my $summary = &GetParam("summary", "");
#   my $oldtime = &GetParam("oldtime", "");
#   my $oldconflict = &GetParam("oldconflict", "");
#   my $isEdit = 0;
#   my $editTime = $Now;
#   my $authorAddr = $ENV{REMOTE_ADDR};

sub DoPostMain {
    my ($string, $id, $summary, $oldtime, $oldconflict, $isEdit, $rebrowseid) = @_;
    my ($editDiff, $old, $newAuthor, $pgtime, $oldrev, $preview, $user);
    my $editTime = $Now;
    my $authorAddr = $ENV{REMOTE_ADDR};
###
###############


### comments 기능
#   if (!&UserCanEdit($id, 1)) {
    if (($rebrowseid eq "") && (!&UserCanEdit($id, 1))) {
###
        # This is an internal interface--we don't need to explain
        &ReportError(Ts('Editing not allowed for %s.', $id));
        return;
    }

# 금지단어
    if (my $bannedText = &TextIsBanned($string)) {
        print &GetHeader("", T('Editing Denied'),"");
        print Ts('Editing not allowed: text includes banned text');
        print " [$bannedText]" if UserIsAdmin();
        print "\n<br><hr noshade size=1><p><strong>". T('This is the text you submitted:').
                "<br>". T('(Copy the text, go back with your browser, paste the text, and edit again please)').
                "</strong><p>".
                &GetTextArea('text', $string, &GetParam("editrows", 20), &GetParam("editcols", 65)).
                "<p>\n";
        print &GetCommonFooter();
        return;
    }

    if (($id eq 'SampleUndefinedPage') || ($id eq T('SampleUndefinedPage'))) {
        &ReportError(Ts('%s cannot be defined.', $id));
        return;
    }
    if (($id eq 'Sample_Undefined_Page')
            || ($id eq T('Sample_Undefined_Page'))) {
        &ReportError(Ts('[[%s]] cannot be defined.', $id));
        return;
    }
    $string =~ s/$FS//g;
    $summary =~ s/$FS//g;
    $summary =~ s/[\r\n]//g;
    # Add a newline to the end of the string (if it doesn't have one)
    $string .= "\n"  if (!($string =~ /\n$/));

    # Remove "\r"-s (0x0d) from the string
    $string =~ s/\r//g;

### <mysign> 등 글작성 직후 수행할 매크로
### comments 구현을 위해 $id 추가, from Jof
    $string = &ProcessPostMacro($string, $id);
###
    # Lock before getting old page to prevent races
    &RequestLock() or die(T('Could not get editing lock'));
    # Consider extracting lock section into sub, and eval-wrap it?
    # (A few called routines can die, leaving locks.)
    &OpenPage($id);
    &OpenDefaultText();
    $old = $Text{'text'};
    $oldrev = $Section{'revision'};
    $pgtime = $Section{'ts'};

### 섹션 단위 편집 - 저장할 때
    my $section = &GetParam('section', 0);
    if ($section >= 1) {
        my $temp_text;
        my (@h_depth, @h_pos);
        my $num = 0;

        $temp_text = $old;

        # {{{ }}} 등 헤드라인이 올 수 없는 것들을 먼저 제외
        %SaveUrl = ();
        $SaveUrlIndex = 0;
        $temp_text = &store_raw_codes($temp_text);

        # 남은 텍스트에서 헤드라인들의 목록을 뽑는다
        while ($temp_text =~ /(^[ \t]*(\=+)\s+[^\n]+\s+\=+\s*$)/gm) {
            $num++;
            $h_pos[$num] = pos($temp_text) - length($1);        # 각 섹션의 시작 포지션
            $h_depth[$num] = length($2);
        }
        $num++;
        $h_pos[$num] = length($temp_text);
        $h_depth[$num] = 1;

        # 같은 depth 의 다음 헤드라인을 찾음
        my $next;
        for ($next = $section+1; ($next <= $#h_depth) && ($h_depth[$section] < $h_depth[$next]); $next++) {}

        # 입력폼에서 넘어온 텍스트를, 그 외 앞뒤 섹션과 결합
        $temp_text = substr($temp_text, 0, $h_pos[$section]).
            $string.
            substr($temp_text, $h_pos[$next]);

        # 제외했던 내용 복원
        $temp_text = &RestoreSavedText($temp_text);
        %SaveUrl = ();
        $SaveUrlIndex = 0;

        # $string 바꿔치기
        $string = $temp_text;
    }
#####
    $preview = 0;
    $preview = 1  if (&GetParam("Preview", "") ne "");
    if (!$preview && ($old eq $string)) {  # No changes (ok for preview)
        &ReleaseLock();
        &ReBrowsePage($id, "", 1);
        return;
    }
    # Later extract comparison?
#   if (($UserID > 399) || ($Section{'id'} > 399))  {
### 로그인 하지 않은 경우의 conflict
#   if (($UserID ne "") || ($Section{'id'} ne ""))  {
    if (
#       (($UserID ne "") && ($UserID ne "112") && ($UserID ne "113")) ||
        (($UserID ne "") && (&LoginUser())) ||
        (($Section{'id'} ne "") && ($Section{'id'} ne "112") && ($Section{'id'} ne "113"))
        ) {
###
        $newAuthor = ($UserID ne $Section{'id'});       # known user(s)
    } else {
        $newAuthor = ($Section{'ip'} ne $authorAddr);  # hostname fallback
    }
    $newAuthor = 1  if ($oldrev == 0);  # New page
    $newAuthor = 0  if (!$newAuthor);   # Standard flag form, not empty
    # Detect editing conflicts and resubmit edit
    if (($oldrev > 0) && ($newAuthor && ($oldtime != $pgtime))) {
        &ReleaseLock();
### 섹션 단위 편집 - 충돌이 발생하면 전체 페이지 편집으로
        $q->param('section','');
#####
        if ($oldconflict>0) {  # Conflict again...
            &DoEdit($id, 2, $pgtime, $string, $preview);
        } else {
            &DoEdit($id, 1, $pgtime, $string, $preview);
        }
        return;
    }
    if ($preview) {
        &ReleaseLock();
        &DoEdit($id, 0, $pgtime, $string, 1);
        return;
    }

    $user = &GetParam("username", "");
    # If the person doing editing chooses, send out email notification
    if ($EmailNotify) {
        EmailNotify($id, $user) if &GetParam("do_email_notify", "") eq 'on';
    }
    if (&GetParam("recent_edit", "") eq 'on') {
        $isEdit = 1;
    }
    if (!$isEdit) {
        &SetPageCache('oldmajor', $Section{'revision'});
    }
    if ($newAuthor) {
        &SetPageCache('oldauthor', $Section{'revision'});
    }
    &SaveKeepSection();
    &ExpireKeepFile();
    if ($UseDiff) {
        &UpdateDiffs($id, $editTime, $old, $string, $isEdit, $newAuthor);
    }
    $Text{'text'} = $string;
    $Text{'minor'} = $isEdit;
    $Text{'newauthor'} = $newAuthor;
    $Text{'summary'} = $summary;
    $Section{'host'} = &GetRemoteHost(0);
    &SaveDefaultText();
    &SavePage();
### 링크 목록을 별도로 관리
    &SaveLinkFile($id);
### rss from usemod1.0
#   &WriteRcLog($id, $summary, $isEdit, $editTime, $user, $Section{'host'});
    &WriteRcLog($id, $summary, $isEdit, $editTime, $user, $Section{'host'}, $Section{'revision'});
###

# Twitter
    if ( GetParam('twitter_edit') and UserIsAdmin() and $TwitterID ) {
        $FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
        my $sum = ": $summary";
        $sum = "" if $sum eq ": *";
        my $url = $FullUrl . &ScriptLinkChar() . $id;
        PostTwitter( "$TwitterPrefix $url $id$sum" );
    }

    if ($UseCache) {
        UnlinkHtmlCache($id);          # Old cached copy is invalid
        if ($Page{'revision'} < 2) {   # If this is a new page...
            &NewPageCacheClear($id);     # ...uncache pages linked to this one.
        }
    }
    if ($UseIndex && ($Page{'revision'} == 1)) {
        unlink($IndexFile);  # Regenerate index on next request
    }
    &ReleaseLock();
### comments from Jof
    if ($rebrowseid ne "") {
        $id = $rebrowseid;
    }
###
    &ReBrowsePage($id, "", 1) if ($id ne "!!");
}

sub UpdateDiffs {
    my ($id, $editTime, $old, $new, $isEdit, $newAuthor) = @_;
    my ($editDiff, $oldMajor, $oldAuthor);

    $editDiff  = &GetDiff($old, $new, 0);     # 0 = already in lock
    $oldMajor  = &GetPageCache('oldmajor');
    $oldAuthor = &GetPageCache('oldauthor');
    if ($UseDiffLog) {
        &WriteDiff($id, $editTime, $editDiff);
    }
    &SetPageCache('diff_default_minor', $editDiff);
    if ($isEdit || !$newAuthor) {
        &OpenKeptRevisions('text_default');
    }
    if (!$isEdit) {
        &SetPageCache('diff_default_major', "1");
    } else {
        &SetPageCache('diff_default_major', &GetKeptDiff($new, $oldMajor, 0));
    }
    if ($newAuthor) {
        &SetPageCache('diff_default_author', "1");
    } elsif ($oldMajor == $oldAuthor) {
        &SetPageCache('diff_default_author', "2");
    } else {
        &SetPageCache('diff_default_author', &GetKeptDiff($new, $oldAuthor, 0));
    }
}

# Translation note: the email messages are still sent in English
# Send an email message.
sub SendEmail {
    my ($to, $from, $reply, $subject, $message) = @_;
        ### debug
        ## print "Content-type: text/plain\n\n";
        ## print " to: '$to'\n";
        ## return;
    # sendmail options:
    #    -odq : send mail to queue (i.e. later when convenient)
    #    -oi  : do not wait for "." line to exit
    #    -t   : headers determine recipient.
    open(my $sendmail, '|-', "$SendMail -oi -t ") or die "Can't send email: $!\n";
    print {$sendmail} <<"EOF";
From: $from
To: $to
Reply-to: $reply
Subject: $subject\n
$message
EOF
    close $sendmail or warn "sendmail didn't close nicely";
}

## Email folks who want to know a note that a page has been modified. - JimM.
sub EmailNotify {
    local $/ = "\n";   # don't slurp whole files in this sub.
    if ($EmailNotify) {
        my ($id, $user) = @_;
        if ($user) {
            $user = " by $user";
        }
        my $address;
        open(my $email, '<', "$DataDir/emails")
            or die "Can't open $DataDir/emails: $!\n";
        $address = join ",", <$email>;
        $address =~ s/\n//g;
        close $email;
        my $home_url = $q->url();
        my $page_url = $home_url . "?$id";
        my $editors_summary = $q->param("summary");
        if (($editors_summary eq "*") or ($editors_summary eq "")){
            $editors_summary = "";
        }
        else {
            $editors_summary = "\n Summary: $editors_summary";
        }
        my $content = <<"END_MAIL_CONTENT";

 The $SiteName page $id at
     $page_url
 has been changed$user to revision $Page{revision}. $editors_summary

 (Replying to this notification will
    send email to the entire mailing list,
    so only do that if you mean to.

    To remove yourself from this list, visit
    ${home_url}?action=editprefs .)
END_MAIL_CONTENT
        my $subject = "The $id page at $SiteName has been changed.";
        # I'm setting the "reply-to" field to be the same as the "to:" field
        # which seems appropriate for a mailing list, especially since the
        # $EmailFrom string needn't be a real email address.
        &SendEmail($address, $EmailFrom, $address, $subject, $content);
    }
}

sub SearchTitleAndBody {
    my ($string) = @_;
    my ($freeName, @found);

    foreach my $name (&AllPagesList()) {
        &OpenPage($name);
        &OpenDefaultText();
        if (($Text{'text'} =~ /$string/i) || ($name =~ /$string/i)) {
            push(@found, $name);
        } elsif ($FreeLinks && ($name =~ m/_/)) {
            $freeName = $name;
            $freeName =~ s/_/ /g;
            if ($freeName =~ /$string/i) {
                push(@found, $name);
            }
        }
    }
    return @found;
}

# 제목에서만 검색
sub SearchTitle {
    my ($string) = @_;
    my ($freeName, @found);

    foreach my $name (&AllPagesList()) {
        if ($name =~ /$string/i) {
            push(@found, $name);
        } elsif ($FreeLinks && ($name =~ m/_/)) {
            $freeName = $name;
            $freeName =~ s/_/ /g;
            if ($freeName =~ /$string/i) {
                push(@found, $name);
            }
        }
    }
    return @found;
}

sub SearchBody {
    my ($string) = @_;
    my (@found);

    foreach my $name (&AllPagesList()) {
        &OpenPage($name);
        &OpenDefaultText();
        if ($Text{'text'} =~ /$string/i){
            push(@found, $name);
        }
    }
    return @found;
}

sub UnlinkHtmlCache {
    my ($id) = @_;
    my $idFile;

    $idFile = &GetHtmlCacheFile($id);
    if (-f $idFile) {
        unlink($idFile);
    }
}

sub NewPageCacheClear {
    my ($id) = @_;

    return if (!$UseCache);
    $id =~ s|.+/|/|;  # If subpage, search for just the subpage
    # The following code used to search the body for the $id
    foreach my $name (&AllPagesList()) {  # Remove all to be safe
        &UnlinkHtmlCache($name);
    }
}

# Note: all diff and recent-list operations should be done within locks.
sub DoUnlock {
    my $LockMessage = T('Normal Unlock.');

    print &GetHeader('', T('Removing edit lock'), '');
    print '<p>', T('This operation may take several seconds...'), "\n";
    if (&ForceReleaseLock('main')) {
        $LockMessage = T('Forced Unlock.');
    }
    # Later display status of other locks?
    &ForceReleaseLock('cache');
    &ForceReleaseLock('diff');
    &ForceReleaseLock('index');
    print "<br><h2>$LockMessage</h2>";
    print &GetCommonFooter();
}

# Note: all diff and recent-list operations should be done within locks.
sub WriteRcLog {
### rss from usemod1.0
#   my ($id, $summary, $isEdit, $editTime, $name, $rhost) = @_;
    my ($id, $summary, $isEdit, $editTime, $name, $rhost, $revision) = @_;
###
    my ($extraTemp, %extra);

    %extra = ();
    $extra{'id'} = $UserID  if ($UserID ne "");
    $extra{'name'} = $name  if ($name ne "");
### 최근변경내역에 북마크 기능 도입
    $extra{'tscreate'} = $Page{'tscreate'};
### rss from usemod 1.0
    $extra{'revision'} = $revision if ($revision ne "");

    $extraTemp = join($FS2, %extra);
    # The two fields at the end of a line are kind and extension-hash
    my $rc_line = join($FS3, $editTime, $id, $summary,
                                         $isEdit, $rhost, "0", $extraTemp);
    open my $out, '>>', $RcFile or die(Ts('%s log error:', $RCName) . " $!");
    print {$out} $rc_line . "\n";
    close $out;
}

sub WriteDiff {
    my ($id, $editTime, $diffString) = @_;

    open (my $out, '>>', "$DataDir/diff_log") or die(T('can not write diff_log'));
    print {$out} "------\n" . $id . "|" . $editTime . "\n";
    print {$out} $diffString;
    close $out;
}

sub DoMaintain {
    my ($fname, $data);
    print &GetHeader('', T('Maintenance on all pages'), '');
    print "<br>";
    $fname = "$DataDir/maintain";
    if (!&UserIsAdmin()) {
        if ((-f $fname) && ((-M $fname) < 0.5)) {
            print T('Maintenance not done.'), ' ';
            print T('(Maintenance can only be done once every 12 hours.)');
            print ' ', T('Remove the "maintain" file or wait.');
            print &GetCommonFooter();
            return;
        }
    }
    &RequestLock() or die(T('Could not get maintain-lock'));
    foreach my $name (&AllPagesList()) {
        &OpenPage($name);
        &OpenDefaultText();
        &ExpireKeepFile();
### 링크 목록을 별도로 관리
        &SaveLinkFile($name);
### page count
        if (!(-f &GetCountFile($name))) {
            &CreatePageDir($CountDir, $name);  # It might not exist yet
            &WriteStringToFile(&GetCountFile($name), "0");
        }
###
        print ".... "  if ($name =~ m|/|);
        print &GetPageLink($name), "<br>\n";
    }
    &WriteStringToFile($fname, "Maintenance done at " . &TimeToText($Now));
    &ReleaseLock();
    # Do any rename/deletion commands
    # (Must be outside lock because it will grab its own lock)
    $fname = "$DataDir/editlinks";
    if (-f $fname) {
        $data = &ReadFileOrDie($fname);
        print '<hr>', T('Processing rename/delete commands:'), "<br>\n";
        &UpdateLinksList($data, 1, 1);  # Always update RC and links
        unlink("$fname.old");
        rename($fname, "$fname.old");
    }
    print &GetCommonFooter();
}

sub UserIsEditorOrError {
    if (!&UserIsEditor()) {
        print '<p>', T('This operation is restricted to site editors only...');
        print &GetCommonFooter();
        return 0;
    }
    return 1;
}

sub UserIsAdminOrError {
    if (!&UserIsAdmin()) {
        print '<p>', T('This operation is restricted to administrators only...');
        print &GetCommonFooter();
        return 0;
    }
    return 1;
}

sub DoEditLock {
    my ($fname);

    print &GetHeader('', T('Set or Remove global edit lock'), '');
    return  if (!&UserIsAdminOrError());
    $fname = "$DataDir/noedit";
    if (&GetParam("set", 1)) {
        &WriteStringToFile($fname, "editing locked.");
    } else {
        unlink($fname);
    }
    if (-f $fname) {
        print '<p>', T('Edit lock created.'), '<br>';
    } else {
        print '<p>', T('Edit lock removed.'), '<br>';
    }
    print &GetCommonFooter();
}

sub DoPageLock {
    my ($fname, $id);

    print &GetHeader('', T('Set or Remove page edit lock'), '');
    # Consider allowing page lock/unlock at editor level?
    return  if (!&UserIsAdminOrError());
    $id = &GetParam("id", "");
    if ($id eq "") {
        print '<p>', T('Missing page id to lock/unlock...');
        return;
    }
    return  if (!&ValidIdOrDie($id));       # Later consider nicer error?
    $fname = &GetLockedPageFile($id);
    if (&GetParam("set", 1)) {
        &WriteStringToFile($fname, "editing locked.");
    } else {
        unlink($fname);
    }
    if (-f $fname) {
        print '<p>', Ts('Lock for %s created.', $id), '<br>';
    } else {
        print '<p>', Ts('Lock for %s removed.', $id), '<br>';
    }
    print &GetCommonFooter();
}

sub DoEditBanned {
    my ($banList, $status);

    print &GetHeader("", "Editing Banned list", "");
    return  if (!&UserIsAdminOrError());
    ($status, $banList) = &ReadFile("$DataDir/banlist");
    $banList = ""  if (!$status);
    print &GetFormStart();
    print GetHiddenValue("edit_ban", 1), "\n";
    print "<p>Each entry is either a commented line (starting with #), ",
        "or a Perl regular expression (matching either an IP address or ",
        "a hostname).  <b>Note:</b> To test the ban on yourself, you must ",
        "give up your admin access (remove password in Preferences).";
    print "<p>Example:<br>",
        "# blocks hosts ending with .foocorp.com<br>",
        "\\.foocorp\\.com\$<br>",
        "# blocks exact IP address<br>",
        "^123\\.21\\.3\\.9\$<br>",
        "# blocks whole 123.21.3.* IP network<br>",
        "^123\\.21\\.3\\.\\d+\$<p>";
    print &GetTextArea('banlist', $banList, 12, 50);
    print "<br>", $q->submit(-name=>'Save'), "\n";
    print "<hr class='footer'>\n";
#   print &GetGotoBar("");
    print $q->end_form;
    print &GetMinimumFooter();
}

sub DoUpdateBanned {
    my ($newList, $fname);

    print &GetHeader("", "Updating Banned list", "");
    return  if (!&UserIsAdminOrError());
    $fname = "$DataDir/banlist";
    $newList = &GetParam("banlist", "#Empty file");
    if ($newList eq "") {
        print "<p>Empty banned list or error.";
        print "<p>Resubmit with at least one space character to remove.";
    } elsif ($newList =~ /^\s*$/s) {
        unlink($fname);
        print "<p>Removed banned list";
    } else {
        &WriteStringToFile($fname, $newList);
        print "<p>Updated banned list";
    }
    print &GetCommonFooter();
}

# ==== Editing/Deleting pages and links ====
sub DoEditLinks {
    print &GetHeader("", T('Editing Links'), "");
    if ($AdminDelete) {
        return  if (!&UserIsAdminOrError());
    } else {
        return  if (!&UserIsEditorOrError());
    }
    print &GetFormStart();
    print GetHiddenValue("edit_links", 1), "\n";
    print "<b>", Ts('Editing/Deleting page titles:'), "</b><br>\n";
    print "<p>", Ts('Enter one command on each line.  Commands are:'), "<br>",
                Ts('<tt>!PageName</tt> -- deletes the page called PageName'), "<br>\n",
                Ts('<tt>=OldPageName=NewPageName</tt> -- Renames OldPageName'), " ",
                Ts('to NewPageName and updates links to OldPageName.'), "<br>",
                Ts('<tt>|OldPageName|NewPageName</tt> -- Changes links to OldPageName to NewPageName.'), " ",
                Ts('(Used to rename links to non-existing pages.)'), "<br>\n";
    print &GetTextArea('commandlist', "", 12, 50);
    print $q->checkbox(-name=>"p_changerc", -override=>1, -checked=>1,
#                                           -label=>"Edit $RCName");
                                            -label=>Ts('Edit %s', $RCName));
    print "<br>\n";
    print $q->checkbox(-name=>"p_changetext", -override=>1, -checked=>1,
#                                           -label=>"Substitute text for rename");
                                            -label=>T('Substitute text for rename'));
    print "<br>", $q->submit(-name=>'Edit'), "\n";
#   print &GetGotoBar("");
    print $q->end_form;
    print "<HR class='footer'>\n";
    print &GetMinimumFooter();
}

sub UpdateLinksList {
    my ($commandList, $doRC, $doText) = @_;

    if ($doText) {
        &BuildLinkIndex();
    }
    &RequestLock() or die "UpdateLinksList could not get main lock";
    unlink($IndexFile)  if ($UseIndex);
    foreach (split(/\n/, $commandList)) {
        s/\s+$//g;
        next  if (!(/^[=!|]/));  # Only valid commands.
        print "Processing $_<br>\n";
        if (/^\!(.+)/) {
            &DeletePage($1, $doRC, $doText);
        } elsif (/^\=(?:\[\[)?([^]=]+)(?:\]\])?\=(?:\[\[)?([^]=]+)(?:\]\])?/) {
            &RenamePage($1, $2, $doRC, $doText);
        } elsif (/^\|(?:\[\[)?([^]|]+)(?:\]\])?\|(?:\[\[)?([^]|]+)(?:\]\])?/) {
            &RenameTextLinks($1, $2);
        }
    }
    &NewPageCacheClear(".");  # Clear cache (needs testing?)
    unlink($IndexFile)  if ($UseIndex);
    &ReleaseLock();
}

sub BuildLinkIndex {
    my (@pglist, @links, $link, %seen);

    @pglist = &AllPagesList();
    %LinkIndex = ();
    foreach my $page (@pglist) {
        &BuildLinkIndexPage($page);
    }
}

sub BuildLinkIndexPage {
    my ($page) = @_;
    my (@links, %seen);

### 링크 목록을 별도로 관리
#   @links = &GetPageLinks($page, 1, 0, 0);
    @links = &GetPageLinksFromFile($page, 1, 0, 0);
###
    %seen = ();
    foreach my $link (@links) {
### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
        if ( $link =~ m!^/! ) {
            $link = (split('/',$page))[0] . $link;
        }
###
        if (defined($LinkIndex{$link})) {
            if (!$seen{$link}) {
                $LinkIndex{$link} .= " " . $page;
            }
        } else {
            $LinkIndex{$link} .= " " . $page;
        }
        $seen{$link} = 1;
    }
}

sub DoUpdateLinks {
    my ($commandList, $doRC, $doText);

    print &GetHeader("", T('Updating Links'), "");
    if ($AdminDelete) {
        return  if (!&UserIsAdminOrError());
    } else {
        return  if (!&UserIsEditorOrError());
    }
    $commandList = &GetParam("commandlist", "");
    $doRC   = &GetParam("p_changerc", "0");
    $doRC   = 1  if ($doRC eq "on");
    $doText = &GetParam("p_changetext", "0");
    $doText = 1  if ($doText eq "on");
    if ($commandList eq "") {
        print "<p>Empty command list or error.";
    } else {
        &UpdateLinksList($commandList, $doRC, $doText);
        print "<p>". T('Finished command list.');
    }
    print &GetCommonFooter();
}

sub EditRecentChanges {
    my ($action, $old, $new) = @_;

    &EditRecentChangesFile($RcFile,    $action, $old, $new);
### RcOldFile 버그 수정
#   &EditRecentChangesFile($RcOldFile, $action, $old, $new);
    &EditRecentChangesFile($RcOldFile, $action, $old, $new) if (-f $RcOldFile);
###
}

sub EditRecentChangesFile {
    my ($fname, $action, $old, $new) = @_;
    my ($status, $fileData, $errorText, @rclist);
    my ($outrc, $ts, $page, $junk);

    ($status, $fileData) = &ReadFile($fname);
    if (!$status) {
        # Save error text if needed.
        $errorText = "<p><strong>Could not open $RCName log file:"
                                 . "</strong> $fname<p>Error was:\n<pre>$!</pre>\n";
        print $errorText;   # Maybe handle differently later?
        return;
    }
    $outrc = "";
    @rclist = split(/\n/, $fileData);
    foreach my $rcline (@rclist) {
        ($ts, $page, $junk) = split(/$FS3/, $rcline);
        if ($page eq $old) {
            if ($action == 1) {  # Delete
                ; # Do nothing (don't add line to new RC)
            } elsif ($action == 2) {
                $junk = $rcline;
                $junk =~ s/^(\d+$FS3)$old($FS3)/"$1$new$2"/ge;
                $outrc .= $junk . "\n";
            }
        } else {
            $outrc .= $rcline . "\n";
        }
    }
    &WriteStringToFile($fname . ".old", $fileData);  # Backup copy
    &WriteStringToFile($fname, $outrc);
}

# Delete and rename must be done inside locks.
sub DeletePage {
    my ($page, $doRC, $doText) = @_;
    my ($fname, $status);

    $page =~ s/ /_/g;
    $page =~ s/\[+//;
    $page =~ s/\]+//;
    $status = &ValidId($page);
    if ($status ne "") {
#       print "Delete-Page: page $page is invalid, error is: $status<br>\n";
        print Ts('Delete-Page: page %s is invalid', $page) . ".<br>" . Ts('error is: %s', $status) . "<br>\n";
        return;
    }

### 페이지 삭제 시에 keep 화일은 보존해 둠
    &OpenPage($page);
    &OpenDefaultText();
    &SaveKeepSection();
    &ExpireKeepFile();
    &WriteRcLog($OpenPageName, "*", 0, $Now, &GetParam("username",""), &GetRemoteHost(0));
###
    $fname = &GetPageFile($page);
    unlink($fname)  if (-f $fname);
### 페이지 삭제 시에 keep 화일은 보존해 둠
#   $fname = $KeepDir . "/" . &GetPageDirectory($page) .  "/$page.kp";
#   unlink($fname)  if (-f $fname);
###

### lck 화일도 같이 삭제
    $fname = &GetLockedPageFile($page);
    unlink($fname) if (-f $fname);
### cache 화일도 같이 삭제
    &UnlinkHtmlCache($page);
### page count 화일도 같이 삭제
    $fname = &GetCountFile($page);
    unlink ($fname) if (-f $fname);
### hide page by gypark
    if (defined($HiddenPage{$page})) {
        # 숨긴 화일의 경우는 keep 화일과 rclog 를 다 제거한다.
        &EditRecentChanges(1, $page, "");
        $fname = $KeepDir . "/" . &GetPageDirectory($page) .  "/$page.kp";
        unlink($fname)  if (-f $fname);
        delete $HiddenPage{$page};
        &SaveHiddenPageFile();
    }
### 링크 목록을 별도로 관리
    $fname = &GetLinkFile($page);
    unlink($fname) if (-f $fname);
###
    unlink($IndexFile)  if ($UseIndex);
### 페이지 삭제 시에 keep 화일은 보존해 둠
#   &EditRecentChanges(1, $page, "")  if ($doRC);  # Delete page
###
    # Currently don't do anything with page text
}

# Given text, returns substituted text
sub SubstituteTextLinks {
    my ($old, $new, $text) = @_;

    # Much of this is taken from the common markup
    %SaveUrl = ();
    $SaveUrlIndex = 0;
    $text =~ s/$FS//g;              # Remove separators (paranoia)
    if ($RawHtml) {
        $text =~ s/(<html>.*?<\/html>)/StoreRaw($1)/iges;
    }
### {{{ }}} 내의 내용은 링크로 간주하지 않음
    $text = store_raw_codes($text);

    if ($FreeLinks) {
        $text =~
         s/\[\[$FreeLinkPattern\|([^\]]+)\]\]/&SubFreeLink($1,$2,$old,$new)/geo;
        $text =~ s/\[\[$FreeLinkPattern\]\]/&SubFreeLink($1,"",$old,$new)/geo;
        $text =~
         s/\[\[$AnchoredFreeLinkPattern\|([^\]]+)\]\]/&SubFreeLink($1,$3,$old,$new,$2)/geo;
        $text =~ s/\[\[$AnchoredFreeLinkPattern\]\]/&SubFreeLink($1,"",$old,$new,$2)/geo;
    }
    if ($BracketText) {  # Links like [URL text of link]
        # 텍스트 부분에 \]라고 써서 대괄호 자체를 표기할 수 있게 수정
        $text =~ s/(\[$UrlPattern\s+((?:\\\]|[^\]])+?)\])/&StoreRaw($1)/geo;
        $text =~ s/(\[$InterLinkPattern\s+([^\]]+?)\])/&StoreRaw($1)/geo;
    }
    $text =~ s/(\[?$UrlPattern\]?)/&StoreRaw($1)/geo;
    $text =~ s/(\[?$InterLinkPattern\]?)/&StoreRaw($1)/geo;
    if ($WikiLinks) {
        $text =~ s/$LinkPattern/&SubWikiLink($1, $old, $new)/geo;
    }

    $text =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
    return $text;
}

sub SubFreeLink {
    my ($link, $name, $old, $new, $anchor) = @_;
    my ($oldlink);

    $oldlink = $link;
    $link =~ s/^\s+//;
    $link =~ s/\s+$//;
    if (($link eq $old) || (&FreeToNormal($old) eq &FreeToNormal($link))) {
        $link = $new;
    } else {
        $link = $oldlink;  # Preserve spaces if no match
    }
    $link = "[[$link";
    if ( defined $anchor and $anchor ne '' ) {
        $link .= "#$anchor";
    }
    if ($name ne "") {
        $link .= "|$name";
    }
    $link .= "]]";
    return &StoreRaw($link);
}

sub SubWikiLink {
    my ($link, $old, $new) = @_;
    my ($newBracket);

    $newBracket = 0;
    if ($link eq $old) {
        $link = $new;
        if (!($new =~ /^$LinkPattern$/)) {
            $link = "[[$link]]";
        }
    }
    return &StoreRaw($link);
}

# Rename is mostly copied from expire
sub RenameKeepText {
    my ($page, $old, $new) = @_;
    my ($fname, $status, $data, @kplist, %tempSection, $changed);
    my ($sectName, $newText);

    $fname = $KeepDir . "/" . &GetPageDirectory($page) .  "/$page.kp";
    return  if (!(-f $fname));
    ($status, $data) = &ReadFile($fname);
    return  if (!$status);
    @kplist = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
    return  if (length(@kplist) < 1);  # Also empty
    shift(@kplist)  if ($kplist[0] eq "");  # First can be empty
    return  if (length(@kplist) < 1);  # Also empty
    %tempSection = split(/$FS2/, $kplist[0], -1);
    if (!defined($tempSection{'keepts'})) {
        return;
    }

### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
    my ( $old_main, $old_sub ) = split("/", $old);
    my ( $new_main, $new_sub ) = split("/", $new);
    my $old_new_same_main      = ( $old_main eq $new_main );
    my ( $page_main, $page_sub) = split("/", $page);
    my $old_page_same_main      = ( $old_main eq $page_main );
###

    # First pass: optimize for nothing changed
    $changed = 0;
    foreach (@kplist) {
        %tempSection = split(/$FS2/, $_, -1);
        $sectName = $tempSection{'name'};
        if ($sectName =~ /^(text_)/) {
            %Text = split(/$FS3/, $tempSection{'data'}, -1);
            $newText = &SubstituteTextLinks($old, $new, $Text{'text'});
### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
            if ( $old_page_same_main && $old_sub ) {
                if ( $old_new_same_main && $new_sub ) {
                    $newText = &SubstituteTextLinks("/$old_sub", "/$new_sub", $newText);
                }
                else {
                    $newText = &SubstituteTextLinks("/$old_sub", $new, $newText);
                }
            }
###
            $changed = 1  if ($Text{'text'} ne $newText);
        }
        # Later add other section types? (maybe)
    }

    return  if (!$changed);  # No sections changed
    open (my $out, '>', $fname) or return;
    foreach (@kplist) {
        %tempSection = split(/$FS2/, $_, -1);
        $sectName = $tempSection{'name'};
        if ($sectName =~ /^(text_)/) {
            %Text = split(/$FS3/, $tempSection{'data'}, -1);
            $newText = &SubstituteTextLinks($old, $new, $Text{'text'});
### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
            if ( $old_page_same_main && $old_sub ) {
                if ( $old_new_same_main && $new_sub ) {
                    $newText = &SubstituteTextLinks("/$old_sub", "/$new_sub", $newText);
                }
                else {
                    $newText = &SubstituteTextLinks("/$old_sub", $new, $newText);
                }
            }
###

            $Text{'text'} = $newText;
            $tempSection{'data'} = join($FS3, %Text);
            print {$out} $FS1, join($FS2, %tempSection);
        } else {
            print {$out} $FS1, $_;
        }
    }
    close $out;
}

sub RenameTextLinks {
    my ($old, $new) = @_;
    my ($changed, $file, $oldText, $newText, $status);
    my ($oldCanonical, @pageList);

    $old =~ s/ /_/g;
    $oldCanonical = &FreeToNormal($old);
    $new =~ s/ /_/g;
    $status = &ValidId($old);
    if ($status ne "") {
        print "Rename-Text: old page $old is invalid, error is: $status<br>\n";
        return;
    }
    $status = &ValidId($new);
    if ($status ne "") {
        print "Rename-Text: new page $new is invalid, error is: $status<br>\n";
        return;
    }
    $old =~ s/_/ /g;
    $new =~ s/_/ /g;

### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
    my ( $old_main, $old_sub ) = split("/", $old);
    my ( $new_main, $new_sub ) = split("/", $new);
    my $old_new_same_main      = ( $old_main eq $new_main );
###

    # Note: the LinkIndex must be built prior to this routine
    return  if (!defined($LinkIndex{$oldCanonical}));

    @pageList = split(' ', $LinkIndex{$oldCanonical});
    foreach my $page (@pageList) {
### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
        my ( $page_main, $page_sub) = split("/", $page);
        my $old_page_same_main      = ( $old_main eq $page_main );
###

        $changed = 0;
        &OpenPage($page);
        foreach my $section (keys %Page) {
            if ($section =~ /^text_/) {
                &OpenSection($section);
                %Text = split(/$FS3/, $Section{'data'}, -1);
                $oldText = $Text{'text'};
                $newText = &SubstituteTextLinks($old, $new, $oldText);
### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
                if ( $old_page_same_main && $old_sub ) {
                    if ( $old_new_same_main && $new_sub ) {
                        $newText = &SubstituteTextLinks("/$old_sub", "/$new_sub", $newText);
                    }
                    else {
                        $newText = &SubstituteTextLinks("/$old_sub", $new, $newText);
                    }
                }
###
                if ($oldText ne $newText) {
                    $Text{'text'} = $newText;
                    $Section{'data'} = join($FS3, %Text);
                    $Page{$section} = join($FS2, %Section);
                    $changed = 1;
                }
            } elsif ($section =~ /^cache_diff/) {
                $oldText = $Page{$section};
                $newText = &SubstituteTextLinks($old, $new, $oldText);
### 링크변경 개선 - "/하위페이지" 형태의 링크도 변경
                if ( $old_page_same_main && $old_sub ) {
                    if ( $old_new_same_main && $new_sub ) {
                        $newText = &SubstituteTextLinks("/$old_sub", "/$new_sub", $newText);
                    }
                    else {
                        $newText = &SubstituteTextLinks("/$old_sub", $new, $newText);
                    }
                }
###
                if ($oldText ne $newText) {
                    $Page{$section} = $newText;
                    $changed = 1;
                }
            }
            # Later: add other text-sections (categories) here
        }
        if ($changed) {
            $file = &GetPageFile($page);
            &WriteStringToFile($file, join($FS1, %Page));
### 링크 목록을 별도로 관리
            &SaveLinkFile($page);
        }
        &RenameKeepText($page, $old, $new);
    }
}

sub RenamePage {
    my ($old, $new, $doRC, $doText) = @_;
    my ($oldfname, $newfname, $oldkeep, $newkeep, $status);

    $old =~ s/ /_/g;
    $new = &FreeToNormal($new);
    $status = &ValidId($old);
    if ($status ne "") {
        print "Rename: old page $old is invalid, error is: $status<br>\n";
        return;
    }
    $status = &ValidId($new);
    if ($status ne "") {
        print "Rename: new page $new is invalid, error is: $status<br>\n";
        return;
    }
    $newfname = &GetPageFile($new);
    if (-f $newfname) {
        print "Rename: new page $new already exists--not renamed.<br>\n";
        return;
    }
    $oldfname = &GetPageFile($old);
    if (!(-f $oldfname)) {
        print "Rename: old page $old does not exist--nothing done.<br>\n";
        return;
    }

    &CreatePageDir($PageDir, $new);  # It might not exist yet
    rename($oldfname, $newfname);
    &CreatePageDir($KeepDir, $new);
    $oldkeep = $KeepDir . "/" . &GetPageDirectory($old) .  "/$old.kp";
    $newkeep = $KeepDir . "/" . &GetPageDirectory($new) .  "/$new.kp";
    unlink($newkeep)  if (-f $newkeep);  # Clean up if needed.
    rename($oldkeep,  $newkeep);
    unlink($IndexFile)  if ($UseIndex);
### 페이지 이름 변경시, lock 화일도 같이 변경
    my ($oldlock, $newlock);
    $oldlock = &GetLockedPageFile($old);
    if (-f $oldlock) {
        $newlock = &GetLockedPageFile($new);
        rename($oldlock, $newlock);
    }
### cache 화일은 삭제
    &UnlinkHtmlCache($old);
### page count 화일도 변경
    my ($oldcnt, $newcnt);
    $oldcnt = &GetCountFile($old);
    if (-f $oldcnt) {
        $newcnt = &GetCountFile($new);
        &CreatePageDir($CountDir, $new);  # It might not exist yet
        rename($oldcnt, $newcnt);
    }
### hide page by gypark
    if (defined($HiddenPage{$old})) {
        delete $HiddenPage{$old};
        $HiddenPage{$new} = "1";
        &SaveHiddenPageFile();
    }

### 링크 목록을 별도로 관리
    my ($oldlink, $newlink);
    $oldlink = &GetLinkFile($old);
    if (-f $oldlink) {
        $newlink = &GetLinkFile($new);
        &CreatePageDir($LinkDir, $new);  # It might not exist yet
        rename($oldlink, $newlink);
    }
    &EditRecentChanges(2, $old, $new)  if ($doRC);
    if ($doText) {
        &BuildLinkIndexPage($new);  # Keep index up-to-date
        &RenameTextLinks($old, $new);
    }
}

sub DoShowVersion {
    print &GetHeader("", T('Displaying Wiki Version'), "");
### 버전 정보를 별도의 변수에 보관
#   print "<p>UseModWiki version 0.92K2<p>\n";
    print "<p>UseModWiki version $WikiVersion ($WikiRelease)<p>\n";

    if (open(my $fh, '<', './README')) {
        local $/ = undef;
        my $readme = <$fh>;
        $readme = QuoteHtml($readme);

        print "<pre>\n". $readme. "\n</pre>\n\n";
        close $fh;
    }

    print &GetCommonFooter();
}


#END_OF_OTHER_CODE

### 통채로 추가한 함수들은 여기에 둠

### 로그인한 사용자인지 검사
sub LoginUser {
    if (($UserID eq "113") || ($UserID eq "112")) {
        return 0;
    } else {
        return 1;
    }
}

### 최근변경내역에 북마크 기능 도입
sub DoBookmark {
    if (&GetParam('username') eq "") {      # 로그인하지 않은 경우
        &BrowsePage(T($RCName));                # 그냥 최근 변경 내역으로 이동
        return 1;
    }
    if (&GetParam('time') ne "") {
        $UserData{'bookmark'} = &GetParam('time');
    } else {
        $UserData{'bookmark'} = $Now;
    }
    &SaveUserData();
    &BrowsePage(T($RCName));
    return 1;
}

### 링크 목록을 별도로 관리
sub GetLinkFile {
    my ($id) = @_;

    return $LinkDir . "/" . &GetPageDirectory($id) . "/$id.lnk";
}

sub SaveLinkFile {
    my ($page) = @_;
    my (%links, @pagelinks, @interlinks, @urllinks, @alllinks);

    @alllinks = &GetPageLinks($page, 1, 1, 1);

    foreach my $link (@alllinks) {
        if ($link =~ /^$InterLinkPattern$/) {
            push(@interlinks, $link);
        } elsif ($link =~ /^$UrlPattern$/) {
            push(@urllinks, $link);
        } else {
            push(@pagelinks, $link);
        }
    }
    $links{'pagelinks'} = join($FS2, @pagelinks);
    $links{'interlinks'} = join($FS2, @interlinks);
    $links{'urllinks'} = join($FS2, @urllinks);

    &CreatePageDir($LinkDir, $page);
    &WriteStringToFile(&GetLinkFile($page), join($FS1, %links));
}

sub GetPageLinksFromFile {
    my ($name, $pagelink, $interlink, $urllink) = @_;
    my ($status, $data, %links, @result, $fname);

### hide page
    if (&PageIsHidden($name)) {
        return;
    }

    @result = ();
    $fname = &GetLinkFile($name);

    if (!(-f $fname)) {
        &SaveLinkFile($name);
    }

    ($status, $data) = &ReadFile($fname);

    if (!($status)) {
        return &GetPageLinks($name, $pagelink, $interlink, $urllink);
    }

    %links = split($FS1, $data, -1);
### hide page by gypark
#   push (@result, split($FS2, $links{'pagelinks'}, -1)) if ($pagelink);
    push (@result, &GetNotHiddenPages(split($FS2, $links{'pagelinks'}, -1))) if ($pagelink);
###
    push (@result, split($FS2, $links{'interlinks'}, -1)) if ($interlink);
    push (@result, split($FS2, $links{'urllinks'}, -1)) if ($urllink);

    return @result;
}

### page count
sub GetCountFile {
    my ($id) = @_;

    return $CountDir . "/" . &GetPageDirectory($id) . "/$id.cnt";
}

sub GetPageCount {
    my ($id) = @_;
    my ($pagecount, $countfile, $status);
    my ($edit_user, $edit_ip, $view_user, $view_ip, $add)
        = ($Section{'username'}, $Section{'ip'},
            &GetParam('username', ""), $ENV{REMOTE_ADDR}, 0);

    # 카운트 읽어옴
    &CreatePageDir($CountDir, $id);
    $countfile = &GetCountFile($id);
    ($status, $pagecount) = &ReadFile($countfile);
    $pagecount = 0 if ($status == 0);

    # 카운트 갱신 여부 결정
    if ($view_user eq "") {
        if ($edit_ip ne $view_ip) {
            $add = 1;
        }
    } elsif ($edit_user ne $view_user) {
        $add = 1;
    }
    $pagecount += $add;

    # 카운트 기록
    if ($add == 1) {
        &RequestLockDir('count', 1, 1, 0) || return $pagecount;
        &WriteStringToFile($countfile, $pagecount);
        &ReleaseLockDir('count');
    }
    return $pagecount;
}

### file upload
sub DoUpload {
    my $file;
    my $upload = &GetParam('upload');
    my $prev_error = &GetParam('error', "");
    my @uploadError = (
            T('Upload completed successfully'),
            T('Invalid filename'),
            T('You can not upload html or any executable scripts'),
            T('File is too large'),
            T('File has no content'),
            T('Failed to get lock'),
        );

    my $result;

    print &GetHttpHeader();
    print &GetHtmlHeader(T('Upload File') . " : $SiteName", "");
    print $q->h2(T('Upload File')) . "\n";
    if (!(&UserCanEdit("",1))) {
        print T('Uploading is not allowed');
        print $q->end_html;
        return;
    }
    if ($prev_error) {
        print "<b>$uploadError[$prev_error]</b><br><hr>\n";
    } elsif ($upload) {
        $file = &GetParam('upload_file');
        $result = &UploadFile($file);
        print "<b>$uploadError[$result]</b><br><hr>\n";
    }
    &PrintUploadFileForm();
    print $q->end_html;
}

sub PrintUploadFileForm {
    print T('Select the file you want to upload') . "\n";
    print "<br>".Ts('File must be smaller than %s MB', ($MaxPost / 1024 / 1024)) . "\n";
    print $q->start_form('post',"$ScriptName", 'multipart/form-data') . "\n";
    print "<input type='hidden' name='action' value='upload'>";
    print "<input type='hidden' name='upload' value='1'>" . "\n";
    print "<center>" . "\n";
    print qq|<div class="file-upload-container">| . "\n";
    print qq|<div class="file-upload">| . "\n";
    print $q->filefield("upload_file","",60,80) . "\n";
    print "&nbsp;&nbsp;" . "\n";
    print qq|</div>| . "\n";
    print $q->submit(T('Upload')) . "\n";
    print qq|</div>| . "\n";
    print "</center>" . "\n";
    print $q->end_form();
}

# $dir내에 $file이름과 동일한 파일이 있을 경우 뒤에 숫자를 붙여 겹치지 않는 번호를 반환함
sub GetUniqueUploadFilename {
    my ( $dir, $file ) = @_;

    return $file if ( not -f "$dir/$file" );

    my ( $filename, $ext ) = ( $file =~ m/^(.+)(\.[^.]+)$/ );
    unless ( $ext ) {
        $filename = $file;
        $ext      = '';
    }

    my $num = 1;
    while ( -f "$dir/${filename}_$num$ext" ) {
        $num++;
    }

    return "${filename}_$num$ext";
}

sub UploadFile {
    my ($file) = @_;
    my ($filename);

    if ($file =~ m/\//) {
        $file =~ m/(.*)\/([^\/]*)/;
        $filename = $2;
    } elsif ($file =~ m/\\/) {
        $file =~ m/(.*)\\([^\\]*)/;
        $filename = $2;
    } else {
        $filename = $file;
    }

    if (($filename eq "") || ($filename =~ /\0/)) {
        return 1;
    }

    if ($filename =~ m/(\.pyc|\.py|\.pl|\.html|\.htm|\.php|\.cgi)$/i) {
        return 2;
    }

    $filename =~ s/ /_/g;
    $filename =~ s/#/_/g;

    &RequestLockDir('upload', 5, 2, 0) || return 5;
    my $target      = GetUniqueUploadFilename( $UploadDir, $filename );
    my $target_full = "$UploadDir/$target";

    &CreateDir($UploadDir);

    my $fh;
    if (!open($fh, '>', $target_full)) {
        &ReleaseLockDir('upload');
        die Ts('cant opening %s', $target_full) . ": $!";
    }
    &ReleaseLockDir('upload');
    binmode $fh;
    while (<$file>) {
        print {$fh} $_;
    }
    close $fh;
    chmod(0644, "$target_full");

    if ((-s "$target_full") > $MaxPost) {
        unlink "$target_full";
        return 3;
    }

    if ((-s "$target_full") == 0) {
        unlink "$target_full";
        return 4;
    }

    print T('Following is the Interlink of your file') . "<br>\n";
    print "<div style='text-align:center; font-size:larger; font-weight:bold;'>\n";
    print "<input style='background-color: #F6F8FA;'  type='text' id='uploadlink' readonly value='Upload:$target'> ";
    print $q->button(
                -name=>T("Copy"),
                -onClick=>"copy_clip('uploadlink', this)"
                );
    print "</div>\n";
    return 0;
}

### DeleteUploadedFiles 매크로
sub DoDeleteUploadedFiles {
    my (%vars, @files);

    print &GetHeader("", T('Delete Uploaded Files'), "");

    if (!(&UserIsAdmin())) {
        print T('Deleting is not allowed');
        print "<br>\n";
    } else {
        %vars = $q->Vars;
        @files = split(/\0/,$vars{'files'}, -1);
        foreach (@files) {
            if ( -d "$UploadDir/$_" ) {
                foreach my $sub_f ( glob("$UploadDir/$_/*") ) {
                    unlink $sub_f;
                }
                if ( rmdir "$UploadDir/$_" ) {
                    print Ts('%s is deleted successfully', $_)."<br>";
                }
                else {
                    print Ts('%s can not be deleted', $_). " : $!<br>";
                }
            }
            else {
                if (unlink ("$UploadDir/$_")) {
                    print Ts('%s is deleted successfully', $_)."<br>";
                } else {
                    print Ts('%s can not be deleted', $_). " : $!<br>";
                }
            }
        }
    }

    if (&GetParam('pagename') ne "") {
        print "<hr size='1'>".Ts('Return to %s' , &GetPageLink(&GetParam('pagename')));
    }

    print &GetCommonFooter();
}

### oekaki
sub DoOekaki {
    my $mode = &GetParam('mode','paint');

    print &GetHttpHeader();
    print &GetHtmlHeader(T("Oekaki $mode") . " : $SiteName", "");
    print $q->h2(T('Oekaki')) . "\n";
    if (!(&UserCanEdit("",1))) {
        print T('Oekaki is not allowed');
        print $q->end_html;
        return;
    }
    if ($mode eq "exit") {
        &OekakiExit();
    } elsif ($mode eq "save") {
        &OekakiSave();
    } elsif ($mode eq "paint") {
        &OekakiPaint();
    } else {
        print Ts('Invalid action parameter %s', ": $mode");
    }

    print $q->end_html;
}

sub OekakiExit {
    my $filename_pattern = qr/^oekaki(_\d+)?.png$/;

    my (@allfiles, @files, %filemtime);

    opendir (DIR, "$UploadDir") || die Ts('cant opening %s', $UploadDir) . ": $!";
    @allfiles = grep { !/^\.\.?$/ } readdir(DIR);
    close(DIR);

    foreach (@allfiles) {
        if ($_ =~ $filename_pattern) {
            push (@files, $_);
            $filemtime{$_} = ($Now - (-M "$UploadDir/$_") * 86400);
        }
    }

    @files = sort {
        $filemtime{$b} <=> $filemtime{$a}
                ||
                $a cmp $b
    } @files;

    print T('If saving oekaki was done successfully')."<br>\n";
    print T('Following is the Interlink of your file') . "<br>\n";
    print "<div style='text-align:center; font-size:larger; font-weight:bold;'>\n";
    print "<input style='background-color: #F6F8FA;'  type='text' id='uploadlink' readonly value='Upload:$files[0]'> ";
    print $q->button(
                -name=>T("Copy"),
                -onClick=>"copy_clip('uploadlink', this)"
                );
    print "<br>";
    print "<img style='border: solid 1 gray;' src='$UploadUrl/$files[0]'>\n";
    print "</div>\n";

    print "<hr size='1'>";
    print T('If you want to paint a new picture')."<br>\n";

    print qq|
<div align="center">
<form action="$ScriptName" method="POST">
<input type="hidden" name="action" value="oekaki">
width [1000-40]<input type="text" name="width" size="4" maxlength="4" value="300">
height [1000-40]<input type="text" name="height" size="4" maxlength="4" value="300">
<input type="submit" value="OK">
</form>
</div>
|;

    print "<hr size='1'>";
    print T('If the picture above is not what you had painted, find your picture from the follwing list')."<br>\n";
    print "<UL>\n";
    foreach (@files) {
        print "<LI>";
        print "<a href='$UploadUrl/$_' target='OekakiPreview'>Upload:$_</a>";
        print " (".&TimeToText($filemtime{$_}).")</LI>\n";
    }
    print "</UL>\n";

}

sub OekakiSave {
    my ($buffer, $target_full);

# POST 데이타 읽음
    read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

# 데이터 검사
    my $mark = "Content-type:image/0";
    if (!($buffer =~ m|$mark|)) {
        die ("Invalid POST data");
    }

# png 데이터의 처음 부분의 index 결정
    my $start = index($buffer, $mark);
    $start = index($buffer, "\r\n", $start+1);
    $start = index($buffer, "\r\n", $start+1);
    if ($start < 0) {
        die ("Can't find PNG data");
    }
    $start += 2;

# png 데이터 결정
    my $png_data = substr($buffer, $start);

# 락을 획득
    if (!(&RequestLockDir('oekaki', 4, 3, 0))) {
        die("can not get lock");
    }

# 저장할 화일명 결정
    $target_full = $UploadDir."/".GetUniqueUploadFilename($UploadDir, 'oekaki.png');

# 저장
    &CreateDir($UploadDir);
    &WriteBinaryToFile($target_full, $png_data);

# 락을 해제
    &ReleaseLockDir('oekaki');
    chmod(0644, "$target_full");

# 종료
    print "Content-type: text/plain\n\n";
    print "success\n";
}

sub OekakiPaint {
    my ($imageWidth, $imageHeight) = (
        &GetParam('width','300'),
        &GetParam('height','300')
    );

    $imageWidth = 40 if ($imageWidth < 40);
    $imageWidth = 1000 if ($imageWidth > 1000);
    $imageHeight = 40 if ($imageHeight < 40);
    $imageHeight = 1000 if ($imageHeight > 1000);

    my ($appletWidth, $appletHeight) = (
        (($imageWidth < 300)?700:($imageWidth+400)),
        (($imageHeight < 300)?600:($imageHeight+300))
    );

    print qq|
<script Language="JavaScript">
<!--
function getColors(){
colors=document.paintbbs.getColors();
}
//-->
</script>

<div align="center">
<form action="$ScriptName" method="POST">
<input type="hidden" name="action" value="oekaki">
width [1000-40]<input type="text" name="width" size="4" maxlength="4" value="$imageWidth">
height [1000-40]<input type="text" name="height" size="4" maxlength="4" value="$imageHeight">
<input type="submit" value="OK">
</form>
</div>

<p align="center">

<applet name="oekakibbs" codebase="./" code="a.p.class" archive="$OekakiJarUrl" width="$appletWidth" height="$appletHeight" mayscript>
<param name="cgi" value="$ScriptName${\(&ScriptLinkChar())}action=oekaki&mode=save">
<param name="url" value="$ScriptName${\(&ScriptLinkChar())}action=oekaki&mode=exit">

<param name="popup" value="0">
<param name="tooltype" value="full">
<param name="anime" value="0">
<param name="animesimple" value="1">
<param name="tooljpgpng" value="0">
<param name="tooljpg" value="0">
<param name="picw" value="$imageWidth">
<param name="pich" value="$imageHeight">
<param name="baseC" value="888888">
<param name="brightC" value="aaaaaa">
<param name="darkC" value="666666">
<param name="backC" value="000000">
<param name="mask" value="12">
<param name="toolpaintmode" value="1">
<param name="toolmask" value="1">
<param name="toollayer" value="1">
<param name="toolalpha" value="1">
<param name="toolwidth" value="200">
<param name="target" value="_self">
<param name="catalog" value="0">
<param name="catalogwidth" value="100">
<param name="catalogheight" value="100">
</applet>

</p>
|;
}

### 관심 페이지
sub DoInterest {
    my ($title, $temp);
    my $mode = &GetParam('mode');
    my $id = &GetParam('id');
    my $failMsg = T('Fail to access Interest Page List');

#   if (&GetParam('username') eq "") {
    if (!&LoginUser()) {
        print &GetHeader('', $failMsg, '');
        print T('You must login to do this action');
        print &GetCommonFooter();
        return;
    }
    if ($mode eq "add") {
        $title = T('Add a page to Interest Page List');
    } elsif (&GetParam('mode') eq "remove") {
        $title = T('Remove a page from Interest Page List');
    } else {
        print &GetHeader('', $failMsg, '');
        print Ts('Invalid action parameter %s', $mode);
        print &GetCommonFooter();
        return;
    }

    $temp = &ValidId($id);
    if ($temp ne "") {
        print &GetHeader('', $failMsg, '');
        print $temp;
        print &GetCommonFooter();
        return;
    }

    print &GetHeader('', $title, '');
    if ($mode eq "add") {
        $UserInterest{$id} = "1";
        print Ts('Page %s is added to your Interest Page List', $id);
    } else {
        delete $UserInterest{$id};
        print Ts('Page %s is removed from your Interest Page List', $id);
    }

    $UserData{'interest'} = join($FS2, %UserInterest);
    &SaveUserData();
    print "<hr size='1'>";
    print Ts('Return to %s' , &GetPageLink($id));
    print &GetCommonFooter();
    return 1;

}

### hide page by gypark
sub DoPageHide {
    my ($id);

    print &GetHeader('', T('Hide or Unhide page'), '');
    return  if (!&UserIsAdminOrError());
    $id = &GetParam("id", "");
    if ($id eq "") {
        print '<p>', T('Missing page id to hide/unhide');
        return;
    }
    return  if (!&ValidIdOrDie($id));       # Later consider nicer error?

    if (&GetParam("set", 1)) {
        $HiddenPage{$id} = "1";
    } else {
        delete $HiddenPage{$id};
    }

    if (!(&SaveHiddenPageFile())) {
        print T('Hiding/Unhiding page failed');
        print &GetCommonFooter();
        return;
    }

    if (defined ($HiddenPage{$id})) {
        print '<p>', Ts('%s is hidden.', $id), '<br>';
    } else {
        print '<p>', Ts('%s is revealed.', $id), '<br>';
    }
    print &GetCommonFooter();
}

sub PageIsHidden {
    my ($id) = @_;

    if ((!(defined $HiddenPage{$id})) || (&UserIsAdmin())) {
        return 0;
    } else {
        return 1;
    }
}

sub GetNotHiddenPages {
    my (@pages) = @_;
    my @notHiddenPages = ();

    foreach (@pages) {
        push (@notHiddenPages, $_) if (!(&PageIsHidden($_)));
    }
    return @notHiddenPages;
}

sub SaveHiddenPageFile {
    my $data;

    $data = join($FS1, %HiddenPage);

    &WriteStringToFile($HiddenPageFile, $data);
    chmod(0644, $HiddenPageFile);

    return 1;
}

sub WriteBinaryToFile {
    my ($file, $string) = @_;

    open(my $out, '>', $file) or die(Ts('cant write %s', $file) . ": $!");
    binmode $out;
    print {$out} $string;
    close $out;
}

### template page
sub GetTemplatePageText {
    my ($newpage) = @_;
    my $templatePage = "";
    my ($fname, $status, $data);

    if ($newpage eq "") {
        return "";
    }

    if ($newpage =~ /^(.*)\/(.*)/) {
        $templatePage = $1 . "/" . $TemplatePage;
    } else {
        $templatePage = $TemplatePage;
    }

    $fname = &GetPageFile($templatePage);
    if (!(-f $fname)) {
        $fname = &GetPageFile($TemplatePage);
        if (!(-f $fname)) {
            return "";
        }
    }

    ($status, $data) = &ReadFile($fname);
    if (!$status) {
        return "";
    }

    my %temp_Page = split(/$FS1/, $data, -1);
    my %temp_Section = split(/$FS2/, $temp_Page{'text_default'}, -1);
    my %temp_Text = split(/$FS3/, $temp_Section{'data'}, -1);
### template macro
    my $return_text = &TemplateMacroSubst($newpage, $temp_Text{'text'});

    return $return_text;
}

### template macro
sub TemplateMacroSubst {
    my ($newpage, $text) = @_;
    my ($newpage_main, $newpage_sub);

### null
    $text =~ s/<template_null>//gi;

### pagename, mainpagename, subpagename
    if ($newpage =~ /^(.*)\/(.*)/) {
        ($newpage_main, $newpage_sub) = ($1, $2);
    } else {
        ($newpage_main, $newpage_sub) = ($newpage, "");
    }

    $text =~ s/<template_pagename>/$newpage/gi;
    $text =~ s/<template_mainpagename>/$newpage_main/gi;
    $text =~ s/<template_subpagename>/$newpage_sub/gi;
    $text =~ s/<template_date>/&CalcDay($Now)/gei;

    return "$text";
}

### rss from usemod1.0
sub DoRss {
    print "Content-type: text/xml; charset=$HttpCharset\n\n";
    &DoRc(0);
}

sub GetRcRss {
    my ($rssHeader, $headList, $items);

    # Normally get URL from script, but allow override
    $FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
    $QuotedFullUrl = &QuoteHtml($FullUrl);
    $SiteDescription = &QuoteHtml($SiteDescription);

    my $ChannelAbout = &QuoteHtml($FullUrl . &ScriptLinkChar()
        . $ENV{QUERY_STRING});
    $rssHeader = <<RSS ;
<?xml version="1.0" encoding="$HttpCharset"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns="http://purl.org/rss/1.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:wiki="http://purl.org/rss/1.0/modules/wiki/"
>
    <channel rdf:about="$ChannelAbout">
        <title>${\(&QuoteHtml($SiteName))}</title>
        <link>${\($QuotedFullUrl . &QuoteHtml(&ScriptLinkChar()."$RCName"))}</link>
        <description>${\(&QuoteHtml($SiteDescription))}</description>
        <wiki:interwiki>
            <rdf:Description link="$QuotedFullUrl">
                <rdf:value>$InterWikiMoniker</rdf:value>
            </rdf:Description>
        </wiki:interwiki>
        <items>
            <rdf:Seq>
RSS
    ($headList, $items) = &GetRc(0, @_);
    $rssHeader .= $headList;
    return <<RSS ;
$rssHeader
            </rdf:Seq>
        </items>
    </channel>
    <image rdf:about="${\(&QuoteHtml($RssLogoUrl))}">
        <title>${\(&QuoteHtml($SiteName))}</title>
        <url>$RssLogoUrl</url>
        <link>$QuotedFullUrl</link>
    </image>
$items
</rdf:RDF>
RSS
}

sub GetRc {
    my $rcType = shift;
    my @outrc = @_;
    my ($date, $newtop, $author, $inlist, $result);
    my ($showedit, $link, $all, $idOnly, $headItem, $item);
    my ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);
    my ($rcchangehist, $tEdit, $tChanges, $tDiff);
    my ($headList, $historyPrefix, $diffPrefix);
    my %extra = ();
    my %changetime = ();
    my %pagecount = ();
    # Slice minor edits
    $showedit = &GetParam("rcshowedit", $ShowEdits);
    $showedit = &GetParam("showedit", $showedit);
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
    my $num_items = &GetParam("items", 0);
    my $num_printed = 0;

    if ($showedit != 1) {
        my @temprc = ();
        foreach my $rcline (@outrc) {
            ($ts, $pagename, $summary, $isEdit, $host) = split(/$FS3/, $rcline);
            if ($showedit == 0) {  # 0 = No edits
                push(@temprc, $rcline)  if (!$isEdit);
            } else {               # 2 = Only edits
                push(@temprc, $rcline)  if ($isEdit);
            }
        }
        @outrc = @temprc;
    }
# Optimize param fetches out of main loop
    $rcchangehist = &GetParam("rcchangehist", 1);
# Optimize translations out of main loop
    $tEdit    = T('(edit)');
    $tDiff    = T('(diff)');
    $tChanges = T('changes');
### 북마크
#   $diffPrefix = $QuotedFullUrl . &QuoteHtml("?action=browse\&diff=4\&id=");
    $diffPrefix = $QuotedFullUrl . &QuoteHtml(&ScriptLinkChar()."action=browse\&diff=5\&id=");
###
    $historyPrefix = $QuotedFullUrl . &QuoteHtml(&ScriptLinkChar()."action=history\&id=");
    foreach my $rcline (@outrc) {
        ($ts, $pagename) = split(/$FS3/, $rcline);
        $pagecount{$pagename}++;
        $changetime{$pagename} = $ts;
    }
    $date = "";
    $all = &GetParam("rcall", 0);
    $all = &GetParam("all", $all);
    $newtop = &GetParam("rcnewtop", $RecentTop);
    $newtop = &GetParam("newtop", $newtop);
    $idOnly = &GetParam("rcidonly", "");
    $inlist = 0;
    $headList = '';
    $result = '';
    @outrc = reverse @outrc if ($newtop);
    foreach my $rcline (@outrc) {
        ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
            = split(/$FS3/, $rcline);
        next  if ((!$all) && ($ts < $changetime{$pagename}));
        next  if (($idOnly ne "") && ($idOnly ne $pagename));
### hide page
        next if (&PageIsHidden($pagename));
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
        $num_printed++;
        last if (($num_items > 0) && ($num_printed > $num_items));
###
        %extra = split(/$FS2/, $extraTemp, -1);
        if ($date ne &CalcDay($ts)) {
            $date = &CalcDay($ts);
            if (1 == $rcType) {  # HTML
                # add date, properly closing lists first
                if ($inlist) {
                    $result .= "</UL>\n";
                    $inlist = 0;
                }
                $result .= "<p><strong>" . $date . "</strong></p>\n";
                if (!$inlist) {
                    $result .= "<UL>\n";
                    $inlist = 1;
                }
            }
        }
        if (0 == $rcType) {  # RSS
            ($headItem, $item) = &GetRssRcLine($pagename, $ts, $host,
                        $extra{'name'}, $extra{'id'}, $summary, $isEdit,
                        $pagecount{$pagename}, $extra{'revision'},
                        $diffPrefix, $historyPrefix);
            $headList .= $headItem;
            $result   .= $item;
        } else {  # HTML
            $result .= &GetHtmlRcLine($pagename, $ts, $host, $extra{'name'},
                        $extra{'id'}, $summary, $isEdit,
                        $pagecount{$pagename}, $extra{'revision'},
                        $tEdit, $tDiff, $tChanges, $all, $rcchangehist);
        }
    }
    if (1 == $rcType) {
        $result .= "</UL>\n"  if ($inlist);  # Close final tag
    }
    return ($headList, $result);  # Just ignore headList for HTML
}

sub GetRssRcLine {
    my ($pagename, $timestamp, $host, $userName, $userID, $summary,
        $isEdit, $pagecount, $revision, $diffPrefix, $historyPrefix) = @_;
    my ($itemID, $description, $authorLink, $author, $status,
        $importance, $date, $item, $headItem);

# encode pagename for URL (ext1.88)
    my $encoded_pagename = &EncodeUrl($pagename);

    # Add to list of items in the <channel/>
    $itemID = $FullUrl . &ScriptLinkChar()
            . &GetOldPageParameters('browse', $encoded_pagename, $revision);
    $itemID = &QuoteHtml($itemID);
    $headItem = "                <rdf:li rdf:resource=\"$itemID\"/>\n";
# Add to list of items proper.
    if (($summary ne "") && ($summary ne "*")) {
        $description = &QuoteHtml($summary);
    }
    $host = &QuoteHtml($host);
    $host =~ s/\d+$/xxx/;
    if ($userName) {
        $author = &QuoteHtml($userName);
        $authorLink = "link=\"$QuotedFullUrl".&ScriptLinkChar()."$author\"";
    } else {
        $author = $host;
    }
    $status = (1 == $revision) ? 'new' : 'updated';
    $importance = $isEdit ? 'minor' : 'major';
    $timestamp += $TimeZoneOffset;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($timestamp);
    $year += 1900;
    $date = sprintf("%4d-%02d-%02dT%02d:%02d:%02d+%02d:00",
        $year, $mon+1, $mday, $hour, $min, $sec, ($TimeZoneOffset/(60*60) + $RssTimeZone));
    $pagename = &QuoteHtml($pagename);
    # Write it out longhand
    $item = <<RSS ;
    <item rdf:about="$itemID">
        <title>$pagename</title>
        <link>$QuotedFullUrl${\(&ScriptLinkChar())}$encoded_pagename</link>
        <description>$description</description>
        <dc:date>$date</dc:date>
        <dc:creator>$author</dc:creator>
        <dc:contributor>
            <rdf:Description wiki:host="$host" $authorLink>
                <rdf:value>$author</rdf:value>
            </rdf:Description>
        </dc:contributor>
        <wiki:status>$status</wiki:status>
        <wiki:importance>$importance</wiki:importance>
        <wiki:diff>$diffPrefix$encoded_pagename</wiki:diff>
        <wiki:version>$revision</wiki:version>
        <wiki:history>$historyPrefix$encoded_pagename</wiki:history>
    </item>
RSS
    return ($headItem, $item);
}

sub GetHtmlRcLine {
### 현재는 사용되지 않음
    die "GetHtmlRcLine -- must not be executed!!!";
}

sub EncodeUrl {
    my ($string) = @_;
    $string =~ s!([^:/&?#=a-zA-Z0-9_.-])!uc sprintf "%%%02x", ord($1)!eg;
    return $string;
}

sub DecodeUrl {
    my ($string) = @_;
    $string =~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge;
    return $string;
}

# 금지단어
sub TextIsBanned {
    my ($text) = @_;
    my ($data, $status);

    ($status, $data) = &ReadFile("$DataDir/bantext");
    return if (!$status);

    $data =~ s/\r//g;
    foreach (split(/\n/, $data)) {
        next if ((/^\s*$/) || (/^#/));
        return $1 if ($text =~ /($_)/i);
    }
    return;
}

# $str 의 인코딩을 $from 에서 $to 로 컨버트
sub convert_encode {
    my ($str, $from, $to) = @_;
    $str = encode($to, decode($from, $str));
    return $str;
}

# 인자를 $HashKey를 salt로 하여 crypt하고, 앞의 두 바이트 제외하여 반환
sub simple_crypt {
    my ($orig) = @_;

    my $encrypt = crypt($orig, $HashKey);

    return substr($encrypt, 2);
}

# 섹션 단위 편집을 위한 내부 함수
# {{{ }}} 등, 헤드라인이나 페이지 링크 관련 작업을 할 때 고려하면 안 될 부분을 빼낸다
sub store_raw_codes {
    my ($text) = @_;

    $text =~ s/(^{{{\n(.*?)\n}}}$)/StoreRaw($1)/igesm;
    $text =~ s/(^{{{#!(\w+( .+?)?)\n(.*?)\n}}}$)/StoreRaw($1)/igesm;
    $text =~ s/(^{{{(\w+)(\|(n|\d+|n\d+|\d+n))?\n(.*?)\n}}}$)/StoreRaw($1)/igesm;
    $text =~ s"(<nowiki>.*?</nowiki>)"StoreRaw($1)"iges;
    $text =~ s"(<pre>.*?</pre>)"StoreRaw($1)"iges;
    $text =~ s"(<code>.*?</code>)"StoreRaw($1)"iges;

    return $text;
}

# 스트링의 인코딩을 추측해서, 내 HttpCharset으로 컨버트
sub guess_and_convert {
    my ($string) = @_;

    # legal UTF-8인지 체크
    if ($HttpCharset =~ /utf-8|utf8/i) {
        if (eval { require Unicode::CheckUTF8; }) {
            if (Unicode::CheckUTF8::is_utf8($string)) {
                # ok
                return $string;
            }
        }
    }

    # 추측
    if (eval { require Encode::Guess; }) {
        my @suspects = (@UrlEncodingGuess, 'utf8');
        my $decoder = Encode::Guess::guess_encoding($string, @suspects);
        if (ref($decoder)) {
            # 추측 성공
            return convert_encode($string, $decoder->name, $HttpCharset);
        }
    }

    # 모듈이 없거나, 있지만 추측 실패. 변환 포기
    return $string;
}

# $str - 쪼갤 스트링
# $length - 앞에서부터의 문자 갯수
# return: (처음 length 길이의 스트링, 나머지 스트링)
sub split_string {
    my ($str, $length) = @_;

    my $chars = decode( $HttpCharset, $str );
    my $first = substr( $chars, 0, $length );
    my $last  = substr( $chars, $length );

    return ( encode( $HttpCharset, $first ), encode( $HttpCharset, $last ) );
}

# Twitter
# $msg - 트위터에 올릴 내용
sub PostTwitter {
    my $msg = shift;

    if ( eval "require Net::Twitter::Lite::WithAPIv1_1;" ) {
        my $msg_length = 140;

        # URL은 %인코딩한 후, t.co로 변환될때 길이가 얼마나 줄어들지(때론 늘어날지) 고려
        my $shorterlink = sub {
            my $url = shift;
            my $converted = EncodeUrl( $url );
            $msg_length += length($converted) - 20;
            return $converted;
        };

        my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
                consumer_key        => $TwitterConsumerKey,
                consumer_secret     => $TwitterConsumerSecret,
                access_token        => $TwitterAccessToken,
                access_token_secret => $TwitterAccessTokenSecret,
                legacy_lists_api => 0,
                ssl => 1,
                );

        # 긴 URL 줄이기
        $msg =~ s/$UrlPattern/$shorterlink->($1)/ge;

        # 140자 제한
        $msg = decode($HttpCharset, $msg);
        $msg = substr($msg, 0, $msg_length);
# URI 모듈 1.40 이상을 쓰는 경우는 아래 주석 처리
#         $msg = encode("UTF-8", $msg);

        my $result = eval { $nt->update($msg) };

        if ( $@ ) {
            my ( undef, $filename, $line, $subroutine ) = caller(0);
            warn "twitter error [$filename:$line:$subroutine] [$@]";
        }
    }
}

### 통채로 추가한 함수들의 끝

### 환경 변수들을 지정하는 루틴을 제거. 무조건 config file 를 읽음.
if (-f $ConfigFile) {
    do "$ConfigFile";
} else {
    die "Can not load config file";
}

&DoWikiRequest()  if ($RunCGI && !(defined $_ and $_ eq 'nocgi'));   # Do everything.
1; # In case we are loaded from elsewhere
# == End of UseModWiki script. ===========================================

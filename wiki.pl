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

###############
### added by gypark
### wiki.pl 버전 정보
use vars qw($WikiVersion $WikiRelease $HashKey);
$WikiVersion = "0.92K3-ext1.76";
$WikiRelease = "2005-02-27";

$HashKey = "salt"; # 2-character string
###
###############

local $| = 1;  # Do not buffer output (localized for mod_perl)

# Configuration/constant variables:
###############
### modified by gypark
### 제일 끝에 ConfigFile 등등 추가
use vars qw(@RcDays @HtmlPairs @HtmlSingle
	$TempDir $LockDir $DataDir $HtmlDir $UserDir $KeepDir $PageDir
	$InterFile $RcFile $RcOldFile $IndexFile $FullUrl $SiteName $HomePage
	$LogoUrl $RcDefault $IndentLimit $RecentTop $EditAllowed $UseDiff
	$UseSubpage $UseCache $RawHtml $SimpleLinks $NonEnglish $LogoLeft
	$KeepDays $HtmlTags $HtmlLinks $UseDiffLog $KeepMajor $KeepAuthor
	$FreeUpper $EmailNotify $SendMail $EmailFrom $FastGlob $EmbedWiki
	$ScriptTZ $BracketText $UseAmPm $UseIndex $UseLookup
	$RedirType $AdminPass $EditPass $UseHeadings $NetworkFile $BracketWiki
	$FreeLinks $WikiLinks $AdminDelete $FreeLinkPattern $RCName $RunCGI
	$ShowEdits $ThinLine $LinkPattern $InterLinkPattern $InterSitePattern
	$UrlProtocols $UrlPattern $ImageExtensions $RFCPattern $ISBNPattern
	$FS $FS1 $FS2 $FS3 $CookieName $SiteBase $StyleSheet $NotFoundPg
	$FooterNote $EditNote $MaxPost $NewText $NotifyDefault $HttpCharset);
###
###############

###############
### added by gypark
### 패치를 위해 추가된 환경설정 변수
use vars qw(
	$UserGotoBar $UserGotoBar2 $UserGotoBar3 $UserGotoBar4 
	$ConfigFile $SOURCEHIGHLIGHT @SRCHIGHLANG $LinkFirstChar
	$EditGuideInExtern $SizeTopFrame $SizeBottomFrame
	$LogoPage $CheckTime $LinkDir $IconDir $CountDir $UploadDir $UploadUrl
	$HiddenPageFile $TemplatePage
	$InterWikiMoniker $SiteDescription $RssLogoUrl $RssDays $RssTimeZone
	$SlashLinks $InterIconDir $SendPingAllowed $JavaScript
	$UseLatex
	);
###
###############

use vars qw($DocID $ImageTag $ClickEdit $UseEmoticon $EmoticonPath $EditPagePos $EditFlag);		# luke
use vars qw($TableOfContents @HeadingNumbers $NamedAnchors $AnchoredLinkPattern);
use vars qw($TableTag $TableMode);

# Note: $NotifyDefault is kept because it was a config variable in 0.90
# Other global variables:
use vars qw(%Page %Section %Text %InterSite %SaveUrl %SaveNumUrl
	%KeptRevisions %UserCookie %SetCookie %UserData %IndexHash %Translate
	%LinkIndex $InterSiteInit $SaveUrlIndex $SaveNumUrlIndex $MainPage
	$OpenPageName @KeptList @IndexList $IndexInit
	$q $Now $UserID $TimeZoneOffset $ScriptName $BrowseCode $OtherCode);

###############
### added by gypark
### 패치를 위해 추가된 내부 전역 변수
use vars qw(%RevisionTs $FS_lt $FS_gt $StartTime $Sec_Revision $Sec_Ts
	$ViewCount $AnchoredFreeLinkPattern %UserInterest %HiddenPage
	$pageid $IsPDA $MemoID
	$QuotedFullUrl
	%MacroFunc %MacroFile
	$UseShortcut $UseShortcutPage);
###
###############

# == Configuration =====================================================
###############
### replaced by gypark
### 보안을 위해서 데이타 저장 공간을 다른 곳으로 지정
### 적절히 바꾸어서 사용할 것
# $DataDir     = "data"; # Main wiki directory
$DataDir     = "data";    # Main wiki directory
$ConfigFile  = "config.pl"; # path of config file
###
###############
$RunCGI      = 1;       # 1 = Run script as CGI,  0 = Load but do not run

# Default configuration
$CookieName  = "Wiki";          # Name for this wiki (for multi-wiki sites)
$SiteName    = "Wiki";          # Name of site (used for titles)
$HomePage    = "HomePage";      # Home page (change space to _)
$RCName      = "RecentChanges"; # Name of changes page (change space to _)
$LogoUrl     = "";     # URL for site logo ("" for no logo)
$ENV{PATH}   = "/usr/bin/:/bin/";     # Path used to find "diff"
$ScriptTZ    = "";              # Local time zone ("" means do not print)
$RcDefault   = 30;              # Default number of RecentChanges days
@RcDays      = qw(1 3 7 30 90); # Days for links on RecentChanges
$KeepDays    = 14;              # Days to keep old revisions
$SiteBase    = "";              # Full URL for <BASE> header
$FullUrl     = "";              # Set if the auto-detected URL is wrong
$RedirType   = 1;               # 1 = CGI.pm, 2 = script, 3 = no redirect
$AdminPass   = "admin";         # Set to non-blank to enable password(s)
$EditPass    = "edit";          # Like AdminPass, but for editing only
$StyleSheet  = "wiki.css";      # URL for CSS stylesheet (like "/wiki.css")
$NotFoundPg  = "";              # Page for not-found links ("" for blank pg)
$EmailFrom   = "Wiki";          # Text for "From: " field of email notes.
$SendMail    = "/usr/sbin/sendmail";  # Full path to sendmail executable
$FooterNote  = "";              # HTML for bottom of every page
$EditNote    = "";              # HTML notice above buttons on edit page
$MaxPost     = 1024 * 1024 * 1;  # Maximum 210K posts (about 200K for pages)
$NewText     = "";              # New page text ("" for default message)
$HttpCharset = "euc-kr";              # Charset for pages, like "iso-8859-2"
$UserGotoBar = "<a href='/'>Home</a>";              # HTML added to end of goto bar
$UserGotoBar2 = "";
$UserGotoBar3 = "";
$UserGotoBar4 = "";
# do "./translations/korean.pl";    # Path of translation file
$SOURCEHIGHLIGHT    = "/usr/local/bin/source-highlight";    # path of source-highlight
@SRCHIGHLANG = qw(cpp java javascript prolog perl php3 python flex changeelog);
$LinkFirstChar = 1;    # 1 = link on first character,  0 = followed by "?" mark (classical)
$EditGuideInExtern = 0; # 1 = show edit guide in bottom frame, 0 = don't show
$SizeTopFrame = 160;
$SizeBottomFrame = 110;
$LogoPage   = "";	# this page will be displayed when no parameter
$CheckTime = 0;   # 1 = mesure the processing time (requires Time::HiRes module), 0 = do not 
$IconDir = "./icons/";	# directory containing icon files
$UploadDir   = "./upload";	# by gypark. file upload
$UploadUrl   = ""; # by gypark, URL for the directory containing uploaded file
                   # if undefined, it has the same value as $UploadDir
$HiddenPageFile = "$DataDir/hidden";  # hidden pages list file
$TemplatePage = "TemplatePage"; # name of template page for creating new page
$InterWikiMoniker = '';         # InterWiki moniker for this wiki. (for RSS)
$SiteDescription  = $SiteName;  # Description of this wiki. (for RSS)
$RssLogoUrl  = '';              # Optional image for RSS feed
$RssDays     = 7;               # Default number of days in RSS feed
$RssTimeZone = 9;				# Time Zone of Server (hour), 0 for GMT, 9 for Korea
$SlashLinks   = 0;      # 1 = use script/action links, 0 = script?action
$InterIconDir = "./icons-inter/"; # directory containing interwiki icons
$SendPingAllowed = 0;   # 0 - anyone, 1 - who can edit, 2 - who is admin
$JavaScript  = "wikiscript.js";   # URL for JavaScript code (like "/wikiscript.js")
$UseLatex    = 0;		# 1 = Use LaTeX conversion   2 = Don't convert

# Major options:
$UseSubpage  = 1;       # 1 = use subpages,       0 = do not use subpages
$UseCache    = 0;       # 1 = cache HTML pages,   0 = generate every page
$EditAllowed = 1;       # 1 = editing allowed,    0 = read-only
$RawHtml     = 0;       # 1 = allow <HTML> tag,   0 = no raw HTML in pages
$HtmlTags    = 1;       # 1 = "unsafe" HTML tags, 0 = only minimal tags
$UseDiff     = 1;       # 1 = use diff features,  0 = do not use diff
$FreeLinks   = 1;       # 1 = use [[word]] links, 0 = LinkPattern only
$WikiLinks   = 1;       # 1 = use LinkPattern,    0 = use [[word]] only
$AdminDelete = 1;       # 1 = Admin only page,    0 = Editor can delete pages
$RunCGI      = 1;       # 1 = Run script as CGI,  0 = Load but do not run
$EmailNotify = 0;       # 1 = use email notices,  0 = no email on changes
$EmbedWiki   = 0;       # 1 = no headers/footers, 0 = normal wiki pages

# Minor options:
$LogoLeft    = 0;       # 1 = logo on left,       0 = logo on right
$RecentTop   = 1;       # 1 = recent on top,      0 = recent on bottom
$UseDiffLog  = 1;       # 1 = save diffs to log,  0 = do not save diffs
$KeepMajor   = 1;       # 1 = keep major rev,     0 = expire all revisions
$KeepAuthor  = 1;       # 1 = keep author rev,    0 = expire all revisions
$ShowEdits   = 0;       # 1 = show minor edits,   0 = hide edits by default
$HtmlLinks   = 1;       # 1 = allow A HREF links, 0 = no raw HTML links
$SimpleLinks = 0;       # 1 = only letters,       0 = allow _ and numbers
$NonEnglish  = 0;       # 1 = extra link chars,   0 = only A-Za-z chars
$ThinLine    = 1;       # 1 = fancy <hr> tags,    0 = classic wiki <hr>
$BracketText = 1;       # 1 = allow [URL text],   0 = no link descriptions
$UseAmPm     = 1;       # 1 = use am/pm in times, 0 = use 24-hour times
$UseIndex    = 0;       # 1 = use index file,     0 = slow/reliable method
$UseHeadings = 1;       # 1 = allow = h1 text =,  0 = no header formatting
$NetworkFile = 1;       # 1 = allow remote file:, 0 = no file:// links
$BracketWiki = 0;       # 1 = [WikiLnk txt] link, 0 = no local descriptions
$UseLookup   = 0;       # 1 = lookup host names,  0 = skip lookup (IP only)
$FreeUpper   = 0;       # 1 = force upper case,   0 = do not force case
$FastGlob    = 1;       # 1 = new faster code,    0 = old compatible code

# HTML tag lists, enabled if $HtmlTags is set.
# Scripting is currently possible with these tags,
# so they are *not* particularly "safe".
# Tags that must be in <tag> ... </tag> pairs:
@HtmlPairs = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
  em s strike strong tt var div center blockquote ol ul dl table caption);
# Single tags (that do not require a closing /tag)
@HtmlSingle = qw(br p hr li dt dd tr td th);
@HtmlPairs = (@HtmlPairs, @HtmlSingle);  # All singles can also be pairs

# == You should not have to change anything below this line. =============
$IndentLimit = 20;                  # Maximum depth of nested lists
$PageDir     = "$DataDir/page";     # Stores page data
$HtmlDir     = "$DataDir/html";     # Stores HTML versions
$UserDir     = "$DataDir/user";     # Stores user data
$KeepDir     = "$DataDir/keep";     # Stores kept (old) page data
$TempDir     = "$DataDir/temp";     # Temporary files and locks
$LockDir     = "$TempDir/lock";     # DB is locked if this exists
$InterFile   = "intermap";			# Interwiki site->url map
$RcFile      = "$DataDir/rclog";    # New RecentChanges logfile
$RcOldFile   = "$DataDir/oldrclog"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$LinkDir     = "$DataDir/link";    # by gypark. Stores the links of each page
$CountDir    = "$DataDir/count";	# by gypark. Stores view-counts

# added by luke

$UseEmoticon 	= 1;		# 1 = use emoticon, 0 = not use
$EmoticonPath	= "http:emoticon/";	# where emoticon stored
$ClickEdit	 	= 1;		# 1 = edit page by double click on page, 0 = no use
$EditPagePos	= 1;		# 1 = bottom, 2 = top, 3 = top & bottom
$NamedAnchors   = 1;        # 0 = no anchors, 1 = enable anchors, 2 = enable but suppress display

# == End of Configuration =================================================

umask 0;

$TableOfContents = "";
# 단축키
$UseShortcut = 1;
$UseShortcutPage = 1;

# The "main" program, called at the end of this script file.
sub DoWikiRequest {
###############
### replaced by gypark
### 환경 변수들을 지정하는 루틴을 제거. 무조건 config file 를 읽음.
	if (-f $ConfigFile) {
		do "$ConfigFile";
	} else {
		die "Can not load config file";
	}
###
###############

###############
### added by gypark
### 처리 시간 측정
if ($CheckTime) {
	eval "use Time::HiRes qw( usleep ualarm gettimeofday tv_interval )";
	if ($@) { 
		$CheckTime = 0; 
	} else {
		$StartTime = [gettimeofday()];
	}
}
###
###############

###############
### added by gypark
### oekaki
	if ($ENV{'QUERY_STRING'} eq "action=oekaki&mode=save") {
		&OekakiSave();
		return;
	}
###
###############

	&InitLinkPatterns();
	if (!&DoCacheBrowse()) {
		eval $BrowseCode;
		&InitRequest() or return;
		if (!&DoBrowseRequest()) {
			eval $OtherCode;
			&DoOtherRequest();
		}
	}
}

# == Common and cache-browsing code ====================================
sub InitLinkPatterns {
	my ($UpperLetter, $LowerLetter, $AnyLetter, $LpA, $LpB, $QDelim);

	# Field separators are used in the URL-style patterns below.
#  $FS  = "\xb3";      # The FS character is a superscript "3"
	$FS  = "\x7f";
	$FS1 = $FS . "1";   # The FS values are used to separate fields
	$FS2 = $FS . "2";   # in stored hashtables and other data structures.
	$FS3 = $FS . "3";   # The FS character is not allowed in user data.
###############
### added by gypark
	$FS_lt = $FS . "lt";
	$FS_gt = $FS . "gt";
###
###############

	$UpperLetter = "[A-Z";
	$LowerLetter = "[a-z";
	$AnyLetter   = "[A-Za-z";
	if ($NonEnglish) {
		$UpperLetter .= "\xc0-\xde";
		$LowerLetter .= "\xdf-\xff";
		$AnyLetter   .= "\xc0-\xff";
	}
	if (!$SimpleLinks) {
		$AnyLetter .= "_0-9";
	}
	$UpperLetter .= "]"; $LowerLetter .= "]"; $AnyLetter .= "]";

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
###############
### replaced by gypark
### anchor 에 한글 사용
#	$AnchoredLinkPattern = $LinkPattern . '#(\\w+)' . $QDelim if $NamedAnchors;
	$AnchoredLinkPattern = $LinkPattern . '#([0-9A-Za-z\xa0-\xff]+)' . $QDelim if $NamedAnchors;
###
###############
	$LinkPattern .= $QDelim;

	# Inter-site convention: sites must start with uppercase letter
	# (Uppercase letter avoids confusion with URLs)
	$InterSitePattern = $UpperLetter . $AnyLetter . "+";
	$InterLinkPattern = "((?:$InterSitePattern:[^\\]\\s\"<>$FS]+)$QDelim)";

	if ($FreeLinks) {
		# Note: the - character must be first in $AnyLetter definition
		#if ($NonEnglish) {
			$AnyLetter = "[-,.()' _0-9A-Za-z\xa0-\xff]";
		#} else {
		#  $AnyLetter = "[-,.()' _0-9A-Za-z]";
		#}
	}
	$FreeLinkPattern = "($AnyLetter+)";
	if ($UseSubpage) {
		$FreeLinkPattern = "((?:(?:$AnyLetter+)?\\/)?$AnyLetter+)";
	}
	$FreeLinkPattern .= $QDelim;

###############
### added by gypark
### 한글패이지에 anchor 사용
### from Bab2's patch
	$AnchoredFreeLinkPattern = $FreeLinkPattern . '#([0-9A-Za-z\xa0-\xff]+)' . $QDelim if $NamedAnchors;
###
###############

	# Url-style links are delimited by one of:
	#   1.  Whitespace                           (kept in output)
	#   2.  Left or right angle-bracket (< or >) (kept in output)
	#   3.  Right square-bracket (])             (kept in output)
	#   4.  A single double-quote (")            (kept in output)
	#   5.  A $FS (field separator) character    (kept in output)
	#   6.  A double double-quote ("")           (removed from output)

	$UrlProtocols = "http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|mms|mmst|"
					. "prospero|telnet|gopher";
	$UrlProtocols .= '|file'  if $NetworkFile;
	$UrlPattern = "((?:(?:$UrlProtocols):[^\\]\\s\"<>$FS]+)$QDelim)";
	$ImageExtensions = "(gif|jpg|png|bmp|jpeg|GIF|JPG|PNG|BMP|JPEG)";
	$RFCPattern = "RFC\\s?(\\d+)";
###############
### replaced by gypark
### ISBN 패턴 수정
#	$ISBNPattern = "ISBN:?([0-9- xX]{10,})";
	$ISBNPattern = "ISBN:?([0-9-xX]{10,})";
###
###############
}

# Simple HTML cache
sub DoCacheBrowse {
	my ($query, $idFile, $text);

	return 0  if (!$UseCache);
	$query = $ENV{'QUERY_STRING'};
	if (($query eq "") && ($ENV{'REQUEST_METHOD'} eq "GET")) {
###############
### replaced by gypark
### LogoPage 가 있으면 이것을 embed 형식으로 출력
#		$query = $HomePage;  # Allow caching of home page.
		if ($LogoPage eq "") {
			$query = $HomePage;  # Allow caching of home page.
		} else {
			$query = $LogoPage;
		}
###
###############
	}
###############
### added by gypark
### LogoPage 가 있으면 이것을 embed 형식으로 출력
	return 0 if ($query eq $LogoPage);
###
###############
	if (!($query =~ /^$LinkPattern$/)) {
		if (!($FreeLinks && ($query =~ /^$FreeLinkPattern$/))) {
			return 0;  # Only use cache for simple links
		}
	}
	$idFile = &GetHtmlCacheFile($query);
	if (-f $idFile) {
		local $/ = undef;   # Read complete files
		open(INFILE, "<$idFile") or return 0;
		$text = <INFILE>;
		close INFILE;
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
$BrowseCode = ""; # Comment next line to always compile (slower)
#$BrowseCode = <<'#END_OF_BROWSE_CODE';
use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub InitRequest {
	my @ScriptPath = split('/', "$ENV{SCRIPT_NAME}");

	$CGI::POST_MAX = $MaxPost;
###############
### replaced by gypark
### file upload
#	$CGI::DISABLE_UPLOADS = 1;  # no uploads
	$CGI::DISABLE_UPLOADS = 0;  
###
###############
	$q = new CGI;
	$q->autoEscape(undef);

###############
### added by gypark
### file upload
	if ($q->cgi_error() =~ m/^413/) {
		print $q->redirect(-url=>"http:$ENV{SCRIPT_NAME}?action=upload&error=3");
		exit 1;
	}
	$UploadUrl = "http:$UploadDir" if ($UploadUrl eq "");
###
###############
	$Now = time;                     # Reset in case script is persistent
	$ScriptName = pop(@ScriptPath);  # Name used in links
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
###############
### added by gypark
### hide page
	my ($status, $data) = &ReadFile($HiddenPageFile);
	if ($status) {
		%HiddenPage = split(/$FS1/, $data, -1);
	}
###
###############
	return 1;
}

sub InitCookie {
	%SetCookie = ();
	$TimeZoneOffset = 0;
	undef $q->{'.cookies'};  # Clear cache if it exists (for SpeedyCGI)
	%UserCookie = $q->cookie($CookieName);
	$UserID = $UserCookie{'id'};
	&LoadUserData($UserID);
	if (($UserData{'id'}       != $UserCookie{'id'})      ||
			($UserData{'randkey'}  != $UserCookie{'randkey'})) {
		$UserID = 113;
		%UserData = ();   # Invalid.  Later consider warning message.
	}
	if ($UserData{'tzoffset'} != 0) {
		$TimeZoneOffset = $UserData{'tzoffset'} * (60 * 60);
	}
}

sub DoBrowseRequest {
	my ($id, $action, $text);

	if (!$q->param) {             # No parameter
###############
### replaced by gypark
### LogoPage 가 있으면 이것을 embed 형식으로 출력
#		&BrowsePage($HomePage);
		if ($LogoPage eq "") {
			&BrowsePage($HomePage);
		} else {
			$EmbedWiki = 1;
			&BrowsePage($LogoPage);
		}
###
###############
		return 1;
	}
	$id = &GetParam('keywords', '');
###############
### pda clip by gypark
	$IsPDA = &GetParam("pda", "");
	$EmbedWiki = 1 if ($IsPDA);
###
###############
	if ($id) {                    # Just script?PageName
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
	$DocID = $id;
	if ($action eq 'browse') {
		if ($FreeLinks && (!-f &GetPageFile($id))) {
			$id = &FreeToNormal($id);
		}
		if (($NotFoundPg ne '') && (!-f &GetPageFile($id))) {
			$id = $NotFoundPg;
		}
###############
### added by gypark
### id 가 NULL 일 경우 홈으로 이동
### from Bab2's patch
		if ($id eq '') {
			$id = $HomePage;
		}
###
###############
		&BrowsePage($id)  if &ValidIdOrDie($id);
		return 1;
	} elsif ($action eq 'rc') {
###############
### pda clip by gypark
#		&BrowsePage(T($RCName));
		if ($IsPDA) {
			my $temp_id = T("$RCName");
			print &GetHeader($temp_id, &QuoteHtml($temp_id), "");
			&DoRc(1);
			print $q->end_html;
		} else {
			&BrowsePage(T($RCName));
		}
###
###############
		return 1;
	} elsif ($action eq 'random') {
		&DoRandom();
		return 1;
	} elsif ($action eq 'history') {
		$ClickEdit = 0;								# luke added
		&DoHistory($id)   if &ValidIdOrDie($id);
		return 1;
	}
	return 0;  # Request not handled
}

sub BrowsePage {
	my ($id) = @_;
	my ($fullHtml, $oldId, $allDiff, $showDiff, $openKept);
	my ($revision, $goodRevision, $diffRevision, $newText);

###############
### added by gypark
### comments from Jof
	$pageid = $id;
###
###############
###############
### added by gypark
### hide page
	if (&PageIsHidden($id)) {
		print &GetHeader($id, &QuoteHtml($id), $oldId);
		print Ts('%s is a hidden page', $id);
		print &GetCommonFooter();
		return;
	}
###
###############
		
	&OpenPage($id);
	&OpenDefaultText();
###############
### added by gypark
### page count
	if (-f &GetPageFile($id)) {
		$ViewCount = &GetPageCount($id) if (-f &GetPageFile($id));
	}
###
###############
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
###############
### added by gypark
### 매크로가 들어간 페이지의 편집가이드 문제 해결
	$Sec_Revision = $Section{'revision'};
	$Sec_Ts = $Section{'ts'};
###
###############
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
###############
### added by gypark
### #EXTERN
	if (substr($Text{'text'}, 0, 8) eq '#EXTERN ') {
		$oldId = &GetParam('oldid', '');
		my ($externURL) = ($Text{'text'} =~ /\#EXTERN\s+([^\s]+)/);
		if ($externURL =~ /^$UrlPattern$/) {
			&BrowseExternUrl($id, $oldId, $externURL);
			return;
		}
	}
###
###############
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
###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
		if ($showDiff == 5) { 
#			if (&GetParam('username',"") ne "") {
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
###
###############
		$fullHtml .= &GetDiffHTML($showDiff, $id, $diffRevision, "$revision", $newText);
		$fullHtml .= "<hr>\n";
	}

	if ($EditPagePos >= 2) {
		$fullHtml .= &GetTrackbackGuide($id);
		$fullHtml .= &GetEditGuide($id, $goodRevision);		# luke added
	}

	$fullHtml .= &WikiToHTML($Text{'text'});
	# $fullHtml .= "<hr  noshade size=1>\n"  if (!&GetParam('embed', $EmbedWiki));
	if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)) {

		if (&GetParam("sincelastvisit", 0)) {
			my $cookie1 = $q->cookie(
				-name	=> $CookieName . "-RC",
				-value	=> time(),
				-expires => '+60d');
			print "Set-Cookie: $cookie1\r\n";
		}

		print $fullHtml;
		&DoRc(1);
#		print "<HR class='footer'>\n"  if (!&GetParam('embed', $EmbedWiki));
		print &GetFooterText($id, $goodRevision);
		return;
	}
	$fullHtml .= &GetFooterText($id, $goodRevision);
	print $fullHtml;
	return  if ($showDiff || ($revision ne ''));  # Don't cache special version
###############
### replaced by gypark
### redirect 로 옮겨가는 경우에는 cache 생성을 하지 않게 함
#	&UpdateHtmlCache($id, $fullHtml)  if $UseCache;
	&UpdateHtmlCache($id, $fullHtml)  if ($UseCache && ($oldId eq ''));
###
###############
}

sub ReBrowsePage {
	my ($id, $oldId, $isEdit) = @_;

	if ($oldId ne "") {   # Target of #REDIRECT (loop breaking)
		print &GetRedirectPage("action=browse&id=$id&oldid=$oldId",
													 $id, $isEdit);
	} else {
		print &GetRedirectPage($id, $id, $isEdit);
	}
}

###############
### added by gypark
### #EXTERN
sub BrowseExternUrl {
	my ($id, $oldId, $url) = @_;
	my $sizeBottomFrame = $SizeBottomFrame * $EditGuideInExtern;

	if (&GetParam('InFrame','') eq '1') {
		print &GetHeader($id, "$id [InTopFrame]",$oldId);
		print &GetMinimumFooter();
		return;
	} elsif ((&GetParam('InFrame','') eq '2') && ($EditGuideInExtern)) {
		print &GetHeader($id, "$id [InBottomFrame]",$oldId);
		print "<hr>\n";
		print &GetTrackbackGuide($id);
		print &GetEditGuide($id, '');
		print &GetMinimumFooter();
		return;
	} else {
		print &GetHttpHeader();
		print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\">\n";
		print "<html>\n";
		print "<title>$SiteName: $id</title>\n";
		print "<frameset rows=\"$SizeTopFrame,*,$sizeBottomFrame\" cols=\"1\" frameborder=\"0\">\n";
		print "  <frame src=\"$ScriptName?action=browse&InFrame=1&id=$id&oldid=$oldId\" noresize scrolling=\"no\">\n";
		print "  <frame src=\"$url\" noresize>\n";
		print "  <frame src=\"$ScriptName?action=browse&InFrame=2&id=$id&oldid=$oldId\" noresize scrolling=\"no\">\n"
			if ($EditGuideInExtern);
		print "  <noframes>\n";
		print "  <body>\n";
		print "  <p>".T('You need the web browser which supports frame tag.')."\n";
		print "  </body>\n";
		print "  </noframes>\n";
		print "</frameset>\n";
		print "</html>\n";
		return;
	}
}
###
###############

sub DoRc {
###############
### added by gypark
### rss from usemod1.0
	my ($rcType) = @_;
	my $showHTML;
###
###############
	my ($fileData, $rcline, $i, $daysago, $lastTs, $ts, $idOnly);
	my (@fullrc, $status, $oldFileData, $firstTs, $errorText);
	my $starttime = 0;
	my $showbar = 0;

###############
### added by gypark
### rss from usemod1.0
	if (0 == $rcType) {
		$showHTML = 0;
	} else {
		$showHTML = 1;
	}
###
###############

###############
### pda clip by gypark
	if ($IsPDA) {
		$daysago = &GetParam("days", 0);
		$daysago = 7 if ($daysago == 0);
		$starttime = $Now - ((24*60*60)*$daysago);
		print "<h2>$SiteName : " . 
			Ts('Updates in the last %s day' . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
	} else {
###
###############
	if (&GetParam("sincelastvisit", 0)) {
		$starttime = $q->cookie($CookieName ."-RC");
	} elsif (&GetParam("from", 0)) {
		$starttime = &GetParam("from", 0);
###############
### replaced by gypark
### rss from usemod1.0
#		print "<h2>" . Ts('Updates since %s', &TimeToText($starttime))
#					. "</h2>\n";
		if ($showHTML) {
			print "<h2>" . Ts('Updates since %s', &TimeToText($starttime))
						. "</h2>\n";
		}
###
###############
	} else {
		$daysago = &GetParam("days", 0);
		$daysago = &GetParam("rcdays", 0)  if ($daysago == 0);
		if ($daysago) {
			$starttime = $Now - ((24*60*60)*$daysago);
###############
### replaced by gypark
### rss from usemod1.0
#			print "<h2>" . Ts('Updates in the last %s day'
#						 . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
			if ($showHTML) {
				print "<h2>" . Ts('Updates in the last %s day'
							 . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
			}
###
###############
			# Note: must have two translations (for "day" and "days")
			# Following comment line is for translation helper script
			# Ts('Updates in the last %s days', '');
		}
	}
	if ($starttime == 0) {
###############
### replaced by gypark
### rss from usemod1.0
#		$starttime = $Now - ((24*60*60)*$RcDefault);
#	 	print "<h2>" . Ts('Updates in the last %s day'
#			. (($RcDefault != 1)?"s":""), $RcDefault) . "</h2>\n";
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
###############
		# Translation of above line is identical to previous version
	}
###############
### pda clip by gypark
	}
###
###############

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
	if (@fullrc > 0) {  # Only false if no lines in file
		($lastTs) = split(/$FS3/, $fullrc[$#fullrc]);
	}
	$lastTs++  if (($Now - $lastTs) > 5);  # Skip last unless very recent

	$idOnly = &GetParam("rcidonly", "");
###############
### replaced by gypark
### rss from usemod1.0
#	if ($idOnly ne "") {
	if ($idOnly && $showHTML) {
###
###############
		print '<b>(' . Ts('for %s only', &ScriptLink($idOnly, $idOnly))
					. ')</b><br>';
	}
###############
### pda clip by gypark
	if (!($IsPDA)) {
###
###############
###############
### added by gypark
### rss from usemod1.0
	if ($showHTML) {
###
###############
	foreach $i (@RcDays) {
		print " | "  if $showbar;
		$showbar = 1;
		print &ScriptLink("action=rc&days=$i",
			Ts('%s day' . (($i != 1)?'s':''), $i));
			# Note: must have two translations (for "day" and "days")
			# Following comment line is for translation helper script
			# Ts('%s days', '');
	}

###############
### replaced by gypark
### 최근변경내역에 북마크 기능 도입
#	print "<br>" . &ScriptLink("action=rc&from=$lastTs",
#		T('List new changes starting from'));
#	print " " . &TimeToText($lastTs) . "<br>\n";

#	if (&GetParam("username") eq "") {
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
### 
###############
###############
### added by gypark
### rss from usemod1.0
	}
###
###############
###############
### pda clip by gypark
	}
###
###############

	# Later consider a binary search?
	$i = 0;
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
###############
### replaced by gypark
### rss from usemod1.0
#	if ($i == @fullrc) {
	if ($i == @fullrc && $showHTML) {
###
###############
		print '<br><strong>' . Ts('No updates since %s',
											&TimeToText($starttime)) . "</strong><br>\n";
	} else {
		splice(@fullrc, 0, $i);  # Remove items before index $i
		# Later consider an end-time limit (items older than X)
###############
### replaced by gypark
### rss from usemod1.0
#		print &GetRcHtml(@fullrc);
#	}
#	print '<p>' . Ts('Page generated %s', &TimeToText($Now)), "<br>\n";
		if (0 == $rcType) {
			print &GetRcRss(@fullrc);
		} else {
			print &GetRcHtml(@fullrc);
		}
	}
	if ($showHTML) {
		print '<p>' . Ts('Page generated %s', &TimeToText($Now)), "<br>\n";
	}
###
###############
}

sub GetRcHtml {
	my @outrc = @_;
	my ($rcline, $html, $date, $sum, $edit, $count, $newtop, $author);
	my ($showedit, $inlist, $link, $all, $idOnly);
###############
### replaced by gypark
### RcOldFile 버그 수정
#	my ($ts, $oldts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);
	my ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);
###
###############
	my ($tEdit, $tChanges, $tDiff);
	my %extra = ();
	my %changetime = ();
	my %pagecount = ();

	$tEdit    = T('(edit)');    # Optimize translations out of main loop
	$tDiff    = T('(diff)');
	$tChanges = T('changes');
	$showedit = &GetParam("rcshowedit", $ShowEdits);
	$showedit = &GetParam("showedit", $showedit);

###############
### added by gypark
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
	my $num_items = &GetParam("items", 0);
	my $num_printed = 0;
###
###############
###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
	my $bookmark;
	my $bookmarkuser = &GetParam('username', "");
	my ($rcnew, $rcupdated, $rcdiff, $rcdeleted, $rcinterest) = (
			"<img style='border:0' src='$IconDir/rc-new.gif'>",
			"<img style='border:0' src='$IconDir/rc-updated.gif'>",
			"<img style='border:0' src='$IconDir/rc-diff.gif'>",
			"<img style='border:0' src='$IconDir/rc-deleted.gif'>",
### 관심 페이지
			"<img style='border:0' src='$IconDir/rc-interest.gif' alt='".T('Interesting Page')."'>",
	);
	$bookmark = &GetParam('bookmark',-1);
###
###############

	if ($showedit != 1) {
		my @temprc = ();
		foreach $rcline (@outrc) {
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
	foreach $rcline (@outrc) {
### summary 개선 by gypark
# 		($ts, $pagename) = split(/$FS3/, $rcline);
		($ts, $pagename, $summary) = split(/$FS3/, $rcline);
####

###############
### replaced by gypark
### 최근변경내역에 북마크 기능 도입
#		$pagecount{$pagename}++;
### summary 개선 by gypark
#		$pagecount{$pagename}++ if ($ts > $bookmark);
		if ($ts > $bookmark) {
			$pagecount{$pagename}++;
			if (&LoginUser() && !($all)) {
				if (($summary ne "") && ($summary ne "*")) {
					$summary = &QuoteHtml($summary);
					$all_summary{$pagename} = "[$summary]<br>" . $all_summary{$pagename};
				}
			}
		}
####
###
###############
		$changetime{$pagename} = $ts;
	}
	$date = "";
	$inlist = 0;
###############
### replaced by gypark
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
### pda clip 기능 추가
#	$html = "";
	if ($IsPDA) {
		$html = "";
	} else {
		$html = "<TABLE class='rc'>";
	}
###
###############
### summary 개선 by gypark
#	$all = &GetParam("rcall", 0);
#	$all = &GetParam("all", $all);
#	$newtop = &GetParam("rcnewtop", $RecentTop);
#	$newtop = &GetParam("newtop", $newtop);
#	$idOnly = &GetParam("rcidonly", "");
####

	@outrc = reverse @outrc if ($newtop);
###############
### commented by gypark
### RcOldFile 버그 수정
#	($oldts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
#		= split(/$FS3/, $outrc[0]);
#	$oldts += 1;


	foreach $rcline (@outrc) {
		($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
			= split(/$FS3/, $rcline);
		# Later: need to change $all for new-RC?
		next  if ((!$all) && ($ts < $changetime{$pagename}));
		next  if (($idOnly ne "") && ($idOnly ne $pagename));
###############
### added by gypark
### hide page
		next if (&PageIsHidden($pagename));
###
###############
###############
### added by gypark
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
		$num_printed++;
		last if (($num_items > 0) && ($num_printed > $num_items));
###
###############
###############
### commented by gypark
### RcOldFile 버그 수정
#		next  if ($ts >= $oldts);
#		$oldts = $ts;
###
###############
		# print $ts . " " . $pagename . "<br>\n";
		%extra = split(/$FS2/, $extraTemp, -1);
		if ($date ne &CalcDay($ts)) {
			$date = &CalcDay($ts);
			if ($inlist) {
###############
### commented by gypark
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
### pda clip 기능 추가
#				$html .= "</UL>\n";
				$html .= "</UL>\n" if ($IsPDA);
###
###############
				$inlist = 0;
			}
###############
### replaced by gypark
### 최근변경내역에 북마크 기능 도입
### 최근 변경 내역을 테이블로 출력 패치도 같이 적용
### pda clip 기능 추가
#			$html .= "<p><strong>" . $date . "</strong><p>\n";
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
###
###############
		}
		if (!$inlist) {
###############
### commented by gypark
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
### pda clip 기능 추가
#			$html .= "<UL>\n";
			$html .= "<UL>\n" if ($IsPDA);
###
###############
			$inlist = 1;
		}
		$host = &QuoteHtml($host);
		if (defined($extra{'name'}) && defined($extra{'id'})) {
###############
### pda clip by gypark
#			$author = &GetAuthorLink($host, $extra{'name'}, $extra{'id'});
			if ($IsPDA) {
				$author = &GetPageLink($extra{'name'});
			} else {
				$author = &GetAuthorLink($host, $extra{'name'}, $extra{'id'});
			}
###
###############
		} else {
			$author = &GetAuthorLink($host, "", 0);
		}
		$sum = "";
		if (($summary ne "") && ($summary ne "*")) {
			$summary = &QuoteHtml($summary);
###############
### replaced by gypark
### 최근 변경 내역을 테이블로 출력
#			$sum = "<strong>[$summary]</strong> ";
			$sum = "[$summary]";
###
###############
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
###############
### replaced by gypark
### 최근변경내역에 북마크 기능 도입
#			$link .= &ScriptLinkDiff(4, $pagename, $tDiff, "") . "  ";
			if (!(-f &GetPageFile($pagename))) {
				$link .= &GetHistoryLink($pagename, $rcdeleted);
			} elsif (($bookmarkuser eq "") || ($ts <= $bookmark)) {
				$link .= &ScriptLinkDiff(4, $pagename, $rcdiff, "") . "  ";
			} elsif ($extra{'tscreate'} > $bookmark) {
				$link .= $rcnew . "  ";
			} else {
				$link .= &ScriptLinkDiffRevision(5, $pagename, "", $rcupdated) . "  ";
			}
###
###############
		}
###############
### replaced by gypark
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
### pda clip 기능 추가
#		$link .= &GetPageLink($pagename);
#		$html .= "<li>$link ";
#		# Later do new-RC looping here.
#		$html .=  &CalcTime($ts) . " $count$edit" . " $sum";
#		$html .= ". . . . . $author\n";  # Make dots optional?
#	}
#	$html .= "</UL>\n" if ($inlist);
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
# 			if ($sum ne "") {
# 					. "<TD colspan=4 class='rcsummary'>&nbsp;&nbsp;$sum</TD></TR>\n";
#			}
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

###
###############
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

###############
### added by gypark
### hide page
	if (&PageIsHidden($id)) {
		print &GetHeader("",&QuoteHtml(Ts('History of %s', $id)), "");
		print Ts('%s is a hidden page', $id);
		print &GetCommonFooter();
		return;
	}
###
###############
	
	print &GetHeader("",&QuoteHtml(Ts('History of %s', $id)), "") . "<br>";
	&OpenPage($id);
	&OpenDefaultText();
	$canEdit = &UserCanEdit($id,1);
	$canEdit = 0;  # Turn off direct "Edit" links
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
###############
### replaced by gypark
### History 화면에서, 제일 마지막 revision 은 revision 번호 대신
### "현재 버전" 이라고 나오게 함
#		$html .= &GetPageLinkText($id, Ts('Revision %s', $rev)) . ' ';
		$html .= &GetPageLinkText($id, Ts('Current Revision', $rev)) . ' ';
###
###############
		if ($canEdit) {
			$html .= &GetEditLink($id, T('Edit')) . ' ';
		}
	} else {
		$html .= &GetOldPageLink('browse', $id, $rev, Ts('Revision %s', $rev)) . ' ';
		if ($canEdit) {
			$html .= &GetOldPageLink('edit',   $id, $rev, T('Edit')) . ' ';
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
###############
### added by gypark
### 스크립트 뒤에 / or ? 선택 from usemod1.0
sub ScriptLinkChar {
	if ($SlashLinks) {
		return '/';
	}
	return '?';
}

sub ScriptLink {
	my ($action, $text) = @_;

#	return "<A href=\"$ScriptName?$action\">$text</A>";
	return "<a href=\"$ScriptName" . &ScriptLinkChar() . "$action\">$text</a>";
}
###
###############

# luke added

sub HelpLink {
	my ($id, $text) = @_;
	my $url = "$ScriptName?action=help&index=$id";

	return "<a href=\"javascript:help('$url')\">$text</a>";
}

# end

sub GetPageLink {
	my ($id) = @_;
	my $name = $id;

	$id =~ s|^/|$MainPage/|;
	if ($FreeLinks) {
		$id = &FreeToNormal($id);
		$name =~ s/_/ /g;
	}
###############
### pda clip by gypark
	if ($IsPDA) {
		return 	&ScriptLink("action=browse&pda=1&id=$id", $name);
	}
###
###############
	return &ScriptLink($id, $name);
}

sub GetPageLinkText {
	my ($id, $name) = @_;

	$id =~ s|^/|$MainPage/|;
	if ($FreeLinks) {
		$id = &FreeToNormal($id);
		$name =~ s/_/ /g;
	}
###############
### pda clip by gypark
	if ($IsPDA) {
		return 	&ScriptLink("action=browse&pda=1&id=$id", $name);
	}
###
###############
	return &ScriptLink($id, $name);
}

sub GetEditLink {
	my ($id, $name) = @_;

	if ($FreeLinks) {
		$id = &FreeToNormal($id);
		$name =~ s/_/ /g;
	}
	return &ScriptLink("action=edit&id=$id", $name);
}

###############
### replaced by gypark
### from usemod1.0
# sub GetOldPageLink {
# 	my ($kind, $id, $revision, $name) = @_;
# 
# 	if ($FreeLinks) {
# 		$id = &FreeToNormal($id);
# 		$name =~ s/_/ /g;
# 	}
# 	return &ScriptLink("action=$kind&id=$id&revision=$revision", $name);
# }
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
###
###############

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
	if ($FreeLinks) {
		if ($name =~ m| |) {  # Not a single word
			$name = "[$name]";  # Add brackets so boundaries are obvious
		}
	}
###############
### replaced by gypark
### 존재하지 않는 페이지에 대한 링크 출력 형식 변경
#	return $name . &GetEditLink($id,"?");
	if ((&GetParam('linkstyle', $LinkFirstChar)) 
			&& ($name =~ /(\[)?([^\/]*\/)?([a-zA-Z0-9\/]|[\x80-\xff][\x80-\xff])([^\]]*)(\])?/)) {
		return $2 . &GetEditLink($id,"<b>$3</b>") . $4;
	} else {
		return $name . &GetEditLink($id,"?");
	}
###
###############
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

###############
### added by gypark
### 역링크 추가
sub GetReverseLink {
	my ($id) = @_;
	my $name = $id;

	if ($FreeLinks) {
		$name =~ s/_/ /g;  # Display with spaces
	}
	return &ScriptLink("reverse=$id", $name);
}
###
###############

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
	return "<a href=\"$ScriptName?$action\" title=\"$title\">$text</a>";
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
	$result .= &GetHtmlHeader("$SiteName: $title", $title);
###############
### pda clip by gypark
	if ($IsPDA) {
		$result .= "<h1>$title</h1>\n<hr>";
	}
###
###############

	return $result  if ($embed);

###############
### added by gypark
### #EXTERN
	return $result if (&GetParam('InFrame','') eq '2');
###
###############

###############
### replaced by gypark
### #EXTERN
#	if ($oldId ne '') {
#		$result .= $q->h3('(' . Ts('redirected from %s',
#															 &GetEditLink($oldId, $oldId)) . ')');
#	}

	my $topMsg = "";
	if ($oldId ne '') {
		$topMsg .= '('.Ts('redirected from %s',&GetEditLink($oldId, $oldId)).')  ';
	}
	if (&GetParam('InFrame','') eq '1') {
		$topMsg .= '('.Ts('%s includes external page',&GetEditLink($id,$id)).')';
	}
	$result .= $q->h3($topMsg) if (($oldId ne '') || (&GetParam('InFrame','') eq '1'));
###
###############

	if ((!$embed) && ($LogoUrl ne "")) {
		$logoImage = "IMG class='logoimage' src=\"$LogoUrl\" alt=\"$altText\" border=0";
		if (!$LogoLeft) {
			$logoImage .= " align=\"right\"";
		}
###############
### replaced by gypark
### 로고 이미지에 단축키 alt+w 지정
#		$header = &ScriptLink($HomePage, "<$logoImage>");
		$header = "<a accesskey=\"w\" href=\"$ScriptName\"><$logoImage></a>";
###
###############
	}
	if ($id ne '') {
###############
### replaced by gypark
### 사이트 로고가, action 이 들어가는 페이지에서만 표시되는 문제를 해결
### from http://host9.swidc.com/~ncc1701/wiki/wiki.cgi?FAQ
#		$result .= $q->h1(&GetSearchLink($id));
### 역링크 개선
#		$result .= $q->h1($header . &GetSearchLink($id));
		$result .= $q->h1({-class=>"pagename"}, $header . &GetReverseLink($id));
###
###############
	} else {
		$result .= $q->h1({-class=>"actionname"}, $header . $title);
	}

###############
### added by gypark
### page 처음에 bottom 으로 가는 링크를 추가
### #EXTERN
	if (&GetParam('InFrame','') eq '') {
		$result .= "\n<div align=\"right\"><a accesskey=\"z\" name=\"PAGE_TOP\" href=\"#PAGE_BOTTOM\">". T('Bottom')." [b]" . "</a></div>\n";
	}
###
###############

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
	if (defined($SetCookie{'id'})) {
###############
### replaced by gypark
### 로긴할 때 자동 로그인 여부 선택
### from Bab2's patch
#		$cookie = "$CookieName="
#						. "rev&" . $SetCookie{'rev'}
#						. "&id&" . $SetCookie{'id'}
#						. "&randkey&" . $SetCookie{'randkey'};
#		$cookie .= ";expires=Fri, 08-Sep-2010 19:48:23 GMT";

		$cookie = "$CookieName="
			. "expire&" . $SetCookie{'expire'}
			. "&rev&"   . $SetCookie{'rev'}
			. "&id&"    . $SetCookie{'id'}
			. "&randkey&" . $SetCookie{'randkey'}
			. ";";
		if ($SetCookie{'expire'} eq "1") {
			$cookie .= "expires=Fri, 08-Sep-2010 19:47:23 GMT";
		}
###
###############
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

	$html = '';
	$dtd = '-//IETF//DTD HTML//EN';
	$bgcolor = 'white';  # Later make an option
	$html = qq(<!DOCTYPE HTML PUBLIC "$dtd">\n);
	$title = $q->escapeHTML($title);
	$html .= "<HTML><HEAD><TITLE>$title</TITLE>\n";

	if ($SiteBase ne "") {
		$html .= qq(<BASE HREF="$SiteBase">\n);
	}
	if ($StyleSheet ne '') {
		$html .= qq(<LINK REL="stylesheet" HREF="$StyleSheet">\n);
	}
	# Insert other header stuff here (like inline style sheets?)
###############
### added by gypark
### 헤더 출력 개선
	$html .= qq(<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=$HttpCharset">\n);
	$html .= qq(<META HTTP-EQUIV="Content-Script-Type" CONTENT="text/javascript">\n);
	$html .= qq(<link rel="alternate" type="application/rss+xml" title="$SiteName" href="http://$ENV{SERVER_NAME}$ENV{SCRIPT_NAME}?action=rss">\n);
	$html .= qq(<script src="$JavaScript" language="javascript" type="text/javascript"></script>);
	$html .= "\n";
###
###############

	$bodyExtra = '';
	if ($bgcolor ne '') {
		$bodyExtra = qq( BGCOLOR="$bgcolor");
	}
###############
### replaced by gypark
### #EXTERN
	# added luke
#	if ($ClickEdit) {
#		if ($FreeLinks) {
#			$id = &FreeToNormal($id);
#		}
#		$bodyExtra .= qq(ondblclick="location.href='$ScriptName?action=edit&id=$id'");
#	}
	# end

	if (&GetParam('InFrame','') ne '') {
		$html .= qq(<base target="_parent">\n);
	} else {
		if ($ClickEdit) {
			if ($FreeLinks) {
				$id = &FreeToNormal($id);
			}
			$bodyExtra .= qq( ondblclick="location.href='$ScriptName?action=edit&id=$id'" );
		}
	}
###
###############

### 단축키
	my $headExtra;
	if ($UseShortcut) {
		my $shortCutUrl = "$ScriptName".&ScriptLinkChar();
		my $shortCutLogin = &LoginUser()?"logout":"login";
		my $shortCutHome = &FreeToNormal($HomePage);

		$headExtra .= <<EOH;
<script>
<!--
var key = new Array();

key['f'] = "${shortCutUrl}$shortCutHome";
key['i'] = "${shortCutUrl}action=index";
key['r'] = "${shortCutUrl}action=rc";
key['l'] = "${shortCutUrl}action=$shortCutLogin";
key['m'] = "${shortCutUrl}action=bookmark&time=$Now";

key['t'] = "#PAGE_TOP";
key['b'] = "#PAGE_BOTTOM";

EOH

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
function GetKeyStroke(KeyStorke) {
	var evt = KeyStorke || window.event;
	var eventChooser = evt.keyCode || evt.which;
	var target = evt.target || evt.srcElement;
	while (target && target.tagName.toLowerCase() != 'input' && target.tagName.toLowerCase() != 'textarea') {
		target = target.parentElement;
	}
	if (!target) {
		var which = String.fromCharCode(eventChooser).toLowerCase();
		for (var i in key) {
			if (which == i) {
				document.location.href = key[i];
			}
		}
	}
}

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
#		print "<HR class='footer'>\n"  if (!&GetParam('embed', $EmbedWiki));

###############
### added by gypark
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
###
###############

###############
### replaced by gypark
### 페이지 하단에 출력되는 순서를 바꿈
# 	if (&UserCanEdit($id, 0)) {
# 		if ($rev ne '') {
# 			$result .= &GetOldPageLink('edit',   $id, $rev,
# 																 Ts('Edit revision %s of this page', $rev));
# 		} else {
# 			$result .= &GetEditLink($id, T('Edit text of this page'));
# 		}
# 	} else {
# 		$result .= T('This page is read-only');
# 	}
# 	$result .= ' | ';
# 	$result .= &GetHistoryLink($id, T('History'));
# 	if ($rev ne '') {
# 		$result .= ' | ';
# 		$result .= &GetPageLinkText($id, T('View current revision'));
# 	}
# 	if ($Section{'revision'} > 0) {
# 		$result .= '<br>';
# 		if ($rev eq '') {  # Only for most current rev
# 			$result .= T('Last edited');
# 		} else {
# 			$result .= T('Edited');
# 		}
# 		$result .= ' ' . &TimeToText($Section{ts});
# 	}
# 	if ($UseDiff) {
# 		$result .= ' ' . &ScriptLinkDiff(4, $id, T('(diff)'), $rev);
# 	}
# 
# 	$result .= "</div>";

###############
### replaced by gypark
### 매크로가 들어간 페이지의 편집가이드 문제 해결
#	if ($Section{'revision'} > 0) {
	if ($Sec_Revision > 0) {
###
###############
		$result .= '<br>';
		if ($rev eq '') {  # Only for most current rev
			$result .= T('Last edited');
		} else {
			$result .= T('Edited');
		}
###############
### replaced by gypark
### 매크로가 들어간 페이지의 편집가이드 문제 해결
#		$result .= ' ' . &TimeToText($Section{ts});
		$result .= ' ' . &TimeToText($Sec_Ts);
###
###############
	}
	if ($UseDiff) {
		$result .= ' ' . &ScriptLinkDiff(4, $id, T('(diff [d])'), $rev);
	}

	$result .= '<br>';
###############
### added by gypark
### page count
	$result .= Ts('%s hit' . (($ViewCount > 1)?'s':'') , $ViewCount)." | " if ($ViewCount ne "");
###
###############
###############
### added by gypark
### 관심 페이지
#	if (&GetParam('username') ne "") {
	if (&LoginUser()) {
		if (defined($UserInterest{$id})) {
			$result .= &ScriptLink("action=interest&mode=remove&id=$id", T('Remove from interest list'));
		} else {
			$result .= &ScriptLink("action=interest&mode=add&id=$id", T('Add to my interest list'));
		}
		$result .= " | ";
	}
###
###############
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
###############
### replaced by gypark
### view action 추가
#		$result .= T('This page is read-only');
		if ($rev ne '') {
			$result .= &GetOldPageLink('edit',   $id, $rev,
						 Ts('View revision %s of this page', $rev));
		} else {
			$result .= &GetEditLink($id, T('View text of this page'));
		}
###
###############
	}
	$result .= "</DIV>";
###
###############
	return $result;
}

sub GetFooterText {
	my ($id, $rev) = @_;
	my $result = '';

	if (&GetParam('embed', $EmbedWiki)) {
		return $q->end_html;
	}

	if ($EditPagePos eq 1 or $EditPagePos eq 3) {
		$result .= &GetTrackbackGuide($id);
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
###############
### replaced by gypark
### page 마지막에 top 으로 가는 링크를 추가
#	if ($FooterNote ne '') {
#		return T($FooterNote) . $q->end_html;  # Allow local translations
#	}
#	return $q->end_html;

### #EXTERN
	if (&GetParam('InFrame','') ne '') {
		return $q->end_html;
	}
###
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
### 

	return $result;
###
###############
}

sub GetFormStart {
	#return $q->startform("POST", "$ScriptName", "");

###############
### replaced by gypark
### form 에 이름을 넣을 수 있도록 함
#	return $q->startform("POST", "$ScriptName", "application/x-www-form-urlencoded");

	my ($name) = @_;

	if ($name eq '') {
		return $q->startform("POST", "$ScriptName", "application/x-www-form-urlencoded");
	} else {
		return $q->startform(-method=>"POST", -action=>"$ScriptName", -enctype=>"application/x-www-form-urlencoded" ,-name=>"$name") ;
	}
###
###############
}

sub GetGotoBar {
	my ($id) = @_;
	my ($main, $bartext);

	$bartext = "\n<TABLE class='gotobar' width='100%'>";
	$bartext .= &GetFormStart();
	$bartext .= "<TR class='gotobar'>\n<TD class='gotohomepage'>";
	$bartext .= &GetPageLink($HomePage).&GetPageLinkText($HomePage, " [f]");
	$bartext .= "</TD>\n<TD class='gotoindex'>" . &ScriptLink("action=index", T('Index')." [i]");
	$bartext .= "</TD>\n<TD class='gotorecentchanges'>" . &GetPageLink(T($RCName)).&ScriptLink("action=rc", " [r]");
	if ($id =~ m|/|) {
		$main = $id;
		$main =~ s|/.*||;  # Only the main page name (remove subpage)
###############
### replaceed by gypark
### subpage 의 경우, 상위페이지 이름 앞에 아이콘 표시
#		$bartext .= " </td><td> " . &GetPageLink($main);
		$bartext .= "</TD>\n<TD class='gotoparentpage'><img src=\"$IconDir/parentpage.gif\" border=\"0\" alt=\""
					. T('Main Page:') . " $main\" align=\"absmiddle\">" . &GetPageLink($main);
###
###############
	}
###############
### added by gypark
### 상단 메뉴 바에 사용자 정의 항목을 추가
### UserGotoBar2~4 라는 이름으로 지정해주면 된다
	if ($UserGotoBar2 ne '') {
		$bartext .= "</TD>\n<TD class='gotouser'>" . $UserGotoBar2;
	}
	if ($UserGotoBar3 ne '') {
		$bartext .= "</TD>\n<TD class='gotouser'>" . $UserGotoBar3;
	}
	if ($UserGotoBar4 ne '') {
		$bartext .= "</TD>\n<TD class='gotouser'>" . $UserGotoBar4;
	}
###
###############
	$bartext .= "</TD>\n<TD class='gotopref'>" . &GetPrefsLink();
	if (&GetParam("linkrandom", 0)) {
		$bartext .= "</TD>\n<TD class='gotorandom'>" . &GetRandomLink();
	}
	if (&UserIsAdmin()) {
		$bartext .= "</TD>\n<TD class='gotoadmin'>" . &ScriptLink("action=adminmenu", T('Admin'));
	}
	$bartext .= "</TD>\n<TD class='gotolinks'>" . &ScriptLink("action=links", T('Links'));
#	if (($UserID eq "113") || ($UserID eq "112")) {
	if (!&LoginUser()) {
		$bartext .= "</TD>\n<TD class='gotologin'>" . &ScriptLink("action=login", T('Login')." [l]");
	}
	else {
		$bartext .= "</TD>\n<TD class='gotologin'>".
			&GetPageLink(&GetParam('username'));
		$bartext .= "</TD>\n<TD class='gotologin'>" . &ScriptLink("action=logout", T('Logout'). " [l]");
	}
	$bartext .= "</TD>\n<TD class='gotosearch'>" . &GetSearchForm();
	if ($UserGotoBar ne '') {
		$bartext .= "</TD>\n<TD class='gotouser'>" . $UserGotoBar;
	}
	$bartext .= "</TD></TR>";
	$bartext .= $q->endform;
	$bartext .= "</TABLE><HR class='gotobar'>\n";
	return $bartext;
}

sub GetSearchForm {
	my ($result);

###############
### repalced by gypark
### 상단메뉴에 "Search:" 도 번역을 시킴
### 단축키 alt-s 지정
#	$result = "Search: <input class=text type=text name='search' size=10>" 
# . $q->textfield(-name=>'search', -size=>12)
#						. &GetHiddenValue("dosearch", 1);

	$result = T('Search:') . " <input accesskey=\"s\"class=text type=text name='search' size=10>"
						. &GetHiddenValue("dosearch", 1);
###
###############
	return $result;
}

sub GetRedirectPage {
	my ($newid, $name, $isEdit) = @_;
	my ($url, $html);
	my ($nameLink);

	# Normally get URL from script, but allow override.
	$FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
	$url = $FullUrl . "?" . $newid;
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
###############
### added by gypark
### include 매크로 안에서 위키태그를 작동하게 함
### http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
	$pageText = &MacroIncludeSubst($pageText);
###
###############

	if ($RawHtml) {
		$pageText =~ s/<html>((.|\n)*?)<\/html>/&StoreRaw($1)/ige;
	}
###############
### replaced by gypar
### {{{ }}} 처리를 위해, 본문 소스는 특별하게 Quote 한다
#	$pageText = &QuoteHtml($pageText);
	$pageText = &QuoteHtmlForPageContent($pageText);
###
###############

###############
### replaced by gypark
### {{{ }}} 처리를 위해서, 줄 끝에 오는 백슬래쉬 두개와 하나도 임시태그를 거쳐 변환시킨다
#	$pageText =~ s/\\\\ *\r?\n/<BR>/g;		# double backslash for forced <BR> - comes in handy for <LI>
#	$pageText =~ s/\\ *\r?\n/ /g;			# Join lines with backslash at end

	$pageText =~ s/\\\\ *\r?\n/&__DOUBLEBACKSLASH__;/g;		# double backslash for forced <BR> - comes in handy for <LI>
	$pageText =~ s/\\ *\r?\n/&__SINGLEBACKSLASH__;/g;			# Join lines with backslash at end

###
###############

###############
### replaced by gypark
### {{{ }}} 처리를 위해 아래 두 라인의 순서를 바꿈
### from danny's patch.

#	$pageText = &WikiLinesToHtml($pageText);      # Line-oriented markup
#	$pageText = &CommonMarkup($pageText, 1, 0);   # Multi-line markup # line wraped. luke

	$pageText = &CommonMarkup($pageText, 1, 0);   # Multi-line markup # line wraped. luke
	$pageText = &WikiLinesToHtml($pageText);      # Line-oriented markup
###
###############

	$pageText =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
	$pageText =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore nested saved text

	while (@HeadingNumbers) {
		pop @HeadingNumbers;
		$TableOfContents .= "</dd></dl>\n\n";
	}
###############
### added by gypark
### WikiHeading 개선 from Jof
	$pageText =~ s/&__LT__;toc&__GT__;/<a name="toc"><\/a>$TableOfContents/i;
	$pageText =~ s/&__LT__;toc&__GT__;/$TableOfContents/gi;
###
###############

###############
### added by gypark
### {{{ }}} 처리를 위해 추가. 임시 태그를 원래대로 복원
	$pageText =~ s/&__DOUBLEBACKSLASH__;/<BR>\n/g;
	$pageText =~ s/&__SINGLEBACKSLASH__;/ /g;
	$pageText =~ s/&__LT__;/&lt;/g;
	$pageText =~ s/&__GT__;/&gt;/g;
	$pageText =~ s/&__AMP__;/&amp;/g;
	$pageText =~ s/$FS_lt/&lt;/g;
	$pageText =~ s/$FS_gt/&gt;/g;
###
###############

	return &RestoreSavedText($pageText);

#	return $pageText;
}

sub CommonMarkup {
	my ($text, $useImage, $doLines) = @_;
	local $_ = $text;

	if ($doLines < 2) { # 2 = do line-oriented only
###############
### added by gypark
### {{{ }}} 처리 
		s/(^|\n)\{\{\{[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n/&StoreRaw("\n<PRE class=\"code\">") . &StoreCodeRaw($2) . &StoreRaw("\n<\/PRE>") . "\n"/igem;

### plugin
		s/(^|\n)\{\{\{#!((\w+)( .+)?)[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n/$1.&StorePlugin($2,$5)."\n"/igem;

### {{{lang|n|t }}} 처리
		s/(^|\n)\{\{\{([a-zA-Z0-9+]+)(\|(n|\d*|n\d+|\d+n))?[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n/&StoreRaw("<PRE class=\"syntax\">") . &StoreSyntaxHighlight($2, $4, $5) . &StoreRaw("<\/PRE>") . "\n"/igem;
###
###############

###############
### added by gypark
### <raw> 태그 - quoting 도 하지 않는다
		s/\&__LT__;raw\&__GT__;(([^\n])*?)\&__LT__;\/raw\&__GT__;/&StoreCodeRaw($1)/ige;
###
###############

		# The <nowiki> tag stores text with no markup (except quoting HTML)
		s/\&__LT__;nowiki\&__GT__;((.|\n)*?)\&__LT__;\/nowiki\&__GT__;/&StoreRaw($1)/ige;
		# The <pre> tag wraps the stored text with the HTML <pre> tag
		s/\&__LT__;pre\&__GT__;((.|\n)*?)\&__LT__;\/pre\&__GT__;/&StorePre($1, "pre")/ige;
		s/\&__LT__;code\&__GT__;((.|\n)*?)\&__LT__;\/code\&__GT__;/&StorePre($1, "code")/ige;

###############
### added by gypark
### LaTeX 지원
		if ($UseLatex) {
#			s/\$\$((.|\n)*?)\$\$/&StoreRaw(&MakeLaTeX("\$"."$1"."\$", "display"))/ige;
#			s/\$((.|\n)*?)\$/&StoreRaw(&MakeLaTeX("\$"."$1"."\$", "inline"))/ige;
			s/\\\[((.|\n)*?)\\\]/&StoreRaw(&MakeLaTeX("\$"."$1"."\$", "display"))/ige;
			s/\$\$((.|\n)*?)\$\$/&StoreRaw(&MakeLaTeX("\$"."$1"."\$", "inline"))/ige;
		}
###
###############

###############
### replaced by gypark
### anchor 에 한글 사용
#		s/\[\#(\w+)\]/&StoreHref(" name=\"$1\"")/ge if $NamedAnchors;
		s/\[\#([0-9A-Za-z\xa0-\xff]+)\]/&StoreHref(" name=\"$1\"")/ge if $NamedAnchors;
###
###############
		if ($HtmlTags) {
			my ($t);
			foreach $t (@HtmlPairs) {
				s/\&__LT__;$t(\s[^<>]+?)?\&__GT__;(.*?)\&__LT__;\/$t\&__GT__;/<$t$1>$2<\/$t>/gis;
			}
			foreach $t (@HtmlSingle) {
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
###############
### added by gypark
### 한글패이지에 anchor 사용
### from Bab2's patch
			s/\[\[$AnchoredFreeLinkPattern\|([^\]]+)\]\]/&StoreBracketAnchoredLink($1, $2, $3)/geos if $NamedAnchors;
			s/\[\[$AnchoredFreeLinkPattern\]\]/&StoreRaw(&GetPageOrEditAnchoredLink($1, $2, ""))/geos if $NamedAnchors;
###
###############
		}
		if ($BracketText) {  # Links like [URL text of link]
			s/\[$UrlPattern\s+([^\]]+?)\]/&StoreBracketUrl($1, $2)/geos;
			s/\[$InterLinkPattern\s+([^\]]+?)\]/&StoreBracketInterPage($1, $2)/geos;
			if ($WikiLinks && $BracketWiki) {  # Local bracket-links
				s/\[$LinkPattern\s+([^\]]+?)\]/&StoreBracketLink($1, $2)/geos;
				s/\[$AnchoredLinkPattern\s+([^\]]+?)\]/&StoreBracketAnchoredLink($1, $2, $3)/geos if $NamedAnchors;
			}
		}

		if ($useImage) {
			$_ = &EmoticonSubst($_);			# luke added
		}

### img macro from Jof
		s/\&__LT__;img\(([^,\n\s]*?)\)\&__GT__;/&MacroImgTag($1,0,0,'','')/gei;
		s/\&__LT__;img\(([^,\n\s]*?),(\d+?),(\d+?)\)\&__GT__;/&MacroImgTag($1,$2,$3,'','')/gei;
		s/\&__LT__;img\(([^,\n\s]*?),(\d+?),(\d+?),([^,\n]*?)\)\&__GT__;/&MacroImgTag($1,$2,$3,$4,'')/gei;
		s/\&__LT__;img\(([^,\n\s]*?),(\d+?),(\d+?),([^,\n]*?),([^,\n\s]*?)\)\&__GT__;/&MacroImgTag($1,$2,$3,$4,$5)/gei;
####

		s/\[$UrlPattern\]/&StoreBracketUrl($1, "")/geo;
		s/\[$InterLinkPattern\]/&StoreBracketInterPage($1, "")/geo;
###############
### added by gypark
### 개별적인 IMG: 태그
		s/IMG:([^<>\n]*)\n?$UrlPattern/&StoreImgUrl($1, $2, $useImage)/geo;
###
###############
		s/$UrlPattern/&StoreUrl($1, $useImage)/geo;
###############
### replaced by gypark
### InterWiki 로 적힌 이미지 처리
#		s/$InterLinkPattern/&StoreInterPage($1)/geo;
		s/$InterLinkPattern/&StoreInterPage($1, $useImage)/geo;
###
###############

		if ($WikiLinks) {
			s/$AnchoredLinkPattern/&StoreRaw(&GetPageOrEditAnchoredLink($1, $2, ""))/geo if $NamedAnchors;
			s/$LinkPattern/&GetPageOrEditLink($1, "")/geo;
		}

		s/$RFCPattern/&StoreRFC($1)/geo;
		s/$ISBNPattern/&StoreISBN($1)/geo;
		s/CD:\s*(\d+)/&StoreHotTrack($1)/geo;

###############
### commented by gypark
### 매크로 처리 시점을 밖으로 빼낸다
		$_ = &MacroSubst($_); 				# luke added
###
###############

###############
### replaced by gypark
### ==== 가 hr 과 헤드라인 양쪽에서 처리되어 충돌이 생긴다. hr 패턴을 수정
### http://www.usemod.com/cgi-bin/wiki.pl?ThinLine
# 		if ($ThinLine) {
# 			s/----+/<hr noshade size=1>/g;
# 			s/====+/<hr noshade size=2>/g;
# 		} else {
# 			s/----+/<hr>/g;
# 		}

		if ($ThinLine) {
			s/--------+/<hr noshade style="height:5px">/g;
			s/-------+/<hr noshade style="height:4px">/g;
			s/------+/<hr noshade style="height:3px">/g;
			s/-----+/<hr noshade style="height:2px">/g;
			s/----+/<hr noshade style="height:1px">/g;
		} else {
			s/----+/<hr>/g;
		}

###
###############

	}
	if ($doLines) { # 0 = no line-oriented, 1 or 2 = do line-oriented
		# The quote markup patterns avoid overlapping tags (with 5 quotes)
		# by matching the inner quotes for the strong pattern.
		s/('*)'''(.*?)'''/$1<strong>$2<\/strong>/g;
		s/''(.*?)''/<em>$1<\/em>/g;
		if ($UseHeadings) {
			s/(^|\n)\s*(\=+)\s+([^\n]+)\s+\=+/&WikiHeading($1, $2, $3)/geo;
###############
### replaced by gypark
### table 내 셀 별로 정렬
#			s/((\|\|)+)/"<\/TD><TD COLSPAN=\"" . (length($1)\/2) . "\">"/ge if $TableMode;

# rowspan 을 vvv.. 로 표현하는 경우 (차후에 다시 고려할 예정)
#			my %td_align = ("&__LT__;", "left", "&__GT__;", "right", "|", "center");
#			s/((\|\|)*)(\|(&__LT__;|&__GT__;|\|)(v*))/"<\/TD><TD align=\"$td_align{$4}\" COLSPAN=\""
#				. ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"".(length($5)+1):"") . "\">"/ge if $TableMode;
# rowspan 을 v3 으로 표현하는 경우
			my %td_align = ("&__LT__;", "left", "&__GT__;", "right", "|", "center");
			s/((\|\|)*)(\|(&__LT__;|&__GT__;|\|)((v(\d*))?))/"<\/TD><TD align=\"$td_align{$4}\" COLSPAN=\""
				. ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"" . ((length($7))?"$7":"2"):"") . "\">"/ge if $TableMode;
###
###############
		}
	}

###############
### commented by gypark
### {{{ }}} 처리 때문에 함수 호출 순서를 바꾸면 표작성이 안된다
### 다음 두 줄을 주석처리해주어 해결

#	s/^\|([^|]+)[^|]/<TR><TD>$1<\/TD>\n/g;      # start of line: new table-row -- luke
#	s/\|([^|]+)[^|]/<td>$1<\/td>\n/g;           # new field -- luke

###
###############

	return $_;
}

# luke added

sub EmoticonSubst {

	my ($txt) = @_;

	if ($UseEmoticon) {
		my ($e, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8);

		$e1 = $EmoticonPath . "/emoticon-ambivalent.gif ";
		$e2 = $EmoticonPath . "/emoticon-laugh.gif ";
		$e3 = $EmoticonPath . "/emoticon-sad.gif ";
		$e4 = $EmoticonPath . "/emoticon-smile.gif ";
		$e5 = $EmoticonPath . "/emoticon-surprised.gif ";
		$e6 = $EmoticonPath . "/emoticon-tongue-in-cheek.gif ";
		$e7 = $EmoticonPath . "/emoticon-unsure.gif ";
		$e8 = $EmoticonPath . "/emoticon-wink.gif ";

		$txt =~ s/\s\^[oO_\-]*\^[;]*/$e2/g;
		$txt =~ s/\s-[_]+-[;]*/$e7/g;
		$txt =~ s/\so\.O[^A-z]/$e5/g;
		$txt =~ s/\s\*\.\*/$e5/g;
		$txt =~ s/\s\=\.\=[;]*/$e7/g;
		$txt =~ s/\s\:-[sS][^A-z]/$e7/g;

		$txt =~ s/\s\:[-]*D[^A-z]/$e2/g;
		$txt =~ s/\s\:[-]*\([^A-z]/$e3/g;
		$txt =~ s/\s\:[-]*\)[^A-z]/$e4/g;
		$txt =~ s/\s\:[-]*[oO][^A-z]/$e5/g;
		$txt =~ s/\s\:[-]*[pP][^A-z]/$e6/g;
		$txt =~ s/\s\;[-]*\)[^A-z]/$e8/g;
	}

	return $txt;
}

sub MacroSubst {
	my ($txt) = @_;

### <UploadedFiles>
	$txt =~ s/(\&__LT__;uploadedfiles\&__GT__;)/&MacroUploadedFiles($1)/gei;
### <comments(숫자)>
	$txt =~ s/(\&__LT__;comments\(([^,]+),([-+]?\d+)\)&__GT__;)/&MacroComments($1,$2,$3)/gei;
### <noinclude> </noinclude> from Jof
	$txt =~ s/\&__LT__;(\/)?noinclude\&__GT__;//gei;
### <longcomments(숫자)>
	$txt =~ s/(\&__LT__;longcomments\(([^,]+),([-+]?\d+)\)&__GT__;)/&MacroComments($1,$2,$3,1)/gei;
### <memo(제목)></memo> from Jof
	$MemoID = 0;
	$txt =~ s/(&__LT__;memo\(([^\n]+?)\)&__GT__;((.)*?)&__LT__;\/memo&__GT__;)/&MacroMemo($1, $2, $3)/geis;
### <trackbacksent> <trackbackreceived>
	$txt =~ s/(((^|\n)\* .*)*\n?)(&__LT__;trackbacksent&__GT__;)/&MacroTrackbackSent($4,$1)/gei;
	$txt =~ s/(((^|\n)\* .*\n\*\* .*\n\*\* .*)*\n?)(&__LT__;trackbackreceived&__GT__;)/&MacroTrackbackReceived($4,$1)/gei;
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
		}
	}

	foreach my $macro (sort keys %MacroFunc) {
		$txt = &{$MacroFunc{$macro}}($txt);
	}

	return $txt;
}


###############
### added by gypark
sub RemoveLink {
	my ($string) = @_;

	$string =~ s/<a href[^>]*>(\?<\/a>)?//ig;
	$string =~ s/<\/?b>//ig;
	$string =~ s/<\/a>//ig;

	return $string;
}
###
###############

###############
### added by gypark
### include 매크로 안에서 위키태그를 작동하게 함
### http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
sub MacroIncludeSubst {
	my ($txt) = @_;

	$txt =~ s/(^|\n)<include\((.*)\)>([\r\f]*\n)/$1 . &MacroInclude($2) . $3/geim;
### toc 를 포함하지 않는 includenotoc 매크로 추가
	$txt =~ s/(^|\n)<includenotoc\((.*)\)>([\r\f]*\n)/$1 . &MacroInclude($2, "notoc") . $3/geim;
### includeday 매크로
	$txt =~ s/(^|\n)(<includeday\(([^,\n]+,)?([-+]?\d+)\)>)([\r\f]*\n)/$1 . &MacroIncludeDay($2, $3, $4) . $5/geim;
### includedays 매크로
	$txt =~ s/(^|\n)(<includedays\(([^,\n]+,)?([-+]?\d+),([-+]?\d+)\)>)([\r\f]*\n)/$1 . &MacroIncludeDay($2, $3, $4, $5) . $6/geim;
	return $txt;
}
###
###############

###############
### added by gypark
### 추가한 매크로의 동작부
### trackback
sub MacroTrackbackSent {
	my ($itself, $trackbacks) = @_;
	my $title = &T('No Trackback sent');

	my $count = ($trackbacks =~ s/((^|\n)\* .*)/$1/g);
	$title = &Ts('Trackback sent [%s]', $count) if ($count);

	return &MacroMemo("", $title, $trackbacks, "trackbacklist");
}

sub MacroTrackbackReceived {
	my ($itself, $trackbacks) = @_;
	my $title = &T('No Trackback received');

	my $count = ($trackbacks =~ s/((^|\n)\* .*\n\*\* .*\n\*\* .*)/$1/g);
	$title = &Ts('Trackback received [%s]', $count) if ($count);

	return &MacroMemo("", $title, $trackbacks, "trackbacklist");
}

### img from Jof
sub MacroImgTag {
	my ($url,$width,$height,$caption,$float) = @_;
	my ($s_width,$s_height,$s_tag,$s_divstyle,$s_caption,$return);
	
	$s_width 	= " width=\"$width\"" if ( $width>0 );
	$s_height	= " height=\"$height\"" if ( $height>0 );
	$s_tag		= " title=\"$url\"";
	$s_divstyle	= " style=\"float:$float;\"" if ($float ne '');
	$s_caption	= "<br><span class=\"imgcaption\">$caption</span>" if ($caption ne '');
	
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
		$return 	= "<a href=\"$url\"><img src=\"$url\" $s_width $s_height $s_tag border=\"1\" style=\"margin:5px;\"></a>";
	}
	else
	{
		$return 	= "<img src=\"$url\" $s_tag border=\"1\" style=\"margin:5px;\">";
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
	$MemoID++;

	my $memo_id = "__MEMO__$MemoID";

	return "<A class=\"$class\" href=\"#\" onClick=\"" .
		"return onMemoToggle('$memo_id');\">" .
		$title .
		"</A>" .
		"<DIV class=\"$class\" id=\"$memo_id\" style=\"display:none\">" .
		$text .
		"</DIV>";
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
	my $submit_button = $q->submit(-name=>"Submit",-value=>T("Submit"));

	if ($long) {
		$hidden_long = &GetHiddenValue("long","1") . "<br>";
	}

	if (((!&UserCanEdit($id,1)) && (($abs_up < 100) || ($abs_up > $threshold2))) || (&UserIsBanned())) {		# 에디트 불가
		$readonly_true = "true";
		$readonly_style = "background-color: #f0f0f0;";
		$readonly_msg = T('Comment is not allowed');
		$submit_button = "";
		$name_field = $q->textfield(-name=>"name",
									-class=>"comments",
									-size=>"10",
									-maxlength=>"80",
									-readonly=>"$readonly_true",
									-style=>"$readonly_style",
									-default=>"$idvalue");
		if ($long) {		# longcomments
			$comment_field = $q->textarea(-name=>"comment",
									-class=>"comments",
									-rows=>"7",
									-cols=>"80",
									-readonly=>"$readonly_true",
									-style=>"$readonly_style",
									-default=>"$readonly_msg");
		} else {			# comments
			$comment_field = $q->textfield(-name=>"comment", 
											-class=>"comments",
											-size=>"60",
											-readonly=>"$readonly_true",
											-style=>"$readonly_style",
											-default=>"$readonly_msg");
		}
	} else {											# 에디트 가능
		$name_field = $q->textfield(-name=>"name",
									-class=>"comments",
									-size=>"10",
									-maxlength=>"80",
									-default=>"$idvalue");
		if ($long) {		# longcomments
			$comment_field = $q->textarea(-name=>"comment",
									-class=>"comments",
									-rows=>"7",
									-cols=>"80"
									-default=>"");
		} else {			# comments
			$comment_field = $q->textfield(-name=>"comment",
											-class=>"comments",
											-size=>"60",
											-default=>"");
		}
	}

	$txt =
		$q->startform(-name=>"comments",-method=>"POST",-action=>"$ScriptName") .
		&GetHiddenValue("action","comments") .
		&GetHiddenValue("id","$id") .
		&GetHiddenValue("pageid","$pageid") .
		&GetHiddenValue("up","$up") .
		(($threadindent ne '')?&GetHiddenValue("threadindent",$threadindent):"") .
		T('Name') . ": " .
		$name_field . "&nbsp;" .
		T('Comment') . ": " .
		$hidden_long .
		$comment_field . "&nbsp;" .
		$submit_button .
		$q->endform;

	if ($threadindent ne '') {
		if ($threadindent >= 1) {	# "새글쓰기"도 감추고 싶다면 1 대신 0으로 할 것
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
	my $uploadsearch = "<img style='border:0' src='$IconDir/upload-search.gif'>";
	my $canDelete = &UserIsAdmin();
	
	if (!(-e $UploadDir)) {
		&CreateDir($UploadDir);
	}

	opendir (DIR, "$UploadDir") || die Ts('cant opening %s', $UploadDir) . ": $!";
	@files = readdir(DIR);
	shift @files;
	shift @files;
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
	$txt .= "</TR>";


	foreach (@files) {
		$txt .= "<TR class='uploadedfiles'>";
		if ($canDelete) {
			$txt .= "<TD class='uploadedfiles' align='center'>";
			$txt .= "<input type='checkbox' name='files' value='$_'></input> ";
			$txt .= "</TD>";
		}
		$txt .= "<TD class='uploadedfiles'>";
		$txt .= &ScriptLink("reverse=Upload:$_", $uploadsearch) . " ";
		$txt .= "<a href='$UploadUrl/$_'>$_</a>";
		$txt .= "</TD>";

		$size = $filesize{$_};
		while ($size =~ m/(\d+)(\d{3})((,\d{3})*$)/) {
			$size = "$1,$2$3";
		}
		$txt .= "<TD class='uploadedfiles' align='right'>$size</TD>";
		$txt .= "<TD class='uploadedfiles'>".&TimeToText($filemtime{$_})."</TD>";
		$txt .= "</TR>";
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
	$txt .= "<TD class='uploadedfiles'>&nbsp;</TD>";

	$txt .= "</TABLE>";
	$txt .= $q->submit(T('Delete Checked Files')) if ($canDelete);
	$txt .= $q->endform;
	return $txt;

}

### <IncludeDay>
sub MacroIncludeDay {
	my ($itself, $mainpage, $day_offset, $num_days) = @_;
	my $page = "";
	my $temp;
	my $result = "";

	my ($sign, $num);
	if ($num_days =~ /([-+]?(\d+))/) {
		$num = $2;
		$sign = $1 / $num if ($num != 0);
	} else {
		$num = -1;
	}

	# main page 처리
	if ($mainpage ne "") {
		$temp = $mainpage;
		$temp =~ s/,$//;
		$temp = &RemoveLink($temp);
		$temp = &FreeToNormal($temp);
		if (&ValidId($temp) ne "") {
			return $itself;
		}
		$temp =~ s/\/.*$//;
		$mainpage = $temp . "/";
	}

	# 날짜의 변위 계산 
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	my $maximum_count = 100;
	while (($num != 0) && ($maximum_count > 0)) {
		$temp = $Now + ($day_offset * 86400);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($temp+$TimeZoneOffset);

		$page = $mainpage . ($year + 1900) . "-";

		if ($mon + 1 < 10) {
			$page .= "0";
		}
		$page .= ($mon + 1) . "-";

		if ($mday < 10) {
			$page .= "0";
		}
		$page .= "$mday";

		$temp = &MacroInclude($page);
		if ($num == -1) {
			$result .= $temp;
			last;
		} else {
			if ($temp ne "") {
				$num--;
				$result .= $temp . "\n";
			}
			$day_offset += $sign;
		}
		$maximum_count--;
	}

	return $result;
}

sub MacroInclude {
	my ($name, $opt) = @_;

	if ($OpenPageName eq $name) { # Recursive Include 방지
		return "";
	}
	
	$name =~ s|^/|$MainPage/|;
	$name = &FreeToNormal($name);

	my $fname = &GetPageFile($name);	# 존재하지 않는 파일이면 그냥 리턴
	if (!(-f $fname)) {
		return "";
	}
		
###############
### added by gypark
### hide page
	if (&PageIsHidden($name)) {
		return "";
	}
###
###############
	my $data = &ReadFileOrDie($fname);
	my %SubPage = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields

	if (!defined($SubPage{"text_default"})) {
		return "";
	}

	my %SubSection = split(/$FS2/, $SubPage{"text_default"}, -1);
	my %TextInclude = split(/$FS3/, $SubSection{'data'}, -1);
	
	# includenotoc 의 경우
	$TextInclude{'text'} =~ s/<toc>/$FS_lt."toc".$FS_gt/gei if ($opt eq "notoc");
	# noinclude 처리 from Jof
	$TextInclude{'text'} =~ s/<noinclude>(.)*?<\/noinclude>//igs;

	return $TextInclude{'text'};
}

# end

sub WikiLinesToHtml {
	my ($pageText) = @_;
	my ($pageHtml, @htmlStack, $code, $depth, $oldCode);
	my ($tag);

###############
### added by gypark
	my %td_align = ("&__LT__;", "left", "&__GT__;", "right", "|", "center");
###
###############
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
# 		} elsif (s/^((\|\|)+)(.*)\|\|\s*$/"<TR VALIGN='CENTER' ALIGN='CENTER'><TD colspan='" . (length($1)\/2) . "'>$3<\/TD><\/TR>\n"/e) {
# 			$code = 'TABLE';
# 			$TableMode = 1;
# 			$depth = 1;

# rowspan 을 vvv.. 로 표현하는 경우 (차후에 다시 고려할 예정)
# 		} elsif (s/^((\|\|)*)(\|(&__LT__;|&__GT__;|\|)(v*))(.*)\|\|\s*$/"<TR VALIGN='CENTER' ALIGN='CENTER'>"
# 				. "<TD align=\"$td_align{$4}\" colspan=\""
# 				. ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"".(length($5)+1):"") . "\">"
# 				. $6 . "<\/TD><\/TR>\n"/e) {
# 			$code = 'TABLE';
# 			$TableMode = 1;
# 			$depth = 1;

		} elsif (s/^((\|\|)*)(\|(&__LT__;|&__GT__;|\|)((v(\d*))?))(.*)\|\|\s*$/"<TR VALIGN='CENTER' ALIGN='CENTER'>"
				. "<TD align=\"$td_align{$4}\" colspan=\""
				. ((length($1)\/2)+1) . ((length($5))?"\" ROWSPAN=\"" . ((length($7))?"$7":"2"):"") . "\">"
				. $8 . "<\/TD><\/TR>\n"/e) {
			$code = 'TABLE';
			$TableMode = 1;
			$depth = 1;

###
###############
		} elsif (/^IMG:(.*)$/) {		# luke added
			StoreImageTag($1);
			$_ = "";
		} elsif (/^TABLE:(.*)$/) {		# luke added
			StoreTableTag($1);
			$_ = "";
		} else {
			$depth = 0;
		}

		while (@htmlStack > $depth) {   # Close tags as needed
		#  $pageHtml .=  "</" . pop(@htmlStack) . ">\n";		-- deleted luke
			$tag = pop(@htmlStack);								# added luke
			if ($tag eq "TABLE") {
###############
### replaced by gypark
### 줄 중간 || 문제 해결
### from Jof4002's patch
#				$pageHtml .=  "</TR>\n";
#				$tag = "table"

				$TableMode = 0;
###
###############
			};
			$pageHtml .=  "</" . $tag . ">\n";					# added end luke
		}
		if ($depth > 0) {
			$depth = $IndentLimit  if ($depth > $IndentLimit);
			if (@htmlStack) {  # Non-empty stack
				$oldCode = pop(@htmlStack);
				if ($oldCode ne $code) {
###############
### added by gypark
### 줄 중간 || 문제 해결
### from Jof4002's patch
					if ($oldCode eq "TABLE") {
						$TableMode = 0;
					}
###
###############
					$pageHtml .= "</$oldCode><$code>\n";
				}
				push(@htmlStack, $code);
			}
			while (@htmlStack < $depth) {
				push(@htmlStack, $code);
				if ($code eq "TABLE") {					# added luke
					$pageHtml .= "<TABLE $TableTag >\n";
				} else {
					$pageHtml .= "<$code>\n";
				};										# added luke
				# $pageHtml .= "<$code>\n";				# deleted luke
			}
		}
		s/^\s*$/<p>\n/;                        # Blank lines become <p> tags
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
	if (1) {   # Make an official option?
		$html =~ s/&amp;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references
	}

	return $html;
}

###############
### added by gypark
### {{{ }}} 처리를 위해 본문 처리시에는 Quote 를 다르게 함
sub QuoteHtmlForPageContent {
	my ($html) = @_;

	$html =~ s/&/&__AMP__;/g;
	$html =~ s/</&__LT__;/g;
	$html =~ s/>/&__GT__;/g;
	if (1) {   # Make an official option?
		$html =~ s/&__AMP__;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references
	}


	return $html;
}
###
###############

sub StoreInterPage {
###############
### replaced by gypark
### InterWiki 로 적힌 이미지 처리
#	my ($id) = @_;
	my ($id, $useImage) = @_;
###
###############
	my ($link, $extra);

###############
### replaced by gypark
### InterWiki 로 적힌 이미지 처리
#	($link, $extra) = &InterPageLink($id);
	($link, $extra) = &InterPageLink($id, $useImage);
###
###############
	# Next line ensures no empty links are stored
	$link = &StoreRaw($link)  if ($link ne "");
	return $link . $extra;
}

sub InterPageLink {
###############
### replaced by gypark
### InterWiki 로 적힌 이미지 처리
#	my ($id) = @_;
	my ($id, $useImage) = @_;
###
###############
	my ($name, $site, $remotePage, $url, $punct);

	($id, $punct) = &SplitUrlPunct($id);

	$name = $id;
	($site, $remotePage) = split(/:/, $id, 2);
	$url = &GetSiteUrl($site);
###############
### added by gypark
### interwiki 아이콘
	my ($image, $url_main);
	if ($url =~ /\|/) {
		($url, $image) = split(/\|/, $url, 2);		
	}
	$url_main = $url;
###
###############
	return ("", $id . $punct)  if ($url eq "");
	$remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML
	$url .= $remotePage;
###############
### added by gypark
### InterWiki 로 적힌 이미지 처리
### from Jof's patch
	if ($useImage && ($url =~ /^(http:|https:|ftp:).+\.$ImageExtensions$/)) {
		$url = $1 if ($url =~ /^https?:(.*)/ && $1 !~ /^\/\//);
		return ("<img $ImageTag src=\"$url\" alt=\"$id\">", $punct);
	}
###
###############

###############
### replaced by gypark
### interwiki 아이콘
#	return ("<a href=\"$url\">$name</a>", $punct);
	my $link_html = '';
	if (!($image)) {
		$image = "default-inter.gif";
	}
	if (!($image =~ m/\//)) {
		$image = "$InterIconDir/$image";
	}
	$link_html = "<A class='inter' href='$url_main'>" .
				"<IMG class='inter' src='$image' alt='$site:' title='$site:'>" .
				"</A>";
	$link_html .= "<A class='inter' href='$url' title='$id'>$remotePage</A>";
### 외부 URL 을 새창으로 띄울 수 있는 링크를 붙임
	$link_html .= "<a href=\"$url\" target=\"_blank\"><img src=\"$IconDir/newwindow.gif\" border=\"0\" alt=\"" . T('Open in a New Window') . "\" align=\"absbottom\"></a>";
	return ($link_html, $punct);
###
###############

}

sub StoreBracketInterPage {
	my ($id, $text) = @_;
	my ($site, $remotePage, $url, $index);

	($site, $remotePage) = split(/:/, $id, 2);
	$remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML
	$url = &GetSiteUrl($site);
###############
### added by gypark
### interwiki 아이콘
	my ($image, $url_main);
	if ($url =~ /\|/) {
		($url, $image) = split(/\|/, $url, 2);		
	}
	$url_main = $url;
###
###############
	if ($text ne "") {
		return "[$id $text]"  if ($url eq "");
	} else {
		return "[$id]"  if ($url eq "");
		$text = &GetBracketUrlIndex($id);
	}
	$url .= $remotePage;
###############
### replaced by gypark
### interwiki 아이콘
#	return &StoreRaw("<a href=\"$url\">[$text]</a>");
	my $link_html = '';
	$link_html = "<A class='inter' href='$url' title='$id'>[$text]</A>" .
### 외부 URL 을 새창으로 띄울 수 있는 링크를 붙임
				"<a href=\"$url\" target=\"_blank\">" .
				"<img src=\"$IconDir/newwindow.gif\" border=\"0\" alt=\"" . T('Open in a New Window') . "\" align=\"absbottom\">" .
				"</a>";
	return &StoreRaw($link_html);
###
###############
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
###############
### replaced by gypark
### file upload
#		($status, $data) = &ReadFile($InterFile);
#		return ""  if (!$status);
#		%InterSite = split(/\s+/, $data);  # Later consider defensive code
		($status, $data) = &ReadFile($InterFile);
		if ($status) {
			%InterSite = split(/\s+/, $data);
		}
		if (!defined($InterSite{'Upload'})) {
### interwiki 아이콘
			$InterSite{'Upload'} = "$UploadUrl\/|default-upload.gif";
		}
###
###############
###############
### added by gypark
### Local, LocalWiki 인터위키 from usemod 1.0
### interwiki 아이콘 같이 적용
		if (!defined($InterSite{'LocalWiki'})) {
			$InterSite{'LocalWiki'} = $ScriptName . &ScriptLinkChar() . "|default-local.gif";
		}
		if (!defined($InterSite{'Local'})) {
			$InterSite{'Local'} = $ScriptName . &ScriptLinkChar() . "|default-local.gif";
		}
###
###############

	}
	$url = $InterSite{$site}  if (defined($InterSite{$site}));
	return $url;
}

sub StoreRaw {
	my ($html) = @_;

	$SaveUrl{$SaveUrlIndex} = $html;
	return $FS . $SaveUrlIndex++ . $FS;
}

###############
### added by gypark
### 몇 가지 함수들 추가

### {{{ }}} 처리를 위해
sub StoreCodeRaw {
	my ($html) = @_;

#	$html =~ s/&__LT__;/</g;
#	$html =~ s/&__GT__;/>/g;
#	$html =~ s/&__AMP__;/&/g;

#	$html =~ s/&__AMP__;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references

	$html =~ s/&([#a-zA-Z0-9]+);/&amp;$1;/g;
	$html =~ s/&__DOUBLEBACKSLASH__;/\\\\\n/g;
	$html =~ s/&__SINGLEBACKSLASH__;/\\\n/g;
	$html =~ s/&__LT__;/&lt;/g;
	$html =~ s/&__GT__;/&gt;/g;
	$html =~ s/&__AMP__;/&amp;/g;

	$SaveUrl{$SaveUrlIndex} = $html;
	return $FS . $SaveUrlIndex++ . $FS;

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

# source-highlight 출력물 앞뒤의 pre 태그와 tt 태그를 뺀다
	shift @html;
	shift @html;
	pop @html;
	pop @html;

	my ($line, $result);

	$result = "";
	foreach $line (@html) {
		$line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__DOUBLEBACKSLASH__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1\\\\\n$6/g;
		$line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__SINGLEBACKSLASH__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1\\\n$6/g;
		$line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__GT__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1&gt;$6/g;
		$line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__LT__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1&lt;$6/g;
		$line =~ s/(<font [^>]*>)?&amp;(<\/font>)?(<font [^>]*>)?__AMP__(<\/font>)?(<font [^>]*>)?;(<\/font>)?/$1&amp;$6/g;

		$SaveUrl{$SaveUrlIndex} = $line;
		$result .= $FS . $SaveUrlIndex++ . $FS;

	}
	return $result;
}

###############
### added by gypark
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

	if ($plugin_file eq "") {	# 플러그인이 없음
		return &StoreRaw("\n<PRE class='code'>").
			&StoreRaw("\n<font color='red'>No such plugin found: $name</font>\n").
			&StoreCodeRaw($content).
			&StoreRaw("\n<\/PRE>") . "\n";
	}

	my $loadplugin = eval "require '$plugin_file'";

	if (not $loadplugin) {		# 플러그인 로드에 실패
		return &StoreRaw("\n<PRE class='code'>").
			&StoreRaw("\n<font color='red'>Failed to load plugin: $name</font>\n").
			&StoreCodeRaw($content).
			&StoreRaw("\n<\/PRE>") . "\n";
	}

	my $func = "plugin_$name";
	my $content_unquoted = &UnquoteHtmlForPageContent($content);
	my $txt = &{\&$func}($content_unquoted, @opt);
	if (not defined $txt) {		# 플러그인이 undef 반환
		return &StoreRaw("\n<PRE class='code'>").
			&StoreRaw("\n<font color='red'>Error occurred while processing: $name</font>\n").
			&StoreCodeRaw($content).
			&StoreRaw("\n<\/PRE>") . "\n";
	}

	return &StoreRaw($txt);
}
###
###############

### 글을 작성한 직후에 수행되는 매크로들
sub ProcessPostMacro {
	my ($string, $id) = @_;

	### 여기에 사용할 매크로들을 나열한다
	$string = &PostMacroMySign($string);
	### comments from Jof
	if (length($id) != 0) {
		$string =~ s/(^|\n)<((long)?comments)\(([-+]?\d+)\)>([\r\f]*\n)/$1<$2($id,$4)>$5/gim;
	}
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

###
###############


sub StorePre {
	my ($html, $tag) = @_;

	return &StoreRaw("<$tag>" . $html . "</$tag>");
}

###############
### added by gypark
sub UnquoteHtmlForPageContent {
	my ($html) = @_;
	$html =~ s/&__GT__;/>/g;
	$html =~ s/&__LT__;/</g;
	$html =~ s/&__AMP__;/&/g;
	$html =~ s/&__DOUBLEBACKSLASH__;/\\\\\n/g;
	$html =~ s/&__SINGLEBACKSLASH__;/\\\n/g;
	return $html;
}
###
###############

###############
### added by gypark
### LaTeX 지원
sub MakeLaTeX {
	my ($latex,  $type) = @_;

	$latex = &UnquoteHtmlForPageContent($latex);

	# 그림파일의 이름은 텍스트를 해슁하여 결정
	my $hash;
	my $hasMD5 = eval "require Digest::MD5;";
	if ($hasMD5) {
		$hash = Digest::MD5::md5_base64($latex);
	} else {
		$hash = crypt($latex, $HashKey);
	}
	$hash =~ s/(\W)/uc sprintf "_%02x", ord($1)/eg;

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
		open (OUTFILE, ">srender.tex");
		print OUTFILE $template;
		close OUTFILE;

		open SAVEOUT, ">&STDOUT";
		open SAVEERR, ">&STDERR";
		open STDOUT, ">hash.log";
		open STDERR, ">&STDOUT";

		# 그림 생성
		qx(latex -interaction=nonstopmode srender.tex);
		qx(dvips srender.dvi);
		qx(convert -transparent "white" -density 100x100 -trim -shave 0x2 srender.ps $hashimage);

		close STDOUT;
		close STDERR;
		open STDOUT, ">&SAVEOUT";
		open STDERR, ">&SAVEERR";

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
		$imgpath = "<IMG border=0 vspace=0 hspace=0 align='middle' ".
			"src='$LatexUrl/$hashimage' ".
			"alt=\"\$$latex\$\">";
	} elsif ($type eq "display") {
		$imgpath = "<br>".
			"<IMG border=0 vspace=15 hspace=40 align='middle' ".
			"src='$LatexUrl/$hashimage' ".
			"alt=\"$latex\">".
			"</br>";
	}
	return $imgpath;
}
###
###############

sub StoreHref {
	my ($anchor, $text) = @_;

	return "<a" . &StoreRaw($anchor) . ">$text</a>";
}

sub StoreUrl {
	my ($name, $useImage) = @_;
	my ($link, $extra);

	($link, $extra) = &UrlLink($name, $useImage);
	# Next line ensures no empty links are stored
	$link = &StoreRaw($link)  if ($link ne "");
	return $link . $extra;
}

###############
### added by gypark
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
###
###############

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
###############
### replaced by gypark
### 이미지에 alt 태그를 넣어 원래 주소를 보임
#		return ("<img $ImageTag src=\"$name\">", $punct);
		return ("<img $ImageTag src=\"$name\" alt=\"$name\">", $punct);
###
###############
	}
###############
### added by gypark
### 상대 경로로 적힌 URL 을 제대로 처리
	my $protocol;
	($protocol, $name) = ($1, $2) if ($name =~ /^(https?:)(.*)/ && $2 !~ /^\/\//);
###
###############

###############
### replaced by gypark
### 외부 URL 을 새창으로 띄울 수 있는 링크를 붙임
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
#	return ("<a href=\"$name\">$name</a>", $punct);
	return ("<A class='outer' href=\"$name\">$protocol$name</A><a href=\"$name\" target=\"_blank\"><img src=\"$IconDir/newwindow.gif\" border=\"0\" alt=\"" . T('Open in a New Window') . "\" align=\"absbottom\"></a>", $punct);
###
###############
}

sub StoreBracketUrl {
	my ($url, $text) = @_;

	$url = $1 if ($url =~ /^https?:(.*)/ && $1 !~ /^\/\//);
	if ($text eq "") {
		$text = &GetBracketUrlIndex($url);
	}
###############
### replaced by gypark
### 외부 URL 을 새창으로 띄울 수 있는 링크를 붙임
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
#	return &StoreRaw("<a href=\"$url\">[$text]</a>");
	return &StoreRaw("<A class='outer' href=\"$url\">[$text]</A><a href=\"$url\" target=\"_blank\"><img src=\"$IconDir/newwindow.gif\" border=\"0\" alt=\"" . T('Open in a New Window') . "\" align=\"absbottom\"></a>");
###
###############
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

	return &StoreRaw(&ISBNLink($num));
}

sub ISBNLink {
	my ($rawnum) = @_;
	my ($rawprint, $html, $num, $first, $second, $third, $hyphened);

	$num = $rawnum;
	$rawprint = $rawnum;
	$rawprint =~ s/ +$//;
	$num =~ s/[- ]//g;
	if (length($num) != 10) {
		return "ISBN $rawnum";
	}
	#$hyphened = $num;	
	#$hyphened =~ s/(..)(.....)(..)(.)/\1-\2-\3-\4/;

###############
### replaced by gypark
### ISBNLink 개선
### 국내 서적은 알라딘으로
	my ($noCoverIcon, $iconNum) = ("icons/isbn-nocover.jpg", ($num % 5));
	$noCoverIcon = "icons/isbn-nocover-$iconNum.jpg"
		if (-f "icons/isbn-nocover-$iconNum.jpg");

	if ($num =~ /^89/) {
		return "<a href='http://www.aladdin.co.kr/catalog/book.asp?ISBN=$num'>" .
			"<IMG class='isbn' ".
			"$ImageTag src='http://www.aladdin.co.kr/Cover/$num\_1.gif' ".
			"OnError='src=\"$noCoverIcon\"' ".
			"alt='".T('Go to the on-line bookstore')." ISBN:$rawprint'>".
			"</a>";
	}
### 일본 서적은 별도로 링크
	if ($num =~ /^4/) {
		return "<a href='http://bookweb.kinokuniya.co.jp/guest/cgi-bin/wshosea.cgi?W-ISBN=$num'>" .
			"<IMG class='isbn' ".
			"$ImageTag src='http://bookweb.kinokuniya.co.jp/imgdata/$num.jpg' ".
			"OnError='src=\"$noCoverIcon\"' ".
			"alt='".T('Go to the on-line bookstore')." ISBN:$rawprint'>".
			"</a>";
	}

### 외국 서적은 아마존으로
	return "<a href='http://www.amazon.com/exec/obidos/ISBN=$num'>" .
		"<IMG class='isbn' ".
		"$ImageTag src='http://images.amazon.com/images/P/$num.01.MZZZZZZZ.gif' ".
		"OnError='src=\"$noCoverIcon\"' ".
		"alt='".T('Go to the on-line bookstore')." ISBN:$rawprint'>".
		"</a>";

#	$first  = "<a href=\"http://shop.barnesandnoble.com/bookSearch/"
#						. "isbnInquiry.asp?isbn=$num\">";
#	$second = "<a href=\"http://www.amazon.com/exec/obidos/"
#						. "ISBN=$num\">" . T('alternate') . "</a>";
#	$third  = "<a href=\"http://www.pricescan.com/books/"
#						. "BookDetail.asp?isbn=$num\">" . T('search') . "</a>";
#	$html  = $first . "ISBN " . $rawprint . "</a> ";
#	$html .= "($second, $third)";
#	$html .= " "  if ($rawnum =~ / $/);  # Add space if old ISBN had space.
#	return $html;
### 
###############

}

sub SplitUrlPunct {
	my ($url) = @_;
	my ($punct);

	if ($url =~ s/\"\"$//) { return ($url, "");   # Delete double-quote delimiters here
	}
	$punct = "";
###############
### replaced by gypark
### 한글이 포함된 인터위키에서 일부 한글을 인식하지 못하는 문제 해결
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki

#	($punct) = ($url =~ /([^a-zA-Z0-9\/\xc0-\xff]+)$/);
#	$url =~ s/([^a-zA-Z0-9\/\xc0-\xff]+)$//;

	($punct) = ($url =~ /([^a-zA-Z0-9\/\x80-\xff]+)$/);
	$url =~ s/([^a-zA-Z0-9\/\x80-\xff]+)$//;
###
###############
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

#	$anchor = $text;
#	$anchor =~ s/\<.*?\>//g;
#	$anchor =~ s/\W/_/g;
#	$anchor =~ s/__+/_/g;
#	$anchor =~ s/^_//;
#	$anchor =~ s/_$//;
#	$anchor = '_' . (join '_', @HeadingNumbers) unless $anchor; # Last ditch effort

	$anchor = 'H_' . (join '_', @HeadingNumbers); 

###
###############


###############
### replaced by gypark
### <toc> 개선
### http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁
#	$TableOfContents .= $number . &ScriptLink("$OpenPageName#$anchor",$text) . "</dd>\n<dt> </dt><dd>";
	$TableOfContents .= $number . "<a href=\"#$anchor\">" . $text . "</a></dd>\n<dt> </dt><dd>";
###
###############

###############
### replaced by gypark
### WikiHeading 개선 from Jof
#	return &StoreHref(" name=\"$anchor\"") . $number;
	return &StoreHref(" name='$anchor' href='#toc'",$number);
###
###############
}

sub WikiHeading {
	my ($pre, $depth, $text) = @_;

	$depth = length($depth);
	$depth = 6  if ($depth > 6);
	$text =~ s/^#\s+/&WikiHeadingNumber($depth,$')/e; # $' == $POSTMATCH
	return $pre . "<H$depth>$text</H$depth>\n";
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
###############
### added by gypark
### 번역의 편의를 위하여
		my $fromRevision = Ts('Revision %s', $revOld);
###
###############
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
	
###############
### added by gypark
### {{{ }}} 처리를 위해 추가. 임시 태그를 원래대로 복원
### diff 화면에서도 \\ 와 \ 처리를 해 주는 게 나을려나?
	$html =~ s/&__LT__;/&lt;/g;
	$html =~ s/&__GT__;/&gt;/g;
	$html =~ s/&__AMP__;/&amp;/g;
###
###############

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
###############
### replaced by gypark
### diff 출력 개선
#	$diff_out = `diff $oldName $newName`;
	$diff_out = `diff -u $oldName $newName`;
	if ($diff_out eq "") {
		$diff_out = `diff $oldName $newName`;
	}
###
###############
	&ReleaseDiffLock()  if ($lock);
	$diff_out =~ s/\\ No newline.*\n//g;   # Get rid of common complaint.
	# No need to unlink temp files--next diff will just overwrite.
	return $diff_out;
}

###############
### added by gypark
### diff 출력 개선
sub DiffToHTML {
	my ($html) = @_;
	if ($html =~ /^---/) {
		return &DiffToHTMLunified($html);
	} else {
		return &DiffToHTMLplain($html);
	}
}
###
###############

###############
### replaced by gypark
### diff 출력 개선
# sub DiffToHTML {
sub DiffToHTMLplain {
###
###############
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

###############
### added by gypark
### diff 출력 개선
sub DiffToHTMLunified {
	my ($html) = @_;
	my (@lines, $line, $result, $row, $td_class, $in_table, $output_exist);

	@lines = split("\n", $html);
	shift(@lines);
	shift(@lines);

	$output_exist = 0;
	$in_table = 0;
	foreach $line (@lines) {
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
###
###############

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

###############
### added by gypark
### template page
	if (($TemplatePage) && (&GetParam("action","") eq "edit")) {
		my $temp;
		$temp = &GetTemplatePageText(&GetParam("id",""));
		if ($temp ne "") {
			$Text{'text'} = $temp;
		}
	}
###
###############

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

###############
### replaced by gypark
### 페이지 삭제 시에 keep 화일은 보존해 둠
#	return  if ($Section{'revision'} < 1);  # Don't keep "empty" revision
	if ($Section{'revision'} < 1) {
		if (-f $file) {
			unlink($file) || die "error while removing obsolete keep file [$file]";
		}
		return;
	}
###
###############

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
	open (OUT, ">$fname") or die (Ts('cant write %s', $fname) . ": $!");
	foreach (@kplist) {
		%tempSection = split(/$FS2/, $_, -1);
		$sectName = $tempSection{'name'};
		$sectRev = $tempSection{'revision'};
		if ($keepFlag{$sectRev . "," . $sectName}) {
			print OUT $FS1, $_;
		}
	}
	close(OUT);
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
###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
	%RevisionTs = ();
###
###############
	foreach (@KeptList) {
		%tempSection = split(/$FS2/, $_, -1);
		next  if ($tempSection{'name'} ne $name);
		$KeptRevisions{$tempSection{'revision'}} = $_;
###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
		$RevisionTs{$tempSection{'revision'}} = $tempSection{'ts'};
###
###############
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
###############
### added by gypark
### 관심 페이지
	%UserInterest = split(/$FS2/, $UserData{'interest'}, -1);
###
###############
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
###############
### added by gypark
### hide page
	if (($id ne "") && (&PageIsHidden($id))) {
		return 0;
	}
###
###############
	
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
###############
### replaced by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
#		return 1  if ($userPassword eq $_);
		return 1  if (crypt($_, $userPassword) eq $userPassword);
###
###############
	}
	return 0;
}

sub UserIsEditor {
	my (@pwlist, $userPassword);

	return 1  if (&UserIsAdmin());             # Admin includes editor
	return 0  if ($EditPass eq "");
	$userPassword = &GetParam("adminpw", "");  # Used for both
	return 0  if ($userPassword eq "");
	foreach (split(/\s+/, $EditPass)) {
		next  if ($_ eq "");
###############
### replaced by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
#		return 1  if ($userPassword eq $_);
		return 1  if (crypt($_, $userPassword) eq $userPassword);
###
###############
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

	if (open(IN, "<$fileName")) {
		$data=<IN>;
		close IN;
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

	open (OUT, ">$file") or die(Ts('cant write %s', $file) . ": $!");
	print OUT  $string;
	close(OUT);
}

sub AppendStringToFile {
	my ($file, $string) = @_;

	open (OUT, ">>$file") or die(Ts('cant write %s', $file) . ": $!");
	print OUT  $string;
	close(OUT);
}

sub CreateDir {
	my ($newdir) = @_;

###############
### replaced by gypark
### 디렉토리 생성에 실패할 경우 에러 출력
#	mkdir($newdir, 0775)  if (!(-d $newdir));
	if (!(-d $newdir)) {
		mkdir($newdir, 0775) or die(Ts('cant create directory %s', $newdir) . ": $!");
	}
###
###############
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
	my (@pages, @dirs, $id, $dir, @pageFiles, @subpageFiles, $subId);

	@pages = ();
	if ($FastGlob) {
		# The following was inspired by the FastGlob code by Marc W. Mengel.
		# Thanks to Bob Showalter for pointing out the improvement.
		opendir(PAGELIST, $PageDir);
		@dirs = readdir(PAGELIST);
		closedir(PAGELIST);
		@dirs = sort(@dirs);
		foreach $dir (@dirs) {
			next  if (($dir eq '.') || ($dir eq '..'));
			opendir(PAGELIST, "$PageDir/$dir");
			@pageFiles = readdir(PAGELIST);
			closedir(PAGELIST);
			foreach $id (@pageFiles) {
				next  if (($id eq '.') || ($id eq '..'));
				if (substr($id, -3) eq '.db') {
					push(@pages, substr($id, 0, -3));
				} elsif (substr($id, -4) ne '.lck') {
					opendir(PAGELIST, "$PageDir/$dir/$id");
					@subpageFiles = readdir(PAGELIST);
					closedir(PAGELIST);
					foreach $subId (@subpageFiles) {
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
		foreach $dir (@dirs) {
			if (-e "$PageDir/$dir") {  # Thanks to Tim Holt
				while (<$PageDir/$dir/*.db $PageDir/$dir/*/*.db>) {
					s|^$PageDir/||;
					m|^[^/]+/(\S*).db|;
					$id = $1;
					push(@pages, $id);
				}
			}
		}
	}
	return sort(@pages);
}

sub AllPagesList {
	my ($rawIndex, $refresh, $status);

	if (!$UseIndex) {
### hide page by gypark
#		return &GenerateAllPagesList();
		return &GetNotHiddenPages(&GenerateAllPagesList());
###
	}
	$refresh = &GetParam("refresh", 0);
	if ($IndexInit && !$refresh) {
		# Note for mod_perl: $IndexInit is reset for each query
		# Eventually consider some timestamp-solution to keep cache?
### hide page by gypark
#		return @IndexList;
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
#			return @IndexList;
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
#	return @IndexList;
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
$OtherCode = ""; # Comment next line to always compile (slower)
#$OtherCode = <<'#END_OF_OTHER_CODE';

# luke added

sub DoPreview {
	$ClickEdit = 0;
	print &GetHttpHeader();
	print &GetHtmlHeader("$SiteName: " . T('Preview'), "Preview");
###############
### replaced by gypark
### 미리보기에서 <mysign> 등의 preprocessor 사용
#	print &WikiToHTML(&GetParam("text", undef));

	my ($textPreview) = &GetParam("text", undef);
	$MainPage = &GetParam("id", ".");
	$MainPage =~ s|/.*||;
	print &WikiToHTML(&ProcessPostMacro($textPreview));
###
###############
}

###############
### replaceed by gypark
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
###
###############

sub DoOtherRequest {
	my ($id, $action, $text, $search);

	$ClickEdit = 0;									# luke added
	$UseShortcutPage = 0;		# 단축키
	$action = &GetParam("action", "");
	$id = &GetParam("id", "");
	if ($action ne "") {
		$action = lc($action);
###############
### replaced by gypark
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

			if (not $loadaction) {		# action 로드 실패
				$UseShortcut = 0;
				&ReportError(Ts('Fail to load action: %s', $action));
				return;
			}

			my $func = "action_$action";
			&{\&$func}();
			return;
		}
###
###############
		if ($action eq "edit") {
			$UseShortcut = 0;	# 단축키
			&DoEdit($id, 0, 0, "", 0)  if &ValidIdOrDie($id);
		} elsif ($action eq "unlock") {
			&DoUnlock();
		} elsif ($action eq "index") {
			&DoIndex();
###############
### added by gypark
### titleindex action 추가
### from Bab2's patch
		} elsif ($action eq "titleindex") {
			$UseShortcut = 0;
			&DoTitleIndex();
###
###############
		} elsif ($action eq "help") {				# luke added
			$UseShortcut = 0;
			&DoHelp();								# luke added
		} elsif ($action eq "preview") {			# luke added
			$UseShortcut = 0;
			&DoPreview();							# luke added
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
			$UserID = 0;
			&DoEditPrefs();  # Also creates new ID
		} elsif ($action eq "version") {
			&DoShowVersion();
###############
### added by gypark
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
### comment from Jof
		} elsif (($action eq "comments") || ($action eq "longcomments")) {
			&DoComments($id) if &ValidIdOrDie($id);
### rss from usemod1.0
		} elsif ($action eq "rss") {
			$UseShortcut = 0;
			&DoRss();
### Trackback
		} elsif ($action eq "send_ping") {
			&DoSendTrackbackPing($id);
		} elsif ($action eq "trackback") {
			&DoReceiveTrackbackPing($id);
###
###############
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
###############
### added by gypark
### 역링크
	$search = &GetParam("reverse", "");
	if ($search ne "") {
		&DoReverse($search);
		return;
	}
###
###############
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

###############
### added by gypark
### view action 추가
	my $canEdit = &UserCanEdit($id,1);
###
###############

###############
### commented by gypark
### view action 추가
#	if (!&UserCanEdit($id, 1)) {
#		print &GetHeader("", T('Editing Denied'), "");
#		if (&UserIsBanned()) {
#			print T('Editing not allowed: user, ip, or network is blocked.');
#			print "<p>";
#			print T('Contact the wiki administrator for more information.');
#		} else {
### 수정 불가를 알리는 메세지에, 사이트 제목이 아니라 
### 해당 페이지명이 나오도록 수정
#			print Ts('Editing not allowed: %s is read-only.', $SiteName);
#			print Ts('Editing not allowed: %s is read-only.', $id);
#		}
#		print &GetCommonFooter();
#		return;
#	}
###
###############

	# Consider sending a new user-ID cookie if user does not have one
	&OpenPage($id);
	&OpenDefaultText();
	$pageTime = $Section{'ts'};
	$header = Ts('Editing %s', $id);
###############
### added by gypark
### view action 추가
	$header = Ts('Viewing %s', $id) if (!$canEdit);
###
###############
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
###############
### added by gypark
### view action 추가
			$header = Ts('Viewing revision %s of', $revision) . " $id" if (!$canEdit);
###
###############
		}
	}
	$oldText = $Text{'text'};
	if ($preview && !$isConflict) {
		$oldText = $newText;
	}
	$editRows = &GetParam("editrows", 20);
	$editCols = &GetParam("editcols", 65);
	print &GetHeader('', &QuoteHtml($header), '');
###############
### added by gypark
### hide page
	if (&PageIsHidden($id)) {
		print Ts('%s is a hidden page', $id);
		print &GetCommonFooter();
		return;
	}
###
###############
###############
### added by gypark
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
###
###############
###############
### replaced by gypark
### view action 추가
# 	if ($revision ne '') {
	if ($canEdit && ($revision ne '')) {
###
###############
		print "\n<b>"
				. Ts('Editing old revision %s.', $revision) . "  "
		. T('Saving this page will replace the latest revision with this text.')
				. '</b><br>'
	}
###############
### replaced by gypark
### view action 추가
# 	if ($isConflict) {
	if ($canEdit && $isConflict) {
###
###############
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

	print qq|
<script language="javascript" type="text/javascript">
<!--
function preview()
{
	var w = window.open("", "Preview", "width=640,height=480,resizable=1,statusbar=1,scrollbars=1");
	w.focus();

	var body = '<html><head><title>Wiki Preview</title><meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head>';
	body += '<body><form method="post" action="$ScriptName">';
	body += '<input type="hidden" name="id" value="$id">';
	body += '<input type="hidden" name="action" value="preview"><input type=hidden name="text"></form></body></html>';

	w.document.open();
	w.document.charset = '$HttpCharset';
	w.document.write(body);
	w.document.close();
	w.document.forms[0].elements['text'].value = window.document.forms[1].elements['text'].value;
	w.document.forms[0].submit();
}
function help(s)
{
	var w = window.open(s, "Help", "width=500,height=400, resizable=1, scrollbars=1");
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
	var w = window.open("$ScriptName?action=upload", "upload", "width=640,height=250,resizable=1,statusbar=1,scrollbars=1");
	w.focus();
}
function oekaki()
{
	var w = window.open("$ScriptName?action=oekaki&mode=paint", "oekaki", "width=900,height=750,resizable=1,statusbar=1,scrollbars=1");
	w.focus();
}
//-->
</script>
|;
###
###############

###############
### added by gypark
### view action 추가
	if ($canEdit) {
###
###############
		print T('Editing Help :') . "&nbsp;";
###############
### replaced by gypark
### 도움말 별도의 화일로 분리

# 	print &HelpLink(1, T('Make Page')) . " | ";
#   ...
# 	print &HelpLink(5, T('Emoticon')) . "<br>\n";
		use vars qw(@HelpItem);
		require mod_edithelp;

		foreach (0 .. $#HelpItem) {
			print &HelpLink($_, T("$HelpItem[$_]"));
			print " | " if ($_ ne $#HelpItem);
		}
		print "<br>\n";
###
###############
###############
### added by gypark
### view action 추가
	}
###
###############

###############
### replaced by gypark
### 편집모드에 들어갔을때 포커스가 편집창에 있도록 한다
#	print &GetFormStart();
	print &GetFormStart("form_edit");
###
###############
###############
### added by gypark
### view action 추가
	if ($canEdit) {
###
###############
		print &GetHiddenValue("title", $id), "\n",
					&GetHiddenValue("oldtime", $pageTime), "\n",
					&GetHiddenValue("oldconflict", $isConflict), "\n";
		if ($revision ne "") {
			print &GetHiddenValue("revision", $revision), "\n";
		}
		print &GetTextArea('text', $oldText, $editRows, $editCols);
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
#		print $q->submit(-name=>'Save', -value=>T('Save')), "\n";
		print $q->submit(-accesskey=>'r', -name=>'Save', -value=>T('Save')." [alt+r]"), "\n";
		$userName = &GetParam("username", "");
		if ($userName ne "") {
			print ' (', T('Your user name is'), ' ',
						&GetPageLink($userName) . ') ';
		} else {
			print ' (', Ts('Visit %s to set your user name.', &GetPrefsLink()), ') ';
		}
###############
### replaced by gypark 
### 미리보기 버튼에 번역함수 적용
		print q(<input accesskey="p" type="button" name="prev1" value="). 
			T('Popup Preview')." [alt+p]" . 
			q(" onclick="javascript:preview();">); # luke added
###
###############

###############
### added by gypark
### file upload
		print " ".q(<input accesskey="u" type="button" name="prev1" value="). 
			T('Upload File')." [alt+u]" . 
			q(" onclick="javascript:upload();">);
### oekaki
		print " ".q(<input accesskey="o" type="button" name="prev1" value="). 
			T('Oekaki')." [alt+o]" . 
			q(" onclick="javascript:oekaki();">);
###
###############
		if ($isConflict) {
			print "\n<br><hr noshade size=1><p><strong>", T('This is the text you submitted:'),
					"</strong><p>",
					&GetTextArea('newtext', $newText, $editRows, $editCols),
					"<p>\n";
###############
### added by gypark
### conflict 발생시 양쪽의 입력을 비교
			my $conflictdiff = &GetDiff($oldText, $newText, 1);
			$conflictdiff = T('No diff available.') if ($conflictdiff eq "");
			print "\n<br><hr noshade size=1><p><strong>",
				T('This is the difference between the saved text and your text:'),
				"</strong><p>",
				&DiffToHTML($conflictdiff),
				"<p>\n";
###
###############
		}
###############
### added by gypark
### view action 추가
	} else {
		print $q->textarea(-class=>'view', -accesskey=>'i', -name=>'text', 
				-default=>$oldText, -rows=>$editRows, -columns=>$editCols, 
				-override=>1, -style=>'width:100%', -wrap=>'virtual', 
				-readonly=>'true');
	}
###
###############
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
###############
### added by gypark
### 편집 화면 아래에 편집을 취소하고 원래 페이지로 돌아가는 링크 추가
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
	print Ts('Return to %s' , &GetPageLink($id)) . " | ";
###
###############
	print &GetHistoryLink($id, T('View other revisions')) . "<br>\n";
	# print &GetGotoBar($id);
	print $q->endform;
###############
### added by gypark
### 편집모드에 들어갔을때 포커스가 편집창에 있도록 한다
	print "\n<script language=\"JavaScript\" type=\"text/javascript\">\n"
		. "<!--\n"
		. "document.form_edit.text.focus();\n"
		. "//-->\n"
		. "</script>\n";
###
###############
	print &GetMinimumFooter();
}

sub GetTextArea {
	my ($name, $text, $rows, $cols) = @_;
###############
### added by gypark
### &lt; 와 &gt; 가 들어가 있는 페이지를 수정할 경우 자동으로 부등호로 바뀌어
### 버리는 문제를 해결
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
	$text =~ s/(\&)/\&amp;/g;
###
###############

###############
### replaced by gypark
### 편집창에 alt+i 단축키 추가
# 	if (&GetParam("editwide", 1)) {
# 		return $q->textarea(-name=>$name, -default=>$text,
# 												-rows=>$rows, -columns=>$cols, -override=>1,
# 												-style=>'width:100%', -wrap=>'virtual');
# 	}
# 	return $q->textarea(-name=>$name, -default=>$text,
# 											-rows=>$rows, -columns=>$cols, -override=>1,
# 											-wrap=>'virtual');

	if (&GetParam("editwide", 1)) {
		return $q->textarea(-accesskey=>'i', -name=>$name, -default=>$text,
												-rows=>$rows, -columns=>$cols, -override=>1,
												-style=>'width:100%', -wrap=>'virtual');
	}
	return $q->textarea(-accesskey=>'i', -name=>$name, -default=>$text,
											-rows=>$rows, -columns=>$cols, -override=>1,
											-wrap=>'virtual');

###
###############

}

sub DoEditPrefs {
	my ($check, $recentName, %labels);

	$recentName = $RCName;
	$recentName =~ s/_/ /g;
	&DoNewLogin()  if ($UserID eq "");
	print &GetHeader('', T('Editing Preferences'), "");
	print &GetFormStart();
	print GetHiddenValue("edit_prefs", 1), "\n";
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
###############
### added by gypark
### 빈 페이지 링크 스타일을 환경 설정에서 결정
### from Bab2's patch
	print '<br>', &GetFormCheck('linkstyle', $LinkFirstChar,
			T('Make link at the first character of an empty page'));
###
###############
	print '<br>', &GetFormCheck('linkrandom', 0,
												T('Add "Random Page" link to link bar'));
	print '<br>', $q->submit(-name=>'Save', -value=>T('Save')), "\n";
	print "<hr class='footer'>\n";
	print $q->endform;
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
###############
### added by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
	my $hashpass = "";
###
###############

	# All link bar settings should be updated before printing the header
	&UpdatePrefCheckbox("toplinkbar");
###############
### added by gypark
### 빈 페이지 링크 스타일을 환경 설정에서 결정
### from Bab2's patch
	&UpdatePrefCheckbox("linkstyle");
###
###############
	&UpdatePrefCheckbox("linkrandom");
	print &GetHeader('',T('Saving Preferences'), '');
	print '<br>';

###############
### replaced by gypark
### 아이디 첫글자를 대문자로 변환

#	$UserID = &GetParam("p_username",  "");
#	$username = &GetParam("p_username",  "");
	$UserID = &FreeToNormal(&GetParam("p_username",  ""));
	$username = &FreeToNormal(&GetParam("p_username",  ""));
###
###############
###############
### added by gypark
### 다른 사용자의 환경설정 변경을 금지
	my ($status, $data) = &ReadFile(&UserDataFilename($UserID));
	if ($status) {
		if ((!(&UserIsAdmin)) && ($UserData{'id'} ne $UserID)) {
			print T('Error: Can not update prefs. That ID already exists and does not match your ID.'). '<br>';
			print &GetCommonFooter();
			return;
		}
	}
###
###############
	if ($FreeLinks) {
		$username =~ s/^\[\[(.+)\]\]/$1/;  # Remove [[ and ]] if added
		$username =  &FreeToNormal($username);
		$username =~ s/_/ /g;
	}
###############
### replaced by gypark
### 아이디 항목을 공란으로 놓지 못하게 하고, 최소 4자 이상이어야 하도록 제한
### based on Bab2's patch
#	if ($username eq "") {
#		print T('UserName removed.'), '<br>';
#		undef $UserData{'username'};
#	} elsif ((!$FreeLinks) && (!($username =~ /^$LinkPattern$/))) {
#		print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
#	} elsif ($FreeLinks && (!($username =~ /^$FreeLinkPattern$/))) {
#		print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
#	} elsif (length($username) > 50) {  # Too long
#		print T('UserName must be 50 characters or less. (not saved)'), "<br>\n";
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
###############
### added by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
	$hashpass = crypt($password, $HashKey);
###
###############
	if ($password eq "") {
		print T('Password removed.'), '<br>';
		undef $UserData{'password'};
	} elsif ($password ne "*") {
		print T('Password changed.'), '<br>';
###############
### replaced by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
#		$UserData{'password'} = $password;
		$UserData{'password'} = $hashpass;
###
###############
	}
	if ($AdminPass ne "") {
		$password = &GetParam("p_adminpw",  "");
###############
### added by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
		$hashpass = crypt($password, $HashKey);
###
###############
		if ($password eq "") {
			print T('Administrator password removed.'), '<br>';
			undef $UserData{'adminpw'};
		} elsif ($password ne "*") {
			print T('Administrator password changed.'), '<br>';
###############
### replaced by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
#			$UserData{'adminpw'} = $password;
			$UserData{'adminpw'} = $hashpass;
###
###############
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

	$UserData{'id'} = $UserID;
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
			open(NOTIFY, "$DataDir/emails")
				or die(Ts('Could not read from %s:', "$DataDir/emails") . " $!\n");
			@old_emails = <NOTIFY>;
			close(NOTIFY);
		} else {
			@old_emails = ();
		}
		my $already_in_list = grep /$new_email/, @old_emails;
		if ($notify and (not $already_in_list)) {
			&RequestLock() or die(T('Could not get mail lock'));
			open(NOTIFY, ">>$DataDir/emails")
				or die(Ts('Could not append to %s:', "$DataDir/emails") . " $!\n");
			print NOTIFY $new_email, "\n";
			close(NOTIFY);
			&ReleaseLock();
		}
		elsif ((not $notify) and $already_in_list) {
			&RequestLock() or die(T('Could not get mail lock'));
			open(NOTIFY, ">$DataDir/emails")
				or die(Ts('Could not overwrite %s:', "$DataDir/emails") . " $!\n");
			foreach (@old_emails) {
				print NOTIFY "$_" unless /$new_email/;
			}
			close(NOTIFY);
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

###############
### added by gypark
### titleindex action 추가
### from Bab2's patch
sub DoTitleIndex {
	my (@list);
	my $index;
	print "Content-type: text/plain\n\n";
	@list = &AllPagesList();
	foreach $index (@list) {
		print $index."\r\n";
	}
}
###
###############

sub DoIndex {
	print &GetHeader('', T('Index of all pages'), '');
	print '<br>';
	&PrintPageList(&AllPagesList());
	print &GetCommonFooter();
}

# Create a new user file/cookie pair
sub DoNewLogin {
	# Later consider warning if cookie already exists
	# (maybe use "replace=1" parameter)
	$SetCookie{'randkey'} = int(rand(1000000000));
	$SetCookie{'rev'} = 1;
	%UserCookie = %SetCookie;
	$UserID = $SetCookie{'id'};
	# The cookie will be transmitted in the next header
	%UserData = %UserCookie;
	$UserData{'createtime'} = $Now;
	$UserData{'createip'} = $ENV{REMOTE_ADDR};
	&SaveUserData();
}

sub DoEnterLogin {
	print &GetHeader('', T('Login'), "");
###############
### replaced by gypark
### 사용자 아이디를 입력하는 란에 포커스를 준다
#	print &GetFormStart();
	print &GetFormStart("form_login");
###
###############
	print &ScriptLink("action=newlogin", T('Create new UserName') . "<br>");
	print &GetHiddenValue('enter_login', 1), "\n";
	print '<br>', T('UserName:'), ' ',
				$q->textfield(-name=>'p_userid', -value=>'',
											-size=>15, -maxlength=>50);
	print '<br>', T('Password:'), ' ',
				$q->password_field(-name=>'p_password', -value=>'',
													 -size=>15, -maxlength=>50);
###############
### added by gypark
### 로긴할 때 자동 로그인 여부 선택
### from Bab2's patch
	print '<br>', &GetFormCheck('expire', 0, T('Keep login information'));
###
###############
	print '<br>', $q->submit(-name=>'Login', -value=>T('Login')), "\n";
	print "<hr class='footer'>\n";
	print $q->endform;
###############
### added by gypark
### 사용자 아이디를 입력하는 란에 포커스를 준다
	print "\n<script language=\"JavaScript\" type=\"text/javascript\">\n"
		. "<!--\n"
		. "document.form_login.p_userid.focus();\n"
		. "//-->\n"
		. "</script>\n";
###
###############
	print &GetMinimumFooter();
}

sub DoLogin {
	my ($uid, $password, $success);

	$success = 0;
###############
### replaced by gypark
### 아이디 첫글자를 무조건 대문자로 변환
#	$uid = &GetParam("p_userid", "");
	$uid = &FreeToNormal(&GetParam("p_userid", ""));
###
###############
	$password = &GetParam("p_password",  "");
	if (($password ne "") && ($password ne "*")) {
		$UserID = $uid;

		&LoadUserData();
###############
### replaced by gypark
### 암호를 암호화해서 저장
### from Bab2's patch
#		if (defined($UserData{'password'}) &&
#				($UserData{'password'} eq $password)) {
		if (defined($UserData{'password'}) &&
				(crypt($password, $UserData{'password'}) eq $UserData{'password'})) {
###
###############
###############
### added by gypark
### 로긴할 때 자동 로그인 여부 선택
### from Bab2's patch
			my $expire_mode = &UpdatePrefCheckbox("expire");
			if ($expire_mode eq "") {
				$SetCookie{'expire'} = 1;
			} else {
				$SetCookie{'expire'} = $expire_mode;
			}
###
###############
			$SetCookie{'id'} = $uid;
			$SetCookie{'randkey'} = $UserData{'randkey'};
			$SetCookie{'rev'} = 1;
			$success = 1;
		}
		else {
			$SetCookie{'id'} = "";
###############
### added by gypark
### 잘못된 아이디를 넣었을 때의 처리 추가
### from Bab2's patch
			$UserID = "";
			&LoadUserData();
###
###############
		}
	}

###############
### replaced by gypark
### 로긴 성공 또는 실패시의 메시지 수정

#	print &GetHeader('', T('Login Results'), '');
#
# 	if ($success) {
# 		print Ts('Login for user ID %s complete.', $uid);
# 		%UserCookie = %SetCookie;
# 	} else {
# 		print Ts('Login for user ID %s failed.', $uid);
# 		%UserCookie = %SetCookie;
# 		$UserID = "";
# 	}
	if ($success) {
		print &GetHeader('', T('Login completed'), '');
		print Ts('Login for user ID %s complete.', $uid);
		%UserCookie = %SetCookie;
	} else {
		print &GetHeader('', T('Login failed'), '');
		print Ts('Login for user ID %s failed.', $uid);
		%UserCookie = %SetCookie;
		$UserID = "";
		print "<br>" . &ScriptLink("action=login", T('Try Again'));
	}

###
###############
	print "<hr class='footer'>\n";
	#print &GetGotoBar('');
	print $q->endform;
	print &GetMinimumFooter();
}

sub DoLogout {
	my ($uid);

	$SetCookie{'id'} = "";
	$SetCookie{'randkey'} = $UserData{'randkey'};
	$SetCookie{'rev'} = 1;

###############
### replaced by gypark
### logout 직후에도 상단메뉴에 logout 링크가 남아 있는 문제 해결
### 근본적인 조치가 되지 못한다. 주의
#	print &GetHeader('', T('Logout Results'), '');

	my $tempUserID = $UserID;
	$UserID = "113";
	print &GetHeader('', T('Logout Results'), '');
	$UserID = $tempUserID;
###
###############

#	if (($UserID ne "113") && ($UserID ne "112")) {
	if (&LoginUser()) {
		print Ts('Logout for user ID %s complete.', $UserID);
	}

	print "<hr class='footer'>\n";
	%UserCookie = %SetCookie;
	$UserID = "";
	#print &GetGotoBar('');
	print $q->endform;
	print &GetMinimumFooter();
}

# Later get user-level lock
sub SaveUserData {
	my ($userFile, $data);
###############
### added by gypark
### 설치 후 처음으로 사용자 아이디를 만들 때 에러가 나는 것을 해결
	&CreateDir($UserDir);
###
###############
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
	@x = &SearchTitleAndBody($string);
	&PrintPageList(@x);

	if ($#x eq -1) {
		print &ScriptLink("action=edit&id=$string", Ts('Create a new page : %s', $string));
	}

	print &GetCommonFooter();
}

###############
### added by gypark
sub DoReverse {
	my ($string) = @_;
	my @x = ();
	my $pagelines;

	if ($string eq '') {
		&DoIndex();
		return;
	}
	print &GetHeader('', &QuoteHtml(Ts('Links to %s', $string)), '');
### hide page by gypark
	if (&PageIsHidden($string)) {
		print Ts('%s is a hidden page', $string);
		print &GetCommonFooter();
		return;
	}
###
	print '<br>';

	foreach $pagelines (&GetFullLinkList("page=1&inter=1&unique=1&sort=1&exists=2&empty=0&reverse=$string")) {
		my @pages = split(' ', $pagelines);
		@x = (@x, shift(@pages));
	}
	
	&PrintPageList(@x);

	if ($#x eq -1) {
		print T('No reverse link.') . "<br>";
	}
	if (&ValidId($string) eq "") {
		print "<hr size=\"1\">";
		print Ts('Return to %s' , &GetPageLink($string)) . "<br>";
	}

	print &GetCommonFooter();
}
###
###############

###############
### replaced by gypark
### 목차를 A,B,..,가,나,... 등으로 구분해서 출력하도록 함
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki

# sub PrintPageList {
# 	my $pagename;
# 
# 	print "<h2>", Ts('페이지 수: %s', ($#_ + 1)), "</h2>\n";
# 	foreach $pagename (@_) {
# 		print ".... "  if ($pagename =~ m|/|);
# 		print &GetPageLink($pagename);
# 
# 		if (&UserIsAdmin()) {
# 			print " | " . &ScriptLink("action=pagelock&set=1&id=" . $pagename, T('lock'));
# 			print " | " . &ScriptLink("action=pagelock&set=0&id=" . $pagename, T('unlock'));
# 		}
# 		print "<br>\n";
# 	}
# }

sub PrintPageList {
	my ($pagename);
	my $count = 0;
	my $titleIsPrinted = 0;
	my @han = qw(가 나 다 라 마 바 사 아 자 차 카 타 파 하);
	my @indexTitle = (0, "A".."Z");
	push (@indexTitle, @han, "기타");
	my @indexSearch=("A".."Z");
	push (@indexSearch, @han, "豈");

	print "<a name='TOC'></a><h2>", Ts('%s pages found:', ($#_ + 1)), "</h2>\n";

###############
### replaced by gypark
### index 또는 검색결과 창의 제일 상단에 구분탭 링크를 넣음

# 	foreach $pagename(@_) {
# 		until (
# 			$pagename lt @indexSearch[$count]
# 			&& ($count == 0 || $pagename gt @indexSearch[$count-1])
# 		) {
# 			$count++;
# 			$titleIsPrinted = 0;
# 			last if $count > 40;
# 		}
# 		if (!$titleIsPrinted) {
#			print $q->h3($indexTitle[$count]);

	# 상단에 앵커를 가리키는 인덱스 나열
	my $count2 = 0;
	print("\n|");
	while ( $count2 <= $#indexTitle ) {
#		if ($indexTitle[$count2] == 'Z') {
		if ($count2 == 27) {
			print("<br>\n|");
		}
		print("<a href=\"#H_$indexTitle[$count2]\"><b>");
		print("&nbsp;$indexTitle[$count2]&nbsp;");
		print("</b></a>|");
		$count2++;
	}
	print "<br><br>";
	$count2 = 0;

	foreach $pagename(@_) {
###############
### added by gypark
### hide page
		next if (&PageIsHidden($pagename));
###
###############
		until (
			$pagename lt @indexSearch[$count]
			&& ($count == 0 || $pagename gt @indexSearch[$count-1])
		) {
			$count++;
			$titleIsPrinted = 0;
			last if $count > 40;
		}
		if (!$titleIsPrinted) {
			# 페이지가 없는 색인의 앵커 처리
			while ( $count2 <= ($count - 1) ) {
				print "\n<a name=\"H_$indexTitle[$count2]\">";
# 아래 주석을 해제하면 페이지가 없는 색인도 헤드라인이 나오나,
# 사용하지 않는 것이 좋다. 역링크를 사용해보면 이해가 될 듯
#				print $q->h3($indexTitle[$count2]);
				print "</a>";
				$count2++;
			}
# 앵커를 삽입
			print $q->h3("<a name=\"H_$indexTitle[$count]\" title=\"". T('Top') ."\" href=\"#TOC\">$indexTitle[$count]</A>"); 
			$count2 = $count + 1;
### gypark 의 색인 패치
###############
			$titleIsPrinted=1;
		}

		print ".... " if ($pagename =~ m|/|);
		print &GetPageLink($pagename);

		if (&UserIsAdmin()) {
###############
### added by gypark
### 관리자의 인덱스 화면에서는 잠긴 페이지를 별도로 표시
			if (-f &GetLockedPageFile($pagename)) {
				print " " . T('(locked)');
			}
### 
###############
			print " | " . &ScriptLink("action=pagelock&set=1&id=" . $pagename, T('lock'));
			print " | " . &ScriptLink("action=pagelock&set=0&id=" . $pagename, T('unlock'));
###############
### added by gypark
### hide page
			if (defined($HiddenPage{$pagename})) {
				print " | " . T('(hidden)');
			}
			print " | " . &ScriptLink("action=pagehide&set=1&id=" . $pagename, T('hide'));
			print " | " . &ScriptLink("action=pagehide&set=0&id=" . $pagename, T('unhide'));
###
###############
		}
		print $q->br;
		print "\n";
	}
}

### jof4002 의 index 화면 패치
###############

sub DoLinks {
	print &GetHeader('', &QuoteHtml(T('Full Link List')), '');
	print "<pre>\n";  # Extra lines to get below the logo
	&PrintLinkList(&GetFullLinkList());
	print "</pre><HR class='footer'>\n";
	print &GetMinimumFooter();
}

###############
### added by gypark
### 역링크를 찾는 함수 추가
# sub MacroReverse {
# 	my $pagelines;
# 	my @result = ();
# 
# 	foreach $pagelines (&GetFullLinkList(@_)) {
# 		my @pages = split(' ', $pagelines);
# 		@result = (@result, shift(@pages));
# 	}
# 	return @result;
# }
###
###############

sub PrintLinkList {
	my ($pagelines, $page, $names, $editlink);
	my ($link, $extra, @links, %pgExists);

	%pgExists = ();
	foreach $page (&AllPagesList()) {
		$pgExists{$page} = 1;
	}
	$names = &GetParam("names", 1);
	$editlink = &GetParam("editlink", 0);
	foreach $pagelines (@_) {
		@links = ();
###############
### replaced by gypark
### full link list 개선
#		foreach $page (split(' ', $pagelines)) {
		my @pages = split(' ', $pagelines);
		foreach $page (@pages) {
###
###############
			if ($page =~ /\:/) {  # URL or InterWiki form
				if ($page =~ /$UrlPattern/) {
					($link, $extra) = &UrlLink($page);
				} else {
					($link, $extra) = &InterPageLink($page);
				}
			} else {
				if ($pgExists{$page}) {
					$link = &GetPageLink($page);
###############
### added by gypark
### full link list 개선
				} elsif ($page =~ /^\// && $pgExists{(split ('/',$pages[0]))[0].$page}) {
					($link, $extra) = &GetPageLinkText((split ('/',$pages[0]))[0].$page, $page);
###
###############
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
###############
### added by gypark
### GetFullLinkList 에 인자처리 기능 추가
	my ($opt) = @_;
	my $opt_item;
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
	foreach $opt_item (split('&',$opt)) {
		if ($opt_item =~ /^(.+)=(.+)$/) {
			$args{$1} = $2;
		}
	}
###
###############

###############
### replaceed by gypark
### 역링크 검색 옵션 추가
#	my ($name, $unique, $sort, $exists, $empty, $link, $search);
	my ($name, $unique, $sort, $exists, $empty, $link, $search, $reverse);
###
###############
	my ($pagelink, $interlink, $urllink);
	my (@found, @links, @newlinks, @pglist, %pgExists, %seen);

###############
### replaced by gypark
### GetFullLinkList 에 인자처리 기능 추가
# 	$unique = &GetParam("unique", 1);
# 	$sort = &GetParam("sort", 1);
# 	$pagelink = &GetParam("page", 1);
# 	$interlink = &GetParam("inter", 0);
# 	$urllink = &GetParam("url", 0);
# 	$exists = &GetParam("exists", 2);
# 	$empty = &GetParam("empty", 0);
# 	$search = &GetParam("search", "");
	$unique = &GetParam("unique", $args{"unique"});
	$sort = &GetParam("sort", $args{"sort"});
	$pagelink = &GetParam("page", $args{"page"});
	$interlink = &GetParam("inter", $args{"inter"});
	$urllink = &GetParam("url", $args{"url"});
	$exists = &GetParam("exists", $args{"exists"});
	$empty = &GetParam("empty", $args{"empty"});
	$search = &GetParam("search", $args{"search"});
###
###############

###############
### added by gypark
### 역링크 기능 추가
	$reverse = &GetParam("reverse", $args{"reverse"});
###
###############
	if (($interlink == 2) || ($urllink == 2)) {
		$pagelink = 0;
	}

	%pgExists = ();
	@pglist = &AllPagesList();
	foreach $name (@pglist) {
		$pgExists{$name} = 1;
	}
	%seen = ();
	foreach $name (@pglist) {
		@newlinks = ();
		if ($unique != 2) {
			%seen = ();
		}
###############
### replaced by gypark
### 링크 목록을 별도로 관리
#		@links = &GetPageLinks($name, $pagelink, $interlink, $urllink);
		@links = &GetPageLinksFromFile($name, $pagelink, $interlink, $urllink);
###
###############

		foreach $link (@links) {
			$seen{$link}++;
			if (($unique > 0) && ($seen{$link} != 1)) {
				next;
			}
###############
### replaced by gypark
### /페이지 형식의 하위페이지의 존재에 대한 버그수정
#			if (($exists == 0) && ($pgExists{$link} == 1)) {
# 				next;
# 			}
# 			if (($exists == 1) && ($pgExists{$link} != 1)) {
# 				next;
# 			}

			my $link2 = $link;
			$link2 = (split ('/',$name))[0]."$link" if ($link =~ /^\//);
			if (($exists == 0) && ($pgExists{$link2} == 1)) {
				next;
			}
			if (($exists == 1) && ($pgExists{$link2} != 1)) {
				next;
			}
###
###############
			if (($search ne "") && !($link =~ /$search/)) {
				next;
			}
###############
### added by gypark
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

###
###############
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
	$text =~ s/<html>((.|\n)*?)<\/html>/ /ig;
	$text =~ s/<nowiki>(.|\n)*?\<\/nowiki>/ /ig;
	$text =~ s/<pre>(.|\n)*?\<\/pre>/ /ig;
	$text =~ s/<code>(.|\n)*?\<\/code>/ /ig;
###############
### added by gypark
### {{{ }}} 내의 내용은 태그로 간주하지 않음
	$text =~ s/(^|\n)\{\{\{[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n/ \n/igm;
	$text =~ s/(^|\n)\{\{\{([a-zA-Z0-9+]+)(\|(n|\d*|n\d+|\d+n))?[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n/ \n/igm;
###
###############
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
		}
		if ($WikiLinks) {
			$text =~ s/$LinkPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
		}
	}
	return @links;
}

###############
### added by gypark
### comments from Jof
sub DoPost {
	my $string = &GetParam("text", undef);
	my $id = &GetParam("title", "");
	my $summary = &GetParam("summary", "");
	my $oldtime = &GetParam("oldtime", "");
	my $oldconflict = &GetParam("oldconflict", "");
	DoPostMain($string, $id, $summary, $oldtime, $oldconflict, 0);
	return;
}
###
###############


###############
### replaced by gypark
### comments from Jof
# sub DoPost {
# 	my ($editDiff, $old, $newAuthor, $pgtime, $oldrev, $preview, $user);
# 	my $string = &GetParam("text", undef);
# 	my $id = &GetParam("title", "");
# 	my $summary = &GetParam("summary", "");
# 	my $oldtime = &GetParam("oldtime", "");
# 	my $oldconflict = &GetParam("oldconflict", "");
#  	my $isEdit = 0;
# 	my $editTime = $Now;
# 	my $authorAddr = $ENV{REMOTE_ADDR};

sub DoPostMain {
	my ($string, $id, $summary, $oldtime, $oldconflict, $isEdit, $rebrowseid) = @_;
	my ($editDiff, $old, $newAuthor, $pgtime, $oldrev, $preview, $user);
	my $editTime = $Now;
	my $authorAddr = $ENV{REMOTE_ADDR};
###
###############


###############
### replaced by gypark
### comments 기능
#	if (!&UserCanEdit($id, 1)) {
	if (($rebrowseid eq "") && (!&UserCanEdit($id, 1))) {
###
###############
		# This is an internal interface--we don't need to explain
		&ReportError(Ts('Editing not allowed for %s.', $id));
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
	
###############
### added by gypark
### <mysign> 등 글작성 직후 수행할 매크로
### comments 구현을 위해 $id 추가, from Jof
	$string = &ProcessPostMacro($string, $id);
###
###############
	# Lock before getting old page to prevent races
	&RequestLock() or die(T('Could not get editing lock'));
	# Consider extracting lock section into sub, and eval-wrap it?
	# (A few called routines can die, leaving locks.)
	&OpenPage($id);
	&OpenDefaultText();
	$old = $Text{'text'};
	$oldrev = $Section{'revision'};
	$pgtime = $Section{'ts'};

	$preview = 0;
	$preview = 1  if (&GetParam("Preview", "") ne "");
	if (!$preview && ($old eq $string)) {  # No changes (ok for preview)
		&ReleaseLock();
		&ReBrowsePage($id, "", 1);
		return;
	}
	# Later extract comparison?
#	if (($UserID > 399) || ($Section{'id'} > 399))  {
###############
### replaced by gypark
### 로그인 하지 않은 경우의 conflict
#	if (($UserID ne "") || ($Section{'id'} ne ""))  {
	if (
#		(($UserID ne "") && ($UserID ne "112") && ($UserID ne "113")) ||
		(($UserID ne "") && (&LoginUser())) ||
		(($Section{'id'} ne "") && ($Section{'id'} ne "112") && ($Section{'id'} ne "113"))
		) {
###
###############
		$newAuthor = ($UserID ne $Section{'id'});       # known user(s)
	} else {
		$newAuthor = ($Section{'ip'} ne $authorAddr);  # hostname fallback
	}
	$newAuthor = 1  if ($oldrev == 0);  # New page
	$newAuthor = 0  if (!$newAuthor);   # Standard flag form, not empty
	# Detect editing conflicts and resubmit edit
	if (($oldrev > 0) && ($newAuthor && ($oldtime != $pgtime))) {
		&ReleaseLock();
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
###############
### added by gypark
### 링크 목록을 별도로 관리
	&SaveLinkFile($id);
###
###############
###############
### replaced by gypark
### rss from usemod1.0
#	&WriteRcLog($id, $summary, $isEdit, $editTime, $user, $Section{'host'});
	&WriteRcLog($id, $summary, $isEdit, $editTime, $user, $Section{'host'}, $Section{'revision'});
###
###############
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
###############
### added by gypark
### comments from Jof
	if ($rebrowseid ne "") {
		$id = $rebrowseid;
	}
###
###############
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
	open (SENDMAIL, "| $SendMail -oi -t ") or die "Can't send email: $!\n";
	print SENDMAIL <<"EOF";
From: $from
To: $to
Reply-to: $reply
Subject: $subject\n
$message
EOF
	close(SENDMAIL) or warn "sendmail didn't close nicely";
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
		open(EMAIL, "$DataDir/emails")
			or die "Can't open $DataDir/emails: $!\n";
		$address = join ",", <EMAIL>;
		$address =~ s/\n//g;
		close(EMAIL);
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
	my ($name, $freeName, @found);

	foreach $name (&AllPagesList()) {
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

sub SearchBody {
	my ($string) = @_;
	my ($name, @found);

	foreach $name (&AllPagesList()) {
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
	my $name;

	return if (!$UseCache);
	$id =~ s|.+/|/|;  # If subpage, search for just the subpage
	# The following code used to search the body for the $id
	foreach $name (&AllPagesList()) {  # Remove all to be safe
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
###############
### replaced by gypark
### rss from usemod1.0
#	my ($id, $summary, $isEdit, $editTime, $name, $rhost) = @_;
	my ($id, $summary, $isEdit, $editTime, $name, $rhost, $revision) = @_;
###
###############
	my ($extraTemp, %extra);

	%extra = ();
	$extra{'id'} = $UserID  if ($UserID ne "");
	$extra{'name'} = $name  if ($name ne "");
###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
	$extra{'tscreate'} = $Page{'tscreate'};
### rss from usemod 1.0
	$extra{'revision'} = $revision if ($revision ne "");
###############

	$extraTemp = join($FS2, %extra);
	# The two fields at the end of a line are kind and extension-hash
	my $rc_line = join($FS3, $editTime, $id, $summary,
										 $isEdit, $rhost, "0", $extraTemp);
	if (!open(OUT, ">>$RcFile")) {
		die(Ts('%s log error:', $RCName) . " $!");
	}
	print OUT  $rc_line . "\n";
	close(OUT);
}

sub WriteDiff {
	my ($id, $editTime, $diffString) = @_;

	open (OUT, ">>$DataDir/diff_log") or die(T('can not write diff_log'));
	print OUT  "------\n" . $id . "|" . $editTime . "\n";
	print OUT  $diffString;
	close(OUT);
}

sub DoMaintain {
	my ($name, $fname, $data);
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
	foreach $name (&AllPagesList()) {
		&OpenPage($name);
		&OpenDefaultText();
		&ExpireKeepFile();
###############
### added by gypark
### 링크 목록을 별도로 관리
		&SaveLinkFile($name);
### page count
		if (!(-f &GetCountFile($name))) {
			&CreatePageDir($CountDir, $name);  # It might not exist yet
			&WriteStringToFile(&GetCountFile($name), "0");
		}
###
###############
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
#	print &GetGotoBar("");
	print $q->endform;
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
#											-label=>"Edit $RCName");
											-label=>Ts('Edit %s', $RCName));
	print "<br>\n";
	print $q->checkbox(-name=>"p_changetext", -override=>1, -checked=>1,
#											-label=>"Substitute text for rename");
											-label=>T('Substitute text for rename'));
	print "<br>", $q->submit(-name=>'Edit'), "\n";
#	print &GetGotoBar("");
	print $q->endform;
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
	my (@pglist, $page, @links, $link, %seen);

	@pglist = &AllPagesList();
	%LinkIndex = ();
	foreach $page (@pglist) {
		&BuildLinkIndexPage($page);
	}
}

sub BuildLinkIndexPage {
	my ($page) = @_;
	my (@links, $link, %seen);

###############
### replaced by gypark
### 링크 목록을 별도로 관리
#	@links = &GetPageLinks($page, 1, 0, 0);
	@links = &GetPageLinksFromFile($page, 1, 0, 0);
###
###############
	%seen = ();
	foreach $link (@links) {
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
###############
### replaced by gypark
### RcOldFile 버그 수정
#	&EditRecentChangesFile($RcOldFile, $action, $old, $new);
	&EditRecentChangesFile($RcOldFile, $action, $old, $new) if (-f $RcOldFile);
###
###############
}

sub EditRecentChangesFile {
	my ($fname, $action, $old, $new) = @_;
	my ($status, $fileData, $errorText, $rcline, @rclist);
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
	foreach $rcline (@rclist) {
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
#		print "Delete-Page: page $page is invalid, error is: $status<br>\n";
		print Ts('Delete-Page: page %s is invalid', $page) . ".<br>" . Ts('error is: %s', $status) . "<br>\n";
		return;
	}

###############
### added by gypark
### 페이지 삭제 시에 keep 화일은 보존해 둠
	&OpenPage($page);
	&OpenDefaultText();
	&SaveKeepSection();
	&ExpireKeepFile();
	&WriteRcLog($OpenPageName, "*", 0, $Now, &GetParam("username",""), &GetRemoteHost(0));
###
###############
	$fname = &GetPageFile($page);
	unlink($fname)  if (-f $fname);
###############
### commented by gypark
### 페이지 삭제 시에 keep 화일은 보존해 둠
#	$fname = $KeepDir . "/" . &GetPageDirectory($page) .  "/$page.kp";
#	unlink($fname)  if (-f $fname);
###
###############

#########################################################3
### added by gypark
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
#########################################################3
###############
### added by gypark
### 링크 목록을 별도로 관리
	$fname = &GetLinkFile($page);
	unlink($fname) if (-f $fname);
###
###############
	unlink($IndexFile)  if ($UseIndex);
###############
### commented by gypark
### 페이지 삭제 시에 keep 화일은 보존해 둠
#	&EditRecentChanges(1, $page, "")  if ($doRC);  # Delete page
###
###############
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
		$text =~ s/(<html>((.|\n)*?)<\/html>)/&StoreRaw($1)/ige;
	}
	$text =~ s/(<pre>((.|\n)*?)<\/pre>)/&StoreRaw($1)/ige;
	$text =~ s/(<code>((.|\n)*?)<\/code>)/&StoreRaw($1)/ige;
	$text =~ s/(<nowiki>((.|\n)*?)<\/nowiki>)/&StoreRaw($1)/ige;
###############
### added by gypark
### {{{ }}} 내의 내용은 태그로 간주하지 않음
	$text =~ s/((^|\n)\{\{\{[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n)/&StoreRaw($1)/igem;
	$text =~ s/((^|\n)\{\{\{([a-zA-Z0-9+]+)(\|(n|\d*|n\d+|\d+n))?[ \t\r\f]*\n((.|\n)*?)\n\}\}\}[ \t\r\f]*\n)/&StoreRaw($1)/igem;
###
###############

	if ($FreeLinks) {
		$text =~
		 s/\[\[$FreeLinkPattern\|([^\]]+)\]\]/&SubFreeLink($1,$2,$old,$new)/geo;
		$text =~ s/\[\[$FreeLinkPattern\]\]/&SubFreeLink($1,"",$old,$new)/geo;
	}
	if ($BracketText) {  # Links like [URL text of link]
		$text =~ s/(\[$UrlPattern\s+([^\]]+?)\])/&StoreRaw($1)/geo;
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
	my ($link, $name, $old, $new) = @_;
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

	# First pass: optimize for nothing changed
	$changed = 0;
	foreach (@kplist) {
		%tempSection = split(/$FS2/, $_, -1);
		$sectName = $tempSection{'name'};
		if ($sectName =~ /^(text_)/) {
			%Text = split(/$FS3/, $tempSection{'data'}, -1);
			$newText = &SubstituteTextLinks($old, $new, $Text{'text'});
			$changed = 1  if ($Text{'text'} ne $newText);
		}
		# Later add other section types? (maybe)
	}

	return  if (!$changed);  # No sections changed
	open (OUT, ">$fname") or return;
	foreach (@kplist) {
		%tempSection = split(/$FS2/, $_, -1);
		$sectName = $tempSection{'name'};
		if ($sectName =~ /^(text_)/) {
			%Text = split(/$FS3/, $tempSection{'data'}, -1);
			$newText = &SubstituteTextLinks($old, $new, $Text{'text'});
			$Text{'text'} = $newText;
			$tempSection{'data'} = join($FS3, %Text);
			print OUT $FS1, join($FS2, %tempSection);
		} else {
			print OUT $FS1, $_;
		}
	}
	close(OUT);
}

sub RenameTextLinks {
	my ($old, $new) = @_;
	my ($changed, $file, $page, $section, $oldText, $newText, $status);
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

	# Note: the LinkIndex must be built prior to this routine
	return  if (!defined($LinkIndex{$oldCanonical}));

	@pageList = split(' ', $LinkIndex{$oldCanonical});
	foreach $page (@pageList) {
		$changed = 0;
		&OpenPage($page);
		foreach $section (keys %Page) {
			if ($section =~ /^text_/) {
				&OpenSection($section);
				%Text = split(/$FS3/, $Section{'data'}, -1);
				$oldText = $Text{'text'};
				$newText = &SubstituteTextLinks($old, $new, $oldText);
				if ($oldText ne $newText) {
					$Text{'text'} = $newText;
					$Section{'data'} = join($FS3, %Text);
					$Page{$section} = join($FS2, %Section);
					$changed = 1;
				}
			} elsif ($section =~ /^cache_diff/) {
				$oldText = $Page{$section};
				$newText = &SubstituteTextLinks($old, $new, $oldText);
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
###############
### added by gypark
### 링크 목록을 별도로 관리
			&SaveLinkFile($page);
###
###############
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
###############
### added by gypark
### 페이지 이름 변경시, lock 화일도 같이 변경
	my ($oldlock, $newlock);
	$oldlock = &GetLockedPageFile($old);
	if (-f $oldlock) {
		$newlock = &GetLockedPageFile($new);
		rename($oldlock, $newlock) || die "error while renaming lock";
	}
### cache 화일은 삭제
	&UnlinkHtmlCache($old);
### page count 화일도 변경
	my ($oldcnt, $newcnt);
	$oldcnt = &GetCountFile($old);
	if (-f $oldcnt) {
		$newcnt = &GetCountFile($new);
		&CreatePageDir($CountDir, $new);  # It might not exist yet
		rename($oldcnt, $newcnt) || die "error while renaming count file";
	}
### hide page by gypark
	if (defined($HiddenPage{$old})) {
		delete $HiddenPage{$old};
		$HiddenPage{$new} = "1";
		&SaveHiddenPageFile();
	}
###
###############

###############
### added by gypark
### 링크 목록을 별도로 관리
	my ($oldlink, $newlink);
	$oldlink = &GetLinkFile($old);
	if (-f $oldlink) {
		$newlink = &GetLinkFile($new);
		&CreatePageDir($LinkDir, $new);  # It might not exist yet
		rename($oldlink, $newlink) || die "error while renaming link file";
	}
###
###############
	&EditRecentChanges(2, $old, $new)  if ($doRC);
	if ($doText) {
		&BuildLinkIndexPage($new);  # Keep index up-to-date
		&RenameTextLinks($old, $new);
	}
}

sub DoShowVersion {
	print &GetHeader("", T('Displaying Wiki Version'), "");
###############
### replaced by gypark
### 버전 정보를 별도의 변수에 보관
# 	print "<p>UseModWiki version 0.92K2<p>\n";
	print "<p>UseModWiki version $WikiVersion ($WikiRelease)<p>\n";
###
###############
	print &GetCommonFooter();
}


#END_OF_OTHER_CODE

###############
### added by gypark
### 통채로 추가한 함수들은 여기에 둠

### 로그인한 사용자인지 검사
sub LoginUser {
	if (($UserID eq "113") || ($UserID eq "112")) {
		return 0;
	} else {
		return 1;
	}
}

###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
sub DoBookmark {
	if (&GetParam('username') eq "") {		# 로그인하지 않은 경우
		&BrowsePage(T($RCName));				# 그냥 최근 변경 내역으로 이동
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
###
###############

###############
### added by gypark
### 링크 목록을 별도로 관리
sub GetLinkFile {
	my ($id) = @_;

	return $LinkDir . "/" . &GetPageDirectory($id) . "/$id.lnk";
}

sub SaveLinkFile {
	my ($page) = @_;
	my (%links, @pagelinks, @interlinks, @urllinks, @alllinks, $link);

	@alllinks = &GetPageLinks($page, 1, 1, 1);

	foreach $link (@alllinks) {
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

###############
### added by gypark
### hide page
	if (&PageIsHidden($name)) {
		return;
	}
###
###############

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
#	push (@result, split($FS2, $links{'pagelinks'}, -1)) if ($pagelink);
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
	if (&GetParam('InFrame',"") ne "") {
		$add = 0;
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
	print &GetHtmlHeader("$SiteName : ". T('Upload File'), "");
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
	print $q->filefield("upload_file","",60,80) . "\n";
	print "&nbsp;&nbsp;" . "\n";
	print $q->submit(T('Upload')) . "\n";
	print "</center>" . "\n";
	print $q->endform();
}

sub UploadFile {
	my ($file) = @_;
	my ($filename);
	my ($target);

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
	my $prefix = &GetLastPrefix($UploadDir, $filename);
	my $target = $prefix.$filename;
	my $target_full = "$UploadDir/$target";

	&CreateDir($UploadDir);

	if (!open (FILE, ">$target_full")) {
		&ReleaseLockDir('upload');
		die Ts('cant opening %s', $target_full) . ": $!";
	}
	&ReleaseLockDir('upload');
	binmode FILE;
	while (<$file>) {
		print FILE $_;
	}
	close(FILE);
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
	print "Upload:$target\n";
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
			if (unlink ("$UploadDir/$_")) {
				print Ts('%s is deleted successfully', $_)."<br>";
			} else {
				print Ts('%s can not be deleted', $_). " : $!<br>";
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
	print &GetHtmlHeader("$SiteName : ". T("Oekaki $mode"), "");
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
	my $filename = "oekaki.png";
	my (@allfiles, @files, %filemtime);

	opendir (DIR, "$UploadDir") || die Ts('cant opening %s', $UploadDir) . ": $!";
	@allfiles = readdir(DIR);
	shift @allfiles;
	shift @allfiles;
	close(DIR);

	foreach (@allfiles) {
		if ($_ =~ m/$filename$/) {
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
	print "Upload:$files[0]<br>\n";
	print "<img style='border: solid 1 gray;' src='$UploadUrl/$files[0]'>\n";
	print "</div>\n";

	print "<hr size='1'>";
	print T('If you want to paint a new picture')."<br>\n";

	print qq|
<div align="center">
<form action="$ScriptName" method="POST">
<input type="hidden" name="action" value="oekaki">
width [640-40]<input type="text" name="width" size="4" maxlength="3" value="300">
height [480-40]<input type="text" name="height" size="4" maxlength="3" value="300">
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
	my ($buffer, $p, $filename, $prefix, $target_full);

# POST 데이타 읽음
	read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	$p = index($buffer, "\r");

# 각종 에러 처리
	if (!($buffer =~ m/^\0\0\0\0\r\n/)) {
		die("Invalid POST data");
	}

	if ($p < 0) {
		my $size = length($buffer);
		die("Data size $size");
	}

# 현재는 제대로 동작하지 않는다
#	if (!(&UserCanEdit("",1))) {
#		die T('Oekaki is not allowed');
#	}

# 락을 획득
	if (!(&RequestLockDir('oekaki', 4, 3, 0))) {
		die("can not get lock");
	}

# 저장할 화일명 결정
	$filename = "oekaki.png";
	$prefix = &GetLastPrefix($UploadDir, $filename);
	$target_full = $UploadDir."/".$prefix.$filename;

# 저장
	&CreateDir($UploadDir);
	&WriteBinaryToFile($target_full, substr($buffer, $p+2));

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
	$imageWidth = 640 if ($imageWidth > 640);
	$imageHeight = 40 if ($imageHeight < 40);
	$imageHeight = 480 if ($imageHeight > 480);

	my ($appletWidth, $appletHeight) = (
		(($imageWidth < 300)?400:($imageWidth+100)),
		(($imageHeight < 300)?420:($imageHeight+120))
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
width [640-40]<input type="text" name="width" size="4" maxlength="3" value="$imageWidth">
height [480-40]<input type="text" name="height" size="4" maxlength="3" value="$imageHeight">
<input type="submit" value="OK">
</form>
</div>

<p align="center">
<applet codebase="./" code="pbbs.PaintBBS.class" archive="./PaintBBS.jar" name="paintbbs" width="$appletWidth" height="$appletHeight">
<param name="jp" value="false">
<param name="image_width" value="$imageWidth">
<param name="image_height" value="$imageHeight">

<param name="image_bkcolor" value="#ffffff">

<param name="undo" value="60">
<param name="undo_in_mg" value="12">

<param name="color_text" value="#505078">
<param name="color_bk" value="#9999bb">
<param name="color_bk2" value="#8888aa">

<param name="color_icon" value="#ccccff">
<param name="color_iconselect" value="#202030">

<param name="url_save" value="$ScriptName?action=oekaki&mode=save">
<param name="url_exit" value="$ScriptName?action=oekaki&mode=exit">

<param name="poo" value="true">
<param name="target" value="_self">
</applet></p>

|;
}

### 화일명이 겹칠 경우 앞에 붙일 prefix 를 얻는 함수
sub GetLastPrefix {
	my ($dir, $file) = @_;

	if (!(-f "$dir/$file")) {
		return "";
	}
	
	if (!(-f "$dir/2_$file")) {
		return "2_";
	}

	my $prefix = 2;
	while (-f "$dir/$prefix"."_$file") {
		$prefix += 10;
	}
	$prefix -= 10;
	while (-f "$dir/$prefix"."_$file") {
		$prefix++;
	}

	return $prefix ."_";
}

### 관심 페이지
sub DoInterest {
	my ($title, $temp);
	my $mode = &GetParam('mode');
	my $id = &GetParam('id');
	my $failMsg = T('Fail to access Interest Page List');

#	if (&GetParam('username') eq "") {
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

	open (OUT, ">$file") or die(Ts('cant write %s', $file) . ": $!");
	binmode(OUT);
	print OUT  $string;
	close(OUT);
}

### comments from Jof
sub DoComments {
	my ($id) = @_;	
	my $pageid = &GetParam("pageid", "");
	my $name = &GetParam("name", "");
	my $newcomments = &GetParam("comment", "");
	my $up   = &GetParam("up", "");
	my ($timestamp) = CalcDay($Now) . " " . CalcTime($Now);
	my $string;
	my $long = &GetParam("long", "");

	# thread
	my $threadindent = &GetParam("threadindent", "");
	my $abs_up = abs($up);
	my ($threshold1, $threshold2) = (100000000, 1000000000);
	
	if ($newcomments =~ /^\s*$/) {
		&ReBrowsePage($pageid, "", 0);
		return;
	}
		
	$name = &GetRemoteHost(0) if ($name eq "");
	$name =~ s/,/./g;
	$newcomments = &QuoteHtml($newcomments);

	&OpenPage($id);
	&OpenDefaultText();
	$string = $Text{'text'};

	if ($threadindent ne '') {		# thread
		$newcomments =~ s/^\s*//g;
		$newcomments =~ s/\s*$//g;
		$newcomments =~ s/(\n)\s*(\r?\n)/$1$2/g;
		$newcomments =~ s/(\r?\n)/ \\\\$1/g;

		my ($comment_head, $comment_tail) = ("", "");
		my $newup;

		if (($abs_up >= 100) && ($abs_up <= $threshold2)) {	# 커멘트 권한 상속
			$newup = $Now - $threshold2;
		} else {
			$newup = $Now;
		}

		$comment_tail = "<thread($id,$newup," . ($threadindent+1) . ")>";

		if ($threadindent >= 1) {
			for (1 .. $threadindent) {
				$comment_head .= ":";
			}
			$comment_head .= " ";
		} else {	# 새글
			$comment_head = "<thread>\n";
			$comment_tail .= "\n</thread>";
		}

		if (($up > 0) && ($up < $threshold1)) {		# 위로 달리는 새글
			$string =~ s/(\<thread\($id,$up(,\d+)?\)\>)/$comment_head$newcomments <mysign($name,$timestamp)>\n$comment_tail\n\n$1/;
		} else {									# 리플 or 아래로 달리는 새글
			$string =~ s/(\<thread\($id,$up(,\d+)?\)\>)/$1\n\n$comment_head$newcomments <mysign($name,$timestamp)>\n$comment_tail/;
		}
	} elsif ($long) {				# longcomments
		$newcomments =~ s/^\s*//g;
		$newcomments =~ s/\s*$//g;
		$newcomments =~ s/(\n)\s*(\r?\n)/$1$2/g;
		$newcomments =~ s/(\r?\n)/ \\\\$1/g;

		if ($up > 0) {
			$string =~ s/(\<longcomments\($id,$up\)\>)/\n$newcomments <mysign($name,$timestamp)>\n$1/;
		} else {
			$string =~ s/(\<longcomments\($id,$up\)\>)/$1\n$newcomments <mysign($name,$timestamp)>\n/;
		}
	} else {						# comments
		$newcomments =~ s/(----+)/<nowiki>$1<\/nowiki>/g;
		if ($up > 0) {
			$string =~ s/\<comments\($id,$up\)\>/* ''' $name ''' : $newcomments - <small>$timestamp<\/small>\n\<comments\($id,$up\)\>/;
		} else {
			$string =~ s/\<comments\($id,$up\)\>/\<comments\($id,$up\)\>\n* ''' $name ''' : $newcomments - <small>$timestamp<\/small>/;
		}
	}

	if (((!&UserCanEdit($id,1)) && (($abs_up < 100) || ($abs_up > $threshold2))) || (&UserIsBanned())) {		# 에디트 불가
		$pageid = "";
	}

	DoPostMain($string, $id, "*", $Section{'ts'}, 0, 0, $pageid);
	return;
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

	return "$text";
}

### rss from usemod1.0
sub DoRss {
	print "Content-type: text/xml\n\n";
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
        <link>${\($QuotedFullUrl . &QuoteHtml("?$RCName"))}</link>
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
	my ($rcline, $date, $newtop, $author, $inlist, $result);
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
###############
### added by gypark
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
	my $num_items = &GetParam("items", 0);
	my $num_printed = 0;
###
###############
	if ($showedit != 1) {
		my @temprc = ();
		foreach $rcline (@outrc) {
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
###############
### replaced by gypark
### 북마크
#	$diffPrefix = $QuotedFullUrl . &QuoteHtml("?action=browse\&diff=4\&id=");
	$diffPrefix = $QuotedFullUrl . &QuoteHtml("?action=browse\&diff=5\&id=");
###
###############
	$historyPrefix = $QuotedFullUrl . &QuoteHtml("?action=history\&id=");
	foreach $rcline (@outrc) {
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
	foreach $rcline (@outrc) {
		($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
			= split(/$FS3/, $rcline);
		next  if ((!$all) && ($ts < $changetime{$pagename}));
		next  if (($idOnly ne "") && ($idOnly ne $pagename));
### hide page
		next if (&PageIsHidden($pagename));
###############
### added by gypark
### 최근 변경 내역과 rss 에 아이템 갯수 지정 옵션
		$num_printed++;
		last if (($num_items > 0) && ($num_printed > $num_items));
###
###############
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

	# Add to list of items in the <channel/>
	$itemID = $FullUrl . &ScriptLinkChar()
			. &GetOldPageParameters('browse', $pagename, $revision);
	$itemID = &QuoteHtml($itemID);
	$headItem = "                <rdf:li rdf:resource=\"$itemID\"/>\n";
# Add to list of items proper.
	if (($summary ne "") && ($summary ne "*")) {
		$description = &QuoteHtml($summary);
	}
	$host = &QuoteHtml($host);
	if ($userName) {
		$author = &QuoteHtml($userName);
		$authorLink = "link=\"$QuotedFullUrl?$author\"";
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
        <link>$QuotedFullUrl?$pagename</link>
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
        <wiki:diff>$diffPrefix$pagename</wiki:diff>
        <wiki:version>$revision</wiki:version>
        <wiki:history>$historyPrefix$pagename</wiki:history>
    </item>
RSS
	return ($headItem, $item);
}

sub GetHtmlRcLine {
### 현재는 사용되지 않음
	die "GetHtmlRcLine -- must not be executed!!!";
}

### Trackback
sub DoSendTrackbackPing {
	require Net::Trackback::Client;
	require Net::Trackback::Ping;

	my ($id) = @_;
	my ($ping_url, $title, $url, $excerpt, $blog_name, $ping_permalink);
	my $validid = &ValidId($id);
	my $result = "";

	$ping_url = &GetParam('ping_url');
	$title = &GetParam('title');
	$url = &GetParam('url');
	$excerpt = &GetParam('excerpt');
	$blog_name = &GetParam('blog_name');
	$ping_permalink = &GetParam('ping_permalink');

	if ($validid ne '') {
		$result .= $validid;
	} elsif (!&UserCanSendTrackbackPing($id)) {
		$result .= &T('You are not allowed to send Trackback ping of this page');
	} elsif ($ping_url eq '') {
		$result .= &T('No Ping URL');
	} else {
		my $ping = Net::Trackback::Ping->new;
		$ping->ping_url("$ping_url");
		$ping->title("$title");
		$ping->url("$url");
		$ping->excerpt("$excerpt");
		$ping->blog_name("$blog_name");

		my $client = Net::Trackback::Client->new();
		my $msg = $client->send_ping($ping);
		my $msg_str = $msg->to_xml;

		my ($code, $message) = ($msg_str =~ m!<error>(\d+).*<message>(.*?)</message>!s);
		
		if ($msg->is_success) {
			sleep(1);
			$Now = time;
			&OpenPage($id);
			&OpenDefaultText();
			my $string = $Text{'text'};
			my $macro = "\<trackbacksent\>";
			if ($string =~ /$macro/) {
				my $timestamp = &CalcDay($Now) . " " . &CalcTime($Now);
				my $newtrackbacksent = "* $timestamp | " . 
					(($ping_permalink ne '')?$ping_permalink:$ping_url);
				$string =~ s/($macro)/$newtrackbacksent\n$1/;
				&DoPostMain($string, $id, &T('New Trackback Sent'), $Section{'ts'}, 0, 0, "!!");
			}
			$result .= &T('Ping successfully sent');
		} else {
			$result .= &Ts('Error occurred: %s', "$code - $message");
		}
	}

	print &GetHttpHeader();
	print &GetHtmlHeader("$SiteName : ". &T('Send Trackback Ping'), "");
	print $q->h2(&T('Send Trackback Ping')) . "\n";
	print $result;
	print "<hr size='1'>".Ts('Return to %s' , &GetPageLink($id));
	print $q->end_html;

	return;
}

sub UserCanSendTrackbackPing {
	my ($id) = @_;

	return 1 if ($SendPingAllowed == 0);
	return 1 if (&UserIsAdmin());
	return 1 if (($SendPingAllowed == 1) && (&UserCanEdit($id)));

	return 0;
}

sub PageCanReceiveTrackbackPing {
	my ($id) = @_;

	return 0 if (! -f &GetPageFile($id));
	return 0 if (defined $HiddenPage{$id});
	return 0 if (-f &GetLockedPageFile($id));

	return 1;
}

sub DoReceiveTrackbackPing {
	my ($id) = @_;
	my $normal_id = $id;

	my $url = &GetParam('url');
	my $title = &GetParam('title', $url);
	my $blog_name = &GetParam('blog_name');
	my $excerpt = &GetParam('excerpt');
	if (length($excerpt) > 255) {
		$excerpt = substr($excerpt, 0, 252);
		$excerpt =~ s/(([\x80-\xff].)*)[\x80-\xff]?$/$1/;
		$excerpt .= "...";
	}
	$excerpt =~ s/(\r?\n)/ /g;
	$excerpt = &QuoteHtml($excerpt);
	$excerpt = "<nowiki>$excerpt</nowiki>";

	if ($FreeLinks) {
		$normal_id = &FreeToNormal($id);
	}

	if ($url eq '') {
		&SendTrackbackResponse("1", "No URL (url)");
	} elsif ($id eq '') {
		&SendTrackbackResponse("1", "No Pagename (id)");
	} elsif (!&PageCanReceiveTrackbackPing($normal_id)) {
		&SendTrackbackResponse("1", "Invalid Pagename (Page is missing, or Trackback is not allowed)");
	} else {
		&OpenPage($normal_id);
		&OpenDefaultText();
		my $string = $Text{'text'};
		my $macro = "\<trackbackreceived\>";
		if (!($string =~ /$macro/)) {
			$string .= "\n$macro\n";
		}
		my $timestamp = &CalcDay($Now) . " " . &CalcTime($Now);
		my $newtrackbackreceived = "* " .
			&Ts('Trackback from %s', "'''<nowiki>$blog_name</nowiki>'''") .
			" $timestamp\n" .
			"** " . &T('Title:') . " [$url $title]\n" .
			"** " . &T('Content:') . " $excerpt";
		$string =~ s/($macro)/$newtrackbackreceived\n$1/;
		&DoPostMain($string, $id, &T('New Trackback Received'), $Section{'ts'}, 0, 0, "!!");
		&SendTrackbackResponse(0, "");
	}
}

sub SendTrackbackResponse {
	my ($code, $message) = @_;

	if ($code == 0) {
		print <<END;
Content-Type: application/xml; charset: iso-8859-1\n
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>0</error>
</response>
END
	} else {
		print <<END;
Content-Type: application/xml; charset: iso-8859-1\n
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>$code</error>
<message>$message</message>
</response>
END
	}
}
	
sub EncodeUrl {
	my ($string) = @_;
	$string =~ s!([^a-zA-Z0-9_.-])!uc sprintf "%%%02x", ord($1)!eg;
	return $string;
}

sub GetTrackbackGuide {
	my ($id) = @_;

	my $result = "\n<HR class='footer'>\n<DIV class='trackbackguide'>";

	my $trackbackguide = "<P>";

	$FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
	my $encoded = &EncodeUrl($id);
	my $url = $FullUrl . &ScriptLinkChar() . "action=trackback&id=$encoded";

	if (&PageCanReceiveTrackbackPing($id)) {
		$trackbackguide .= &T('Trackback address of this page:') . " " . (&UrlLink("$url"))[0];
	} else {
		$trackbackguide .= &T('This page can not receive Trackback');
	}

	if (&UserCanSendTrackbackPing($id)) {
		$FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
		my $url = $FullUrl . &ScriptLinkChar . $id;
		my $title = $id;
		if ($FreeLinks) {
			$title =~ s/_/ /g;  # Display with spaces
		}
		my $excerpt = $Text{'text'};
		$excerpt =~ s/<.*?>//g;
		if (length($excerpt) > 255) {
			$excerpt = substr($excerpt, 0, 252);
			$excerpt =~ s/(([\x80-\xff].)*)[\x80-\xff]?$/$1/;
			$excerpt .= "...";
		}
		$excerpt =~ s/(\r?\n)/ /g;
		$excerpt = &QuoteHtml($excerpt);
		$excerpt =~ s/"/&quot;/g;

		$trackbackguide .= "\n<BR>";
		$trackbackguide .= &GetFormStart("Trackback_ping") .
			&GetHiddenValue("action", "send_ping") .
			&GetHiddenValue("title", "$title") .
			&GetHiddenValue("blog_name", "$SiteName") .
			&GetHiddenValue("excerpt", "$excerpt") .
			&GetHiddenValue("url", "$url") .
			&GetHiddenValue("id", "$id") .
			"<TABLE style='border: none;'>" .
			"<TR><TD style='border: none;' colspan=2>" . &T('Send Trackback Ping of this page to:') . "</TD></TR>" .
			"<TR><TD style='border: none;'>" . &T('Trackback URL:') . "</TD>" .
			"<TD style='border: none;'>" . $q->textfield(-name=>"ping_url", -default=>"", -override=>1, -size=>100, -maxlength=>200) . "</TD></TR>" .
			"<TR><TD style='border: none;'>" . &T('Permalink URL (optional):') . "</TD>" .
			"<TD style='border: none;'>" .
			$q->textfield(-name=>"ping_permalink", -default=>"", -override=>1, -size=>100, -maxlength=>200) . "</TD></TR>" .
			"<TR><TD style='text-align: center; border: none;' colspan=2>" . $q->submit(&T('Send Ping')) . "</TD></TR>" .
			"</TABLE>" .
			$q->endform;
	}

	$result .= &MacroMemo("", &T('Send Trackback'), $trackbackguide, "trackbackguidecontent");

	$result .= "</DIV>";
}
### 통채로 추가한 함수들의 끝
###############

&DoWikiRequest()  if ($RunCGI && ($_ ne 'nocgi'));   # Do everything.
1; # In case we are loaded from elsewhere
# == End of UseModWiki script. ===========================================

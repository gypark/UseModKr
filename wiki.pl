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
$WikiVersion = "0.92K3-ext1.30";
$WikiRelease = "2003-03-02";

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
	$ScriptTZ $BracketText $UseAmPm $UseConfig $UseIndex $UseLookup
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
	$ConfigFile $SOURCEHIGHLIGHT %SRCHIGHLANG $LinkFirstChar
	$EditGuideInExtern $SizeTopFrame $SizeBottomFrame
	$LogoPage $CheckTime $LinkDir $IconDir
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
use vars qw(%RevisionTs $FS_lt $FS_gt $StartTime $Sec_Revision $Sec_Ts);
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
$UseConfig   = 1;       # 1 = use config file,    0 = do not look for config

# == Configuration =======================================================
# Original version from UseModWiki 0.92 (April 21, 2001)

$CookieName  = "WikiWiki";      # Name for this wiki (for multi-wiki sites)
$SiteName    = "WikiWiki";		# Name of site (used for titles)
$HomePage    = "WikiHome";      # Home page (change space to _)
$RCName      = "RecentChanges"; # Name of changes page (change space to _)
$LogoUrl     = "";     # URL for site logo ("" for no logo)
$ENV{PATH}   = "/usr/bin/";     # Path used to find "diff"
$ScriptTZ    = "";              # Local time zone ("" means do not print)
$RcDefault   = 30;              # Default number of RecentChanges days
@RcDays      = qw(1 3 7 30 90); # Days for links on RecentChanges
$KeepDays    = 14;              # Days to keep old revisions
$SiteBase    = "";              # Full URL for <BASE> header
$FullUrl     = "";              # Set if the auto-detected URL is wrong
$RedirType   = 1;               # 1 = CGI.pm, 2 = script, 3 = no redirect
$AdminPass   = "abcd1234";      # Set to non-blank to enable password(s)
$EditPass    = "";              # Like AdminPass, but for editing only
$StyleSheet  = "wiki.css";      # URL for CSS stylesheet (like "/wiki.css")
$NotFoundPg  = "";              # Page for not-found links ("" for blank pg)
$EmailFrom   = "wiki";          # Text for "From: " field of email notes.
$SendMail    = "/usr/sbin/sendmail";  # Full path to sendmail executable
$FooterNote  = "";              # HTML for bottom of every page
$EditNote    = "";              # HTML notice above buttons on edit page
$MaxPost     = 1024 * 210;      # Maximum 210K posts (about 200K for pages)
$NewText     = "";              # New page text ("" for default message)
$HttpCharset = "euc-kr";              # Charset for pages, like "iso-8859-2"
$UserGotoBar = "<a href='/'>Home</a>";   # HTML added to end of goto bar
###############
### added by gypark
### 상단메뉴에 사용자 정의 링크 추가. config.pl 또는 이곳에서 정의해 줄 것
### 정의되어 있지 않거나 NULL string 으로 정의되어있다면, 
### 메뉴바에도 나타나지 않는다
$UserGotoBar2 = "";              # HTML added to end of goto bar
$UserGotoBar3 = "";              # HTML added to end of goto bar
$UserGotoBar4 = "";              # HTML added to end of goto bar
$SOURCEHIGHLIGHT    = "/usr/local/bin/source-highlight";    # path of source-highlight 
%SRCHIGHLANG = ("cpp", 1, "java", 1, "prolog", 1, "perl", 1, 
		"php3", 1, "python", 1, "flex", 1, "changelog", 1
		); # supported languages
$LinkFirstChar = 0;    # 1 = link on first character,  0 = followed by "?" mark (classical)
$EditGuideInExtern = 0; # 1 = show edit guide in bottom frame, 0 = don't show
$SizeTopFrame = 160;
$SizeBottomFrame = 110;
$LogoPage   = "";	# this page will be displayed when no parameter
$CheckTime = 0;   # 1 = mesure the processing time (requires Time::HiRes module), 0 = do not 
$IconDir = "./icons";
###
###############


# Major options:
$UseSubpage  = 1;       # 1 = use subpages,       0 = do not use subpages
$UseCache    = 0;       # 1 = cache HTML pages,   0 = generate every page
$EditAllowed = 1;       # 1 = editing allowed,    0 = read-only
$RawHtml     = 1;       # 1 = allow <HTML> tag,   0 = no raw HTML in pages
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
$UseDiffLog  = 0;       # 1 = save diffs to log,  0 = do not save diffs
$KeepMajor   = 1;       # 1 = keep major rev,     0 = expire all revisions
$KeepAuthor  = 1;       # 1 = keep author rev,    0 = expire all revisions
$ShowEdits   = 0;       # 1 = show minor edits,   0 = hide edits by default
$HtmlLinks   = 0;       # 1 = allow A HREF links, 0 = no raw HTML links
$SimpleLinks = 1;       # 1 = only letters,       0 = allow _ and numbers
$NonEnglish  = 0;       # 1 = extra link chars,   0 = only A-Za-z chars
$ThinLine    = 1;       # 1 = fancy <hr> tags,    0 = classic wiki <hr>
$BracketText = 1;       # 1 = allow [URL text],   0 = no link descriptions
$UseAmPm     = 0;       # 1 = use am/pm in times, 0 = use 24-hour times
$UseIndex    = 0;       # 1 = use index file,     0 = slow/reliable method
$UseHeadings = 1;       # 1 = allow = h1 text =,  0 = no header formatting
$NetworkFile = 1;       # 1 = allow remote file:, 0 = no file:// links
$BracketWiki = 1;       # 1 = [WikiLnk txt] link, 0 = no local descriptions
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
$InterFile   = "$DataDir/intermap"; # Interwiki site->url map
$RcFile      = "$DataDir/rclog";    # New RecentChanges logfile
$RcOldFile   = "$DataDir/rclog.old"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$LinkDir     = "$DataDir/link";    # Stores the links of each page

# added by luke

$UseEmoticon 	= 1;		# 1 = use emoticon, 0 = not use
$EmoticonPath 	= "http:emoticon/";	# where emoticon stored
$ClickEdit	 	= 1;		# 1 = edit page by double click on page, 0 = no use
$EditPagePos	= 1;		# 1 = bottom, 2 = top, 3 = top & bottom
$NamedAnchors	= 1;		# 0 = no anchors, 1 = enable anchors, 2 = enable but suppress display

# == End of Configuration =================================================

umask 0;

$TableOfContents = "";

# The "main" program, called at the end of this script file.
sub DoWikiRequest {
###############
### replaced by gypark
### 보안을 위해서, 설정 화일을 다른 것으로 지정
### 적절히 바꾸어서 사용할 것
#	if ($UseConfig && (-f "config.pl")) {
#		do "config.pl";  # Later consider error checking?
#	}
 	if ($UseConfig && (-f $ConfigFile)) {
 		do "$ConfigFile";
	}
### 번역 메시지를 사용할 경우는 config.pl 또는 
### 이 아래에 불러올 화일명을 적는다
#   do "./translations/trans.pl";
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
	$AnchoredLinkPattern = $LinkPattern . '#(\\w+)' . $QDelim if $NamedAnchors;
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

	# Url-style links are delimited by one of:
	#   1.  Whitespace                           (kept in output)
	#   2.  Left or right angle-bracket (< or >) (kept in output)
	#   3.  Right square-bracket (])             (kept in output)
	#   4.  A single double-quote (")            (kept in output)
	#   5.  A $FS (field separator) character    (kept in output)
	#   6.  A double double-quote ("")           (removed from output)

	$UrlProtocols = "http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|mms|"
									. "prospero|telnet|gopher";
	$UrlProtocols .= '|file'  if $NetworkFile;
	$UrlPattern = "((?:(?:$UrlProtocols):[^\\]\\s\"<>$FS]+)$QDelim)";
	$ImageExtensions = "(gif|jpg|png|bmp|jpeg|GIF|JPG|PNG|BMP|JPEG)";
	$RFCPattern = "RFC\\s?(\\d+)";
	$ISBNPattern = "ISBN:?([0-9- xX]{10,})";
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
	$CGI::DISABLE_UPLOADS = 1;  # no uploads
	$q = new CGI;
	$q->autoEscape(undef);

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
		&BrowsePage(T($RCName));
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

	&OpenPage($id);
	&OpenDefaultText();
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
			$diffRevision = $Page{'revision'} - 1;
			while (($diffRevision > 1) && 
				(defined($RevisionTs{$diffRevision})) && 
				($RevisionTs{$diffRevision} > &GetParam('bookmark',-1))) {
				$diffRevision--;
			}
			$showDiff = &GetParam("defaultdiff", 1);
		}
###
###############
		$fullHtml .= &GetDiffHTML($showDiff, $id, $diffRevision, "$revision", $newText);
		$fullHtml .= "<hr>\n";
	}

	if ($EditPagePos >= 2) {
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
		&DoRc();
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
	my ($fileData, $rcline, $i, $daysago, $lastTs, $ts, $idOnly);
	my (@fullrc, $status, $oldFileData, $firstTs, $errorText);
	my $starttime = 0;
	my $showbar = 0;

	if (&GetParam("sincelastvisit", 0)) {
		$starttime = $q->cookie($CookieName ."-RC");
	} elsif (&GetParam("from", 0)) {
		$starttime = &GetParam("from", 0);
		print "<h2>" . Ts('Updates since %s', &TimeToText($starttime))
					. "</h2>\n";
	} else {
		$daysago = &GetParam("days", 0);
		$daysago = &GetParam("rcdays", 0)  if ($daysago == 0);
		if ($daysago) {
			$starttime = $Now - ((24*60*60)*$daysago);
			print "<h2>" . Ts('Updates in the last %s day'
						 . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
			# Note: must have two translations (for "day" and "days")
			# Following comment line is for translation helper script
			# Ts('Updates in the last %s days', '');
		}
	}
	if ($starttime == 0) {
		$starttime = $Now - ((24*60*60)*$RcDefault);
	 	print "<h2>" . Ts('Updates in the last %s day'
			. (($RcDefault != 1)?"s":""), $RcDefault) . "</h2>\n";
		# Translation of above line is identical to previous version
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
	if (@fullrc > 0) {  # Only false if no lines in file
		($lastTs) = split(/$FS3/, $fullrc[$#fullrc]);
	}
	$lastTs++  if (($Now - $lastTs) > 5);  # Skip last unless very recent

	$idOnly = &GetParam("rcidonly", "");
	if ($idOnly ne "") {
		print '<b>(' . Ts('for %s only', &ScriptLink($idOnly, $idOnly))
					. ')</b><br>';
	}
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

	if (&GetParam("username") eq "") {
		print "<br>" . &ScriptLink("action=rc&from=$lastTs",
			T('List new changes starting from'));
		print " " . &TimeToText($lastTs) . "<br>\n";
	} else {
		my $bookmark = &GetParam('bookmark',-1);
		print "<br>" . &ScriptLink("action=bookmark&time=$Now",
				T('Update my bookmark timestamp'));
		print " (". 
			Ts('currently set to %s', &TimeToText($bookmark)).
			")<br>\n";
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
	if ($i == @fullrc) {
		print '<br><strong>' . Ts('No updates since %s',
											&TimeToText($starttime)) . "</strong><br>\n";
	} else {
		splice(@fullrc, 0, $i);  # Remove items before index $i
		# Later consider an end-time limit (items older than X)
		print &GetRcHtml(@fullrc);
	}
	print '<p>' . Ts('Page generated %s', &TimeToText($Now)), "<br>\n";

}

sub GetRcHtml {
	my @outrc = @_;
	my ($rcline, $html, $date, $sum, $edit, $count, $newtop, $author);
	my ($showedit, $inlist, $link, $all, $idOnly);
	my ($ts, $oldts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);
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
### 최근변경내역에 북마크 기능 도입
	my $bookmark;
	my $bookmarkuser = &GetParam('username', "");
	my ($rcnew, $rcupdated, $rcdiff, $rcdeleted) = (
			"<img style='border:0' src='$IconDir/rc-new.gif'>",
			"<img style='border:0' src='$IconDir/rc-updated.gif'>",
			"<img style='border:0' src='$IconDir/rc-diff.gif'>",
			"<img style='border:0' src='$IconDir/rc-deleted.gif'>"
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

	# Later consider folding into loop above?
	# Later add lines to assoc. pagename array (for new RC display)
	foreach $rcline (@outrc) {
		($ts, $pagename) = split(/$FS3/, $rcline);
###############
### replaced by gypark
### 최근변경내역에 북마크 기능 도입
#		$pagecount{$pagename}++;
		$pagecount{$pagename}++ if ($ts > $bookmark);
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
#	$html = "";
	$html = "<TABLE class='rc'>";
###
###############
	$all = &GetParam("rcall", 0);
	$all = &GetParam("all", $all);
	$newtop = &GetParam("rcnewtop", $RecentTop);
	$newtop = &GetParam("newtop", $newtop);
	$idOnly = &GetParam("rcidonly", "");

	@outrc = reverse @outrc if ($newtop);
	($oldts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
		= split(/$FS3/, $outrc[0]);
	$oldts += 1;
	foreach $rcline (@outrc) {
		($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
			= split(/$FS3/, $rcline);
		# Later: need to change $all for new-RC?
		next  if ((!$all) && ($ts < $changetime{$pagename}));
		next  if (($idOnly ne "") && ($idOnly ne $pagename));
		next  if ($ts >= $oldts);
		$oldts = $ts;
		# print $ts . " " . $pagename . "<br>\n";
		%extra = split(/$FS2/, $extraTemp, -1);
		if ($date ne &CalcDay($ts)) {
			$date = &CalcDay($ts);
			if ($inlist) {
###############
### commented by gypark
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
#				$html .= "</UL>\n";
###
###############
				$inlist = 0;
			}
###############
### replaced by gypark
### 최근변경내역에 북마크 기능 도입
### 최근 변경 내역을 테이블로 출력 패치도 같이 적용
#			$html .= "<p><strong>" . $date . "</strong><p>\n";
			$html .= "<TR class='rc'><TD colspan='6' class='rcblank'>&nbsp;</TD></TR>".
				"<TR class='rc'>".
				"<TD colspan=6 class='rcdate'><b>" . $date . "</b>";
			if ($bookmarkuser eq "") {
				$html .= "<br>&nbsp;</TD></TR>\n";
			} else {
				$html .= "  [" .&ScriptLink("action=bookmark&time=$ts",T('set bookmark')) ."]"
					. "</TD></TR>\n";
			}
###
###############
		}
		if (!$inlist) {
###############
### commented by gypark
### 최근 변경 내역을 테이블로 출력
### from Jof4002's patch
#			$html .= "<UL>\n";
###
###############
			$inlist = 1;
		}
		$host = &QuoteHtml($host);
		if (defined($extra{'name'}) && defined($extra{'id'})) {
			$author = &GetAuthorLink($host, $extra{'name'}, $extra{'id'});
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
#		$link .= &GetPageLink($pagename);
#		$html .= "<li>$link ";
#		# Later do new-RC looping here.
#		$html .=  &CalcTime($ts) . " $count$edit" . " $sum";
#		$html .= ". . . . . $author\n";  # Make dots optional?
#	}
#	$html .= "</UL>\n" if ($inlist);
		$html .= "<TR class='rc'><TD class='rc'>&nbsp;&nbsp;&nbsp;</TD>"
			. "<TD class='rc'>$link </TD>"
			. "<TD class='rcpage'>" . &GetPageOrEditLink($pagename) . "</TD>"
			. "<TD class='rctime'>" . &CalcTime($ts) . "</TD>"
			. "<TD class='rccount'>$count$edit</TD>"
			. "<TD class='rcauthor'>$author</TD></TR>\n";
		if ($sum ne "") {
			$html .= "<TR class='rc'><TD colspan=2 class='rc'></TD>"
				. "<TD colspan=4 class='rcsummary'>&nbsp;&nbsp;$sum</TD></TR>\n";
		}
	}
	$html .= "</table>";

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

	print &GetHeader("",&QuoteHtml(Ts('History of %s', $id)), "") . "<br>";
	&OpenPage($id);
	&OpenDefaultText();
	$canEdit = &UserCanEdit($id);
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
sub ScriptLink {
	my ($action, $text) = @_;

	return "<A href=\"$ScriptName?$action\">$text</A>";
}

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
	return &ScriptLink($id, $name);
}

sub GetPageLinkText {
	my ($id, $name) = @_;

	$id =~ s|^/|$MainPage/|;
	if ($FreeLinks) {
		$id = &FreeToNormal($id);
		$name =~ s/_/ /g;
	}
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

sub GetOldPageLink {
	my ($kind, $id, $revision, $name) = @_;

	if ($FreeLinks) {
		$id = &FreeToNormal($id);
		$name =~ s/_/ /g;
	}
	return &ScriptLink("action=$kind&id=$id&revision=$revision", $name);
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
		$result .= "\n<div align=\"right\"><a accesskey=\"z\" name=\"#PAGE_TOP\" href=\"#PAGE_BOTTOM\">". T('Bottom') . "</a></div>\n";
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
			$bodyExtra .= qq(ondblclick="location.href='$ScriptName?action=edit&id=$id'") if (&UserCanEdit($id,0));
		}
	}

###
###############

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
		$result .= ' ' . &ScriptLinkDiff(4, $id, T('(diff)'), $rev);
	}

	$result .= '<br>';

	$result .= &GetHistoryLink($id, T('History'));
	if ($rev ne '') {
		$result .= ' | ';
		$result .= &GetPageLinkText($id, T('View current revision'));
	}

	$result .= ' | ';

	if (&UserCanEdit($id, 0)) {
		if ($rev ne '') {
			$result .= &GetOldPageLink('edit',   $id, $rev,
																 Ts('Edit revision %s of this page', $rev));
		} else {
			$result .= &GetEditLink($id, T('Edit text of this page'));
		}
	} else {
		$result .= T('This page is read-only');
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
	$result .= "<a accesskey=\"x\" name=\"#PAGE_BOTTOM\" href=\"#PAGE_TOP\">" . T('Top') . "</a></DIV>\n" . $q->end_html;
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
	$bartext .= &GetPageLink($HomePage);
	$bartext .= "</TD>\n<TD class='gotoindex'>" . &ScriptLink("action=index", T('Index'));
	$bartext .= " </TD>\n<TD class='gotorecentchanges'> " . &GetPageLink(T($RCName));
	if ($id =~ m|/|) {
		$main = $id;
		$main =~ s|/.*||;  # Only the main page name (remove subpage)
###############
### replaceed by gypark
### subpage 의 경우, 상위페이지 이름 앞에 아이콘 표시
#		$bartext .= " </td><td> " . &GetPageLink($main);
		$bartext .= " </TD>\n<TD class='gotoparentpage'> <img src=\"$IconDir/parentpage.gif\" border=\"0\" alt=\""
					. T('Main Page:') . " $main\" align=\"absmiddle\">" . &GetPageLink($main);
###
###############
	}
###############
### added by gypark
### 상단 메뉴 바에 사용자 정의 항목을 추가
### UserGotoBar2~4 라는 이름으로 지정해주면 된다
	if ($UserGotoBar2 ne '') {
		$bartext .= " </TD>\n<TD class='gotouser'> " . $UserGotoBar2;
	}
	if ($UserGotoBar3 ne '') {
		$bartext .= " </TD>\n<TD class='gotouser'> " . $UserGotoBar3;
	}
	if ($UserGotoBar4 ne '') {
		$bartext .= " </TD>\n<TD class='gotouser'> " . $UserGotoBar4;
	}
###
###############
	$bartext .= " </TD>\n<TD class='gotopref'> " . &GetPrefsLink();
	if (&GetParam("linkrandom", 0)) {
		$bartext .= " </TD>\n<TD class='gotorandom'> " . &GetRandomLink();
	}
	if (&UserIsAdmin()) {
		$bartext .= " </TD>\n<TD class='gotoadmin'> " . &ScriptLink("action=editlinks", T('Admin'));
	}
	$bartext .= " </TD>\n<TD class='gotolinks'> " . &ScriptLink("action=links", T('Links'));
	if (($UserID eq "113") || ($UserID eq "112")) {
		$bartext .= " </TD>\n<TD class='gotologin'> " . &ScriptLink("action=login", T('Login'));
	}
	else {
		$bartext .= " </TD>\n<TD class='gotologin'> " . &ScriptLink("action=logout", T('Logout'));
	}
	$bartext .= " </TD>\n<TD class='gotosearch'> " . &GetSearchForm();
	if ($UserGotoBar ne '') {
		$bartext .= " </TD>\n<TD class='gotouser'> " . $UserGotoBar;
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
	$pageText =~ s/&__LT__;toc&__GT__;/$TableOfContents/gi;

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

		s/\[\#(\w+)\]/&StoreHref(" name=\"$1\"")/ge if $NamedAnchors;
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

	$txt =~ s/\&__LT__;Date\&__GT__;/&MacroDate()/gei;
	$txt =~ s/\&__LT__;time\&__GT__;/&MacroTime()/gei;
	$txt =~ s/\&__LT__;DateTime\&__GT__;/&MacroDateTime()/gei;
	$txt =~ s/\&__LT__;PageCount\&__GT__;/&MacroPageCount()/gei;
	$txt =~ s/\&__LT__;Anchor\((.*)\)\&__GT__;/&MacroAnchor($1)/gei;
	$txt =~ s/\&__LT__;RandomPage\((.*)\)\&__GT__;/&MacroRandom($1)/gei;

###############
### commented by gypark
### include 매크로 안에서 위키태그를 작동하게 함
### http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
#	$txt =~ s/\&__LT__;Include\((.*)\)\&__GT__;/&MacroInclude($1)/gei;
###
###############
	$txt =~ s/\&__LT__;FullSearch\((.*)\)\&__GT__;/&MacroFullSearch($1)/gei;
	$txt =~ s/\&__LT__;titlesearch\((.*)\)\&__GT__;/&MacroTitleSearch($1)/gei;
	$txt =~ s/\&__LT__;goto\((.*)\)\&__GT__;/&MacroGoto($1)/gei;
	$txt =~ s/\&__LT__;history\((.*)\)\&__GT__;/&MacroHistory($1)/gei;
###############
### added by gypark
### 매크로 추가
### <mysign(name,time)>
	$txt =~ s/\&__LT__;mysign\(([^,]+),(\d+-\d+-\d+ \d+:\d+.*)\)\&__GT__;/&MacroMySign($1, $2)/gei;
### <calendar([page,] year, month)>
	$txt =~ s/\&__LT__;calendar\(([^,\n]+,)?([-+]?\d+),([-+]?\d+)\)\&__GT__;/&MacroCalendar($1, $2, $3)/gei;
### <wikiversion>
	$txt =~ s/\&__LT__;wikiversion&__GT__;/&MacroWikiVersion()/gei;
### <vote(count [,scale])>
	$txt =~ s/\&__LT__;vote\((\d+)(,(\d+))?\)&__GT__;/&MacroVote($1,$3)/gei;
### <AllPagesTo(page)>
	$txt =~ s/\&__LT__;allpagesto\(([^\n]+)\)\&__GT__;/&MacroAllPagesTo($1)/gei;
### <AllPagesFrom(page)>
	$txt =~ s/\&__LT__;allpagesfrom\(([^,\n]+)(,\d)?\)\&__GT__;/&MacroAllPagesFrom($1, $2)/gei;
### <OrphanedPages>
	$txt =~ s/\&__LT__;orphanedpages\(([-+])?(\d+)\)\&__GT__;/&MacroOrphanedPages($1, $2)/gei;
### <WatedPages>
	$txt =~ s/\&__LT__;wantedpages\&__GT__;/&MacroWantedPages()/gei;
### <userlist>
	$txt =~ s/\&__LT__;userlist\&__GT__;/&MacroUserList()/gei;
### 사전매크로
	$txt =~ s/\&__LT__;dic\(([^)]+)\)\&__GT__;/&MacroEDic($1)/gei;
	$txt =~ s/\&__LT__;kdic\(([^)]+)\)\&__GT__;/&MacroKDic($1)/gei;
	$txt =~ s/\&__LT__;jdic\(([^)]+)\)\&__GT__;/&MacroJDic($1)/gei;
###
###############
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

	$txt =~ s/<include\((.*)\)>/&MacroInclude($1)/gei;
### toc 를 포함하지 않는 includenotoc 매크로 추가
	$txt =~ s/<includenotoc\((.*)\)>/&MacroInclude($1, "notoc")/gei;
### includday 매크로
	$txt =~ s/<includeday\(([^,\n]+,)?([-+]?\d+)\)>/&MacroIncludeDay($1, $2)/gei;
	return $txt;
}
###
###############

###############
### added by gypark
### 추가한 매크로의 동작부

### 세 가지 사전 매크로
sub MacroEDic {
	return "<A class='dic' href='http://dic.naver.com/endic?query=@_' target='dictionary'>@_</A>";
}
sub MacroKDic {
	return "<A class='dic' href='http://krdic.naver.com/krdic?query=@_' target='dictionary'>@_</A>";
}
sub MacroJDic {
	return "<A class='dic' href='http://jpdic.naver.com/jpdic?query=@_' target='dictionary'>@_</A>";
}

### <IncludeDay>
sub MacroIncludeDay {
	my ($mainpage, $day_offset) = @_;
	my $page = "";
	my $temp;

	# main page 처리
	if ($mainpage ne "") {
		$temp = $mainpage;
		$temp =~ s/,$//;
		$temp = &RemoveLink($temp);
		$temp = &FreeToNormal($temp);
		if (&ValidId($temp) ne "") {
			return "&lt;includeday($mainpage$day_offset)&gt;";
		}
		$temp =~ s/\/.*$//;
		$page = "$temp/";
	}

	# 날짜의 변위 계산 
	$temp = $Now + ($day_offset * 86400);
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($temp+$TimeZoneOffset);

	$page .= ($year + 1900) . "-";

	if ($mon + 1 < 10) {
		$page .= "0";
	}
	$page .= ($mon + 1) . "-";

	if ($mday < 10) {
		$page .= "0";
	}
	$page .= "$mday";

	return &MacroInclude($page);
}

### <UserList>
sub MacroUserList {
	my (@userlist, $result);
	my $usernumber;
	opendir(USERLIST, $UserDir);
	@userlist = readdir(USERLIST);
	close(USERLIST);
	shift @userlist;
	shift @userlist;
	@userlist = sort @userlist;
	foreach $usernumber (0..(@userlist-1)) {
		@userlist[$usernumber] =~ s/(.*)\.db/($1)/gei;
		@userlist[$usernumber] = &StorePageOrEditLink("@userlist[$usernumber]", "@userlist[$usernumber]") . "<br>";
	}

	$result = "@userlist";
	
	return $result;
}

### <WantedPages>
sub MacroWantedPages {
	my ($pageline, @found, $page);
	my %numOfReverse;
	my $txt;

	foreach $pageline (&GetFullLinkList("exists=0&sort=0")) {
		my @links = split(' ', $pageline);
		my $id = shift(@links);
		foreach $page (@links) {
			$page = (split('/',$id))[0]."$page" if ($page =~ /^\//);
			push(@found, $page) if ($numOfReverse{$page} == 0);
			$numOfReverse{$page}++;
		}
	}
	@found = sort(@found);

	foreach $page (@found) {
		$txt .= ".... " if ($page =~ m|/|);
		$txt .= &GetPageOrEditLink($page, $page) . " ("
			. &ScriptLink("action=links&editlink=1&empty=0&reverse=$page", $numOfReverse{$page})
			. ")<br>";
	}

	return $txt;
}


### <OrphanedPages>
sub MacroOrphanedPages {
	my ($less_or_more, $criterion) = @_;
	my (@allPages, $page, $pageline);
	my %numOfReverse;
	my $txt;

	@allPages = &AllPagesList();

	foreach $page (@allPages) {
		$numOfReverse{$page} = 0;
	}

	foreach $pageline (&GetFullLinkList("exists=1&sort=0")) {
		my @links = split(' ', $pageline);
		my $id = shift(@links);
		my $link;
		foreach $link (@links) {
			$link = (split('/',$id))[0]."$link" if ($link =~ /^\//);
			next if ($id eq $link);
			$numOfReverse{$link}++;
		}
	}

	foreach $page (@allPages) {
		next if (($less_or_more eq "-") && ($numOfReverse{$page} > $criterion));
		next if (($less_or_more eq "+") && ($numOfReverse{$page} < $criterion));
		next if (($less_or_more eq "") && ($numOfReverse{$page} != $criterion));
		$txt .= ".... " if ($page =~ m|/|);
		$txt .= &GetPageLink($page) . "<br>";
	}

	return $txt;
}

### <AllPagesFrom(page)>
sub MacroAllPagesFrom {
	my ($string, $exists) = @_;
	my (@x, @links, $pagename, %seen, %pgExists);
	my $txt;
	
	$string = &RemoveLink($string);
	$string = &FreeToNormal($string);
	if (&ValidId($string) ne "") {
		return "&lt;allpagesfrom($string)&gt;";
	}

	if ($exists =~ /,(\d)/) {
		$exists = $1;
	} else {
		$exists = 2;
	}
	
	%pgExists = ();
	foreach $pagename (&AllPagesList()) {
		$pgExists{$pagename} = 1;
	}

###############
### replaced by gypark
### 링크 목록을 별도로 관리
#	@x = &GetPageLinks($string, 1, 0, 0);
	@x = &GetPageLinksFromFile($string, 1, 0, 0);
###
###############


	foreach $pagename (@x) {
		$pagename = (split('/',$string))[0]."$pagename" if ($pagename =~ /^\//);
		if ($seen{$pagename} != 0) {
			next;
		}
		if (($exists == 0) && ($pgExists{$pagename} == 1)) {
			next;
		}
		if (($exists == 1) && ($pgExists{$pagename} != 1)) {
			next;
		}
		$seen{$pagename}++;
		push (@links, $pagename);
	}
	@links = sort(@links);

	foreach $pagename (@links) {
		$txt .= ".... "  if ($pagename =~ m|/|);
		$txt .= &GetPageOrEditLink($pagename) . "<br>";
	}

	return $txt;
}

### <AllPagesTo(page)>
sub MacroAllPagesTo {
	my ($string) = @_;
	my @x = ();
	my ($pagelines, $pagename, $txt);
	my $pagename;
	
	$string = &RemoveLink($string);
	$string = &FreeToNormal($string);
	if (&ValidId($string) ne "") {
		return "&lt;allpagesto($string)&gt;";
	}

	foreach $pagelines (&GetFullLinkList("empty=0&sort=1&reverse=$string")) {
		my @pages = split(' ', $pagelines);
		@x = (@x, shift(@pages));
	}

	foreach $pagename (@x) {
		$txt .= ".... "  if ($pagename =~ m|/|);
		$txt .= &GetPageLink($pagename) . "<br>";
	}

	return $txt;
}

### <vote(count [,scale])>
sub MacroVote {
	my ($count, $scale) = @_;
	my $maximum = 1000;
	$scale = 10 if ($scale eq '');
	my $width = $count * $scale;
	$width = $maximum if ($width > $maximum);

	return "<table ".(($width)?"bgcolor=\"lightgrey\" ":"")
		."width=\"$width\" style=\"border:1 solid gray;\">"
		."<tr><td style=\"padding:0; border:none; font-size:8pt;\">$count"
		."</td></tr></table>";
}

### <mysign(name,time)> 매크로 추가
sub MacroMySign {
	my ($author, $timestamp) = @_;
	return "<div align=\"right\">-- $author <small>$timestamp</small></div>";
}

### <calendar([page,] year, month)> 매크로 추가
sub MacroCalendar {
	use Time::Local;
	my ($cal_mainpage, $cal_year, $cal_month) = @_;

	my $result='';
	my $cal_result='';
	my $cal_page;
	my @cal_color = ("red", "black", "black", "black", "black", "black", "blue", "green");
	my @cal_dow = (T('Su'), T('Mo'), T('Tu'), T('We'), T('Th'), T('Fr'), T('Sa'));
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($Now+$TimeZoneOffset);
	my ($this_year, $this_month, $this_day) = ($year, $mon, $mday);
	my $cal_time;
	my ($td_class, $span_style);
	my $temp;

	# 달의 값이 13 이상이면 무효
	if (!($cal_month =~ /[-+]/) && ($cal_month > 12)) {
		return "&lt;calendar($cal_mainpage$cal_year,$cal_month)&gt;";
	}

	# prefix 처리
	if (length($cal_mainpage) != 0) {
		$temp = $cal_mainpage;
		$temp =~ s/,$//;
		$temp = &RemoveLink($temp);
		$temp = &FreeToNormal($temp);
		if (&ValidId($temp) ne "") {
			return "&lt;calendar($cal_mainpage$cal_year,$cal_month)&gt;";
		}
		$temp =~ s/\/.*$//;
		$cal_mainpage = "$temp/";
	}

	# 년도나 달에 0 을 인자로 받으면 올해 또는 이번 달
	$cal_year = $this_year+1900 if ($cal_year == 0); 
	$cal_month = $this_month+1 if ($cal_month == 0);

	# 년도에 + 또는 - 가 있으면 올해로부터 변위 계산
	if ($cal_year =~ /\+(\d+)/ ) {
		$cal_year = $this_year+1900 + $1;
	} elsif ($cal_year =~ /-(\d+)/ ) {
		$cal_year = $this_year+1900 - $1;
	}

	# 달에 + 또는 - 가 있으면 이번 달로부터 변위 계산
	if ($cal_month =~ /\+(\d+)/ ) {
		$cal_month = $this_month+1 + $1;
		while ($cal_month > 12)  {
			$cal_month -= 12;
			$cal_year++;
		}
	} elsif ($cal_month =~ /-(\d+)/ ) {
		$cal_month = $this_month+1 - $1;
		while ($cal_month < 1) {
			$cal_month += 12;
			$cal_year--;
		}
	}
	
	# 1902년부터 2037년 사이만 지원함. 그 범위를 벗어나면 1902년과 2037년으로 계산
	$cal_year = 2037 if ($cal_year > 2037);
	$cal_year = 1902 if ($cal_year < 1902);

	# 1월~9월은 01~09로 만듦
	if ($cal_month < 10) {
		$cal_month = "0" . $cal_month;
	}

	# 달력 제목 출력
	$result .= "<TABLE class='calendar'>";
	$result .= "<CAPTION class='calendar'>" 
		."<a href=\"$ScriptName?$cal_mainpage$cal_year-$cal_month\">"
		.(length($cal_mainpage)?"$cal_mainpage<br>":"")
		."$cal_year-$cal_month"
		."</a>"
		."</CAPTION>";

	# 상단의 요일 출력 
	$result .= "<TR class='calendar'>";
	for (0..6) {
		$result .= "<TH class='calendar'>"
			. "<span style='color:$cal_color[$_]'>$cal_dow[$_]</span></TH>";
	}
	$result .= "</TR>";

	# 인자로 주어진 달의 1일날을 찾음
	$cal_time = timelocal(0,0,0,1,$cal_month-1,$cal_year);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($cal_time);
	# 달력의 첫번째 날 찾음
	$cal_time -= $wday * (60 * 60 * 24);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($cal_time);

	# 달력 그림
	my ($temp_month, $temp_day);
		
	for (1..6) {
		$result .= "<TR class='calendar'>";
		for (0..6) {

			# 1~9는 01~09로 만듦
			($temp_month, $temp_day) = ($mon + 1, $mday);
			$temp_month = "0".$temp_month if ($temp_month < 10);
			$temp_day = "0".$temp_day if ($temp_day < 10);
			$cal_page = ($year + 1900)."-".($temp_month)."-".($temp_day);

			$cal_result = $mday;
			$span_style = "";
			if (($year == $this_year) && ($mon == $this_month) && ($mday == $this_day)) {
				$td_class = "calendartoday";
				$span_style = "text-decoration: underline; ";
			} else {
				$td_class = "calendar";
			}

			if (-f &GetPageFile($cal_mainpage . $cal_page)) {
				$span_style .= "font-weight: bold; text-decoration: underline; ";
				$wday = 7;
			}
			if ($cal_month != ($mon+1)) {
				$span_style .= "font-size: 0.9em; ";
			}

			$result .= "<td class='$td_class'>"
				."<a href=\"$ScriptName?$cal_mainpage$cal_page\">"
				."<span style='color:$cal_color[$wday]; $span_style'>"
				.$cal_result
				."</span></a></td>";
			$cal_time += (60 * 60 * 24);
			($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($cal_time);
		}
		$result .= "</TR>";
		# 4 또는 5 줄로 끝낼 수 있으면 끝냄
		last if (($mon+1 > $cal_month) || ($year+1900 > $cal_year));
	}

	$result .= "</table>";
	return $result;
}


### <showversion> 매크로 추가
sub MacroWikiVersion {
	return &ScriptLink("action=version", $WikiVersion);
}
###
###############

sub MacroHistory {
	my ($n) = @_;
	my ($html, $i);

	&OpenPage($DocID);
	&OpenDefaultText();

	$html = "<form action='$ScriptName' METHOD='GET'>";
	$html .= "<input type='hidden' name='action' value='browse'/>";
	$html .= "<input type='hidden' name='diff' value='1'/>";
	$html .= "<input type='hidden' name='id' value='$DocID'/>";
	$html .= "<table border='0' cellpadding=0 cellspacing=0 width='90%'><tr>";
###############
### replaced by gypark
### History 매크로 버그 수정 
#	$html .= &GetHistoryLine($DocID, $Page{'text_default'}, 0, 1);
	$html .= &GetHistoryLine($DocID, $Page{'text_default'}, 0, 0);
###
###############
	&OpenKeptRevisions('text_default');
	$i = 0;
	foreach (reverse sort {$a <=> $b} keys %KeptRevisions) {
		if (++$i > $n) {
			$html .= "<tr><td align='center'><input type='submit' value='" 
					. T('Compare') . "'/>  </td><td>&nbsp;</td></table></form>\n";
			return $html;
		}
		next  if ($_ eq "");  # (needed?)
###############
### replaced by gypark
### History 매크로 버그 수정 
#		$html .= &GetHistoryLine($DocID, $KeptRevisions{$_}, 0, 0);
		$html .= &GetHistoryLine($DocID, $KeptRevisions{$_}, 0, $i);
###
###############
	}
	$html .= "<tr><td align='center'><input type='submit' value='"
				. T('Compare') . "'/>  </td><td>&nbsp;</td></table></form>\n";
	return $html;
}

sub MacroGoto {
	my ($string) = @_;

###############
### added by gypark
### goto 매크로 개선
	$string = &RemoveLink($string);
###
###############

	return
###############
### replaced by gypark
### goto 매크로 개선
### from Bab2's patch
# 		"<form name=goto><input name=wkl type=text size=10 value=$string>" .
# 		"<input type=button value=\"" . T('Go') . "\" onclick='javascript:document.location.href=\"$ScriptName?\"+document.goto.wkl.value'>" .
# 		"</form>";
		"<form name=goto><input type=\"hidden\" name=\"action\" value=\"browse\" id=\"hidden-box\">".
		"<input name='id' type\text size=10 value=$string>" . "&nbsp;" .
		"<input type=submit value=\"". T('Go') . "\">".
		"</form>";
###
###############
}

sub MacroTitleSearch {
	my ($string) = @_;
	my ($name, $freeName, $txt);

	foreach $name (&AllPagesList()) {
		if ($name =~ /$string/i) {
###############
### replace by gypark
### 검색 결과를 세로로 보이도록 수정
#			$txt .= &GetPageLink($name) . " ";
			$txt .= &GetPageLink($name) . "<br>";
###
###############
		} elsif ($FreeLinks && ($name =~ m/_/)) {
			$freeName = $name;
			$freeName =~ s/_/ /g;
			if ($freeName =~ /$string/i) {
###############
### replace by gypark
### 검색 결과를 세로로 보이도록 수정
#				$txt .= &GetPageLink($name) . " ";
				$txt .= &GetPageLink($name) . "<br>";
###
###############
			}
		}
	}
	return $txt;
}

sub MacroFullSearch()
{
	my $pagename;
	my ($string) = @_;
	my @x = &SearchTitleAndBody($string);
	my $txt;

	foreach $pagename (@x) {
		$txt .= ".... "  if ($pagename =~ m|/|);
###############
### replace by gypark
### 검색 결과를 세로로 보이도록 수정
#		$txt .= &GetPageLink($pagename) . " ";
		$txt .= &GetPageLink($pagename) . "<br>";
###
###############

	}
	return $txt;
}

sub MacroDate() { return &CalcDay(time); }
sub MacroTime() { return &CalcTime(time); }
sub MacroDateTime() { return &CalcDay(time) . " " . &CalcTime(time); }
sub MacroAnchor() {	return "<a name=\"\#@_\">"; }

sub MacroPageCount() {
	my @pageList = &AllPagesList();
	return $#pageList + 1;
}

sub MacroRandom() {
	my ($count) = @_;
	my @pageList = &AllPagesList();
	my ($txt);

	srand($Now);
	while ($count-- > 0) {
		$txt .= &GetPageLink($pageList[int(rand($#pageList + 1))]) . " ";
	}
	return $txt;
}

sub MacroInclude {
	my ($name, $opt) = @_;

	if ($OpenPageName eq $name) { # Recursive Include 방지
		return "";
	}
	
	my $fname = &GetPageFile($name);	# 존재하지 않는 파일이면 그냥 리턴
	if (!(-f $fname)) {
		return "";
	}
		
	my $data = &ReadFileOrDie($fname);
	my %SubPage = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields

	if (!defined($SubPage{"text_default"})) {
		return "";
	}

	my %SubSection = split(/$FS2/, $SubPage{"text_default"}, -1);
	my %TextInclude = split(/$FS3/, $SubSection{'data'}, -1);
	
	# includenotoc 의 경우
 	$TextInclude{'text'} =~ s/<toc>/$FS_lt."toc".$FS_gt/gei if ($opt eq "notoc");
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
### 외부 URL 을 새창으로 띄울 수 있는 링크를 붙임
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
#	return ("<a href=\"$url\">$name</a>", $punct);
	return ("<A class='inter' href=\"$url\">$name</A><a href=\"$url\" target=\"_blank\"><img src=\"$IconDir/newwindow.gif\" border=\"0\" alt=\"" . T('Open in a New Window') . "\" align=\"absbottom\"></a>", $punct);
###
###############


}

sub StoreBracketInterPage {
	my ($id, $text) = @_;
	my ($site, $remotePage, $url, $index);

	($site, $remotePage) = split(/:/, $id, 2);
	$remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML
	$url = &GetSiteUrl($site);
	if ($text ne "") {
		return "[$id $text]"  if ($url eq "");
	} else {
		return "[$id]"  if ($url eq "");
		$text = &GetBracketUrlIndex($id);
	}
	$url .= $remotePage;
###############
### replaced by gypark
### 외부 URL 을 새창으로 띄울 수 있는 링크를 붙임
### from http://whitejames.x-y.net/cgi-bin/jofcgi/wiki/wiki.pl?프로그래밍팁/Wiki
#	return &StoreRaw("<a href=\"$url\">[$text]</a>");
	return &StoreRaw("<A class='inter' href=\"$url\">[$text]</A><a href=\"$url\" target=\"_blank\"><img src=\"$IconDir/newwindow.gif\" border=\"0\" alt=\"" . T('Open in a New Window') . "\" align=\"absbottom\"></a>");
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
		($status, $data) = &ReadFile($InterFile);
		return ""  if (!$status);
		%InterSite = split(/\s+/, $data);  # Later consider defensive code

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

	if (!((-x "$SOURCEHIGHLIGHT") && defined($SRCHIGHLANG{$lang}))) {
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

### 글을 작성한 직후에 수행되는 매크로들
sub ProcessPostMacro {
	my ($string) = @_;

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
	$string =~ s/<mysign>/<mysign($author,$timestamp)>/g; 

	return $string;
}

###
###############


sub StorePre {
	my ($html, $tag) = @_;

	return &StoreRaw("<$tag>" . $html . "</$tag>");
}

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
	"<img src=\"http://210.123.8.23/hottracks/cdimg/$id.jpg\"></a>";
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

	if ($num =~ /^89/) {
		return "<a href=\"http://www.aladdin.co.kr/catalog/book.asp?ISBN=$num\"><img $ImageTag src=\"http://www.aladdin.co.kr/Cover/$num\_1.gif\" border=1></a>";
	#	return "<a href=\"http://www.wowbook.com/generic/book/info/book_detail.asp?isbn=ISBN$hyphened\"><img $ImageTag src=\"http://image.wowbook.com/book/large_image/$hyphened.gif\" border=1></a>";
	}

	$first  = "<a href=\"http://shop.barnesandnoble.com/bookSearch/"
						. "isbnInquiry.asp?isbn=$num\">";
	$second = "<a href=\"http://www.amazon.com/exec/obidos/"
						. "ISBN=$num\">" . T('alternate') . "</a>";
	$third  = "<a href=\"http://www.pricescan.com/books/"
						. "BookDetail.asp?isbn=$num\">" . T('search') . "</a>";
	$html  = $first . "ISBN " . $rawprint . "</a> ";
	$html .= "($second, $third)";
	$html .= " "  if ($rawnum =~ / $/);  # Add space if old ISBN had space.
	return $html;
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

	return &StoreHref(" name=\"$anchor\"") . $number;
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

	@lines = split("\n", $html, -1);
	shift(@lines);
	shift(@lines);

	$output_exist = 0;
	$in_table = 0;
	foreach $line (@lines) {
		$row = "";

		$line = &QuoteHtml($line);
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
			$row = "= ".$row;
			$td_class = "diff";
		} elsif ($line =~ /^-(.*)$/) {
			$row = $1;
			$row =~ s/ /&nbsp;/g;
			$row = "- ".$row;
			$td_class = "diffremove";
		} elsif ($line =~ /^\+(.*)$/) {
			$row = $1;
			$row =~ s/ /&nbsp;/g;
			$row = "+ ".$row;
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
}

sub UserDataFilename {
	my ($id) = @_;

	return $UserDir . "/" . "$id.db";
}
	
# ==== Misc. functions ====
sub ReportError {
	my ($errmsg) = @_;

	print $q->header, "<H2>", $errmsg, "</H2>", $q->end_html;
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
		return 1  if (&UserIsEditor());
		return 0  if (&UserIsBanned());
	}
	return 1;
}

sub UserIsBanned {
	my ($host, $ip, $data, $status);

	($status, $data) = &ReadFile("$DataDir/banlist");
	return 0  if (!$status);  # No file exists, so no ban
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
		return &GenerateAllPagesList();
	}
	$refresh = &GetParam("refresh", 0);
	if ($IndexInit && !$refresh) {
		# Note for mod_perl: $IndexInit is reset for each query
		# Eventually consider some timestamp-solution to keep cache?
		return @IndexList;
	}
	if ((!$refresh) && (-f $IndexFile)) {
		($status, $rawIndex) = &ReadFile($IndexFile);
		if ($status) {
			%IndexHash = split(/\s+/, $rawIndex);
			@IndexList = sort(keys %IndexHash);
			$IndexInit = 1;
			return @IndexList;
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
	return @IndexList;
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
	print &WikiToHTML(&ProcessPostMacro($textPreview));
###
###############
}

sub DoHelp {
	my $idx = &GetParam("index", "");
	my $text;

	if ($idx eq 1) {
		$text = qq(
= 페이지 만들기 =

=== 한글이름페이지 ===

한글페이지이름 만드는 법입니다.

이렇게 편집 창에 입력하면... <nowiki>[[새한글이름]] [[한글이름페이지]]</nowiki>

*[[새한글이름]] <- 기존 페이지가 없는 경우 물음표가 생깁니다. 물음표를 클릭하면 새페이지 창이 열립니다.
*[[한글이름페이지]] <- 이미 페이지가 있으면 자동링크가 생깁니다.

=== 영어이름페이지 ===

1. 페이지이름으로 쓰고자 하는 영어를 공백없이 씁니다. 이때 대소문자를 섞어서 쓰면 자동으로 물음표가 생깁니다. 이 페이지 이름이 이미 있다면 물음표는 생기지 않습니다.

편집창에 <nowiki>NewPage WikiSandBox</nowiki>라고 입력하면 다음과 같이 표시됩니다.

*NewPage <- 물음표가 있으면 아직 없는 페이지
*WikiSandBox <- 이미 있는 페이지

이때 물음표를 클릭하면 새페이지 편집창이 생깁니다. 이 페이지이름은 'a href=' 이런표시 없이 그냥 쓰기만 해도 어디서나 자동으로 링크가 되어 바로 이동할 수 있습니다. 이것이 위키의 큰 장점입니다.

2. 대소문자를 섞어쓰지 않는 경우, 즉 모두 소문자거나 모두 대문자인 경우는 자동으로 물음표가 생기지 않습니다. 이런 경우는 두개의 꺽쇠"[[", "]]"로 묶어줍니다. 또한 이미 페이지가 있다고 해도 자동링크가 되지 않으니 링크를 하고 싶으면 역시 이중 꺽쇠로 둘러쌓아야 합니다. 보통 로그인시 아이디는 링크하기 편하라고 소문자로만 써주고, 다른 페이지 이름들은 대소문자 섞어 쓰는 것이 자동링크 만들기가 좋습니다.

편집할 때 <nowiki>[[ika]] [[tommy]]</nowiki> 식으로 입력하면 다음과 같은 형태로 보입니다. [[ika]] [[tommy]]

*ika <- 대소문자 섞어쓰지 않았기 때문에 꺽쇠없이는 이미 페이지가 있어도 자동링크가 되지 않습니다.
*tommy <- 대소문자 섞어쓰지 않았기 때문에 꺽쇠없이는 새페이지가 만들어지지 않습니다.
*[[ika]] <- 기존페이지가 이미 있기 때문에 자동링크가 생깁니다.
*[[tommy]] <- 기존페이지가 없기 때문에 물음표가 있습니다. 물음표를 누르면 새페이지가 생깁니다.

=== 하위페이지 만들기 ===

"/"를 하고 페이지 이름을 만들면 현재 편집하고 있는 문서 밑으로 페이지가 만들어집니다. 이 것을 확인하려면 위의 메뉴바에 있는 Index를 눌러보시면 됩니다. 또한 하위페이지로 들어가면 메뉴바에 상위페이지이름이 보인답니다. 지금 위, 아래 메뉴바에 '문서작성법연습'이라고 보이지요?
 [[/연습페이지]]
라고 입력하면 [[/연습페이지]]라고 보입니다. 그러면 이 페이지의 주소는 문서작성법연습/새페이지만들기연습/연습페이지 라는 이름을 갖게 됩니다. 이름이 너무 길면 딴 곳에서 링크를 걸 때 힘들어지므로 하위페이지는 꼭 필요할 때만 만드세요.
		);
	} elsif ($idx eq 2) {
		$text = qq|
= 문장 구성 =

=== 글자 장식 ===

UseModWiki는 "따옴표(')"를 사용합니다. (html도 사용할 수 있지만, 다른 위키에서도 쓰이는 방법이니 될 수 있으면 이 방법을 익히세요.)

이렇게 입력하면

 *&#39;&#39;한개 따옴표(') 두개로 이탤릭체 만들기&#39;&#39;
 *&#39;&#39;&#39;한개 따옴표(') 세개로 굵게 만들기&#39;&#39;&#39;
 *&#39;&#39;&#39;&#39;&#39;한개 따옴표(') 다섯개로 굵은 이탤릭체 만들기&#39;&#39;&#39;&#39;&#39;

Preview나 저장시 이렇게 보입니다.

*''한개 따옴표(') 두개로 이탤릭체 만들기''
*'''한개 따옴표(') 세개로 굵게 만들기'''
*'''''한개 따옴표(') 다섯개로 굵은 이탤릭체 만들기'''''

=== 제목줄 쓰기 ===

제목(Heading)은 1~6개의 이퀄표시(=)로 이루어집니다. 이것은 HTML &lt;h1&gt; - &lt;h6&gt; 태그에 상응합니다. 이퀄표시를 시작할 때는 왼쪽부터 빈칸없이 딱 붙여서 시작하시고 이퀄표시와 제목글과는 빈칸을 한칸씩 두어야 합니다. 아래 예제를 잘 보세요.

= = Headline size 1 = =
== == Headline size 2 == ==
=== === Headline size 3 === ===

'''제목이 나타나지 않는 경우 다음을 살펴보세요.'''
*좌우 이퀄표시 개수가 똑같아야합니다.
*왼쪽에 빈칸없이 이퀄표시가 시작되어야 합니다.
*이퀄과 안쪽 제목글과는 빈칸을 한칸씩 두어야 합니다.
----
수평선을 긋고 싶으면 '-'(빼기, 하이픈, 대시)를 왼쪽으로부터 딱 붙여서 4개 써주면 됩니다.

<nowiki>----</nowiki><br>
 ↑ 이렇게 쓰면

----
 ↑ 이렇게 보입니다.

=== 들여쓰기 ===

다른 위키(예를 들면 모인모인)에서는 스페이스 공백으로 들여쓰기를 하기도 하지만 UseModWiki에서는 그렇지 않습니다. 왼쪽에서 스페이스 한칸을 띄우면 pre 태그 안에 넣은 것과 같은 효과를 냅니다.

'''기본 들여쓰기 방법'''

이렇게 편집창에 쓰면

 : 한칸 들여 넣고 싶을 때
 :: 두칸 들여 넣고 싶을 때
 ::: 세칸 들여 넣고 싶을 때

Preview나 Save 했을 때 이렇게 보입니다:

: 한칸 들여 넣고 싶을 때
:: 두칸 들여 넣고 싶을 때
::: 세칸 들여 넣고 싶을 때

=== Bullet 넣기 ===

이렇게 편집창에 쓰면

 * 한칸 들여쓰기
 ** 두칸 들여쓰기
 *** 세칸 들여쓰기

Preview나 Save 했을 때 이렇게 보입니다:

* 한칸 들여쓰기
** 두칸 들여쓰기
*** 세칸 들여쓰기

=== 숫자 리스트 ===

이렇게 편집창에 쓰면

 # 숫자리스트 한개 넣었을 때
 ## 숫자리스트를 두개 넣었을 때
 ### 숫자 리스트를 세개 넣었을 때
 ## 숫자리스트를 두개 넣었을 때

Preview나 Save 했을 때 이렇게 보입니다:

# 숫자리스트 한개 넣었을 때
## 숫자리스트를 두개 넣었을 때
### 숫자 리스트를 세개 넣었을 때
## 숫자리스트를 두개 넣었을 때

		|;
	} elsif ($idx eq 3) {
		$text = qq(
= 링크와 이미지 =

=== 이미지 넣기 ===

이미지는 그냥 주소만 쓰면 됩니다.

이렇게 쓰면 <nowiki>http://www.usemod.com/wiki.gif</nowiki>

http://www.usemod.com/wiki.gif 그림이 나옵니다.

=== 링크 넣기 ===

'''위키링크'''

*대소문자 섞어 있는 이름은 페이지 이름만 써주면 됩니다. 예: WikiSandBox
*대문자만, 혹은 소문자만 있는 이름과 한글이름페이지는 이중 꺽쇠를 둘러주세요. 예: <nowiki>[[ika]]</nowiki> -> [[ika]], <nowiki>[[방명록]]</nowiki> -> [[방명록]]
*문서내의 특정 위치에 가기 위해서는 '#'을 사용합니다. 예: <nowiki>SandBox#test</nowiki>. 그리고 <nowiki>SandBox</nowiki>에서 위치 지정은 <nowiki>[#test]</nowiki> 으로 해 줍니다.

'''인터넷링크'''

*주소 그냥 쓰기
**<nowiki>http://www.yahoo.com</nowiki> -> http://www.yahoo.com

*주소에 라벨 붙이기 : Url과 라벨사이에 공백을 하나 두고 꺽쇠"[", "]"로 둘러 쌉니다.
**<nowiki>[http://www.yahoo.com Yahoo페이지로 이동]</nowiki> -> [http://www.yahoo.com Yahoo페이지로 이동]

'''메일주소넣기'''

메일주소를 자동링크시키려면 메일 앞에 <nowiki>mailto:</nowiki>를 넣어주세요.
 mailto:honggildong\@mail.net
이라고 쓰면  mailto:honggildong\@mail.net 라고 자동링크되어 클릭만 하면 메일창이 뜹니다.

'''인터위키 링크'''

<nowiki>NoSmok:TextFormatting</nowiki> NoSmok:TextFormatting

=== 책소개 넣기 ===

좋아하는 책이나, 참고할 책에 대해 즐겨찾기를 하고 싶으면 이 방법을 이용하세요.  책마다 고유의 ISBN(International Standard Book Number)가 있습니다. 이 것을 인터넷 서점 등에서 알아내어 대문자로 ISBN을 쓴 다음 콜론(: )하고 번호를 같이 써주세요.

즉, 편집창에 이렇게 입력하면

<nowiki>ISBN:8930705987</nowiki>

ISBN:8930705987 <- 이렇게 나타나고 이미지를 클릭하시면 [http://www.aladin.co.kr 알라딘]으로 이동합니다. 책링크한 후에 소개를 따로 하셔도 좋겠지요.

=== 음반 소개 넣기 ===

<nowiki>CD:2231815</nowiki>

CD:2231815 <-- 이렇게 나타나고 이미지를 클릭하면 [http://www.hottracks.co.kr 핫트랙]으로 이동합니다.

=== 테이블 그리기 ===

테이블은 행의 첫 연달은 두 글자가 <nowiki>ll(vertical bar, 영문 L 소문자나 숫자 1이 아니라 화폐단위 원 마크를 시프트 누른 상태에서 타이핑 한 것)</nowiki> 로 시작하면 인식됩니다. 행을 합칠 때는 <nowki>ll</nowiki> 문자를 여러번 반복하여 적어줍니다.
예를 들어 3개의 행을 합칠 때는 <nowiki>llllll</nowiki>가 됩니다. 

예:
<pre>
 ll first ll second ll third ll
 llll span four ll five ll
</pre>
|| first || second || third ||
|||| span four || five ||

<b>테이블 꾸미기</b>

 TABLE: <table tag>

 TABLE:으로 줄이 시작하면 그 행 전체는 table tag가 됩니다.

* table tag =
** width=<number percent>
** align=<center left right>
** cellpadding=<number>
** cellspacing=<number>
** border=<number>
** bgcolor=<html color value>

예:
<pre>
 TABLE: bgcolor=yellow cellspacing=5 border=1 width=90% align=center
 ll first ll second ll third ll
 llll span four ll five ll
</pre>
TABLE: bgcolor=yellow cellpadding=2 cellspacing=5 border=1 width=90% align=center

|| first || second || third ||
|||| span four || five ||

		);
	} elsif ($idx eq 4) {
		$text = q|
== 매크로 ==
매크로는 꺽쇠로 둘러싸인 이런 저런 목적의 키워드입니다. * 위키 링크와 헷갈리므로 대소문자를 섞어 쓰지 않도록 하셔야 합니다.

=== <nowiki><date>, <time>, <datetime></nowiki> ===

지금은 <datetime>, 오늘은 <date>, 지금 시각은 <time>

=== <nowiki><pagecount></nowiki> ===

이 위키에는 총 <pagecount>개의 문서가 있습니다.

=== <nowiki><include(문서명)</nowiki> ===

위키 내의 특정 문서를 현재 문서에 포함. < include(밥) > 하면 아래처럼 나온다. [[밥]] 참고.

<include(밥)>

=== <nowiki><history(숫자)></nowiki> ===

현 문서의 수정 내역(변경 히스토리)를 출력. 이때 괄호안의 숫자는 출력할 가장 최근의 변경 내역의 갯수.

<history(5)>

=== <nowiki><titlesearch(문자열)></nowiki> ===

위키 내의 문서제목중에서 문자열을 검색하여 링크 패턴을 출력. 정규식을 사용한다. 예를 들어 위키내에 SF-사변소설, SF-사이버펑크, 스팀펑크 라는 문서가 있을 때,

* titlesearch(^SF)라고 하면 SF-사변소설, SF-사이버펑크를 출력. ^ 는 첫 글자부터 일치
* titlesearch(펑크$)라고 하면 SF-사이버펑크와 스팀펑크를 출력. $ 는 마지막부터 일치
* titlesearch(사변) 이라고 하면 SF-사변소설 출력. 제목중에 '사변'과 일치하는 모든 항목
* titlesearch(.*) 이라고 하면 모든 문서 출력. .*는 모든 문자와 일치.

See Also: <TitleSearch(망년)>

=== <nowiki><fullsearch(문자열)></nowiki> ===

타이틀서치와 마찬가지인데, 문서 제목 뿐만 아니라 문서 내용도 같이 검색. 페이지가 늘어나면 속도가 느려짐.

=== <nowiki><randompage(숫자)></nowiki> ===

위키 내의 문서중에서 '숫자'로 지정한 수 만큼 무작위로 출력

오늘의 페이지: <randompage(2)>

=== <nowiki><goto(문자열)></nowiki> ===

페이지를 찾아가는 폼을 출력. 문자열은 디폴트...

<goto(바보)>
	|;
	}

###############
### added by gypark
### 이모티콘 관련 도움말 추가
### UseEmoticon 값이 1일 때만 출력됨
### from danny's patch
	elsif ($idx eq 5) {
		if ($UseEmoticon eq 0) {
			$text = q|
'''현재 이 홈페이지에서는 이모티콘을 사용하지 않도록 설정되어 있습니다.'''
'''따라서 아래의 도움말은 적용되지 않습니다.'''
			|;
		}
		$text .= q|
== 이모티콘 ==
이모티콘은 감정표현에 사용되는 작은 그림입니다. <br>
다음과 같은 문자열 중 하나를 입력하시면 왼쪽의 그림이 자동으로 삽입됩니다.

* ^^  <nowiki>^^ ^-^ ^_^ ^o^ ^O^ ^^; ^-^; ^_^; ^o^ ^O^ :-D :D</nowiki>
* :-) <nowiki>:-)</nowiki>
* -_- <nowiki>-_- -_-; =.= =.=; :-s :-S</nowiki>
* o.O <nowiki>o.O *.* :-o :-O :o :O</nowiki>
* :-( <nowiki>:-( :(</nowiki>
* :-p <nowiki>:-p :-P :p :P</nowiki>
* ;-) <nowiki>;-) ;)</nowiki>
	|;
	}
###
###############

	$ClickEdit = 0;
	print &GetHttpHeader();
	print &GetHtmlHeader("$SiteName: Preview", "Preview");
	print &WikiToHTML($text);
}

# end

sub DoOtherRequest {
	my ($id, $action, $text, $search);

	$ClickEdit = 0;									# luke added
	$action = &GetParam("action", "");
	$id = &GetParam("id", "");
	if ($action ne "") {
		$action = lc($action);
		if ($action eq "edit") {
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
			&DoTitleIndex();
###
###############
		} elsif ($action eq "help") {				# luke added
			&DoHelp();								# luke added
		} elsif ($action eq "preview") {			# luke added
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
###
###############
		} else {
			# Later improve error reporting
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

	if (!&UserCanEdit($id, 1)) {
		print &GetHeader("", T('Editing Denied'), "");
		if (&UserIsBanned()) {
			print T('Editing not allowed: user, ip, or network is blocked.');
			print "<p>";
			print T('Contact the wiki administrator for more information.');
		} else {
###############
### replaced by gypark
### 수정 불가를 알리는 메세지에, 사이트 제목이 아니라 
### 해당 페이지명이 나오도록 수정
#			print Ts('Editing not allowed: %s is read-only.', $SiteName);
			print Ts('Editing not allowed: %s is read-only.', $id);
###
###############
		}
		print &GetCommonFooter();
		return;
	}
	# Consider sending a new user-ID cookie if user does not have one
	&OpenPage($id);
	&OpenDefaultText();
	$pageTime = $Section{'ts'};
	$header = Ts('Editing %s', $id);
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
		}
	}
	$oldText = $Text{'text'};
	if ($preview && !$isConflict) {
		$oldText = $newText;
	}
	$editRows = &GetParam("editrows", 20);
	$editCols = &GetParam("editcols", 65);
	print &GetHeader('', &QuoteHtml($header), '');
	if ($revision ne '') {
		print "\n<b>"
					. Ts('Editing old revision %s.', $revision) . "  "
		. T('Saving this page will replace the latest revision with this text.')
					. '</b><br>'
	}
	if ($isConflict) {
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

	print T('Editing Help :') . "&nbsp;";
	print &HelpLink(1, T('Make Page')) . " | ";
	print &HelpLink(2, T('Text Formatting')) . " | ";
	print &HelpLink(3, T('Link and Image')) . " | ";
###############
### replaceed by gypark
### 이모티콘 관련 도움말 출력
### from danny's patch

#	print &HelpLink(4, "매크로") . "<br>";

	print &HelpLink(4, T('Macro')) . " | ";
	print &HelpLink(5, T('Emoticon')) . "<br>\n";
###
###############
###############
### replaced by gypark
### 편집모드에 들어갔을때 포커스가 편집창에 있도록 한다
#	print &GetFormStart();
	print &GetFormStart("form_edit");
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
	print $q->submit(-name=>'Save', -value=>T('Save')), "\n";
	$userName = &GetParam("username", "");
	if ($userName ne "") {
		print ' (', T('Your user name is'), ' ',
					&GetPageLink($userName) . ') ';
	} else {
		print ' (', Ts('Visit %s to set your user name.', &GetPrefsLink()), ') ';
	}
	#print $q->submit(-name=>'Preview', -value=>T('Preview'));	# luke delete
###############
### replaced by gypark 
### 미리보기 버튼에 번역함수 적용
	# print q(<input type="button" name="prev1" value="Popup Preview" onclick="javascript:preview();">); # luke added
	print q(<input type="button" name="prev1" value="). T('Popup Preview') . q(" onclick="javascript:preview();">); # luke added
###
###############

	if ($isConflict) {
		print "\n<br><hr noshade size=1><p><strong>", T('This is the text you submitted:'),
					"</strong><p>",
					&GetTextArea('newtext', $newText, $editRows, $editCols),
					"<p>\n";
	}
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
	print "<hr noshade size=1><b>$recentName:</b>\n";
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
															Ts('Show (diff) links on %s', $recentName));
		print "<br>", &GetFormCheck('alldiff', 0,
																T('Show differences on all pages'));
		print "  (",  &GetFormCheck('norcdiff', 1,
																Ts('No differences on %s', $recentName)), ")";
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
			T('Use wikiX style for the links to empty pages'));
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

	if (($UserID ne "113") && ($UserID ne "112")) {
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
	print '<br>';

	foreach $pagelines (&GetFullLinkList("page=1&unique=1&sort=1&exists=2&empty=0&reverse=$string")) {
		my @pages = split(' ', $pagelines);
		@x = (@x, shift(@pages));
	}
	
	&PrintPageList(@x);

	if ($#x eq -1) {
		print T('No reverse link.') . "<br>";
	}
	print "<hr size=\"1\">" . Ts('Return to %s' , &GetPageLink($string)) . "<br>";

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

	print "<h2>", Ts('%s pages found:', ($#_ + 1)), "</h2>\n";

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
			print "\n<a name=\"H_$indexTitle[$count]\"></a>";
			print $q->h3($indexTitle[$count] 
					. "&nbsp;<a href=\"#PAGE_TOP\"><img src=\"$IconDir/gotop.gif\" align=\"texttop\" alt=\"" . T('Top') 
					. "\"></a>");
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

sub DoPost {
	my ($editDiff, $old, $newAuthor, $pgtime, $oldrev, $preview, $user);
	my $string = &GetParam("text", undef);
	my $id = &GetParam("title", "");
	my $summary = &GetParam("summary", "");
	my $oldtime = &GetParam("oldtime", "");
	my $oldconflict = &GetParam("oldconflict", "");
	my $isEdit = 0;
	my $editTime = $Now;
	my $authorAddr = $ENV{REMOTE_ADDR};

	if (!&UserCanEdit($id, 1)) {
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
	$string = &ProcessPostMacro($string);
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
	if (($UserID ne "") || ($Section{'id'} ne ""))  {
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
	$Section{'host'} = &GetRemoteHost(1);
	&SaveDefaultText();
	&SavePage();
###############
### added by gypark
### 링크 목록을 별도로 관리
	&SaveLinkFile($id);
###
###############
	&WriteRcLog($id, $summary, $isEdit, $editTime, $user, $Section{'host'});
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
	&ReBrowsePage($id, "", 1);
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
	my ($id, $summary, $isEdit, $editTime, $name, $rhost) = @_;
	my ($extraTemp, %extra);

	%extra = ();
	$extra{'id'} = $UserID  if ($UserID ne "");
	$extra{'name'} = $name  if ($name ne "");
###############
### added by gypark
### 최근변경내역에 북마크 기능 도입
	$extra{'tscreate'} = $Page{'tscreate'};
###
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
	print "<b>Banned IP/network/host list:</b><br>\n";
	print "<p>Each entry is either a commented line (starting with #), ",
				"or a Perl regular expression (matching either an IP address or ",
				"a hostname).  <b>Note:</b> To test the ban on yourself, you must ",
				"give up your admin access (remove password in Preferences).";
	print "<p>Examples:<br>",
				"\\.foocorp.com\$  (blocks hosts ending with .foocorp.com)<br>",
				"^123.21.3.9\$  (blocks exact IP address)<br>",
				"^123.21.3.  (blocks whole 123.21.3.* IP network)<p>";
	print &GetTextArea('banlist', $banList, 12, 50);
	print "<br>", $q->submit(-name=>'Save'), "\n";
	print "<hr>\n";
	print &GetGotoBar("");
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
	&EditRecentChangesFile($RcOldFile, $action, $old, $new);
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
###
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
	push (@result, split($FS2, $links{'pagelinks'}, -1)) if ($pagelink);
	push (@result, split($FS2, $links{'interlinks'}, -1)) if ($interlink);
	push (@result, split($FS2, $links{'urllinks'}, -1)) if ($urllink);

	return @result;
}
###
###############

### 통채로 추가한 함수들의 끝
###############


&DoWikiRequest()  if ($RunCGI && ($_ ne 'nocgi'));   # Do everything.
1; # In case we are loaded from elsewhere
# == End of UseModWiki script. ===========================================

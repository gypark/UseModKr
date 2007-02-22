# === !/usr/local/bin/perl
# == Configuration =======================================================
# Original version from UseModWiki 0.92 (April 21, 2001)

$CookieName   = "Wiki";          # Name for this wiki (for multi-wiki sites)
$SiteName     = "Wiki";          # Name of site (used for titles)
$HomePage     = "HomePage";      # Home page (change space to _)
$RCName       = "RecentChanges"; # Name of changes page (change space to _)
$LogoUrl      = "";              # URL for site logo ("" for no logo)
$ENV{PATH}    = "/bin:/usr/bin/:/usr/local/bin/";     # Path used to find "diff"
$ScriptTZ     = "";              # Local time zone ("" means do not print)
$RcDefault    = 30;              # Default number of RecentChanges days
@RcDays       = qw(1 3 7 30 90); # Days for links on RecentChanges
$KeepDays     = 14;              # Days to keep old revisions
$SiteBase     = "";              # Full URL for <BASE> header
$FullUrl      = "";              # Set if the auto-detected URL is wrong
$RedirType    = 1;               # 1  = CGI.pm, 2  = script, 3  = no redirect
$AdminPass    = "admin";         # Set to non-blank to enable password(s)
$EditPass     = "edit";          # Like AdminPass, but for editing only
$StyleSheetUrl= "/cgi-bin/utf/wiki.css";      # URL for CSS stylesheet (like "/wiki.css")
$NotFoundPg   = "";              # Page for not-found links ("" for blank pg)
$EmailFrom    = "Wiki";          # Text for "From: " field of email notes.
$SendMail     = "/usr/sbin/sendmail";  # Full path to sendmail executable
$FooterNote   = "";              # HTML for bottom of every page
$EditNote     = "";              # HTML notice above buttons on edit page
$MaxPost      = 1024 * 1024 * 3; # Maximum 3MB posts (file upload limit)
$NewText      = "";              # New page text ("" for default message)
$HttpCharset  = "UTF-8";         # Charset for pages, like "iso-8859-2"
$UserGotoBar  = "";              # HTML added to end of goto bar
$UserGotoBar2 = "";
$UserGotoBar3 = "";
$UserGotoBar4 = "";

### Translation
do "./translations/ko_KR.UTF-8.pl";     # korean, UTF-8 encoding
# do "./translations/ko_KR.EUC-KR.pl";    # korean, EUC-kR encoding

### 인자 없이 wiki.pl 을 부르면 $LogoPage 를 embed 형식으로 출력
$LogoPage     = "";                             # this page will be displayed when no parameter
### 페이지 처리 시간 출력
$CheckTime    = 0;                              # 1 = mesure the page-processing time (requires Time::HiRes module), 0 = do not 
### 아이콘 디렉토리 URL
$IconUrl      = "/cgi-bin/utf/icons/";          # URL for directory containing icon files
### interwiki 아이콘 디렉토리 URL
$InterIconUrl = "/cgi-bin/utf/icons-inter/";    # URL for directory containing interwiki icons files
### 이모티콘 디렉토리 URL
$EmoticonUr   = "http:/cgi-bin/utf/emoticon/";  # URL for directory containing emoticon files
### 업로드한 파일이 저장되는 디렉토리 경로와, 브라우저 출력에 사용되는 URL
$UploadDir    = "./upload";                     # directory containing uploaded files
$UploadUrl    = "http:/cgi-bin/utf/upload";     # URL for the directory containing uploaded files
                                                #  if $UploadUrl = "", it has the same value as $UploadDir
### 템플릿 페이지
$TemplatePage = "TemplatePage";                 # name of template page for creating new page
### java script 함수
$JavaScriptUrl= "/cgi-bin/utf/wikiscript.js";   # URL for JavaScript code (like "/wikiscript.js")
### Oekaki용 .jar 파일
$OekakiJarUrl = "/cgi-bin/utf/oekakibbs.jar";   # URL for oekaki .jar file

### for {{{lang }}} block
$SOURCEHIGHLIGHT = "/usr/local/bin/source-highlight";    # Path of "source-highlight" binary
@SRCHIGHLANG     = qw(
		bib bison caml changelog cpp csharp diff flex fortran html java javascript
		langdef latex logtalk lua nohilite outlang pascal perl php postscript
		prolog python ruby sh sml sql style syslog tcl xml
	);													# Supported languages

### for "#EXTERN " directive
$EditGuideInExtern = 0;    # 1 = show edit guide in bottom frame, 0 = don't show
$SizeTopFrame      = 160;  # Height of top frame
$SizeBottomFrame   = 150;  # Height of bottom frame

### rss from usemod 1.0
$InterWikiMoniker = '';         # InterWiki moniker for this wiki. (for RSS)
$SiteDescription  = $SiteName;  # Description of this wiki. (for RSS)
$RssLogoUrl       = '';         # Optional image for RSS feed
$RssDays          = 7;          # Default number of days in RSS feed
$RssTimeZone      = 9;          # Time Zone of Server (hour), 0 for GMT, 9 for Korea
### 스크립트 뒤에 / or ? 선택 from usemod1.0
$SlashLinks   = 1;      # 1 = use script/action links, 0 = script?action
### trackback 보내기
$SendPingAllowed = 0;   # 0 - anyone, 1 - who can edit, 2 - who is admin
### LaTeX 변환 지원
$UseLatex    = 0;		# 1 = Use LaTeX conversion   2 = Don't convert
### 사용자 정의 헤더
$UserHeader  = '';      # Optional HTML header additional content
### 존재하지 않는 페이지 표시 방식
$EditNameLink = 1;      # 1 = edit links use name (CSS), 0 = '?' links
### 방문자 브라우저의 주소창의 인코딩 추측 (utf-8 은 쓰지 말 것)
### The encoding of URL request from visitor's browser may be one of these:
### ex: ('euc-jp', 'shiftjis', '7bit-jis')
### caution: Don't write 'utf-8'. It is included implicitly.
@UrlEncodingGuess = ('euc-kr');
### by luke
$UseEmoticon 	= 1;		# 1 = use emoticon, 0 = not use
$ClickEdit	 	= 1;		# 1 = edit page by double click on page, 0 = no use
$EditPagePos	= 1;		# 1 = bottom, 2 = top, 3 = top & bottom
$NamedAnchors   = 1;        # 0 = no anchors, 1 = enable anchors, 2 = enable but suppress display

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
$UseDiffLog  = 1;       # 1 = save diffs to log,  0 = do not save diffs
$KeepMajor   = 1;       # 1 = keep major rev,     0 = expire all revisions
$KeepAuthor  = 1;       # 1 = keep author rev,    0 = expire all revisions
$ShowEdits   = 0;       # 1 = show minor edits,   0 = hide edits by default
$HtmlLinks   = 1;       # 1 = allow A HREF links, 0 = no raw HTML links
$ThinLine    = 1;       # 1 = fancy <hr> tags,    0 = classic wiki <hr>
$BracketText = 1;       # 1 = allow [URL text],   0 = no link descriptions
$UseAmPm     = 1;       # 1 = use am/pm in times, 0 = use 24-hour times
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
  em s strike strong tt var div center blockquote ol ul dl table caption span);
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
$HiddenPageFile = "$DataDir/hidden";  # hidden pages list file

# == End of Configuration =================================================

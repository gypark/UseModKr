# === !/usr/local/bin/perl
# == Configuration =======================================================
# Original version from UseModWiki 0.92 (April 21, 2001)

$CookieName  = "Wiki";          # Name for this wiki (for multi-wiki sites)
$SiteName    = "Wiki";          # Name of site (used for titles)
$HomePage    = "HomePage";      # Home page (change space to _)
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
$AdminPass   = "admin";         # Set to non-blank to enable password(s)
$EditPass    = "edit";          # Like AdminPass, but for editing only
$StyleSheet  = "wiki.css";      # URL for CSS stylesheet (like "/wiki.css")
$NotFoundPg  = "";              # Page for not-found links ("" for blank pg)
$EmailFrom   = "Wiki";          # Text for "From: " field of email notes.
$SendMail    = "/usr/sbin/sendmail";  # Full path to sendmail executable
$FooterNote  = "";              # HTML for bottom of every page
$EditNote    = "";              # HTML notice above buttons on edit page
$MaxPost     = 1024 * 210;      # Maximum 210K posts (about 200K for pages)
$NewText     = "";              # New page text ("" for default message)
$HttpCharset = "euc-kr";              # Charset for pages, like "iso-8859-2"
$UserGotoBar = "<a href='/'>Home</a>";              # HTML added to end of goto bar
##########################################################
### added by gypark
### 상단 메뉴에 사용자정의링크를 더 달 수 있게 함
$UserGotoBar2 = "";
$UserGotoBar3 = "";
$UserGotoBar4 = "";

### 번역화일 사용
do "./translations/korean.pl";    # Path of translation file

### path of code2html
$SOURCEHIGHLIGHT    = "/usr/local/bin/source-highlight";    # path of source-highlight

### 존재하지 않는 페이지 표시 방식
$LinkFirstChar = 1;    # 1 = link on first character,  0 = followed by "?" mark (classical)
### EXTERN 페이지 하단에 편집 가이드 표시
$EditGuideInExtern = 0; # 1 = show edit guide in bottom frame, 0 = don't show
$SizeTopFrame = 160;
$SizeBottomFrame = 110;
### 인자 없이 wiki.pl 을 부르면 $LogoPage 를 embed 형식으로 출력
$LogoPage   = "";	# this page will be displayed when no parameter
### 페이지 처리 시간을 출력한다
$CheckTime = 1;   # 1 = mesure the processing time (requires Time::HiRes module), 0 = do not 
### 내부 아이콘이 저장된 디렉토리
$IconDir = "./icons/";	# directory containing icon files
### 
##
##########################################################


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
$HtmlLinks   = 0;       # 1 = allow A HREF links, 0 = no raw HTML links
$SimpleLinks = 0;       # 1 = only letters,       0 = allow _ and numbers
$NonEnglish  = 0;       # 1 = extra link chars,   0 = only A-Za-z chars
$ThinLine    = 0;       # 1 = fancy <hr> tags,    0 = classic wiki <hr>
$BracketText = 1;       # 1 = allow [URL text],   0 = no link descriptions
$UseAmPm     = 1;       # 1 = use am/pm in times, 0 = use 24-hour times
$UseIndex    = 0;       # 1 = use index file,     0 = slow/reliable method
$UseHeadings = 1;       # 1 = allow = h1 text =,  0 = no header formatting
$NetworkFile = 1;       # 1 = allow remote file:, 0 = no file:// links
$BracketWiki = 0;       # 1 = [WikiLnk txt] link, 0 = no local descriptions
$UseLookup   = 1;       # 1 = lookup host names,  0 = skip lookup (IP only)
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
$RcOldFile   = "$DataDir/rclog.old"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$LinkDir     = "$DataDir/link";    # Stores the links of each page

# added by luke

$UseEmoticon 	= 1;		# 1 = use emoticon, 0 = not use
$EmoticonPath	= "http:emoticon/";	# where emoticon stored
$ClickEdit	 	= 1;		# 1 = edit page by double click on page, 0 = no use
$EditPagePos	= 1;		# 1 = bottom, 2 = top, 3 = top & bottom
$NamedAnchors   = 1;        # 0 = no anchors, 1 = enable anchors, 2 = enable but suppress display
# == End of Configuration =================================================

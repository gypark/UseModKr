package UseModWiki;

@HelpItem = (
	"Make Page",		# 0
	"Text Formatting",	# 1
	"Link and Image",	# 2
	"Macro",			# 3
	"Emoticon",			# 4
	);


########### Make Page

$HelpText[0] = qq(
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

########### Text Formatting

$HelpText[1] = qq|
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

########### Link and Image

$HelpText[2] = qq(
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

########### Macro

$HelpText[3] = q|
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

########### Emoticon

$HelpText[4] = q|
'''홈페이지 관리자가 이모티콘을 사용하도록 허용한 경우에 적용됩니다'''

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


############# end of help contents

1;

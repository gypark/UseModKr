// 메모 매크로, 트랙백 등에 사용
function onMemoToggle(id)
{   
    if (document.getElementById(id).style.display == "none")
    {
        document.getElementById(id).style.display = "block";
    }
    else
    {
        document.getElementById(id).style.display = "none";
    }
    return false;
}

// 작성 취소 시 확인
var previous_text = "", current_text = "", conflict = false, closeok = false;
function chk_close(e, str) {
    if (!e) e = event;
    if (!closeok) {
        current_text = document.form_edit.text.value;

        if (conflict || (previous_text != current_text)) {
            e.returnValue = str;
        }
    }
}

// text - 클립보드에 복사될 텍스트
// thanks to ChatGPT
function copy_clip(field_id, btn) {

    var elem = document.getElementById(field_id);
    // Clipboard API의 지원 여부를 확인
    if (false && navigator.clipboard && navigator.clipboard.writeText) {
        var text;
        if ('value' in elem) {
            text = elem.value;
        } else {
            text = elem.textContent || elem.innerText;
        }

        // Clipboard API를 사용할 수 있는 경우
        navigator.clipboard.writeText(text).then(function() {
            var origVal = btn.value;
            btn.value = "Copied!";
            setTimeout(function() {
                btn.value = origVal; // 1초 후 원래 값으로 복원
            }, 1000);
        }).catch(function(error) {
            alert('failed to copy: ' + error);
        });
    } else {
        // Clipboard API를 사용할 수 없는 경우 (구형 브라우저)
        try {
            elem.select();  // 텍스트를 선택
            var successful = document.execCommand('copy');  // 텍스트를 클립보드에 복사
            if (successful) {
                var origVal = btn.value;
                btn.value = "Copied!";
                setTimeout(function() {
                    btn.value = origVal; // 1초 후 원래 값으로 복원
                }, 1000);
            }
            else {
                alert('failed to copy...');
            }
        } catch (err) {
            alert('This browse does not support copy command.');
        }
    }
}

// 단축키 개선
function GetKeyStroke(KeyStorke) {
    var evt = KeyStorke || window.event;
    var eventChooser = evt.keyCode || evt.which;
    var target = evt.target || evt.srcElement;
    if (evt.altKey || evt.ctrlKey || evt.metaKey) return;
    while (target && target.tagName.toLowerCase() != 'input' && target.tagName.toLowerCase() != 'textarea') {
        target = target.parentElement;
    }
    if (!target) {
        var which = String.fromCharCode(eventChooser).toLowerCase();
        if (which in key) {
            document.location.href = key[which];
        }
    }
}

// 바로 가기 필드 자동 완성
//==============================================================================
//  SYSTEM      :  잠정판 크로스 프라우저 Ajax용 라이브러리
//  PROGRAM     :  XMLHttpRequest에 의한 송수신을 합니다
//  FILE NAME   :  jslb_ajaxXXX.js
//  CALL FROM   :  Ajax 클라이언트
//  AUTHER      :  Toshirou Takahashi http://jsgt.org/mt/01/
//  SUPPORT URL :  http://jsgt.org/mt/archives/01/000409.html
//  CREATE      :  2005.6.26
//  TEST-URL    :  헤더 http://jsgt.org/ajax/ref/lib/test_head.htm
//  TEST-URL    :  인증   http://jsgt.org/mt/archives/01/000428.html
//  TEST-URL    :  비동기 
//        http://allabout.co.jp/career/javascript/closeup/CU20050615A/index.htm
//  TEST-URL    :  SQL     http://jsgt.org/mt/archives/01/000392.html
//------------------------------------------------------------------------------
// 최신 정보   : http://jsgt.org/mt/archives/01/000409.html 
// 저작권 표시의무 없음. 상업 이용과 개조는 자유. 연락 필요 없음.
//
//

    ////
    // 동작가능한 브라우저 판정
    //
    // @sample        if(chkAjaBrowser()){ location.href='nonajax.htm' }
    // @sample        oj = new chkAjaBrowser();if(oj.bw.safari){ /* Safari 코드 */ }
    // @return        라이브러리가 동작가능한 브라우저만 true  true|false
    //
    //  Enable list (v038현재)
    //   WinIE 5.5+ 
    //   Konqueror 3.3+
    //   AppleWebKit계(Safari,OmniWeb,Shiira) 124+ 
    //   Mozilla계(Firefox,Netscape,Galeon,Epiphany,K-Meleon,Sylera) 20011128+ 
    //   Opera 8+ 
    //
    function chkAjaBrowser()
    {
        var a,ua = navigator.userAgent;
        this.bw= { 
          safari    : ((a=ua.split('AppleWebKit/')[1])?a.split('(')[0]:0)>=124 ,
          konqueror : ((a=ua.split('Konqueror/')[1])?a.split(';')[0]:0)>=3.3 ,
          mozes     : ((a=ua.split('Gecko/')[1])?a.split(" ")[0]:0) >= 20011128 ,
          opera     : (!!window.opera) && ((typeof XMLHttpRequest)=='function') ,
          msie      : (!!window.ActiveXObject)?(!!createHttpRequest()):false 
        }
        return (this.bw.safari||this.bw.konqueror||this.bw.mozes||this.bw.opera||this.bw.msie)
    }
    

    ////
    // XMLHttpRequest 오브젝트 생성
    //
    // @sample        oj = createHttpRequest()
    // @return        XMLHttpRequest 오브젝트(인스턴스)
    //
    function createHttpRequest()
    {
        if(window.ActiveXObject){
             //Win e4,e5,e6용
            try {
                return new ActiveXObject("Msxml2.XMLHTTP") ;
            } catch (e) {
                try {
                    return new ActiveXObject("Microsoft.XMLHTTP") ;
                } catch (e2) {
                    return null ;
                }
            }
        } else if(window.XMLHttpRequest){
             //Win Mac Linux m1,f1,o8 Mac s1 Linux k3용
            return new XMLHttpRequest() ;
        } else {
            return null ;
        }
    }
    
    ////
    // 송수신 함수
    //
    // @sample         sendRequest(onloaded,'&prog=1','POST','./about2.php',true,true)
    // @param callback 송수신시에 기동하는 함수 이름
    // @param data     송신하는 데이터 (&이름1=값1&이름2=값2...)
    // @param method   "POST" 또는 "GET"
    // @param url      요청하는 파일의 URL
    // @param async    비동기라면 true 동기라면 false
    // @param sload    수퍼 로드 true로 강제、생략또는 false는 기본
    // @param user     인증 페이지용 사용자 이름
    // @param password 인증 페이지용 암호
    //
    function sendRequest(callback,data,method,url,async,sload,user,password)
    {
        //XMLHttpRequest 오브젝트 생성
        var oj = createHttpRequest();
        if( oj == null ) return null;
        
        //강제 로드의 설정
        var sload = (!!sendRequest.arguments[5])?sload:false;
        if(sload || method.toUpperCase() == 'GET')url += "?";
        if(sload)url=url+"t="+(new Date()).getTime();
        
        //브라우저 판정
        var bwoj = new chkAjaBrowser();
        var opera     = bwoj.bw.opera;
        var safari    = bwoj.bw.safari;
        var konqueror = bwoj.bw.konqueror;
        var mozes     = bwoj.bw.mozes ;

        //송신 처리
        //opera는 onreadystatechange에 중복 응답이 있을 수 있어 onload가 안전
        //Moz,FireFox는 oj.readyState==3에서도 수신하므로 보통은 onload가 안전
        //Win ie에서는 onload가 동작하지 않는다
        //Konqueror은 onload가 불안정
        //참고 http://jsgt.org/ajax/ref/test/response/responsetext/try1.php
        if(opera || safari || mozes){
            oj.onload = function () { callback(oj); }
        } else {
        
            oj.onreadystatechange =function () 
            {
                if ( oj.readyState == 4 ){
                    callback(oj);
                }
            }
        }

        //URL 인코딩
        data = uriEncode(data)
        if(method.toUpperCase() == 'GET') {
            url += data
        }
        
        //open 메소드
        oj.open(method,url,async,user,password);

        //헤더 application/x-www-form-urlencoded 설정
        setEncHeader(oj)

        //디버그
        //alert("////jslb_ajaxxx.js//// \n data:"+data+" \n method:"+method+" \n url:"+url+" \n async:"+async);
        
        //send 메소드
        oj.send(data);

        //URI 인코딩 헤더 설정
        function setEncHeader(oj){
    
            //헤더 application/x-www-form-urlencoded 설정
            // @see  http://www.asahi-net.or.jp/~sd5a-ucd/rec-html401j/interact/forms.html#h-17.13.3
            // @see  #h-17.3
            //   ( enctype의 기본값은 "application/x-www-form-urlencoded")
            //   h-17.3에 의해、POST/GET 상관없이 설정
            //   POST에서 "multipart/form-data"을 설정할 필요가 있는 경우에는 커스터마이즈 해주세요.
            //
            //  이 메소드가 Win Opera8.0에서 에러가 나므로 분기(8.01은 OK)
            var contentTypeUrlenc = 'application/x-www-form-urlencoded; charset=UTF-8';
            if(!window.opera){
                oj.setRequestHeader('Content-Type',contentTypeUrlenc);
            } else {
                if((typeof oj.setRequestHeader) == 'function')
                    oj.setRequestHeader('Content-Type',contentTypeUrlenc);
            }   
            return oj
        }

        //URL 인코딩
        function uriEncode(data){

            if(data!=""){
                //&와=로 일단 분해해서 encode
                var encdata = '';
                var datas = data.split('&');
                for(i=1;i<datas.length;i++)
                {
                    var dataq = datas[i].split('=');
                    encdata += '&'+encodeURIComponent(dataq[0])+'='+encodeURIComponent(dataq[1]);
                }
            } else {
                encdata = "";
            }
            return encdata;
        }


        return oj
    }

// 여기서부터는 UseModWiki ext버전에서 바로가기 필드 자동완성을 위해 수정했음
// 필요한 전역변수
var have_data = 0;
var page_list;
var previous_search = 'previous';
var resOj;
var timeout = 0;
var timeout_url;
var div_blur = 0;
var user_last_input;
// 엘리먼트들의 이름을 짧게 쓰기 위한 변수
var _goto_field;
var _select_field;
var _list_div;
var _search_field;

function gotobar_init() {
    _goto_field   = document.goto_form.goto_text;
    _select_field = document.goto_form.goto_select;
    _list_div = document.getElementById('goto_list');
    _search_field = document.search_form.search;
}

//송수신 함수
function getTitleIndex(url) {

    // 0.2초 이내에는 다시 갱신하지 않음 - 타이핑 속도를 못 따라잡는 문제
    if (timeout) {
        return;
    }
    timeout=1
    timeout_url=url
//  setTimeout("timeout=0;",200)
    setTimeout("timeout=0; getTitleIndex(timeout_url);",300)

    if (have_data) {
        renew_select()
    }
    else {
        // 처음 한번만 서버에서 목록을 받아옴
        sendRequest(
            on_loaded1,                                 //콜백함수
            '&action=titleindex',                       //파라메터
            'GET',                                      //HTTP메소드
            url,                                        //URL
            true,                                       //비동기
            true                                        //강제로드
        )
    }
}

function on_loaded1(oj)
{
    //응답을 취득
    var res  =  decodeURIComponent(oj.responseText)

    // titleindex 출력을 받아서, 개별 페이지 이름의 배열로 분리
    page_list = res.split(/\s+/)
    have_data = 1;

    // select 목록 갱신
    renew_select()
}

function renew_select() {
    // 사용자가 입력한 값을 포함한 페이지 제목만 추려냄
    var search = _goto_field.value;

    // 입력값에 변동이 없다면 진행하지 않는다
    if (previous_search == search || !page_list) {
        return;
    }
    previous_search = search

    // 목록에서 선택한 직후라면 진행하지 않는다
    if (div_blur) {
        div_blur = 0;
        return;
    }

    // 뒤의 공백을 제거하고, 중간 공백은 "_"로 치환하고, 대소문자 구분 안함
    var temp = search;
    search = search.replace(/\s*$/, '').replaceAll(' ','_');

    // 입력값이 널 문자 또는 일정 길이 이하면 중단 - 속도 문제
    if (search.length < 1) {
        return false;
    }

    user_last_input = temp; // up키로 되돌아갔을때 복원하기 위한 값

    let new_list = page_list.filter(name => name.toLowerCase().includes(search.toLowerCase()));

    // select 목록 갱신
    _list_div.style.display='block'
    resOj = new chgARRAYtoHTMLOptions(new_list,_select_field)
    resOj.addOptions()
}

// 배열을 인자로 받아서, oj에 해당하는 select 목록을 조작하는 객체를 반환
// chgXMLtoHTMLOptions()의 흉내를 내어서 수정함
function chgARRAYtoHTMLOptions(arr,oj) {

    return {

        //XML의 items,value,text을 연결하여 배열로 반환합니다
        setItems : function() {
            return arr;
        },

        //XML의 데이터로부터 오브젝트를 생성합니다
        addOptions : function() {
            //모든 옵션을 지웁니다
            this.delAllOptions(oj)
            //XML 데이터의 오브젝트를 받아 냅니다
            var data = this.setItems()
            //"item" 태그가 나온 순서대로 처리합니다
            for( i = 0 ; i < data.length ; i++ ) {
                var text  = data[i]
                var value = data[i]
                oj.options[oj.length]=new Option(text,value)
            }
        },

        //index로 지정된 옵션을 지웁니다
        delOptionByIndex : function(index) {
            oj.options[index]=null
        },

        //모든 옵션을 지웁니다
        delAllOptions : function(oj) {
            var optionIndex = oj.options.length  
            for ( i=0 ; i <= optionIndex ; i++ ) {
                oj.options[0]=null          // 어째서 "i"가 아니라 "0"일까...?
            }
        },

        //option이 선택된 때의 처리
        onselectedOption : function(oj) {
            _goto_field.value = oj.options[oj.selectedIndex].value
            previous_search = _goto_field.value;
        }
    }
}

function goto_list_blur(oj, field_update, close_div) {
    div_blur = 1    // 텍스트필드값이 변경되더라도 목록 갱신을 하지 않게 함
    if (field_update) {
        resOj.onselectedOption(oj)
    }
    if (close_div) {
        _list_div.style.display = 'none'
    }
}

function goto_list_keydown(oj, KeyStorke) {
    var evt = KeyStorke || window.event;
    var nKeyCode = evt.keyCode;

    // 목록을 닫고 텍스트 필드로 되돌아갈 지 여부 판단
    if (nKeyCode == 13 || nKeyCode == 32) {
        // enter,space가 눌렸을 때 - 필드 갱신 후 닫음
        goto_list_blur(oj, true, true);
        _goto_field.focus();
        return false;
    }
    else if (nKeyCode == 27 || (nKeyCode == 38 && oj.selectedIndex <= 0)) {
        // esc가 눌렸거나
        // up이 눌렸고 목록의 제일 위에 있었을 때 - 필드 갱신 없이 닫기만 함
        goto_list_blur(oj, false, true);
        _goto_field.focus();
        _goto_field.value = user_last_input;
        setTimeout("_search_field.focus(); _goto_field.focus(); _goto_field.value = user_last_input;", 20); // for IE
        return false;
    }
    else if (nKeyCode == 8) {
        // BS - 필드 값에서 한 글자 지우고 포커스 이동
        user_last_input = _goto_field.value.substring(0,_goto_field.value.length-1);
        _goto_field.focus();
        _goto_field.value = user_last_input;
        setTimeout("_search_field.focus(); _goto_field.focus(); _goto_field.value = user_last_input;", 20); // for IE
        return true;
    }
    else {
        return true;
    }
}

function goto_text_keydown(oj, KeyStorke) {
    var evt = KeyStorke || window.event;
    var nKeyCode = evt.keyCode;

    if (nKeyCode == 40 && resOj) {  // down
        _list_div.style.display = 'block'
        if (_select_field.options.length > 0) {
            _search_field.focus()       // 웹마 때문에 우회함
            _select_field.focus()
        }
    }
    else if (nKeyCode == 38) {      // up
        _list_div.style.display = 'none'
    }
}


// 본문 편집 화면에서 페이지 이름 자동완성
document.addEventListener('DOMContentLoaded', function() {
    let editor = document.getElementById('text');
    if (!editor) {
        return;
    }

    let autocompleteBox = document.getElementById('autocomplete-box');
    if (!autocompleteBox) {
        return;
    }

    let currentSuggestions = [];
    let suggestionIndex = -1;

    editor.addEventListener('input', function(e) {
        let text = editor.value;
        let cursorPosition = editor.selectionStart;
        let searchTerm = getSearchTerm(text, cursorPosition);

        if (searchTerm.startsWith('[[')) {
            let query = searchTerm.substring(2);  // "[[" 이후의 텍스트
            fetchSuggestions(query);
        }
        else {
            autocompleteBox.style.display = 'none';
            editor.focus();
        }
    });

    editor.addEventListener('keydown', function(e) {
        if (autocompleteBox.style.display === 'block') {
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                moveSelection(1);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                moveSelection(-1);
            } else if (e.key === 'Enter') {
                e.preventDefault();
                selectSuggestion();
            } else if (e.key === 'Escape') {
                autocompleteBox.style.display = 'none';
                editor.focus();
            }
        }
    });

    document.addEventListener('mousedown', function(e) {
        // 클릭한 위치가 textarea나 autocompleteBox 내에 포함되지 않으면 상자를 닫습니다.
        if (!autocompleteBox.contains(e.target)) {
            autocompleteBox.style.display = 'none';
        }
    });

    // 커서 위치가 아직 닫히지 않은 [[ 뒤에 있을 때만 반환
    function getSearchTerm(text, cursorPosition) {
        let start = text.lastIndexOf('[[', cursorPosition);
        let closeTag = text.lastIndexOf(']]', cursorPosition);
        if (start === -1) return '';
        if (start < closeTag) return '';
        let end = cursorPosition;
        let ret = text.substring(start, end);
        return ret;
    }

    function getTitleIndexInEdit(url) {
        if (have_data) {
            return;
        }

        let xhr = new XMLHttpRequest();
        xhr.open('GET', url + '?action=titleindex', true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                have_data = 1;
                page_list = xhr.responseText.split('\n');
            }
        };
        xhr.send();
    }

    function fetchSuggestions(query) {
        let url = autocompleteBox.getAttribute('data-url');
        getTitleIndexInEdit(url);
        let lines = page_list;

        if (!query) {
            return;
        }

        search = query.replace(/\s*$/, '').replace(' ','_');

        // query가 "/"로 시작할 경우 상위 페이지가 같은 것만
        if (search.startsWith("/")) {
            let current_page_tag = document.querySelector('input[type="hidden"][name="title"]');
            if (current_page_tag) {
                let main_page = current_page_tag.value.split("/")[0];
                if (main_page) {
                    search = main_page + search;
                }
            }
        }
        search = search.toLowerCase();

        if (lines) {
            currentSuggestions = lines.filter(line => line.toLowerCase().includes(search));
        }
        showSuggestions();
    }

    function showSuggestions() {
        updateAutocompleteBoxPosition();

        autocompleteBox.innerHTML = '';
        currentSuggestions.forEach((suggestion, index) => {
            let item = document.createElement('div');
            item.textContent = suggestion;
            item.dataset.index = index;
            item.addEventListener('click', function() {
                suggestionIndex = index;
                moveSelection(0);
                selectSuggestion();
            });

            autocompleteBox.appendChild(item);
        });

        autocompleteBox.style.display = 'block';
        suggestionIndex = -1;
    }

    function moveSelection(direction) {
        let items = autocompleteBox.querySelectorAll('div');
        suggestionIndex = (suggestionIndex + direction + items.length) % items.length;
        items.forEach(item => item.classList.remove('selected'));
        if (items[suggestionIndex]) {
            items[suggestionIndex].classList.add('selected');

            let selectedItem = items[suggestionIndex];
            selectedItem.scrollIntoView({
                block: 'nearest',
                behavior: 'smooth',
            });
        }
    }

    function selectSuggestion() {
        let selected = autocompleteBox.querySelector('div.selected');
        if (selected) {
            let text = editor.value;
            let cursorPosition = editor.selectionStart;
            let searchTerm = getSearchTerm(text, cursorPosition);
            let selectedText = selected.textContent;

            // 입력한 문자열이 "/"로 시작하는 경우 - 선택한 페이지 이름에서 다시 메인 페이지 이름 부분은 제외
            let query = searchTerm.substring(2);  // "[[" 이후의 텍스트
            if (searchTerm.startsWith("[[/")) {
                let current_page_tag = document.querySelector('input[type="hidden"][name="title"]');
                if (current_page_tag) {
                    let main_page = current_page_tag.value.split("/")[0];
                    if (main_page && selectedText.startsWith(main_page + "/")) {
                        selectedText = selectedText.substring(main_page.length);
                    }
                }
            }
            selectedText = selectedText.replaceAll('_', ' ');

            // 치환
            let newText = text.slice(0, cursorPosition - searchTerm.length) + '[[' + selectedText + ']]' + text.slice(cursorPosition);
            editor.value = newText;

            // 커서 위치 계산
            // 앞뒤에 [[ 와 ]] 가 추가되니 +4 필요
            let newCursorPosition = cursorPosition - searchTerm.length + selectedText.length + 4;
            editor.setSelectionRange(newCursorPosition, newCursorPosition);

            autocompleteBox.style.display = 'none';
            editor.focus();
        }
    }

    // 현재 커서가 있는 위치의 바로 아래 부근에 자동완성 제안 상자가 위치하도록 지정
    function updateAutocompleteBoxPosition() {
        let cursorPosition = editor.selectionStart;
        let textBeforeCursor = editor.value.substring(0, cursorPosition);

        // Create a temporary element to measure the exact cursor position
        let tempDiv = document.createElement('div');
        tempDiv.style.position = 'absolute';
        tempDiv.style.whiteSpace = 'pre-wrap';
        tempDiv.style.visibility = 'hidden';
        tempDiv.style.font = window.getComputedStyle(editor).font;
        tempDiv.style.padding = '0';
        tempDiv.style.margin = '0';
        tempDiv.style.border = 'none';

        // Match the editor's style
        tempDiv.style.width = editor.clientWidth + 'px';
        tempDiv.textContent = textBeforeCursor.replace(/\n$/, '\n\u200B'); // Ensure new line is counted

        let tempSpan = document.createElement('span');
        tempSpan.textContent = '|'; // A temporary cursor marker
        tempDiv.appendChild(tempSpan);

        // Position the tempDiv over the textarea
        let editorRect = editor.getBoundingClientRect();
        tempDiv.style.left = editorRect.left + 'px';
        tempDiv.style.top = editorRect.top + 'px';

        // 스크롤되어 넘어간 만큼은 빼야 함
        let scrollTopOffset = editor.scrollTop;

        document.body.appendChild(tempDiv);

        // Calculate the position of the cursor marker
        let tempSpanRect = tempSpan.getBoundingClientRect();
        let lineHeight = parseInt(window.getComputedStyle(editor).lineHeight, 10);

        // Set the position of the autocomplete box relative to the cursor
        autocompleteBox.style.top = tempSpanRect.top + lineHeight - scrollTopOffset + 'px';
        autocompleteBox.style.left = tempSpanRect.left + 'px';
        autocompleteBox.style.width = (editor.clientWidth/3) + 'px';

        document.body.removeChild(tempDiv);
    }
});


// memo
document.addEventListener('DOMContentLoaded', function() {
    const toggleButtons = document.querySelectorAll('.memo-toggle');

    toggleButtons.forEach(button => {
        button.addEventListener('click', function() {
            // 버튼 다음에 있는 .memo 요소를 찾습니다.
            const memoElement = button.nextElementSibling;
            console.log("memoElement:"+memoElement);

            if (memoElement && memoElement.classList.contains('memo')) {
                const isVisible = memoElement.style.display !== 'none';
                memoElement.style.display = isVisible ? 'none' : 'block';

                // aria-expanded 속성 업데이트
                const isExpanded = button.getAttribute('aria-expanded') === 'true';
                button.setAttribute('aria-expanded', !isExpanded);
            }
        });
    });
});

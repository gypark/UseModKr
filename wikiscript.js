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

// msg - 사용자에게 확인창을 띄울때 출력되는 메시지
//     - ""이면 확인창 띄우지 않음
// text - 클립보드에 복사될 텍스트
// 출처: http://www.krikkit.net/howto_javascript_copy_clipboard.html
// modified by raymundo, gypark@gmail.com

// Copyright (C) krikkit - krikkit@gmx.net
// --> http://www.krikkit.net
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
function copy_clip(msg, text) {
	if (msg != "") {
		if (!confirm(msg)) return;
	}

	// IE
	if (window.clipboardData) { 
		window.clipboardData.setData("Text", text);
	}
	// Firefox/Mozilla
	else if (window.netscape) {
		// firefox/mozilla 에서 동작하기 위해서는 사용자 프로파일 디렉토리에 prefs.js 파일에 다음과 같이 적어준다
		// user_pref("signed.applets.codebase_principal_support", true);
		// 또는 "about:config" 페이지를 열어서 다음 항목의 값을 true로 설정해 준다
		// signed.applets.codebase_principal_support

		alert("If it fails to copy, check the option:\n\nsigned.applets.codebase_principal_support  =  true\n\nin \"about:config\" page.");

		netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
		
		var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
		if (!clip) return;

		var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
		if (!trans) return;

		trans.addDataFlavor('text/unicode');

		var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
		var copytext=text;

		str.data=copytext;

		trans.setTransferData("text/unicode",str,copytext.length*2);

		var clipid=Components.interfaces.nsIClipboard;

		if (!clip) return false;

		clip.setData(trans,null,clipid.kGlobalClipboard);
	}
	return false;
}

// 단축키 개선
function GetKeyStroke(KeyStorke) {
	var evt = KeyStorke || window.event;
	var eventChooser = evt.keyCode || evt.which;
	var target = evt.target || evt.srcElement;
	if (evt.altKey || evt.ctrlKey) return;
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
	// @param data	   송신하는 데이터 (&이름1=값1&이름2=값2...)
	// @param method   "POST" 또는 "GET"
	// @param url      요청하는 파일의 URL
	// @param async	   비동기라면 true 동기라면 false
	// @param sload	   수퍼 로드 true로 강제、생략또는 false는 기본
	// @param user	   인증 페이지용 사용자 이름
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
		var opera	  = bwoj.bw.opera;
		var safari	  = bwoj.bw.safari;
		var konqueror = bwoj.bw.konqueror;
		var mozes	  = bwoj.bw.mozes ;

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

function gotobar_init() {
	_goto_field   = document.goto_form.goto_text;
	_select_field = document.goto_form.goto_select;
	_list_div = document.getElementById('goto_list');
}

//송수신 함수
function getMsg(url) {

	// 0.2초 이내에는 다시 갱신하지 않음 - 타이핑 속도를 못 따라잡는 문제
	if (timeout) {
		return;
	}
	timeout=1
	timeout_url=url
//	setTimeout("timeout=0;",200)
	setTimeout("timeout=0; getMsg(timeout_url);",300)

	if (have_data) {
		renew_select()
	}
	else {
		// 처음 한번만 서버에서 목록을 받아옴
		have_data = 1;
		sendRequest(
			on_loaded1,									//콜백함수
			'&action=titleindex',						//파라메터
			'GET',										//HTTP메소드
			url,										//URL
			true,										//비동기
			true										//강제로드
		)
	}
}

function on_loaded1(oj)
{
	//응답을 취득
	var res  =  decodeURIComponent(oj.responseText)

	// titleindex 출력을 받아서, 개별 페이지 이름의 배열로 분리
	page_list = res.split(/\s+/)

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
	search = search.replace(/\s*$/, '').replace(' ','_');

	// 입력값이 널 문자 또는 일정 길이 이하면 중단 - 속도 문제
	if (search.length < 1) {
		return false;
	}

	user_last_input = search;	// up키로 되돌아갔을때 복원하기 위한 값

	search = new RegExp(search, "i")
	var new_list = new Array();
	for( i = 0 ; i < page_list.length ; i++ ){
		if (page_list[i].match(search)) {
			new_list.push(page_list[i])
		}
	}

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
				oj.options[0]=null			// 어째서 "i"가 아니라 "0"일까...?
			}
		},

		//option이 선택된 때의 처리
		onselectedOption : function(oj) {
			_goto_field.value = oj.options[oj.selectedIndex].value
		}
	}
}

function goto_list_blur(oj, field_update, close_div) {
	div_blur = 1	// 텍스트필드값이 변경되더라도 목록 갱신을 하지 않게 함
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
	if (nKeyCode == 13) {
		// enter가 눌렸을 때 - 필드 갱신 후 닫음
		goto_list_blur(oj, true, true);
		_goto_field.focus();
		return false;
	}
	else if (nKeyCode == 38) {
		// up이 눌렸고 목록의 제일 위에 있었을 때 - 필드 갱신 없이 닫기만 함
		if (oj.selectedIndex == 0) {
			goto_list_blur(oj, false, true);
			_goto_field.focus();
			_goto_field.value = user_last_input;
			setTimeout("_goto_field.value = user_last_input", 100); // for IE
			return false;
		}
	}
	else {
		return true;
	}
}

function goto_text_keydown(oj, KeyStorke) {
	var evt = KeyStorke || window.event;
	var nKeyCode = evt.keyCode;

	if (nKeyCode == 40 && resOj) {	// down
		return true;
	}
	else {
		return false;
	}
}

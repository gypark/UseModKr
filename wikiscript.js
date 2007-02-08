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
	if (!confirm(msg)) return;

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


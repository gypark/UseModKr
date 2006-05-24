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
var previous_text, current_text;
var closeok = false;
function chk_close(e, str) {
	if (!e) e = event;
	if (!closeok) {
		current_text = document.form_edit.text.value;

		if (previous_text != current_text) {
			e.returnValue = str;
		}
	}
}

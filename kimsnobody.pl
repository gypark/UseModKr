#!/usr/bin/perl


#   이 파일에서 수정할 곳은 첫줄의 펄path(usr/bin/perl or usr/local/bin/perl)
#   밖에는 없습니다.                          

####################################################################################
#                                                                                  #
#      프로그램이름 : kimsBOARD                                                    #
#            제작자 : 김성호(w3master@kimsworld.net)                               #
#            베포처 : http://www.kimsworld.net                                     #
#          라이센스 : 본 소스는 상업적인 용도가 아닌경우에 개인에 한해서 프리웨어  #
#                     이며 소스를 수정하여 사용할 경우 제작자와 반드시 상의를 거쳐 #
#                     야 하며 수정된 소스는 어떠한 경우에도 재배포 될 수 없습니다. #
#            저작권 : 본 소스에 대한 저작권은 제작자인 김성호에게 있습니다.        #
#                                                                                  #
#                                                                                  #
####################################################################################



if($ENV{'QUERY_STRING'} ne "") {
    @pairs = split(/&/,$ENV{'QUERY_STRING'});
    }
    else {
        $buffer = "";
        read(STDIN,$buffer,$ENV{'CONTENT_LENGTH'});
        @pairs = split(/&/, $buffer);
        }
        
        foreach $pair (@pairs) {
            ($name, $value) = split(/=/,$pair);

            $value =~ tr/+/ /;
            $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;

            $FORM{$name} = $value;
    }
  
$CgiUrl = "kimsnobody.pl";
# $CgiUrl = "kimsnobody.cgi";
$BaseDir = "./";
$ImgUrl = "http://www.junksf.net/kimsboard/image";

     if ($FORM{'action'} eq "remove") {remove_file();}
  elsif ($FORM{'action'} eq "view") {starting(); open_directory(); ending();}
  else {starting(); open_directory(); ending();}
    

###############################################################################
sub open_directory {
print "<form action=$CgiUrl method=post>
       <table border=0 width=700 bgcolor=gray cellspacing=1 cellpadding=1>
  <tr>
    <td bgcolor=C0C0C0 align=center><font face=돋움><strong>NO.</strong></font></td>
    <td bgcolor=C0C0C0 align=center><font face=돋움><strong>형식</strong></font></td>
    <td bgcolor=C0C0C0 align=center><font face=돋움><strong>디렉토리 및 파일</strong></font> <font color=red face=돋움>[현재경로] <input type=text size=40 name=dir value=\"$FORM{'value'}/\">
     <a href=$CgiUrl>[처음]</a> <a href=javascript:history.go(-1)>[뒤로]</a> <a href=\"$CgiUrl?action=$FORM{'action'}&value=$FORM{'value'}\">[리로드]</a></font></td>
    <td bgcolor=C0C0C0 align=center><font face=돋움><strong>열기</strong></font></td>
    <td bgcolor=C0C0C0 align=center><font face=돋움><strong>삭제</strong></font></td>
  </tr></form>\n";    
  
if(!$FORM{'value'}) {$FORM{'value'} = $BaseDir;} else {$FORM{'value'} = "$FORM{'value'}/"; }
opendir(DIRECTORY, "$FORM{'value'}");
@data = readdir(DIRECTORY);
closedir(DIRECTORY);
$pp = 1;

foreach $data (@data) {

if(($data ne ".") && ($data ne "..")) {

file_type();

print "<tr>
    <td align=center bgcolor=EEEEEE><font color=black><b>$pp</b></font></td>\n";
if(!opendir(DIRECTORY, "$FORM{'value'}$data")) {
print "<td align=center bgcolor=white>$wtype</td>
       <td align=center bgcolor=white><a href=\"$FORM{'value'}$data\" target=_blank><font color=blue>$data</font></a></td>
       <td align=center bgcolor=eeeeee> </td>
       <td align=center bgcolor=eeeeee><a href=\"$CgiUrl?action=remove&value=$FORM{'value'}$data\">Del</a></td></tr>\n";
    }
else{ 
print "<td align=center bgcolor=white>Dir</td>
       <td align=center bgcolor=white><a href=\"$FORM{'value'}$data\" target=_blank><font color=blue><b>$data</b></font></a></td>
       <td align=center bgcolor=eeeeee><a href=\"$CgiUrl?action=view&value=$FORM{'value'}$data\">View</a></td>
       <td align=center bgcolor=eeeeee><a href=\"$CgiUrl?action=remove&value=$FORM{'value'}$data\">Del</a></td></tr>\n";
}

$pp++;
}
}
print "</table>\n";
}
###############################################################################
sub remove_file {

if(!opendir(DIRECTORY, "$FORM{'value'}")) {
print `chmod 777 $FORM{'value'}`;
unlink ("$FORM{'value'}");
print "unlink" . $FORM{'value'};
}
else {
print `rmdir -rf $FORM{'value'}`;
print `chmod 777 $FORM{'value'}`;
rmdir ("$FORM{'value'}");
opendir(DIRECTORY, "$FORM{'value'}");
@data = readdir(DIRECTORY);
closedir(DIRECTORY);

foreach $data (@data) {
unlink ("$FORM{'value'}/$data");
}
print `chmod 777 $FORM{'value'}`;
rmdir ("$FORM{'value'}");
}
starting();
open_directory();
ending();
}
################################################################################
sub starting {
print "Content-type: text/html; charset=UTF-8\n\n";
print "
<!---------------------------------------------------------------------->
<!--                                                                  -->
<!--  KIMSBOARD kimsnobody.cgi                                        -->
<!--                                                                  -->
<!--  만든사람 : 김성호                                               -->
<!--  홈페이지 : http://www.kimsworld.net                             -->
<!--  전자우편 : w3master\@kimsworld.net                               -->
<!--  배포날짜 : 2000.03.05                                           -->
<!--                                                                  -->
<!--  프로그램에 관한 것은 홈페이지 게시판이나 이메일을 통해 문의해   -->
<!--  주시기 바랍니다.                                                -->
<!--  Copyright (c) Kim Seong-ho All rights reserved.                 -->
<!--                                                                  -->
<!---------------------------------------------------------------------->";
  print "
  <HTML>
  <HEAD><TITLE>kims nobody_file killer</TITLE>
 <style>
 <!--
  A:link {text-decoration:none}
  A:visited {text-decoration:none}
  A:hover {  text-decoration:none;  color:black;}
   p,br,body,td,input,form,textarea,option {font-size:9pt;}
   select    { background-color:white;}
  .button   { height:21px; border-width:1; border-style:ridge; border-color:#d0d0d0; background-color:;}
  .bot { cursor: hand; font: 9pt 돋움; height: 20px; border-width: 1px 1px 1px 1px; border-color: 888888; color: white; background: 666666; }
  .editbox  { border:1 solid black; background-color:white; }
  .ver8 {font-family:Verdana,Arial,돋움;font-size:8pt}
  .ad{border:1 solid black}
  .family{line-height:140%}
 -->
 </style>\n";
 if($FORM{'action'} eq "remove") {       
       print "<META http-equiv=\"refresh\" content =\"0;url=$CgiUrl?action=view&value=$FORM{'value'}\">\n";
       }
  print "</HEAD>
  <BODY BGCOLOR=#eeeeee>\n";
  print"<center><font size=3><b> [ Kims NOBODY_FILE Killer 0.0.5 ] </b></font><p>\n";
}
###############################################################################
sub ending {
  print "
  <p><hr width=700 size=0>본 파일은 nobody로 생성된 파일과 퍼미션이 rwx-rwx-rwx인 파일만 지울 수 있습니다.<br>
     본 파일을 업로드하기전 우선 지우고자 하는 디렉토리 및 파일을 텔넷이나 ftp에서 최대한 지워줍니다.<br>
     ftp나 텔넷에서 지워지지 않는 디렉토리와 파일을 삭제해줍니다..<br>
     [참고] nobody가 아닌 파일이 nobody파일 사이에 끼어 있으면 한꺼번에 삭제하기는 안됩니다.
  <hr width=700 size=0><br><a href=http://www.kimsworld.net>Created by kims</a></center></font></BODY>
  </HTML>
  \n";
  exit;
}
################################################################################[파일종류파악]
sub file_type {
    $word = $data;
    if($word =~ /.gif/) {$wtype = "Image";} 
    elsif($word =~ /.jpg/) {$wtype = "Image";} 
    elsif($word =~ /.jpeg/) {$wtype = "Image";} 
    elsif($word =~ /.htm/) {$wtype = "html";} 
    elsif($word =~ /.html/) {$wtype = "html";} 
    elsif($word =~ /.zip/) {$wtype = "arc";} 
    elsif($word =~ /.tar/) {$wtype = "arc";} 
    elsif($word =~ /.bmp/) {$wtype = "Image";} 
    elsif($word =~ /.exe/) {$wtype = "exe";} 
    elsif($word =~ /.doc/) {$wtype = "doc";} 
    elsif($word =~ /.cgi/) {$wtype = "cgi";}
    elsif($word =~ /.ph/) {$wtype = "cgi";}
    elsif($word =~ /.class/) {$wtype = "cgi";} 
    elsif($word =~ /.js/) {$wtype = "script";}  
    elsif($word =~ /.pl/) {$wtype = "cgi";} 
    elsif($word =~ /.ppt/) {$wtype = "doc";} 
    elsif($word =~ /.mp3/) {$wtype = "media";} 
    elsif($word =~ /.mpeg/) {$wtype = "media";} 
    elsif($word =~ /.swf/) {$wtype = "media";} 
    elsif($word =~ /.mpg/) {$wtype = "media";} 
    elsif($word =~ /.asx/) {$wtype = "media";}    
    elsif($word =~ /.txt/) {$wtype = "doc";} 
    elsif($word =~ /.rar/) {$wtype = "arc";} 
    elsif($word =~ /.xls/) {$wtype = "doc";} 
    elsif($word =~ /.hwp/) {$wtype = "doc";} 
    elsif($word =~ /.mid/) {$wtype = "doc";} 
    elsif($word =~ /.ra/) {$wtype = "media";} 
    elsif($word =~ /.ram/) {$wtype = "media";}
    else {$wtype = "unknown"}
 }

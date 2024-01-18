function generateTextTop() {
//if (1==1) {
//document.write
return(
`
<script>
function cp2sch22()
{
   //if(!parent.middle.getListItem) return;   
   if(!getListItem) return;
   

   //var szMid = parent.middle.getListItem();
   var szMid = getListItem();   
   
   if (szMid)
   {
	   test(szMid);

	   // //Cheesy solution for the frames for iframe
		// if (parent.right.frames.length == 0)
		// {
			// parent.right.test(szMid);
		// }
		// else
		// {
			// parent.right.frames[1].test(szMid);
		// }
   }
}
</script>

<form name = "myformtop" method="post" action="/cgi-bin/cgi/ngfop/top.pl">
<input type="hidden" NAME="leftsrc" value="cb"/>
<input type="hidden" NAME="leftvalue" value="blank.xml"/>
<input type="hidden" NAME="leftfname" value="blank.xml"/>
<input type="hidden" NAME="leftfdesc" value=""/>
<input type="hidden" NAME="middlefname" value=""/>
<!-- FM 3/17/7 <table style="height:"100%;" height="100%" width="100%"border="0">
<table style= "xxxxxheight:100%; width:100%; border:0">
-->
<table height="100%" width="100%" border="0">
<tr align="center">

<td>
<SELECT NAME="Extra"
style="text-transform: uppercase; color: navy; background: #C9E8FB;
font-family: Verdana; font-size:12px;">
<OPTION VALUE="-1">Send to
<OPTION VALUE="3">
----------
<OPTION VALUE="4">printer
<OPTION VALUE="1">email
<OPTION VALUE="1">phone app
</SELECT>

<a class="menuitem" title="Execute a command" href="javascript:testAjax(document.myformtop.Extra.options[document.myformtop.Extra.selectedIndex].text);">Go!</a>

<a class="menuitem" title="My Picture" href="javascript:myPicture();"><IMG SRC="./ca1.gif" alt="My Picture" align="middle" width="23" height="25" border="1"></a>
<a class="menuitem" title="copy left to right" href="javascript:cp2sch22();"><IMG SRC="/cgi/ngfop/rarrow1.gif" ALT="copy left to right" align="middle" width="23" height="15" border="1"></a>
<a class="menuitem" title="Create a new schedule or choice board" href="/cgi-bin/cgi/ngfop/other2.pl?htmlname=editschframe.htm&name=blank.xml" target="right">New</a>
<a class="menuitem" title="Edit" href="javascript:editSchedule2();" >Edit</a>
<a class="menuitem" title="Delete" href="javascript:del();">Del</a>
<a class="menuitem" title="Sign Out" href="javascript:top.location='/cgi-bin/cgi/ngfop/signin.pl?action=signout'">Sign Out</a>
<a class="menuitem" title="Help" href="javascript:help();">Help</a>
</td>
</tr>
</table>
</form>
`);
//}
}
function help() {
  alert("___.js: help");
}

function myPicture() {
  src =
    "/cgi-bin/cgi/ngfop/editsch.pl?action=edit&name=blank.xml&htmlname=mypicture.htm";
  //top.frames[2].location=src;
  parent.middle.location = src;
}

function cp2sch22() {
  if (!parent.middle.getListItem) return;

  var szMid = parent.middle.getListItem();
  if (szMid) {
    // Cheesy solution for the frames for iframe
    if (parent.right.frames.length == 0) {
      parent.right.test(szMid);
    } else {
      parent.right.frames[1].test(szMid);
    }
  }
}

function setLeftValue(src, value, fdesc) {
  // FM 10/13/7
  //alert("setLeftValue = "+src+", "+value+", "+fdesc); return;

  document.myform.leftfname.value = value;

  // FM 6/12/4

  document.myform.leftsrc.value = src;
  document.myform.leftvalue.value = value;
  document.myform.leftfdesc.value = fdesc;
}

function openInFrame(url, target) {
  window.open(url, target);
  //     "/cgi-bin/cgi/ngfop/other2.pl?htmlname=editschframe.htm&name=blank.xml",
  //     "right"
  //   );
}

function getLeftFN(action) {
  // FM 6/12/04

  if (action == "clear") {
    //	alert ("clear the global vars!!!");

    document.myform.leftsrc.value = "";
    document.myform.leftvalue.value = "";
    document.myform.leftfname.value = "";
    return;
  }
  // FM 6/12/04

  //var objLeft    = parent.left;
  //var objLeftFrm = parent.left.myform;

  var leftsrc = document.myform.leftsrc.value;
  var leftvalue = document.myform.leftvalue.value;
  var xmlfilename = document.myform.leftfname.value;

  //alert("getLeftFN = "+leftsrc+", "+leftvalue+", "+xmlfilename);

  if (leftsrc == "") {
    xmlfilename = leftvalue;
    return xmlfilename;
  }

  //if (objLeftFrm != null)
  if (/calander/i.test(leftsrc)) {
    var obj = myform.elements.People;
    var kid = obj.options[obj.selectedIndex].text;

    date = document.myform.leftvalue.value;

    var total2 = kid + "/" + date + ".xml";

    xmlfilename = total2;
  }

  return xmlfilename;
}

function getLeftfDesc()
{
	var leftsrc   = document.myform.leftsrc.value;

	if (leftsrc == "")
	{
		return document.myform.leftfdesc.value;
	}

	return "";
}

function del()
{
	var fn  = getLeftFN();
	var desc= getLeftfDesc();

	var response = confirm("Are you sure you want to delete \n"+ desc+"\n("+fn+")?","");
	if (response == false)
		return;

	var str="/cgi-bin/cgi/ngfop/editsch.pl?action=delete&htmlname=delete.htm&name="+fn;

	//top.frames[3].location=str;
	// window.open(str);
 	parent.middle.location=str;
   
   // FM 7/8/8
	//var str = "/cgi-bin/cgi/ngfop/other2.pl?htmlname=left01frame.htm&name=blank.xml"
// FM 1/20/24  var str   = "/cgi-bin/cgi/ngfop/left02.pl?htmlname=leftsch.htm";
	//top.frames[1].location=str;
   
	//parent.left.location=str;
   //parent.left[0].location=str;
   // FM 7/8/8

}

function editSchedule2() {
  var xmlfilename = getLeftFN();
  var usedir = "";
  var student = "Jake";
  //   var student =
  //     document.myform.Students.options[document.myform.Students.selectedIndex]
  //       .text;
  if (student) {
    student = "&student=" + student;
  }

  //alert(xmlfilename)
  // FM 7/8/8
  //usedir = "&usedir=usedir(Sussina)";
  // FM 7/8/8

  // aba programs are in the middle.
  if (top.frames[2].runprograms00) {
    /*******************
   alert("yo0u can edit an aba ___ FM SKip this")
   var obj = top.frames[2].document.myform;
   len = obj.elements.C1.length
   
   var strTot = "";
   for (var iii = 0; iii < obj.elements.C1.length; iii++)
   {
     if (obj.elements.C1[iii].checked)
     {
         strTot += obj.elements.C1[iii].value;

         xmlfilename = strTot;
         usedir = "&usedir=usedir(Sussina)";
         break;
     }
   }
 *********************/
  } else if (
    top.frames[2].document.myform &&
    top.frames[2].document.myform.elements.C1
  ) {
    // Editing an ____.xml from the middle list.

    //if (top.frames[2].runprograms00)
    var obj = top.frames[2].document.myform;
    len = obj.elements.C1.length;
    //var fn = "---";
    //var strTot;
    /******
   for (var iii = 0; iii < obj.elements.C1.length; iii++)
   {
      if (obj.elements.C1[iii].checked)
      {
         strTot += obj.elements.C1[iii].value;

         xmlfilename = strTot;
         
         //usedir = "&usedir=usedir(Sussina)";
         break;
      }
   }
   ******/

    str = parent.middle.getListItem();
    //alert("str = "+ str)

    var szName = ""; //str.match(/<Name>(.+)<\/Name>/i);
    if (szName) {
      szName = szName[1];

      if (szName.indexOf(".xml") != -1) {
        var sz22 = szName.match(/<MK_LISTBOX>(.+)<\/MK_LISTBOX>/i);
        if (sz22) {
          szName = sz22[1];
        }
        // FM 6/4/8
        usedir = "&usedir=usedir(Sussina)";
        // Fm 6/4/8
        alert("your special " + szName + "  " + usedir);
        xmlfilename = szName;
      }
    }
  }

  if (/blank.xml/i.test(xmlfilename)) {
    var strMsg =
      "Click on the radio button to the left of the \nschedule you wish to edit";
    alert(strMsg);
    return;
  }

  if (usedir) {
    // __ = "123.xml, usedir(Sussina)"
    xmlfilename += ",usedir(Sussina)";
  }

  //m 5/11/8 var str = "/cgi-bin/cgi/ngfop/other2.pl?htmlname=editschframe.htm&name="+xmlfilename;
  var str =
    "/cgi-bin/cgi/ngfop/other2.pl?htmlname=editschframe3a.htm&name=" +
    xmlfilename +
    student;

  top.frames[3].location = str;
  //parent.right.location=str;
}

function ShowExtra(szExtra) {
  var str;
  var xmlfilename = getLeftFN();

  if (szExtra == "Add a Student") {
    javascript: editSchedule33("Students.xml");
    return;
  }

  if (szExtra == "List") {
    // FM 06/12/04
    getLeftFN("clear");
    // FM 06/12/04

    var str =
      "/cgi-bin/cgi/ngfop/other2.pl?htmlname=left01frame.htm&name=blank.xml";

    //top.frames[1].location=str;
    parent.left.location = str;

    return;
  }

  if (szExtra == "Schedules") {
    // FM 6/12/4
    getLeftFN("clear");
    // FM 6/12/4

    var str = "/cgi-bin/cgi/ngfop/other2.pl?htmlname=pubschedules.htm";

    //top.frames[1].location=str;
    parent.left.location = str;

    return;
  }

  if (szExtra == "Schedules(2)") {
    // FM 6/12/4
    getLeftFN("clear");
    // FM 6/12/4

    //var str = "/cgi-bin/cgi/ngfop/other2.pl?htmlname=pubschedules.htm"
    var str =
      "/cgi-bin/cgi/ngfop/other2.pl?htmlname=demoFramesetLeftFrame.html";

    //top.frames[1].location=str;
    parent.left.location = str;

    return;
  }

  if (szExtra == "*Matching") {
    var xmlfilename = getLeftFN();
    var student =
      document.myform.Students.options[document.myform.Students.selectedIndex]
        .text;
    var str = "/cgi-bin/cgi/ngfop/schABA22.pl?htmlname=schABA44wh.htm";

    if (student) {
      student = "&student=" + student;
      str += student;
    }

    // FM 2/25/8
    var szDir = "";
    var szFN = xmlfilename;
    myre = /schs\//i;
    if (myre.test(xmlfilename)) {
      szFN = xmlfilename.replace(myre, "");
      //var strUsedir = "&usedir=usedir(../schs)";
      szDir = "../schs";
      //var strFromList = "&action=fromlist(" + fn + ")";
    }
    // Fm 2/25/8
    // FM 6/29/7 javascript:abakit_runprograms00(str, szDir, xmlfilename);
    //javascript:abakit_runprograms00(str, "", xmlfilename);
    javascript: abakit_runprograms00(str, szDir, szFN);
    return;
  }

  /******************/
  // Point and Shoot.
  myre = /\.xml/i;
  if (!myre.test(xmlfilename)) {
    var strMsg =
      "Click on the radio button to the left of the \nschedule you wish to view as " +
      szExtra;
    alert(strMsg);
    return;
  }
  /******************/

  if (szExtra == "Cards") {
    var str =
      "/cgi-bin/cgi/ngfop/cards1.pl" +
      "?htmlname=buscards1.htm&name=" +
      xmlfilename;

    //parent.middle.location= str;
    window.open(str);

    return;
  }

  if (szExtra == "Form") {
    var str =
      "/cgi-bin/cgi/ngfop/sch5.pl" + "?htmlname=form01.htm&name=" + xmlfilename;
    window.open(str);
    return;
  }
  if (szExtra == "Form.a") {
    var str =
      "/cgi-bin/cgi/ngfop/sch5.pl" + "?htmlname=form01.htm&name=" + xmlfilename;
    window.open(str);
    return;
  }

  if (szExtra == "Reward") {
    showSR();
    return;
  }

  if (szExtra == "Left2rt") {
    var str =
      "/cgi-bin/cgi/ngfop/sch5.pl" +
      "?htmlname=left2rt.htm&name=" +
      xmlfilename;
    window.open(str);
    return;
  }

  /* Edit Communication board begin */
  if (szExtra == "----------") {
    var xmlfilename = getLeftFN();
    var xmlname = "&name=" + xmlfilename;
    var str = "/cgi-bin/cgi/ngfop/sch3.pl?htmlname=0combrd.htm" + xmlname;
    parent.middle.location = str;

    return;
  }

  alert(szExtra + " not implemented yet\n FM.");
}

function help() {
  alert("___.js: help");
}

function myPicture() {
  src = "/cgi-bin/cgi/ngfop/editsch.pl?action=edit&name=blank.xml&htmlname=mypicture.htm";
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

function editSchedule2() {
  var xmlfilename = getLeftFN();
  var usedir = "";
  var student ="Jake"
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
    "/cgi-bin/cgi/ngfop/other2.pl?htmlname=editschframe.htm&name=" +
    xmlfilename +
    student;

  top.frames[3].location = str;
  //parent.right.location=str;
}

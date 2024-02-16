function help() {
  alert("___.js: help");
}
function test(ddddd) {
  alert(ddddd);
}

function OnInit()
{
  // alert('.js OnInit')
  // debugger
   var xmlfile = document.myform.name.value;
   if (xmlfile.toLowerCase() == "Students.xml".toLowerCase())
   {
      //alert("editsch.htm::OnInit() xmlfile = " + xmlfile);
      top.frames[0].location.reload()
   }

   var SWMs  = document.myform.SWMs.value;
   //alert(":OnInit() SWMs["+SWMs+"]");

   var szPic = SWMs.match(/(\((.+?)\))/);
   
   // Working On
   var szMatches = SWMs.match(/w\((.+?)\)/);
   //alert("szMatches["+szMatches+"]");
   
   if (szMatches && szMatches[0] && szMatches[1])
   {
      //alert("szMatches[1]["+szMatches[1]+"]");
      atemp  = szMatches[1].split(/\s*,\s*/);
      var obj = document.myform.CW1;
      for (var iii = 0; iii < atemp.length; iii++)
      {
         obj[(atemp[iii])].checked = 1;
      }   
   }
   
   // Mastered
   szMatches = SWMs.match(/m\((.+?)\)/);
   //alert("szMatches["+szMatches+"]");
    
   if (szMatches && szMatches[0] && szMatches[1])
   {
      //alert("szMatches[1]["+szMatches[1]+"]");
      atemp  = szMatches[1].split(/\s*,\s*/);
      var obj = document.myform.CM2;
      for (var iii = 0; iii < atemp.length; iii++)
      {
         obj[(atemp[iii])].checked = 1;
      }   
   }
}

function getList(obj)
{
   var str = "";
      
   // the case of 0 elements
   if (obj === undefined)
      return str;

   if (obj.length === undefined)
   {
      return str;
   }

   str = "(";
   var strMs = "M(";
   var objM = document.myform.elements.CM2;
   for (var iii = 0; iii < obj.length; iii++)
   {
      // Clear
      document.myform.elements.HCW1[iii].value="";
      document.myform.HCM2[iii].value = "";
      if (obj[iii].checked)
      {
         str += iii;
         str += ",";
         document.myform.HCW1[iii].value = '1';
      }
      
      if (objM[iii].checked)
      {
         strMs += iii;
         strMs += ",";
         document.myform.HCM2[iii].value = '1';
      }
   }

   str += ")";
   var str2 = str.replace(/,\)/, ")");

   return str2;
}

function save2(name, desc, student)
{
  debugger
   if (student)
   {
      var xmlfile = document.myform.name.value;
      
      var obj = document.myform.elements.CW1;
      var szList = getList(obj);
      
      var szData = student + " " + xmlfile;
      document.myform.student.value = szData;
      // Fm 6/8/9 var answer = confirm (":save2 "+ desc);
      //desc
      //if (!answer) return;
   }
   
	var w_space = String.fromCharCode(32);
	var bValidName=0;

	for (var iii=0; iii< desc.length; iii++)
	{
		if(desc.charAt(iii) != w_space)
		{
			bValidName = 1;
			break;
		}
	}

	if (!bValidName)
	{
		alert("Please enter a Description.");
		return;
	}

	var type;
   if (/cb/ig.test(name))
	{
		type = "cb";
	}
	else
		type = "sch";

	document.myform.type.value = type;
	document.myform.d0.value = desc;
	document.myform.submit();
}


function decorateRow(str)
{
	for (var iii = 0; iii < myform.elements.R1.length; iii++)
	{
		if (myform.elements.R1[iii].checked)	
		{
			// toggle
			strTime = myform.elements.T1[iii].value;
			if (/Reward/i.test(strTime))
				myform.elements.T1[iii].value = "";
			else
				myform.elements.T1[iii].value = "Reward";

			break;
		}
	}
}


// the cut vars
var	gT1   = "";
var	gHR55 = "";
var	gI55src  = "";
var	gI55w = "";
var	gI55h = "";
var	gR55  = "";

function cutRow()
{
	for (var iii = 0; iii < myform.elements.R1.length; iii++)
	{
		if (myform.elements.R1[iii].checked)	
		{
			gT1   =document.myform.T1  [iii].value;
			gHR55 =document.myform.HR55[iii].value;
			gI55src =document.myform.I55 [iii].src;
			gI55w   =document.myform.I55 [iii].width;
			gI55h   =document.myform.I55 [iii].height;
			gR55  =document.myform.R55 [iii].value;

			//
			// clear row
			document.myform.T1  [iii].value ="";
			document.myform.HR55[iii].value ="";
			document.myform.I55 [iii].src   ="";
			document.myform.I55 [iii].width ="";
			document.myform.I55 [iii].height="";
			document.myform.R55 [iii].value ="";

			//pasteRow();
			//

			break;
		}
	}
}

function pasteRow()
{
	for (var iii = 0; iii < myform.elements.R1.length; iii++)
	{
		if (myform.elements.R1[iii].checked)	
		{
			document.myform.T1  [iii].value = gT1;
			document.myform.HR55[iii].value = gHR55;
			document.myform.I55 [iii].src   = gI55src;
			document.myform.I55 [iii].width = gI55w;
			document.myform.I55 [iii].height= gI55h;
			document.myform.R55 [iii].value = gR55;

			break;
		}
	}
}

function insertRow()
{
	var iRow = 0;
	mylistT1   = new Array();
	mylistR1   = new Array();
	mylistHR55 = new Array();
	mylistI55  = new Array();
	mylistR55  = new Array();

   for (var iii = 0; iii < myform.elements.R1.length; iii++)
   {
	   mylistT1.  push(document.myform.T1  [iii].value);
	   mylistR1.  push(document.myform.R1  [iii].value);
	   mylistHR55.push(document.myform.HR55[iii].value);
	   mylistI55. push(document.myform.I55 [iii].src);
	   mylistR55. push(document.myform.R55 [iii].value);

	   if (myform.elements.R1[iii].checked)	
	   {
		   iRow  = iii;
   	}
   }

	if ((iRow +1)< myform.elements.R1.length)
	{
		// move radio check
		document.myform.T1  [iRow].value = "";
		document.myform.R1  [iRow].value = "";
		document.myform.HR55[iRow].value = "";
		document.myform.I55 [iRow].src   = "";
		document.myform.I55 [iRow].width  = 0;
		document.myform.I55 [iRow].height  = 0;
		document.myform.R55 [iRow].value = "";

		// shift rows down
		for (var iii = iRow; iii < myform.elements.R1.length; iii++)
		{
			// pop
			if ((iii +1)< myform.elements.R1.length)
			{
				document.myform.T1  [(iii+1)].value = mylistT1  [iii%myform.elements.R1.length];
				document.myform.R1  [(iii+1)].value = mylistR1  [iii%myform.elements.R1.length];
				document.myform.HR55[(iii+1)].value = mylistHR55[iii%myform.elements.R1.length];
				document.myform.I55 [(iii+1)].src   = mylistI55 [iii%myform.elements.R1.length];
				document.myform.R55 [(iii+1)].value = mylistR55 [iii%myform.elements.R1.length];
			}
		}
	}

	// debugger
	initializeRows();
}



gIwidth  = 50;//document.myform.I55[0].width;
gIheight = 50;//document.myform.I55[0].height;

function test(src)
{
	//debugger
//	alert(document.myform.I55[1].height);
	var szName = src.match(/<Name>(.+)<\/Name>/i);
	var szPic = src.match(/<Picture>(.+)<\/Picture>/i);

	if (szPic)
	{
		szPic = szPic[1];
	}
	else
	{
		szPic = "";
	}

	if (szName)
	{
		szName = szName[1];
	}
	else
	{
		szName = "";
	}

	for (var iii = 0; iii < myform.elements.R1.length; iii++)
	{
		if (myform.elements.R1[iii].checked)	
		{
			if (szName != "")
				document.myform.R55[iii].value = szName;

			if (szPic != "")
			{

				document.myform.HR55[iii].value = szPic;
				document.myform.I55[iii].width  = gIwidth;
				document.myform.I55[iii].height = gIheight;
				document.myform.I55[iii].src    = szPic;
			}
		}
	}
}	// end

// this was in the bottome script tag. ????
gIwidth  = 10;//document.myform.I55[0].width;
gIheight = 10;//document.myform.I55[0].height;

function initializeRows()
{
	gIwidth  = 40;//document.myform.I55[0].width;
	gIheight = 40;//document.myform.I55[0].height;

	var szhRow;
   
   var iLen =document.getElementsByName("R1").length;
      
	//for (var iii = 0; iii < myform.elements.R1.length; iii++)
   for (var iii = 0; iii < iLen; iii++)
	{
		szhRow = document.myform.HR55[iii].value;
		if (szhRow == "")
		{
			document.myform.I55[iii].width  = 0;
			document.myform.I55[iii].height = 0;
		}
		else
		{
			document.myform.I55[iii].width  = gIwidth;
			document.myform.I55[iii].height = gIheight;
		}
	}
}

// initializeRows();
// if (parent.SetHeadValue)
// {
//     <description>
// 		var desc = "<DESCRIPTION>";
//     </description>
// 	parent.SetHeadValue("d0", desc);
// }


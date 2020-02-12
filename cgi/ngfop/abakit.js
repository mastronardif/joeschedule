/*
 * $Log: ua.js,v $
 * Revision 1.9  2009/05/16 14:06:21  fxm
 * fix 
 *
 * Revision 
 * fix line endings
 *
 * Revision 1.7  2008/07/23 16:52:52  
 * use CVS Log for revision history
 *
 *
 */


function abakit_runprograms(argurl, pubdir, desc)
{
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
   
   // Form Vars
   var obj = document.myform;
   var str = "";
   var strTot = "";

   // Check count.
   var bbb=0;

// the case of 1 elements
if (obj.elements.C1.length === undefined)
{
   if (obj.elements.C1.checked)
   {
      strTot += obj.elements.C1.value;
      strTot += ",";
      bbb=1;
   }
}
else
{
   for (var iii = 0; iii < obj.elements.C1.length; iii++)
   {
        if (obj.elements.C1[iii].checked)
        {
                strTot += obj.elements.C1[iii].value;
                strTot += ",";

                // FM Don't forget to put a limit of five here!
                bbb=1;
        }
   }
}
   
   if(bbb==0)
   {
		if (document.myform.xmlfilename.value == "blank.xml")
			alert ("No programs selected.");
		else
		   alert ("No programs selected.\n Please select the programs you would like to run.");
		
        return;
   }

   if(bbb==1)
   {
      var url = argurl;

      if (pubdir)
      {
	      url += "&usedir="+pubdir;
	   }
	
      url += "&action=fromlist("+strTot + ")";

      poptastic(url, desc);
   }
}

function abakit_runprograms00(argurl, pubdir, list)
{
   var url = argurl;

   if (pubdir)
      url += "&usedir=usedir("+pubdir+")";


   if (list.length)
      url += "&action=fromlist("+list + ")";

   poptastic(url, 'list');
}

function abakit_shuffle(arIn)
{
  // Durstenfeld's Permutation Algorithm
  var J, K, Temp;
  var arOut;
  arOut = arIn;
  for(J = arOut.length-1; J >= 0; J--){
    K = parseInt( (J + 1) * Math.random() ) // random number 0 - J

    Temp = arOut[J]
    arOut[J] = arOut[K]
    arOut[K] = Temp
  }

  return(arOut);
}

function poptastic(url, title)
{
   if (url)
   {
      newwindow=window.open(url, title);
      
      if (window.focus) {newwindow.focus()}
   }
}

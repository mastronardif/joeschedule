/*
 * $Log: itouchjs,v $
 * Revision 1.9  2009/10/24  fxm
 * fix
 *
 * Revision
 * fix line endings
 *
 * Revision 1.7  2009/07/23 16:52:52
 * use CVS Log for revision history
 *
 *
 */

var gRows = new Array();
var gRowsLength = 0;
var gRows = new Array();

function itOnInit()
{
//return;
   var iRow=0;
   var mytable=document.getElementById("tableId");
   for(var ii=0; ii < mytable.rows.length; ii++)
   {
      gRows[iRow] = mytable.rows[ii].innerHTML;
      iRow++;
   }
   gRowsLength=mytable.rows.length;
}

var gBodycolor='rgb(24, 201, 92)';
var colorforgnd = gBodycolor;//'rgb(249, 201, 92)'; //'#F5F3E4'; //'#00FFFF'; // .windowbg; ///
var gObj = null;
var gStr = null;
var gMany = 1;

function RestoreList()
{
   gMany=1;
//alert('RestoreList');
//javascript:location.reload(true)
//return;

   var iRow=0;
   var mytable=document.getElementById("tableId");
   for(var ii=0; ii < mytable.rows.length; ii++)
   {
      mytable.deleteRow(-1) 
   }

   
   // restore
   for(var ii=1; ii < gRowsLength; ii++)
   {
      var newrow=mytable.insertRow(-1) //add new row to end of table
	newrow.innerHTML=gRows[ii];
	//var y=newrow.insertCell(0);
	
      //newrow.innerHTML="asdf";
	newrow.innerHTML=gRows[ii];
//      var newCell = newrow.insertCell(0);
//	newCell.innerHTML = 'Hello World!';
//	newCell.innerHTML = gRows[ii]; //'Hello World!';
   }
   
}


function mkblack22(obj, pic)
{
//alert(obj.innerHTML);
//alert(gMany);
//   alert(document.getElementById('tableId').getElementsByTagName('tbody')[0].getElementsByTagName('tr').length);
//return;
/**********
   if (gMany==0)
   {
      
      gMany=1;
      return RestoreList()
   }

   gMany=0;


   if (gObj)
      gObj.bgColor = colorforgnd;

   obj.bgColor= "black";
***********/
   var rows = document.getElementById('tableId').getElementsByTagName('tbody')[0].getElementsByTagName('tr').length;
   var mytable=document.getElementById("tableId");

   for(var ii=mytable.rows.length; ii>2; ii--)
   {
      mytable.deleteRow(-1)
   }

   var sz='<td onclick="RestoreList();" align="left" height="1">'
   sz+=obj.innerHTML
   sz+="</td>"
   mytable.rows[1].innerHTML = sz; //obj.innerHTML; //mytable.rows[1].innerHTML;
   gObj = obj;
   gStr = pic;
gMany=333;

}



function mkblack(obj, pic)
{
if (gMany==333)
   return;

   if (gMany==0)
   {
      return RestoreList()
   }

   gMany=0;


   if (gObj)
      gObj.bgColor = colorforgnd;

   obj.bgColor= "black";
 
   var rows = document.getElementById('tableId').getElementsByTagName('tbody')[0].getElementsByTagName('tr').length;
   var mytable=document.getElementById("tableId");
 
   for(var ii=mytable.rows.length; ii>2; ii--)
   {
      mytable.deleteRow(-1) 
   }

   var sz='<td onclick="mkblack(this, \'/cgi/ngfop/pics/book/gd017.jpg\');" align="left" height="1">'
   sz+=obj.innerHTML
   sz+="</td>"
   mytable.rows[1].innerHTML = sz; //obj.innerHTML; //mytable.rows[1].innerHTML;   
   gObj = obj;
   gStr = pic;
}

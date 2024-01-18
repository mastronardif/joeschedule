function help() {
  alert("___.js: help");
}

function myPicture() {
  alert(
    "user supplied picture.\n Go somewhere get a picture and paste it here.\n You can have local pictures this way and or picture from anywhere on the net."
  );

  src =
    "/cgi-bin/cgi/ngfop/editsch.pl?action=edit&name=blank.xml&htmlname=mypicture.htm";
  //top.frames[2].location=src;
  parent.middle.location = src;
}

function cp2sch22() {
  alert("jsdbugtop: cp2sch22");
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

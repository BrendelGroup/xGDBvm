function showDef(def){
 //document.getElementById('defline').value = def;
  var showToolTip = 1;
  // showToolTip variable intended to provide a user control for diasabling tooltips in future expansion
  if(showToolTip){ Tip(def,BGCOLOR,'#D1EFE0',BORDERCOLOR,'#77BF9E',BORDERSTYLE,'dashed',CENTERMOUSE,true,OPACITY,100,WIDTH,300); }
}
function hideDef(){
}

function displayTE(db,ver,gi,l,r) {
  //add by Qunfeng Dong to display the Transposon image
  var Hlink;
  var Wname;
  Wname = "TE_" + gi + "_" + l + "_" + r;
  Hlink = CGIPATH + "displayTE.pl?db=" + db +"&dbid=" + ver + "&hits=" + gi + ":" + l + ":" + r;
  window.open(Hlink,Wname);
}

function showTRANS(){
  if ((document.guiFORM.r_pos.value - document.guiFORM.l_pos.value) > 50000){
    window.open(CGIPATH + "tview_window.pl?", 'chooser','resizable=no,screenX=450,screenY=300,toolbar=no,status=no,scrollbars=yes,location=yes,menubar=no,width=150,height=200');
  }else{
    window.open(CGIPATH + "showCluster.pl?", '','resizable=yes,screenX=0,screenY=0,toolbar=no,status=yes,location=no,menubar=no,directories=no');
  }
}

function showAltTRANS(){
  if ((document.guiFORM.bac_rpos.value - document.guiFORM.bac_lpos.value) > 50000){
    window.open(CGIPATH + "tview_window.pl?", 'chooser','resizable=no,screenX=450,screenY=300,toolbar=no,status=no,scrollbars=yes,location=yes,menubar=no,width=150,height=200');
  }else{
    window.open(CGIPATH + "showCluster.pl?", '','resizable=yes,screenX=0,screenY=0,toolbar=no,status=yes,location=no,menubar=no,directories=no');
  }
}


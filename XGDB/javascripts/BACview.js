// GCview.js -- javascript to control the region navigation tool

//Constants
var WSIZES   = new Array(1000,2000,5000,10000,20000,50000,100000,150000);

function jumpLEFT(){
  var Wsize = eval(document.guiFORM.bac_rpos.value) - eval(document.guiFORM.bac_lpos.value);
  var l_pos = Math.max(eval(document.guiFORM.bac_lpos.value) - Math.floor(Wsize/2),1);
  var r_pos = l_pos + Wsize;
  
  document.guiFORM.bac_lpos.value = l_pos;
  document.guiFORM.bac_rpos.value = r_pos;

  document.guiFORM.submit();
  return 1;
}

function jumpRIGHT(){
  var Wsize = eval(document.guiFORM.bac_rpos.value) - eval(document.guiFORM.bac_lpos.value);
  var l_pos = eval(document.guiFORM.bac_lpos.value) + (Wsize / 2);
  var r_pos = l_pos + Wsize;

  document.guiFORM.bac_lpos.value = l_pos;
  document.guiFORM.bac_rpos.value = r_pos;

  document.guiFORM.submit();
  return 1;
}

function setWINDOW(WsizeINDX){
  var halfReg  = Math.floor(WSIZES[WsizeINDX] / 2);
  var l_pos = Math.max(Math.floor((eval(document.guiFORM.bac_lpos.value) + eval(document.guiFORM.bac_rpos.value)) / 2) - halfReg,1);
  var r_pos = l_pos + WSIZES[WsizeINDX] - 1;

  document.guiFORM.wsize.value = WsizeINDX;
  document.guiFORM.bac_lpos.value = l_pos;
  document.guiFORM.bac_rpos.value = r_pos;

  document.guiFORM.submit();
  return 1;
}


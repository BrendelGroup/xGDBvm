// Rview.js -- javascript to control the region navigation tool

//Constants
var WSIZES   = new Array(1000,2000,5000,10000,20000,50000,100000,150000);

function jumpLEFT(){
  var Wsize = document.guiFORM.r_pos.value - document.guiFORM.l_pos.value;
  var l_pos = Math.max(document.guiFORM.l_pos.value - Math.floor(Wsize/2),0);
  var r_pos = l_pos + Wsize;
  
  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  submitTYPE(2);
  return 1;
}

function jumpRIGHT(){
  var Wsize = document.guiFORM.r_pos.value - document.guiFORM.l_pos.value;
  var l_pos = Math.max(eval(document.guiFORM.l_pos.value) + Math.floor(Wsize / 2),0);
  var r_pos = l_pos + Wsize;

  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  submitTYPE(2);
  return 1;
}

function setWINDOW(WsizeINDX){
  var halfReg  = Math.floor(WSIZES[WsizeINDX] / 2);
  var l_pos = Math.max(Math.floor((eval(document.guiFORM.l_pos.value) + eval(document.guiFORM.r_pos.value)) / 2) - halfReg,0);
  var r_pos = l_pos + WSIZES[WsizeINDX];

  document.guiFORM.wsize.value = WsizeINDX;
  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  submitTYPE(2);
  return 1;
}



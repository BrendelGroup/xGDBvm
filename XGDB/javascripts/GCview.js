// GCview.js -- javascript to control the region navigation tool

//Constants
var WSIZES   = new Array(1000,2000,5000,10000,20000,50000,100000,150000);

function jumpLEFT(){
  var Wsize = eval(document.guiFORM.r_pos.value) - eval(document.guiFORM.l_pos.value);
  var chr   = document.guiFORM.chr.selectedIndex;
  var l_pos = Math.max(eval(document.guiFORM.l_pos.value) - Math.floor(Wsize/2),1);
  var r_pos = Math.min(l_pos + Wsize,ChrLen[chr]);
  
  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  document.guiFORM.submit();
  return 1;
}

function jumpRIGHT(){
  var Wsize = eval(document.guiFORM.r_pos.value) - eval(document.guiFORM.l_pos.value);
  var chr   = document.guiFORM.chr.selectedIndex;
  var l_pos = Math.min(Math.max(eval(document.guiFORM.l_pos.value) + Math.floor(Wsize / 2),1),ChrLen[chr] - Wsize);
  var r_pos = Math.min(l_pos + Wsize,ChrLen[chr]);

  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  document.guiFORM.submit();
  return 1;
}

function setWINDOW(WsizeINDX){
  var halfReg  = Math.floor(WSIZES[WsizeINDX] / 2);
  var chr   = document.guiFORM.chr.selectedIndex;
  var l_pos = Math.min(Math.max(Math.floor((eval(document.guiFORM.l_pos.value) + eval(document.guiFORM.r_pos.value)) / 2) - halfReg,1),ChrLen[chr] - WSIZES[WsizeINDX]);
  var r_pos = Math.min(l_pos + WSIZES[WsizeINDX] - 1,ChrLen[chr]);

  document.guiFORM.wsize.value = WsizeINDX;
  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  document.guiFORM.submit();
  return 1;
}


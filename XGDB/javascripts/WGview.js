// Gview.js -- javascript to control the selection or a region on the ATmap whole genome density map

//Sniffer
IE4 = (document.all)?true:false;
NS4 = (document.layers)?true:false;
DOM = ((document.getElementById)&&(!IE4))?true:false;

//Constants
var SCALE    = 52881.9215;
var WSIZES   = new Array(1000,2000,5000,10000,20000,50000,100000,150000);

//** I Hate NS4 (Somethings still not working with the mouse capture)

function showRegion(chr){
  var halfReg  = Math.floor(WSIZES[document.guiFORM.wsize.value] / 2);

  if(IE4){
    base = Math.floor((event.offsetX-30)*SCALE);
  }
  l_pos = Math.min(Math.max(base - halfReg,1),ChrLen[chr-1]-(halfReg*2));
  r_pos = Math.min(l_pos + (halfReg*2),ChrLen[chr-1]);
  
  if(IE4){
    document.guiFORM.chr.selectedIndex = chr-1;
    document.guiFORM.l_pos.value = l_pos;
    document.guiFORM.end.value = r_pos;
  }
  window.status = 'Chr:'+chr+', base:'+l_pos;
  return true;
}

function hideRegion(){
  window.status = '';
  return true;
}

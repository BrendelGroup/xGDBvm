var _loaded = 1;

function setIMGW(){
 var gFRAME = frames["clgraph"];
 var imgw = (gFRAME.innerWidth)?gFRAME.innerWidth:(gFRAME.document.documentElement && gFRAME.document.documentElement.clientWidth)?gFRAME.document.documentElement.clientWidth:gFRAME.document.body.clientWidth;
 imgw = imgw - 20;

 if(location.href.match(/imgW=\d+/)){
  location.replace(location.href.replace(/imgW=\d+/,"imgW=" + imgw));
 }else{
  location.replace(location.href + "&imgW=" + imgw);
 } 
} 

function mo(element,pgsID,num){
  clinfo.mo(element,pgsID,num);
  clinfoPlus.mo(element,pgsID,num);
}

function init(){
  while(! clgenomeseq){
    window.setTimeout("init();",10);
  }
  clqseq.init();
}

window.onload=function(){init();};


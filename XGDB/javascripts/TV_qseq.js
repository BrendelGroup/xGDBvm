function init(){
  var docWidth = (document.body.offsetWidth > document.body.scrollWidth)?document.body.offsetWidth:document.body.scrollWidth;

  setScroll();
  if(window.onscroll){
    window.onscroll=function(){doScroll();};
  }else{
    searchScroll();
  }
  window.onresize=function(){setScroll();};
}

function doScroll(){
  var top = (window.pageYOffset)?window.pageYOffset:(document.documentElement && document.documentElement.scrollTop)?document.documentElement.scrollTop:document.body.scrollTop;
  var left = (window.pageXOffset)?window.pageXOffset:(document.documentElement && document.documentElement.scrollLeft)?document.documentElement.scrollLeft:document.body.scrollLeft;
  var docWidth = (document.body.offsetWidth > document.body.scrollWidth)?document.body.offsetWidth:document.body.scrollWidth;

  parent.frames["clgraph"].scrollMARKER(left / docWidth); 
  parent.frames["clgenomeseq"].scrollTo(left,0);
  parent.frames["clqnames"].scrollTo(0,top);
}

function searchScroll(){
  doScroll();
  window.setTimeout("searchScroll();",1);
}

function setScroll(){
  var viewWidth = (self.innerWidth)?self.innerWidth:(document.documentElement && document.documentElement.clientWidth)?document.documentElement.clientWidth:document.body.clientWidth;
  var docWidth = (document.body.offsetWidth > document.body.scrollWidth)?document.body.offsetWidth:document.body.scrollWidth;
  parent.frames["clgraph"].placeMark(viewWidth / docWidth);
}


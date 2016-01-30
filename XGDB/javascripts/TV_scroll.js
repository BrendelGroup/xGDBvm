var _loaded = 1;
var cur_mlft = 0;
var cur_mrgt = 0;

function drawFunction(){
  var markLFT = -2 +  parseInt(parent.frames["clgraph"].document.getElementById('scrollMarker').style.left);
  var markRGT = 4 + markLFT + parseInt(parent.frames["clgraph"].document.getElementById('scrollMarker').style.width);
  var viewWidth = parseInt((self.innerWidth)?self.innerWidth:(document.documentElement && document.documentElement.clientWidth)?document.documentElement.clientWidth:document.body.clientWidth);

  if((markLFT != cur_mlft) || (markRGT != cur_mrgt)){
//window.alert("mRGT = " + markRGT);
    jg.clear();
    jg.drawLine(0,35,markLFT,0);
    jg.drawLine(markRGT,0,viewWidth,35);
    jg.paint();

    cur_mlft = markLFT;
    cur_mrgt = markRGT;
  }
}

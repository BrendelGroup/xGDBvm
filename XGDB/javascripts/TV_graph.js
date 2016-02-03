var cur_mlft = 0;
var cur_mrgt = 0;

function mo(element,pgsID,num){
  return parent.mo(element,pgsID,num);
}

function placeMark(pct){
  var marker = document.getElementById('scrollMarker').style;
  marker.width = (((document.getElementById('tview').width - 40) * pct)-1) + "px";
  marker.display = 'block';
}

function scrollMARKER(pct){
  document.getElementById('scrollMarker').style.left = (19 + ((document.getElementById('tview').width - 40) * pct)) + "px";

  var markLFT = parseInt(document.getElementById('scrollMarker').style.left);
  var markRGT = markLFT + parseInt(document.getElementById('scrollMarker').style.width);
  var viewWidth = parseInt((self.innerWidth)?self.innerWidth:(document.documentElement && document.documentElement.clientWidth)?document.documentElement.clientWidth:document.body.clientWidth);

  if((markLFT != cur_mlft) || (markRGT != cur_mrgt)){
    jg.clear();
    jg.drawLine(0,24,markLFT,0);
    jg.drawLine(markRGT + 2,0,viewWidth - 1,24);
    jg.paint();

    cur_mlft = markLFT;
    cur_mrgt = markRGT;
  }
}

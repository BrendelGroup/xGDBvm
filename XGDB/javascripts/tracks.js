// javascript for Tracks - Matt Wilkerson, Iowa State University, 2003

var browser_type = navigator.appName;
var displayshow, displayhide;

displayhide = "none";
if (browser_type == "Netscape" || browser_type == "Mozilla"){
  displayshow = "table-row";
}else{
  displayshow = "block";
}

var agt=navigator.userAgent.toLowerCase();
var is_mac    = (agt.indexOf("mac")!=-1);



function nothing (){
}

function godown(i){
  if (i < tracksArr.length-1){ // not last track
    movetrack(i, i+1);
    retrack();
    if (is_mac){
      submitTYPE(2);
    }else{
      pass_extra();
    }
  }
}

function goup(i){
  if (i > 0){ // not first track
    movetrack(i, i-1);
 
    retrack();
    if (is_mac){
      submitTYPE(2);
    }else{
      pass_extra();
    }
  }
}

function swap_ARRAY_ELEMENTS(ary,i,j){
  var currentvalue;
  currentvalue = ary[i];
  ary[i] = ary[j];
  ary[j] = currentvalue;
}

function swap_OBJ_FIELD(field,obj1,obj2){
  var currentvalue;
  currentvalue = obj1[field];
  obj1[field] = obj2[field];
  obj2[field] = currentvalue;
}

function movetrack(i,j){
  swap_ARRAY_ELEMENTS(tracksArr,i,j);
  swap_ARRAY_ELEMENTS(openArr,i,j);
  swap_ARRAY_ELEMENTS(extraArr,i,j);

  swap_OBJ_FIELD('src',document.images["image" + i],document.images["image" + j]);
  swap_OBJ_FIELD('useMap',document.images["image" + i],document.images["image" + j]);  
  swap_OBJ_FIELD('display',document.images["image" + i].style,document.images["image" + j].style);
  swap_OBJ_FIELD('value',document.Track_frm.elements["trackname" + i],document.Track_frm.elements["trackname" + j]);
  swap_OBJ_FIELD('bgColor',document.getElementById("track" + i),document.getElementById("track" + j));
  swap_OBJ_FIELD('background',document.Track_frm.elements["trackname" + i].style,document.Track_frm.elements["trackname" + j].style);

  store_extra();

  swap_OBJ_FIELD('innerHTML',document.getElementById('extra'+i),document.getElementById('extra'+j));
  swap_OBJ_FIELD('display',document.getElementById('extra'+i).style,document.getElementById('extra'+j).style);

  restore_extra();
}

function retrack(){
  var tracksordert = "";
  var tracksopent = "";
  var k;
  for(k=0;k<tracksArr.length;k++){
    tracksordert = tracksordert + tracksArr[k] + ",";
    tracksopent = tracksopent + openArr[k] + ",";
    if (openArr[k] == "1"){
      document.Track_frm.elements["opencheck" + k].checked = true;
    }else{
      document.Track_frm.elements["opencheck" + k].checked = false;
    }
    if (extraArr[k] == "1"){
      document.getElementById('extra'+k).style.display = displayshow;
    }else{
      document.getElementById('extra'+k).style.display = displayhide;
    }
  }
  document.guiFORM.trackORDER.value = tracksordert.substring(0,tracksordert.length-1);
  document.guiFORM.trackVISIBLE.value = tracksopent.substring(0,tracksopent.length-1); // for cookie
}

function closedown(i){
  currentvalue = tracksArr[i];
  currentopen = openArr[i];
  currentextra = extraArr[i];
  currenttxt = document.Track_frm.elements["trackname" + i].value;
  currentcolor = document.getElementById("track" + i).bgColor;
  temp_trackhtml = document.getElementById('extra'+i).innerHTML;
  store_extra();
  if (currentopen == "1"){ 
    //## close track ##
    for(x=i;x<tracksArr.length-1;x++){
      y = x + 1;
      tracksArr[x] = tracksArr[y];
      openArr[x]   = openArr[y];
      extraArr[x]  = extraArr[y];
      document.images["image" + x].useMap = document.images["image" + y].useMap;
      if(openArr[y] == "1"){
        document.images["image" + x].src = document.images["image" + y].src;
	document.images["image" + x].style.display = displayshow;
      }else{
        document.images["image" + x].style.display = displayhide;
      }
      document.getElementById("track" + x).bgColor = document.getElementById("track" + y).bgColor;
      document.getElementById("track" + y).bgColor = currentcolor;
      document.Track_frm.elements["trackname" + x].style.background = document.Track_frm.elements["trackname" + y].style.background;
      document.Track_frm.elements["trackname" + y].style.background = currentcolor;
      document.getElementById('extra'+x).innerHTML = document.getElementById('extra'+y).innerHTML;
      document.Track_frm.elements["trackname" + x].value = document.Track_frm["trackname" + y].value;
    }
    z = tracksArr.length - 1;
    tracksArr[z] = currentvalue;
    openArr[z] = "0";
    document.Track_frm.elements["trackname" + z].value = currenttxt;
    document.images["image" + z].style.display = displayhide;
    document.getElementById('extra'+z).innerHTML = temp_trackhtml;
    extraArr[z] = 0; // extra is closed
  }else{ 
    //## open track ##
    openArr[i] = "1";
    image_toggle(tracksArr[i],imageArr[tracksArr[i]],imagemapArr[tracksArr[i]]);
  }
  retrack();
  restore_extra();
  if(is_mac){
    submitTYPE(2);
  }else{
    pass_extra();
  }
}

function reloadTracks(){
 if(document.getElementById("track0")){
  //## preserves tracks when using back button in browser
  tracksArr = document.guiFORM.customORDER.value.split(",");
  openArr   = document.guiFORM.customVISIBLE.value.split(",");

  reloadArr = document.guiFORM.trackDATA.value.split("|");
  for(i=0;i<reloadArr.length;i++){
    pair = reloadArr[i].split("=");
    tempArr[pair[0]] = pair[1];
  }

  for(x=0;x<tracksArr.length;x++){
    y = tracksArr[x];
   /*document.getElementById("track" + x).bgColor = colorsArr[y];*/
   /* document.Track_frm.elements["trackname" + x].style.background = colorsArr[y];*/
    document.Track_frm.elements["trackname" + x].value = namesArr[y];
 
   if (is_mac == "false"){
      document.getElementById('extra'+x).innerHTML = extraHTML[y];
    }
  }

  restore_extra();

  for(x=0;x<tracksArr.length;x++){
    if(openArr[x] == "1"){
      image_toggle(tracksArr[x],imageArr[tracksArr[x]],imagemapArr[tracksArr[x]]);
    }else{
      document.images["image" + x].style.display = displayhide; //##############
    }
  }
 }
}

function extratrack(x){
  if (extraArr[x]){ 
    //## close extra ##
    document.getElementById('extra'+x).style.display = displayhide;
    extraArr[x] = 0;
  }else{ 
    //## open extra ##
    document.getElementById('extra'+x).style.display = displayshow;
    extraArr[x] = 1;
  }
}

function image_toggle(resource_id,imgsrc,mapname){
  for (i=0;i<tracksArr.length;i++){
    if (tracksArr[i] == resource_id){
      trackIND = i;
    }
  }

  document.images["image" + trackIND].src = imgsrc;
  document.images["image" + trackIND].style.display = displayshow;
  document.images["image" + trackIND].useMap = "#" + mapname;

  document.Track_frm.elements["opencheck" + trackIND].checked = true;

  imageArr[resource_id]    = imgsrc;
  imagemapArr[resource_id] = mapname;
  openArr[trackIND]        = "1";

  retrack();
  pass_extra();
}

//###########################################################################
// javascripts for persistent forms in innerHTML
//    -changed divs - October, 2003 Matt Wilkerson, Iowa State University
//###########################################################################
function store_extra(){
  for(i=0; i < document.Track_frm.length; i++){
    if((document.Track_frm.elements[i].type == "radio") || (document.Track_frm.elements[i].type == "checkbox")){
      tempArr[document.Track_frm.elements[i].name + "_" + document.Track_frm.elements[i].value] = document.Track_frm.elements[i].checked;
    }else if(document.Track_frm.elements[i].type == "select"){
      tempArr[document.Track_frm.elements[i].name] = document.Track_frm.elements[i].selectedIndex;
    }else{ //text fields
      tempArr[document.Track_frm.elements[i].name] = document.Track_frm.elements[i].value;
    }
  }
}

function restore_extra(){ // I love Mozilla
 for(i=0;i<document.Track_frm.length;i++){
   ename = document.Track_frm.elements[i].name;
   if(!(ename.match("trackname")) && !(ename.match("opencheck"))) {
    if((document.Track_frm.elements[i].type == "radio") || (document.Track_frm.elements[i].type == "checkbox")){
       TAvalue = tempArr[document.Track_frm.elements[i].name + "_" + document.Track_frm.elements[i].value];
       //alert(document.Track_frm.elements[i].name + document.Track_frm.elements[i].value + "=" + TAvalue + ".");
       if(TAvalue==1 || TAvalue=="true"){ // 1 for within page, true for between pages
         //document.Track_frm.elements[i].checked = TAvalue;
	 document.Track_frm.elements[i].click();
       }
    }else if(document.Track_frm.elements[i].type == "select"){
      document.Track_frm.elements[i].selectedIndex = tempArr[document.Track_frm.elements[i].name];
    }else{
      document.Track_frm.elements[i].value = tempArr[document.Track_frm.elements[i].name];
    }
   }
  }
 }

function pass_extra(){
  store_extra();
  document.guiFORM.trackDATA.value = "";
  for(var i in tempArr){
    if(i != ""){
      if(document.guiFORM.trackDATA.value != ""){
        document.guiFORM.trackDATA.value = document.guiFORM.trackDATA.value + "|" + i + "=" + tempArr[i];
      }else{
        document.guiFORM.trackDATA.value = i + "=" + tempArr[i];
      }
    }
  }
  statecookie = getCookie(xgdb_state);
  cookieArr = statecookie.split("&");
  cookieArr[6] = document.guiFORM.trackORDER.value;
  cookieArr[7] = document.guiFORM.trackVISIBLE.value;
  cookieArr[8] = document.guiFORM.trackDATA.value;
  thisDate = new Date();
  thisDate.setMonth(thisDate.getMonth() + 1);
  document.cookie = xgdb_state + "=" + cookieArr.join("&") + "; expires=" + thisDate.toGMTString() + "; path=/;";
}

function getCookie(name){
  var dc = document.cookie;
  var prefix = name + "=";
  var begin = dc.indexOf("; " + prefix);
  if(begin == -1){
    begin = dc.indexOf(prefix);
    if (begin != 0) return null;
  }else{
    begin += 2;
  }
  var end = document.cookie.indexOf(";", begin);
  if(end == -1){
    end = dc.length;
  }
  return unescape(dc.substring(begin + prefix.length, end));
}

//function setCookie(name, value, expires, path, domain, secure){
//  document.cookie = name + "=" + escape(value) +
//	           ((expires) ? "; expires=" + expires.toGMTString() : "") +
//	     	   ((path) ? "; path=" + path : "") +
//	           ((domain) ? "; domain=" + domain : "") +
//       	   ((secure) ? "; secure" : "");
//}

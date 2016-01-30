var _loaded = 1;

function setIMGW(){
 var imgw = document.body.clientWidth - 245;
 if(document.guiFORM.imgW.value != imgw){
//window.alert("imgw = " + imgw);
//window.alert("guiFORM.imgW.value = " + document.guiFORM.imgW.value);
   document.guiFORM.imgW.value = imgw;
   document.guiFORM.submit();
 }
} 


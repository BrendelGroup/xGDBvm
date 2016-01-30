$(document).ready(function() {
  $('div.showhide> div').hide();
  $('div.showhide> a').click(function() {
	$(this).next().next().slideToggle('fast');
  });
});
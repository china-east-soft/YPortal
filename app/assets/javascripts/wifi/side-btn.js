// scroll side button
var showFloat = false;
$('#float_section').css('opacity', 0);
$('#float_section').show();
$('#gotop').on('click', function(){
  window.scrollTo(0, 0);
});
$(function(){
  $(window).on('scroll', function(){
    if($(window).scrollTop() > 300){
      if(showFloat) return;
      showFloat = true;
      $('#float_section').animate({
        opacity: 1
      }, 500, 'easeOutBack');
    }
    if($(window).scrollTop() <= 300){
      if(!showFloat) return;
      showFloat = false;
      $('#float_section').animate({
        opacity:0
      }, 500, 'easeOutBack');
    }
  });
}
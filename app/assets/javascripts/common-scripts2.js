var Script = function () {


//    tool tips

    $('.tooltips').tooltip();

//    popovers

    $('.popovers').popover();

//    bxslider

    $('.bxslider').show();
    $('.bxslider').bxSlider({
        minSlides: 2,
        maxSlides: 2,
        slideWidth: 276,
        slideMargin: 20
    });

}();

$( document ).ready(function() {
  $('.carousel').carousel({
    interval: 3000
  })    
})
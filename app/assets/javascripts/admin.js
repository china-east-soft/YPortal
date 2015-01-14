//= require jquery
//= require jquery_ujs
//= require jquery-1.8.3.js
//= require jquery.ui.datepicker.js
//= require bootstrap.min.js
//= require jquery.dcjqaccordion.2.7.js
//= require jquery.scrollTo.min.js
//= require jquery.nicescroll.js
//= require respond.min.js

//= require common-scripts.js
//= require count.js
//= require jcrop.js

//= require jquery.dragsort-0.5.1.js
//= require gritter
//= require datepicker.js
//= require jquery.placeholder.js
//= require jquery.cityselect.js
//= require city.min.js
//= require jquery.bxslider.js
//= require jquery.validate.js
//= require highcharts.js
//= require_tree ./plugins


$(document).on("ready page:change", function() {
  $('[data-toggle="popover"]').popover();
});

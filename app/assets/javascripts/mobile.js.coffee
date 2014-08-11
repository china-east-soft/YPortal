#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require bootstrap.min
#= require jquery.autosize
#= require jquery.validate
#= require nprogress

$(document).on 'page:update', ->
  $('[data-behaviors~=autosize]').autosize()

$(document).on 'page:fetch', ->
  NProgress.start()
$(document).on 'page:change', ->
  NProgress.done()
$(document).on 'page:restore', ->
  NProgress.remove()




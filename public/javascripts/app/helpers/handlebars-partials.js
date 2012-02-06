/* we need to wrap this in a document ready to ensure JST is accessible */
$(function(){
  Handlebars.registerPartial('status-message', Handlebars.compile(JST['status-message']))
})
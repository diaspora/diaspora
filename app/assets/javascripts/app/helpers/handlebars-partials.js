/* we need to wrap this in a document ready to ensure JST is accessible */
$(function(){
  Handlebars.registerPartial('status-message', JST['status-message_tpl'])
});

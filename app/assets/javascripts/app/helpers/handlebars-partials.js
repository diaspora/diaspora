/* we need to wrap this in a document ready to ensure JST is accessible */
$(function(){
  Handlebars.registerPartial('status-message', HandlebarsTemplates['status-message_tpl'])
});

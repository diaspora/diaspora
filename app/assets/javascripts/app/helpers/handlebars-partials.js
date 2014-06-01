/* we need to wrap this in a document ready to ensure JST is accessible */
$(function(){
  try {
    Handlebars.registerPartial('status-message', JST['status-message_tpl']);
  } catch (e) {
	console.info("Suppressed error: "+e.message);
  }
});

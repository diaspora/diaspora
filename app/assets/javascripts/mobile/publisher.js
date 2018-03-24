$(document).ready(function(){
  // no publisher available
  if($("#new_status_message").length === 0) { return; }

  $(".service_icon").bind("tap click", function() {
    var service = $(this).toggleClass("dim"),
      selectedServices = $("#new_status_message .service_icon:not(.dim)"),
      provider = service.attr("id"),
      hiddenField = $("#new_status_message input[name='services[]'][value='" + provider + "']"),
      publisherMaxChars = 40000,
      serviceMaxChars;


    $("#new_status_message .counter").remove();

    $.each(selectedServices, function() {
      serviceMaxChars = parseInt($(this).attr("maxchar"), 10);
      if(publisherMaxChars > serviceMaxChars) {
        publisherMaxChars = serviceMaxChars;
      }
    });

    if (selectedServices.length > 0) {
      var counter = $("<span class='counter'></span>");
      $("#status_message_text").after(counter);
      $("#status_message_text").charCount({
        allowed: publisherMaxChars,
        warning: publisherMaxChars / 10,
        counter: counter
      });
    }

    if(hiddenField.length > 0) { hiddenField.remove(); }
    else {
      $("#new_status_message").append(
        $("<input/>", {
          name: "services[]",
          type: "hidden",
          value: provider
        })
      );
    }
  });

  $("#submit_new_message").bind("tap click", function(evt){
    evt.preventDefault();
    $("#new_status_message").submit();
  });

  new Diaspora.MarkdownEditor("#status_message_text");
});

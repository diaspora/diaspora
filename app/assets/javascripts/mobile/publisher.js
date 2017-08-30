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

  $(".dropdown-menu > li").bind("tap click", function(evt) {
    var target = $(evt.target).closest('li');

    // visually toggle the aspect selection
    if (target.is('.radio')) {
      _toggleRadio(target);
    } else if (target.is('.aspect_selector')) {
      // don't close the dropdown
      evt.stopPropagation();
      _toggleCheckbox(target);
    }

    _updateSelectedAspectIds();
    _updateButton('btn-default');

    // update the globe or lock icon
    var icon = $("#visibility-icon");
    if (target.find(".text").text().trim() === Diaspora.I18n.t("stream.public")) {
      icon.removeClass("entypo-lock");
      icon.addClass("entypo-globe");
    } else {
      icon.removeClass("entypo-globe");
      icon.addClass("entypo-lock");
    }
  });

  function _toggleRadio (target) {
    $('.dropdown-menu > li').removeClass('selected');
    target.toggleClass('selected');
  };

  function _toggleCheckbox (target) {
    $('.dropdown-menu > li.radio').removeClass('selected');
    target.toggleClass('selected');
  };

  // take care of the form fields that will indicate the selected aspects
  function _updateSelectedAspectIds() {
    var form = $("#new_status_message");

    // remove previous selection
    form.find('input[name="aspect_ids[]"]').remove();

    // create fields for current selection
    $('.dropdown-menu > li.selected').each(function() {
      var uid = _.uniqueId('aspect_ids_');
      var id = $(this).data('aspect_id');
      form.append(
        '<input id="'+uid+'" name="aspect_ids[]" type="hidden" value="'+id+'">'
      );
    });
  };

  // change class and text of the dropdown button
  function _updateButton(inAspectClass) {
    var button = $('.btn.dropdown-toggle'),
        selectedAspects = $(".dropdown-menu > li.selected").length,
        buttonText;

    if (selectedAspects === 0) {
      button.removeClass(inAspectClass).addClass('btn-default');
      buttonText = Diaspora.I18n.t("aspect_dropdown.select_aspects");
    } else {
      button.removeClass('btn-default').addClass(inAspectClass);
      if (selectedAspects === 1) {
        buttonText = this.$(".dropdown-menu > li.selected .text").first().text();
      } else {
        buttonText = Diaspora.I18n.t("aspect_dropdown.toggle", { count: selectedAspects.toString() });
      }
    }

    button.find('.text').text(buttonText);
  }
});

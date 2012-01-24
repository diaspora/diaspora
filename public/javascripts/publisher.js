/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//TODO: make this a widget
var Publisher = {
  bookmarklet : false,

  form: function(){
    return Publisher.cachedForm = Publisher.cachedForm || $('#publisher');
  },

  input: function(){
    return Publisher.cachedInput = Publisher.cachedInput || Publisher.form().find('#status_message_fake_text');
  },

  hiddenInput: function(){
    return Publisher.cachedHiddenInput= Publisher.cachedHiddenInput || Publisher.form().find('#status_message_text');
  },

  submit: function(){
    return Publisher.cachedSubmit = Publisher.cachedSubmit || Publisher.form().find('#status_message_submit');
  },

  determineSubmitAvailability: function(){
    var onlyWhitespaces = ($.trim(Publisher.input().val()) === ''),
        isSubmitDisabled = Publisher.submit().attr('disabled'),
        isPhotoAttached = ($("#photodropzone").children().length > 0);

    if ((onlyWhitespaces &&  !isPhotoAttached) && !isSubmitDisabled) {
      Publisher.submit().attr('disabled', true);
    } else if ((!onlyWhitespaces || isPhotoAttached) && isSubmitDisabled) {
      Publisher.submit().removeAttr('disabled');
    }
  },

  clear: function(){
    $("#photodropzone").find('li').remove();
    Publisher.input()
      .removeClass("with_attachments")
      .css('paddingBottom', '')
      .mentionsInput("reset");
  },

  bindServiceIcons: function(){
    $(".service_icon").bind("click", function(evt){
      $(this).toggleClass("dim");
      Publisher.toggleServiceField($(this));
    });
  },

  toggleServiceField: function(service){
    Publisher.createCounter(service);

    var provider = service.attr('id');
    var hidden_field = $('#publisher [name="services[]"][value="'+provider+'"]');
    if(hidden_field.length > 0){
      hidden_field.remove();
    } else {
      $("#publisher .content_creation form").append(
      '<input id="services_" name="services[]" type="hidden" value="'+provider+'">');
    }
  },

  isPublicPost: function(){
    return $('#publisher [name="aspect_ids[]"]').first().val() == "public";
  },

  isToAllAspects: function(){
    return $('#publisher [name="aspect_ids[]"]').first().val() == "all_aspects";
  },

  selectedAspectIds: function() {
    var aspects = $('#publisher [name="aspect_ids[]"]');
    var aspectIds = [];
    aspects.each(function() { aspectIds.push( parseInt($(this).attr('value'))); });
    return aspectIds;
  },

  removeRadioSelection: function(hiddenFields){
    $.each(hiddenFields, function(index, value){
      var el = $(value);

      if(el.val() == "all_aspects" || el.val() == "public") {
        el.remove();
      }
    });
  },

  toggleAspectIds: function(li) {
    var aspectId = li.attr('data-aspect_id'),
        hiddenFields = $('#publisher [name="aspect_ids[]"]'),
        appendId = function(){
          $("#publisher .content_creation form").append(
          '<input id="aspect_ids_" name="aspect_ids[]" type="hidden" value="'+aspectId+'">');
        };

    if(li.hasClass('radio')){
      $.each(hiddenFields, function(index, value){
        $(value).remove();
      });
      appendId();

      // close dropdown after selecting a binary option
      li.closest('.dropdown').removeClass('active');

    } else {
      var hiddenField = $('#publisher [name="aspect_ids[]"][value="'+aspectId+'"]');

      // remove all radio selections
      Publisher.removeRadioSelection(hiddenFields);

      if(hiddenField.length > 0){
        hiddenField.remove();
      } else {
        appendId();
      }
    }
  },
  createCounter: function(service){
    var counter = $("#publisher .counter");
    counter.remove();

    var min = 40000;
    var a = $('.service_icon:not(.dim)');
    if(a.length > 0){
      $.each(a, function(index, value){
        var num = parseInt($(value).attr('maxchar'));
        if (min > num) { min = num; }
      });
      $('#status_message_fake_text').charCount({allowed: min, warning: min/10 });
    }
  },

  bindAspectToggles: function() {
    $('#publisher .dropdown .dropdown_list li').bind("click", function(evt){
      var li = $(this),
          button = li.parent('.dropdown').find('.button');

      if(li.hasClass('radio')){
        AspectsDropdown.toggleRadio(li);
      } else {
        AspectsDropdown.toggleCheckbox(li);
      }

      AspectsDropdown.updateNumber(li.closest(".dropdown_list"), null, li.parent().find('li.selected').length, '');

      Publisher.toggleAspectIds(li);
    });
  },

  keyUp : function(){
    Publisher.determineSubmitAvailability()
    Publisher.input().mentionsInput("val", function(value) {
      Publisher.hiddenInput().val(value);
    });
  },

  triggerGettingStarted: function(){
    Publisher.setUpPopovers("#publisher .dropdown", {trigger: 'manual', offset: 10, id: "message_visibility_explain", placement:'below', html:true}, 1000);
    Publisher.setUpPopovers("#publisher #status_message_fake_text", {trigger: 'manual', placement: 'right', offset: 30, id: "first_message_explain", html:true}, 600);
    Publisher.setUpPopovers("#gs-shim", {trigger: 'manual', placement: 'left', id:"stream_explain", offset: -5, html:true}, 1400);

    $("#publisher .button.creation").bind("click", function(){
       $("#publisher .dropdown").popover("hide");
       $("#publisher #status_message_fake_text").popover("hide");
    });
  },

  setUpPopovers: function(selector, options, timeout){
    var selection = $(selector);
    selection.popover(options);
    selection.bind("click", function(){$(this).popover("hide")});

    setTimeout(function(){
      selection.popover("show");

      var popup = selection.data('popover').$tip[0],
          closeIcon = $(popup).find(".close");

      closeIcon.bind("click",function(){
        if($(".popover").length == 1){
          $.get("/getting_started_completed");
        };
        selection.popover("hide");
      });
    }, timeout);
  },

  initialize: function() {
    Publisher.cachedForm = Publisher.cachedSubmit =
      Publisher.cachedInput = Publisher.cachedHiddenInput = false;

    Publisher.bindServiceIcons();
    Publisher.bindAspectToggles();

    /* close text area */
    Publisher.form().delegate("#hide_publisher", "click", function(){
      $.each(Publisher.form().find("textarea"), function(idx, element){
        $(element).val("");
      });
      Publisher.close();
    });

    Mentions.initialize(Publisher.input());

    if(Publisher.hiddenInput().val() === "") {
      Publisher.hiddenInput().val(Publisher.input().val());
    }

    Publisher.input().autoResize({'extraSpace' : 10});
    Publisher.input().keyup(Publisher.keyUp)
  }
};

$(document).ready(function() {
  Publisher.initialize();
  Diaspora.page.subscribe("stream/reloaded", Publisher.initialize);
});

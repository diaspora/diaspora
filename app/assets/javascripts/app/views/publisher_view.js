/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//= require ./publisher/services
//= require ./publisher/aspects_selector
//= require ./publisher/getting_started

app.views.Publisher = Backbone.View.extend(_.extend(
  app.views.PublisherServices,
  app.views.PublisherAspectsSelector,
  app.views.PublisherGettingStarted, {

  el : "#publisher",

  events : {
    "focus textarea" : "open",
    "click #hide_publisher" : "clear",
    "submit form" : "createStatusMessage",
    "click .service_icon": "toggleService",
    "textchange #status_message_fake_text": "handleTextchange",
    "click .dropdown .dropdown_list li": "toggleAspect",
    "click #locator" : "showLocation",
    "click #hide_location" : "destroyLocation",
    "keypress #location_address" : "avoidEnter"
  },

  initialize : function(){
    // init shortcut references to the various elements
    this.el_input = this.$('#status_message_fake_text');
    this.el_hiddenInput = this.$('#status_message_text');
    this.el_wrapper = this.$('#publisher_textarea_wrapper');
    this.el_submit = this.$('input[type=submit]');
    this.el_photozone = this.$('#photodropzone');

    // init mentions plugin
    Mentions.initialize(this.el_input);

    // init autoresize plugin
    this.el_input.autoResize({ 'extraSpace' : 10, 'maxHeight' : Infinity });

    // sync textarea content
    if( this.el_hiddenInput.val() == "" ) {
      this.el_hiddenInput.val( this.el_input.val() );
    }

    // hide close button, in case publisher is standalone
    // (e.g. bookmarklet, mentions popup)
    if( this.options.standalone ) {
      this.$('#hide_publisher').hide();
    }

    // this has to be here, otherwise for some reason the callback for the
    // textchange event won't be called in Backbone...
    this.el_input.bind('textchange', $.noop);

    return this;
  },

  createStatusMessage : function(evt) {
    if(evt){ evt.preventDefault(); }

    var serializedForm = $(evt.target).closest("form").serializeObject();

    // lulz this code should be killed.
    var statusMessage = new app.models.Post();

    statusMessage.save({
      "status_message" : {
        "text" : serializedForm["status_message[text]"]
      },
      "aspect_ids" : serializedForm["aspect_ids[]"],
      "photos" : serializedForm["photos[]"],
      "services" : serializedForm["services[]"],
      "location_address" : $("#location_address").val(),
      "location_coords" : serializedForm["location[coords]"]
    }, {
      url : "/status_messages",
      success : function() {
        if(app.publisher) {
          $(app.publisher.el).trigger('ajax:success');
        }
        if(app.stream) {
          app.stream.items.add(statusMessage.toJSON());
        }
      }
    });

    // clear state
    this.clear();

    // clear location
    this.destroyLocation();
  },

  // creates the location
  showLocation: function(){
    if($('#location').length == 0){
      $('#publisher_textarea_wrapper').after('<div id="location"></div>');
      app.views.location = new app.views.Location();
    }
  },

  // destroys the location
  destroyLocation: function(){
    if(app.views.location){
      app.views.location.remove();
    }
  },

  // avoid submitting form when pressing Enter key
  avoidEnter: function(evt){
    if(evt.keyCode == 13)
      return false;
  },

  clear : function() {
    // clear text(s)
    this.el_input.val('');
    this.el_hiddenInput.val('');

    // remove mentions
    this.el_input.mentionsInput('reset');

    // remove photos
    this.el_photozone.find('li').remove();
    this.$("input[name='photos[]']").remove();
    this.el_wrapper.removeClass("with_attachments");

    // close publishing area (CSS)
    this.close();

    // disable submitting
    this.checkSubmitAvailability();

    return this;
  },

  open : function() {
    // visually 'open' the publisher
    this.$el.removeClass('closed');
    this.el_wrapper.addClass('active');

    // fetch contacts for mentioning
    Mentions.fetchContacts();

    return this;
  },

  close : function() {
    $(this.el).addClass("closed");
    this.el_wrapper.removeClass("active");
    this.el_input.css('height', '');

    return this;
  },

  checkSubmitAvailability: function() {
    if( this._submittable() ) {
      this.el_submit.removeAttr('disabled');
    } else {
      this.el_submit.attr('disabled','disabled');
    }
  },

  // determine submit availability
  _submittable: function() {
    var onlyWhitespaces = ($.trim(this.el_input.val()) === ''),
        isPhotoAttached = (this.el_photozone.children().length > 0);

    return (!onlyWhitespaces || isPhotoAttached);
  },

  handleTextchange: function() {
    var self = this;

    this.checkSubmitAvailability();
    this.el_input.mentionsInput("val", function(value){
      self.el_hiddenInput.val(value);
    });
  }

}));

// jQuery helper for serializing a <form> into JSON
$.fn.serializeObject = function()
{
  var o = {};
  var a = this.serializeArray();
  $.each(a, function() {
    if (o[this.name] !== undefined) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || '');
    } else {
      o[this.name] = this.value || '';
    }
  });
  return o;
};

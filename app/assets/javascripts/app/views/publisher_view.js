/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//= require ./publisher/services
//= require ./publisher/aspects_selector
//= require ./publisher/getting_started
//= require jquery.textchange

app.views.Publisher = Backbone.View.extend(_.extend(
  app.views.PublisherServices,
  app.views.PublisherAspectsSelector,
  app.views.PublisherGettingStarted, {

  el : "#publisher",

  events : {
    "keydown #status_message_fake_text" : "keyDown",
    "focus textarea" : "open",
    "click #hide_publisher" : "clear",
    "submit form" : "createStatusMessage",
    "click .post_preview_button" : "createPostPreview",
    "click .service_icon": "toggleService",
    "textchange #status_message_fake_text": "handleTextchange",
    "click .dropdown .dropdown_list li": "toggleAspect",
    "click #locator" : "showLocation",
    "click #hide_location" : "destroyLocation",
    "keypress #location_address" : "avoidEnter"
  },

  tooltipSelector: ".service_icon",

  initialize : function(){
    // init shortcut references to the various elements
    this.el_input = this.$('#status_message_fake_text');
    this.el_hiddenInput = this.$('#status_message_text');
    this.el_wrapper = this.$('#publisher_textarea_wrapper');
    this.el_submit = this.$('input[type=submit]');
    this.el_preview = this.$('button.post_preview_button');
    this.el_photozone = this.$('#photodropzone');

    // init mentions plugin
    Mentions.initialize(this.el_input);

    // init autoresize plugin
    this.el_input.autoResize({ 'extraSpace' : 10, 'maxHeight' : Infinity });

    // init tooltip plugin
    this.$(this.tooltipSelector).tooltip();

    // sync textarea content
    if( this.el_hiddenInput.val() == "" ) {
      this.el_hiddenInput.val( this.el_input.val() );
    }

    // hide close and preview buttons, in case publisher is standalone
    // (e.g. bookmarklet, mentions popup)
    if( this.options.standalone ) {
      this.$('#hide_publisher').hide();
      this.el_preview.hide();
    }

    // this has to be here, otherwise for some reason the callback for the
    // textchange event won't be called in Backbone...
    this.el_input.bind('textchange', $.noop);

    return this;
  },

  createStatusMessage : function(evt) {
    if(evt){ evt.preventDefault(); }

    //add missing mentions at end of post:
    this.handleTextchange();

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

  createPostPreview : function(evt) {
    if(evt){ evt.preventDefault(); }

    //add missing mentions at end of post:
    this.handleTextchange();

    var serializedForm = $(evt.target).closest("form").serializeObject();

    var photos = new Array();
    $('li.publisher_photo img').each(function(){
      var file = $(this).attr('src').substring("/uploads/images/".length);
      photos.push(
        {
          "sizes":{
            "small" : "/uploads/images/thumb_small_" + file,
            "medium" : "/uploads/images/thumb_medium_" + file,
            "large" : "/uploads/images/scaled_full_" + file
          }
        }
      );
    });

    var mentioned_people = new Array();
    var regexp = new RegExp("@{\(\.\*\) ; \(\.\*\)}", "g");
    while(user=regexp.exec(serializedForm["status_message[text]"])){
      // user[1]: name, user[2]: handle
      var mentioned_user = Mentions.contacts.filter(function(item) { return item.handle == user[2];})[0];
      if(mentioned_user){
        mentioned_people.push({
          "id":mentioned_user["id"],
          "guid":mentioned_user["guid"],
          "name":user[1],
          "diaspora_id":user[2],
          "avatar":mentioned_user["avatar"]
        });
      }
    }

    var date = (new Date()).toISOString();
    var previewMessage = {
      "id" : 0,
      "text" : serializedForm["status_message[text]"],
      "public" : serializedForm["aspect_ids[]"]=="public",
      "created_at" : date,
      "interacted_at" : date,
      "post_type" : "StatusMessage",
      "author" : app.currentUser ? app.currentUser.attributes : {},
      "mentioned_people" : mentioned_people,
      "photos" : photos,
      "frame_name" : "status",
      "title" : serializedForm["status_message[text]"],
      "address" : $("#location_address").val(),
      "interactions" : {"likes":[],"reshares":[],"comments_count":0,"likes_count":0,"reshares_count":0}
    }

    if(app.stream) {
      this.removePostPreview();
      app.stream.items.add(previewMessage);
      this.recentPreview=previewMessage;
      this.modifyPostPreview($('.stream_element:first',$('.stream_container')));
    }
  },

  modifyPostPreview : function(post) {
    post.addClass('post_preview');
    $('a.delete.remove_post',post).hide();
    $('a.like, a.focus_comment_textarea',post).removeAttr("href");
    $('a.like',post).addClass("like_preview");
    $('a.like',post).removeClass("like");
    $('a.focus_comment_textarea',post).addClass("focus_comment_textarea_preview");
    $('a.focus_comment_textarea',post).removeClass("focus_comment_textarea");
    $('a',$('span.details.grey',post)).removeAttr("href");
  },

  removePostPreview : function() {
    if(app.stream && this.recentPreview){
        app.stream.items.remove(this.recentPreview);
        delete this.recentPreview;
    }
  },

  keyDown : function(evt) {
    if( evt.keyCode == 13 && evt.ctrlKey ) {
      this.$("form").submit();
      this.open();
      return false;
    }
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

    // empty upload-photo
    this.$('#fileInfo').empty();

    // close publishing area (CSS)
    this.close();

    // remove preview
    this.removePostPreview();

    // disable submitting
    this.checkSubmitAvailability();

    // force textchange plugin to update lastValue
    this.el_input.data('lastValue', '');
    this.el_hiddenInput.data('lastValue', '');

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
      this.el_preview.removeAttr('disabled');
    } else {
      this.el_submit.attr('disabled','disabled');
      this.el_preview.attr('disabled','disabled');
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

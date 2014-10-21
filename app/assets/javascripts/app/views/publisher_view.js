// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//= require ./publisher/services_view
//= require ./publisher/aspect_selector_view
//= require ./publisher/aspect_selector_blueprint_view
//= require ./publisher/getting_started_view
//= require ./publisher/uploader_view
//= require jquery-textchange

app.views.Publisher = Backbone.View.extend({

  el : "#publisher",

  events : {
    "keydown #status_message_fake_text" : "keyDown",
    "focus textarea" : "open",
    "click #hide_publisher" : "clear",
    "submit form" : "createStatusMessage",
    "click #submit" : "createStatusMessage",
    "click .post_preview_button" : "createPostPreview",
    "textchange #status_message_fake_text": "handleTextchange",
    "click #locator" : "showLocation",
    "click #poll_creator" : "togglePollCreator",
    "click #hide_location" : "destroyLocation",
    "keypress #location_address" : "avoidEnter"
  },

  initialize : function(opts){
    this.standalone = opts ? opts.standalone : false;
    this.disabled   = false;

    // init shortcut references to the various elements
    this.el_input = this.$('#status_message_fake_text');
    this.el_hiddenInput = this.$('#status_message_text');
    this.el_wrapper = this.$('#publisher_textarea_wrapper');
    this.el_submit = this.$('input[type=submit], button#submit');
    this.el_preview = this.$('button.post_preview_button');
    this.el_photozone = this.$('#photodropzone');

    // init mentions plugin
    Mentions.initialize(this.el_input);

    // init autoresize plugin
    this.el_input.autoResize({ 'extraSpace' : 10, 'maxHeight' : Infinity });

    // sync textarea content
    if( this.el_hiddenInput.val() == "" ) {
      this.el_hiddenInput.val( this.el_input.val() );
    }

    // hide close and preview buttons, in case publisher is standalone
    // (e.g. bookmarklet, mentions popup)
    if( this.standalone ) {
      this.$('#hide_publisher').hide();
      this.el_preview.hide();
    }

    // this has to be here, otherwise for some reason the callback for the
    // textchange event won't be called in Backbone...
    this.el_input.bind('textchange', $.noop);

    var _this = this
    $('body').on('click', function(event){
      // if the click event is happened outside the publisher view, then try to close the box
      if( _this.el && $(event.target).closest('#publisher').attr('id') != _this.el.id){
          _this.tryClose()
        }
    });

    // close publisher on post
    this.on('publisher:add', function() {
      this.close();
      this.showSpinner(true);
    });
    
    // open publisher on post error
    this.on('publisher:error', function() {
      this.open();
      this.showSpinner(false);
    });

    // resetting the poll view 
    this.on('publisher:sync', function() {
      this.view_poll_creator.render();
    });

    this.initSubviews();
    return this;
  },

  initSubviews: function() {
    var form = this.$('.content_creation form');

    this.view_services = new app.views.PublisherServices({
      el:    this.$('#publisher_service_icons'),
      input: this.el_input,
      form:  form
    });

    this.view_aspect_selector = new app.views.PublisherAspectSelector({
      el: this.$('.public_toggle .aspect_dropdown'),
      form: form
    });

    this.view_aspect_selector_blueprint = new app.views.PublisherAspectSelectorBlueprint({
      el: this.$('.public_toggle > .dropdown'),
      form: form
    });

    this.view_getting_started = new app.views.PublisherGettingStarted({
      el_first_msg:  this.el_input,
      el_visibility: this.$('.public_toggle > .dropdown'),
      el_stream:     $('#gs-shim')
    });

    this.view_uploader = new app.views.PublisherUploader({
      el: this.$('#file-upload'),
      publisher: this
    });
    this.view_uploader.on('change', this.checkSubmitAvailability, this);

    this.view_poll_creator = new app.views.PublisherPollCreator({
      el: this.$('#poll_creator_container')
    });
    this.view_poll_creator.on('change', this.checkSubmitAvailability, this);
    this.view_poll_creator.render();

  },

  // set the selected aspects in the dropdown by their ids
  setSelectedAspects: function(ids) {
    this.view_aspect_selector.updateAspectsSelector(ids);
    this.view_aspect_selector_blueprint.updateAspectsSelector(ids);
  },

  // inject content into the publisher textarea
  setText: function(txt) {
    this.el_input.val(txt);
    this.el_hiddenInput.val(txt);

    this.el_input.trigger('input');
    this.handleTextchange();
  },

  // show the "getting started" popups around the publisher
  triggerGettingStarted: function() {
    this.view_getting_started.show();
  },

  createStatusMessage : function(evt) {
    this.setButtonsEnabled(false);
    var self = this;

    if(evt){ evt.preventDefault(); }

    // Auto-adding a poll answer always leaves an empty box when the user starts
    // typing in the last box. We'll delete the last one to avoid submitting an 
    // empty poll answer and failing validation.
    this.view_poll_creator.removeLastAnswer();

    //add missing mentions at end of post:
    this.handleTextchange();

    var serializedForm = $(evt.target).closest("form").serializeObject();
    // disable input while posting, must be after the form is serialized
    this.setInputEnabled(false);

    // lulz this code should be killed.
    var statusMessage = new app.models.Post();
    if( app.publisher ) app.publisher.trigger('publisher:add');

    statusMessage.save({
      "status_message" : {
        "text" : serializedForm["status_message[text]"]
      },
      "aspect_ids" : serializedForm["aspect_ids[]"],
      "photos" : serializedForm["photos[]"],
      "services" : serializedForm["services[]"],
      "location_address" : $("#location_address").val(),
      "location_coords" : serializedForm["location[coords]"],
      "poll_question" : serializedForm["poll_question"],
      "poll_answers" : serializedForm["poll_answers[]"]
    }, {
      url : "/status_messages",
      success : function() {
        if( app.publisher ) {
          app.publisher.$el.trigger('ajax:success');
          app.publisher.trigger('publisher:sync');
          self.view_poll_creator.trigger('publisher:sync');
        }

        if(app.stream) app.stream.addNow(statusMessage.toJSON());

        // clear state
        self.clear();

        // standalone means single-shot posting (until further notice)
        if( self.standalone ) self.setEnabled(false);
      },
      error: function(model, resp, options) {
        if( app.publisher ) app.publisher.trigger('publisher:error');
        self.setInputEnabled(true);
        Diaspora.page.flashMessages.render({ 'success':false, 'notice':resp.responseText });
        self.setButtonsEnabled(true);
        self.setInputEnabled(true);
      }
    });
  },

  // creates the location
  showLocation: function(){
    if($('#location').length == 0){
      $('#location_container').append('<div id="location"></div>');
      this.el_wrapper.addClass('with_location');
      this.view_locator = new app.views.Location();
    }
  },

  // destroys the location
  destroyLocation: function(){
    if(this.view_locator){
      this.view_locator.remove();
      this.el_wrapper.removeClass('with_location');
      delete this.view_locator;
    }
  },

  togglePollCreator: function(){
    this.view_poll_creator.$el.toggle();
    this.el_input.focus();
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
    var regexp = new RegExp("@{\(\[\^\;\]\+\); \(\[\^\}\]\+\)}", "g");
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

    var poll = undefined;
    var poll_question = serializedForm["poll_question"];
    var poll_answers_arry = _.flatten([serializedForm["poll_answers[]"]]);
    var poll_answers = _.map(poll_answers_arry, function(answer){
      if(answer) return { 'answer' : answer };
    });
    poll_answers = _.without(poll_answers, undefined);

    if(poll_question && poll_answers.length) {
      poll = {
        'question': poll_question,
        'poll_answers' : poll_answers,
        'participation_count': '0'
      };
    }

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
      "interactions" : {"likes":[],"reshares":[],"comments_count":0,"likes_count":0,"reshares_count":0},
      'poll': poll,
    };
    if(app.stream) {
      this.removePostPreview();
      app.stream.addNow(previewMessage);
      this.recentPreview=previewMessage;
      this.modifyPostPreview($('.stream_element:first',$('.stream_container')));
    }
  },

  modifyPostPreview : function(post) {
    post.addClass('post_preview');
    $('.collapsible',post).removeClass('collapsed').addClass('opened');
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

    // hide spinner
    this.showSpinner(false);

    // enable input
    this.setInputEnabled(true);
    
    // enable buttons
    this.setButtonsEnabled(true);

    // clear location
    this.destroyLocation();

    // clear poll form
    this.view_poll_creator.clearInputs();

    // force textchange plugin to update lastValue
    this.el_input.data('lastValue', '');
    this.el_hiddenInput.data('lastValue', '');

    return this;
  },

  tryClose : function(){
    // if it is not submittable, close it.
    if( !this._submittable() ){
      this.close()
    }
  },

  open : function() {
    if( this.disabled ) return;

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
    this.view_poll_creator.$el.hide();
    return this;
  },

  showSpinner: function(bool) {
    if (bool)
      this.$('#publisher_spinner').removeClass('hidden');
    else
      this.$('#publisher_spinner').addClass('hidden');
  },
  
  checkSubmitAvailability: function() {
    if( this._submittable() ) {
      this.setButtonsEnabled(true);
    } else {
      this.setButtonsEnabled(false);
    }
  },

  setEnabled: function(bool) {
    this.setInputEnabled(bool);
    this.disabled = !bool;

    this.handleTextchange();
  },

  setButtonsEnabled: function(bool) {
    bool = !bool;
    this.el_submit.prop({disabled: bool});
    this.el_preview.prop({disabled: bool});
  },

  setInputEnabled: function(bool) {
    bool = !bool;
    this.el_input.prop({disabled: bool});
    this.el_hiddenInput.prop({disabled: bool});
  },

  // determine submit availability
  _submittable: function() {
    var onlyWhitespaces = ($.trim(this.el_input.val()) === ''),
        isPhotoAttached = (this.el_photozone.children().length > 0),
        isValidPoll = this.view_poll_creator.validatePoll();

    return (!onlyWhitespaces || isPhotoAttached) && isValidPoll && !this.disabled;
  },

  handleTextchange: function() {
    var self = this;

    this.checkSubmitAvailability();
    this.el_input.mentionsInput("val", function(value){
      self.el_hiddenInput.val(value);
    });
  }

});

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
// @license-end


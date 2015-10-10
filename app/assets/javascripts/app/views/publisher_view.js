// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//= require ./publisher/services_view
//= require ./publisher/aspect_selector_view
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
    this.inputEl = this.$("#status_message_fake_text");
    this.hiddenInputEl = this.$("#status_message_text");
    this.wrapperEl = this.$("#publisher_textarea_wrapper");
    this.submitEl = this.$("input[type=submit], button#submit");
    this.previewEl = this.$("button.post_preview_button");
    this.photozoneEl = this.$("#photodropzone");

    // init mentions plugin
    Mentions.initialize(this.inputEl);

    // if there is data in the publisher we ask for a confirmation
    // before the user is able to leave the page
    $(window).on("beforeunload", _.bind(this._beforeUnload, this));

    // sync textarea content
    if( this.hiddenInputEl.val() === "" ) {
      this.hiddenInputEl.val( this.inputEl.val() );
    }
    if( this.inputEl.val() === "" ) {
      this.inputEl.val( this.hiddenInputEl.val() );
    }

    // hide close and preview buttons and manage services link
    // in case publisher is standalone
    // (e.g. bookmarklet, mentions popup)
    if( this.standalone ) {
      this.$("#hide_publisher").hide();
      this.previewEl.hide();
      this.$(".question_mark").hide();
    }

    // this has to be here, otherwise for some reason the callback for the
    // textchange event won't be called in Backbone...
    this.inputEl.bind("textchange", $.noop);

    var _this = this;
    $("body").on("click", function(event){
      // if the click event is happened outside the publisher view, then try to close the box
      if( _this.el && $(event.target).closest("#publisher").attr("id") !== _this.el.id){
          _this.tryClose();
        }
    });

    // close publisher on post
    this.on("publisher:add", function() {
      this.close();
      this.showSpinner(true);
    });

    // open publisher on post error
    this.on("publisher:error", function() {
      this.open();
      this.showSpinner(false);
    });

    // resetting the poll view
    this.on("publisher:sync", function() {
      this.viewPollCreator.render();
    });

    // init autosize plugin
    autosize(this.inputEl);

    this.initSubviews();
    this.checkSubmitAvailability();
    return this;
  },

  initSubviews: function() {
    var form = this.$(".content_creation form");

    this.view_services = new app.views.PublisherServices({
      el:    this.$("#publisher-service-icons"),
      input: this.inputEl,
      form:  form
    });

    this.viewAspectSelector = new app.views.PublisherAspectSelector({
      el: this.$(".public_toggle .aspect_dropdown"),
      form: form
    });

    this.viewGettingStarted = new app.views.PublisherGettingStarted({
      firstMessageEl:  this.inputEl,
      visibilityEl: this.$(".public_toggle .aspect_dropdown > .dropdown-toggle"),
      streamEl:     $("#gs-shim")
    });

    this.viewUploader = new app.views.PublisherUploader({
      el: this.$("#file-upload"),
      publisher: this
    });
    this.viewUploader.on("change", this.checkSubmitAvailability, this);

    this.viewPollCreator = new app.views.PublisherPollCreator({
      el: this.$("#poll_creator_container")
    });
    this.viewPollCreator.on("change", this.checkSubmitAvailability, this);
    this.viewPollCreator.render();
  },

  // set the selected aspects in the dropdown by their ids
  setSelectedAspects: function(ids) {
    this.viewAspectSelector.updateAspectsSelector(ids);
  },

  // inject content into the publisher textarea
  setText: function(txt) {
    this.inputEl.val(txt);
    this.hiddenInputEl.val(txt);
    this.prefillText = txt;

    this.inputEl.trigger("input");
    autosize.update(this.inputEl);
    this.handleTextchange();
  },

  // show the "getting started" popups around the publisher
  triggerGettingStarted: function() {
    this.viewGettingStarted.show();
  },

  createStatusMessage : function(evt) {
    this.setButtonsEnabled(false);
    var self = this;

    if(evt){ evt.preventDefault(); }

    // Auto-adding a poll answer always leaves an empty box when the user starts
    // typing in the last box. We'll delete the last one to avoid submitting an
    // empty poll answer and failing validation.
    this.viewPollCreator.removeLastAnswer();

    //add missing mentions at end of post:
    this.handleTextchange();

    var serializedForm = $(evt.target).closest("form").serializeObject();
    // disable input while posting, must be after the form is serialized
    this.setInputEnabled(false);

    // lulz this code should be killed.
    var statusMessage = new app.models.Post();
    if( app.publisher ) {
      app.publisher.trigger("publisher:add");
    }

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
          app.publisher.$el.trigger("ajax:success");
          app.publisher.trigger("publisher:sync");
          self.viewPollCreator.trigger("publisher:sync");
        }

        if(app.stream && !self.standalone){
          app.stream.addNow(statusMessage.toJSON());
        }

        // clear state
        self.clear();

        // standalone means single-shot posting (until further notice)
        if( self.standalone ) self.setEnabled(false);
      },
      error: function(model, resp) {
        if( app.publisher ) {
          app.publisher.trigger("publisher:error");
        }
        self.setInputEnabled(true);
        app.flashMessages.error(resp.responseText);
        self.setButtonsEnabled(true);
        self.setInputEnabled(true);
      }
    });
  },

  // creates the location
  showLocation: function(){
    if($("#location").length === 0){
      $("#location_container").append("<div id=\"location\"></div>");
      this.wrapperEl.addClass("with_location");
      this.view_locator = new app.views.Location();
    }
  },

  // destroys the location
  destroyLocation: function(){
    if(this.view_locator){
      this.view_locator.remove();
      this.wrapperEl.removeClass("with_location");
      delete this.view_locator;
    }
  },

  togglePollCreator: function(){
    this.viewPollCreator.$el.toggle();
    this.inputEl.focus();
  },

  // avoid submitting form when pressing Enter key
  avoidEnter: function(evt){
    if(evt.keyCode === 13)
      return false;
  },

  getUploadedPhotos: function() {
    var photos = [];
    $("li.publisher_photo img").each(function() {
      var file = $(this).attr("src").substring("/uploads/images/".length);
      photos.push(
        {
          "sizes": {
            "small" : "/uploads/images/thumb_small_" + file,
            "medium" : "/uploads/images/thumb_medium_" + file,
            "large" : "/uploads/images/scaled_full_" + file
          }
        }
      );
    });
    return photos;
  },

  getMentionedPeople: function(serializedForm) {
    var mentionedPeople = [],
        regexp = /@{([^;]+); ([^}]+)}/g,
        user;
    var getMentionedUser = function(handle) {
      return Mentions.contacts.filter(function(user) {
        return user.handle === handle;
      })[0];
    };

    while( (user = regexp.exec(serializedForm["status_message[text]"])) ) {
      // user[1]: name, user[2]: handle
      var mentionedUser = getMentionedUser(user[2]);
      if(mentionedUser){
        mentionedPeople.push({
          "id": mentionedUser.id,
          "guid": mentionedUser.guid,
          "name": user[1],
          "diaspora_id": user[2],
          "avatar": mentionedUser.avatar
        });
      }
    }
    return mentionedPeople;
  },

  getPollData: function(serializedForm) {
    var poll;
    var pollQuestion = serializedForm.poll_question;
    var pollAnswersArray = _.flatten([serializedForm["poll_answers[]"]]);
    var pollAnswers = _.map(pollAnswersArray, function(answer){
      if (answer) {
        return { "answer" : answer };
      }
    });
    pollAnswers = _.without(pollAnswers, undefined);

    if(pollQuestion && pollAnswers.length) {
      poll = {
        "question": pollQuestion,
        "poll_answers" : pollAnswers,
        "participation_count": "0"
      };
    }
    return poll;
  },

  createPostPreview : function(evt) {
    if(evt){ evt.preventDefault(); }
    if(!app.stream) { return; }

    //add missing mentions at end of post:
    this.handleTextchange();

    var serializedForm = $(evt.target).closest("form").serializeObject();
    var photos = this.getUploadedPhotos();
    var mentionedPeople = this.getMentionedPeople(serializedForm);
    var date = (new Date()).toISOString();
    var poll = this.getPollData(serializedForm);
    var locationCoords = serializedForm["location[coords]"];
    if(!locationCoords || locationCoords === "") {
      locationCoords = ["", ""];
    } else {
      locationCoords = locationCoords.split(",");
    }
    var location = {
      "address": $("#location_address").val(),
      "lat": locationCoords[0],
      "lng": locationCoords[1]
    };

    var previewMessage = {
      "id" : 0,
      "text" : serializedForm["status_message[text]"],
      "public" : serializedForm["aspect_ids[]"] === "public",
      "created_at" : date,
      "interacted_at" : date,
      "post_type" : "StatusMessage",
      "author" : app.currentUser ? app.currentUser.attributes : {},
      "mentioned_people" : mentionedPeople,
      "photos" : photos,
      "frame_name" : "status",
      "title" : serializedForm["status_message[text]"],
      "location" : location,
      "interactions" : {"likes":[],"reshares":[],"comments_count":0,"likes_count":0,"reshares_count":0},
      "poll": poll
    };

    this.removePostPreview();
    app.stream.addNow(previewMessage);
    this.recentPreview=previewMessage;
    this.modifyPostPreview($(".stream_element:first",$(".stream_container")));
  },

  modifyPostPreview : function(post) {
    post.addClass("post_preview");
    $(".collapsible",post).removeClass("collapsed").addClass("opened");
    $("a.delete.remove_post",post).hide();
    $("a.like, a.focus_comment_textarea",post).removeAttr("href");
    $("a.like",post).addClass("like_preview")
                    .removeClass("like");
    $("a.focus_comment_textarea",post).addClass("focus_comment_textarea_preview")
                                      .removeClass("focus_comment_textarea");
    $("a",$("span.details.grey",post)).removeAttr("href");
  },

  removePostPreview : function() {
    if(app.stream && this.recentPreview) {
      app.stream.items.remove(this.recentPreview);
      delete this.recentPreview;
    }
  },

  keyDown : function(evt) {
    if( evt.keyCode === 13 && evt.ctrlKey ) {
      this.$("form").submit();
      this.open();
      return false;
    }
  },

  clear : function() {
    // clear text(s)
    this.inputEl.val("");
    this.hiddenInputEl.val("");
    this.inputEl.trigger("keyup")
                 .trigger("keydown");
    autosize.update(this.inputEl);

    // remove mentions
    this.inputEl.mentionsInput("reset");

    // remove photos
    this.photozoneEl.find("li").remove();
    this.$("input[name='photos[]']").remove();
    this.wrapperEl.removeClass("with_attachments");

    // empty upload-photo
    this.$("#fileInfo").empty();

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
    this.viewPollCreator.clearInputs();

    // force textchange plugin to update lastValue
    this.inputEl.data("lastValue", "");
    this.hiddenInputEl.data("lastValue", "");

    return this;
  },

  tryClose : function(){
    // if it is not submittable, close it.
    if( !this._submittable() ){
      this.close();
    }
  },

  open : function() {
    if( this.disabled ) return;

    // visually 'open' the publisher
    this.$el.removeClass("closed");
    this.wrapperEl.addClass("active");
    autosize.update(this.inputEl);

    // fetch contacts for mentioning
    Mentions.fetchContacts();
    return this;
  },

  close : function() {
    $(this.el).addClass("closed");
    this.wrapperEl.removeClass("active");
    this.inputEl.css("height", "");
    this.viewPollCreator.$el.hide();
    return this;
  },

  showSpinner: function(bool) {
    if (bool) {
      this.$("#publisher_spinner").removeClass("hidden");
    }
    else {
      this.$("#publisher_spinner").addClass("hidden");
    }
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
    if (bool) {
      this.submitEl.removeProp("disabled");
      this.previewEl.removeProp("disabled");
    } else {
      this.submitEl.prop("disabled", true);
      this.previewEl.prop("disabled", true);
    }
  },

  setInputEnabled: function(bool) {
    if (bool) {
      this.inputEl.removeProp("disabled");
      this.hiddenInputEl.removeProp("disabled");
    } else {
      this.inputEl.prop("disabled", true);
      this.hiddenInputEl.prop("disabled", true);
    }
  },

  // determine submit availability
  _submittable: function() {
    var onlyWhitespaces = ($.trim(this.inputEl.val()) === ""),
        isPhotoAttached = (this.photozoneEl.children().length > 0),
        isValidPoll = this.viewPollCreator.validatePoll();

    return (!onlyWhitespaces || isPhotoAttached) && isValidPoll && !this.disabled;
  },

  handleTextchange: function() {
    var self = this;

    this.checkSubmitAvailability();
    this.inputEl.mentionsInput("val", function(value){
      self.hiddenInputEl.val(value);
    });
  },

  _beforeUnload: function(e) {
    if(this._submittable() && this.inputEl.val() !== this.prefillText){
      var confirmationMessage = Diaspora.I18n.t("confirm_unload");
      (e || window.event).returnValue = confirmationMessage;       //Gecko + IE
      return confirmationMessage;                                  //Webkit, Safari, Chrome, etc.
    }
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
      o[this.name].push(this.value || "");
    } else {
      o[this.name] = this.value || "";
    }
  });
  return o;
};
// @license-end

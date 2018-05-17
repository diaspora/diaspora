// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//= require ./publisher/aspect_selector_view
//= require ./publisher/getting_started_view
//= require ./publisher/mention_view
//= require ./publisher/poll_creator_view
//= require ./publisher/services_view
//= require ./publisher/uploader_view
//= require jquery-textchange

app.views.Publisher = Backbone.View.extend({

  el : "#publisher",

  events : {
    "keydown #status_message_text": "keyDown",
    "focus textarea" : "open",
    "submit form" : "createStatusMessage",
    "click #submit" : "createStatusMessage",
    "textchange #status_message_text": "checkSubmitAvailability",
    "click #locator" : "showLocation",
    "click #poll_creator" : "togglePollCreator",
    "click #hide_location" : "destroyLocation",
    "keypress #location_address" : "avoidEnter"
  },

  initialize : function(opts){
    this.standalone = opts ? opts.standalone : false;
    this.prefillMention = opts && opts.prefillMention ? opts.prefillMention : undefined;
    this.disabled   = false;

    // init shortcut references to the various elements
    this.inputEl = this.$("#status_message_text");
    this.wrapperEl = this.$("#publisher-textarea-wrapper");
    this.submitEl = this.$("input[type=submit], button#submit");
    this.photozoneEl = this.$("#photodropzone");

    // if there is data in the publisher we ask for a confirmation
    // before the user is able to leave the page
    $(window).on("beforeunload", _.bind(this._beforeUnload, this));
    $(window).on("unload", this.clear.bind(this));

    // hide close and preview buttons and manage services link
    // in case publisher is standalone
    // (e.g. bookmarklet, mentions popup)
    if( this.standalone ) {
      this.$(".question_mark").hide();
    }

    // this has to be here, otherwise for some reason the callback for the
    // textchange event won't be called in Backbone...
    this.inputEl.bind("textchange", $.noop);

    $("body").click(function(event) {
      var $target = $(event.target);
      if ($target.closest("#publisher").length === 0 && !$target.hasClass("dropdown-backdrop")) {
        this.tryClose();
      }
    }.bind(this));

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

    this.initSubviews();
    this.checkSubmitAvailability();
    this.triggerGettingStarted();
    return this;
  },

  initSubviews: function() {
    this.mention = new app.views.PublisherMention({ el: this.$("#publisher-textarea-wrapper") });
    if(this.prefillMention) {
      this.mention.prefillMention([this.prefillMention]);
    }

    var form = this.$(".content_creation form");

    this.view_services = new app.views.PublisherServices({
      el:    this.$("#publisher-service-icons"),
      input: this.inputEl,
      form:  form
    });

    this.viewAspectSelector = new app.views.PublisherAspectSelector({
      el: this.$(".public_toggle .aspect-dropdown"),
      form: form
    });

    this.viewGettingStarted = new app.views.PublisherGettingStarted({
      firstMessageEl:  this.inputEl,
      visibilityEl: this.$(".public_toggle .aspect-dropdown > .dropdown-toggle"),
      streamEl:     $("#main-stream")
    });

    this.viewUploader = new app.views.PublisherUploader({
      el: this.$("#file-upload"),
      publisher: this
    });
    this.viewUploader.on("change", this.checkSubmitAvailability, this);

    var self = this;
    var mdEditorOptions = {
      onPreview: function() {
        self.wrapperEl.addClass("markdown-preview");
        return self.createPostPreview();
      },

      onHidePreview: function() {
        self.wrapperEl.removeClass("markdown-preview");
      },

      onPostPreview: function() {
        var photoAttachments = self.wrapperEl.find(".photo-attachments");
        if (photoAttachments.length > 0) {
          new app.views.Gallery({el: photoAttachments});
        }
      },

      onChange: function() {
        self.inputEl.trigger("textchange");
      }
    };

    if (!this.standalone) {
      mdEditorOptions.onClose = function() {
        self.clear();
      };
    }
    this.markdownEditor = new Diaspora.MarkdownEditor(this.inputEl, mdEditorOptions);

    this.viewPollCreator = new app.views.PublisherPollCreator({
      el: this.$("#poll_creator_container")
    });
    this.viewPollCreator.on("change", this.checkSubmitAvailability, this);
    this.viewPollCreator.render();

    if (this.prefillMention) {
      this.checkSubmitAvailability();
    }
  },

  // set the selected aspects in the dropdown by their ids
  setSelectedAspects: function(ids) {
    this.viewAspectSelector.updateAspectsSelector(ids);
  },

  // inject content into the publisher textarea
  setText: function(txt) {
    this.inputEl.val(txt);
    this.prefillText = txt;

    this.inputEl.trigger("input");
    autosize.update(this.inputEl);
    this.checkSubmitAvailability();
  },

  // show the "getting started" popups around the publisher
  triggerGettingStarted: function() {
    if (gon.preloads.getting_started) {
      this.open();
      this.viewGettingStarted.show();
      if (gon.preloads.mentioned_person) {
        this.mention.addPersonToMentions(gon.preloads.mentioned_person);
      }
    }
  },

  createStatusMessage : function(evt) {
    this.setButtonsEnabled(false);
    var self = this;

    if(evt){ evt.preventDefault(); }

    // Auto-adding a poll answer always leaves an empty box when the user starts
    // typing in the last box. We'll delete the last one to avoid submitting an
    // empty poll answer and failing validation.
    this.viewPollCreator.removeLastAnswer();

    var serializedForm = $(evt.target).closest("form").serializeObject();
    // disable input while posting, must be after the form is serialized
    this.setInputEnabled(false);
    this.wrapperEl.addClass("submitting");

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
        self.wrapperEl.removeClass("submitting");
        self.checkSubmitAvailability();
        autosize.update(self.inputEl);
      }
    });
  },

  // creates the location
  showLocation: function(){
    if($("#location").length === 0){
      this.$(".location-container").append("<div id=\"location\"></div>");
      this.wrapperEl.addClass("with-location");
      this.view_locator = new app.views.Location();
    }
  },

  // destroys the location
  destroyLocation: function(){
    if(this.view_locator){
      this.view_locator.remove();
      this.wrapperEl.removeClass("with-location");
      delete this.view_locator;
    }
  },

  togglePollCreator: function(){
    this.wrapperEl.toggleClass("with-poll");
    this.inputEl.focus();
  },

  // avoid submitting form when pressing Enter key
  avoidEnter: function(evt){
    if(evt.which === Keycodes.ENTER) {
      return false;
    }
  },

  getUploadedPhotos: function() {
    var photos = [];
    $("li.publisher_photo img").each(function() {
      var photo = $(this);
      photos.push(
        {
          "sizes": {
            "small": photo.data("small"),
            "medium": photo.attr("src"),
            "large": photo.data("scaled")
          }
        }
      );
    });
    return photos;
  },

  getPollData: function(serializedForm) {
    var poll;
    var pollQuestion = serializedForm.poll_question;
    var pollAnswersArray = _.flatten([serializedForm["poll_answers[]"]]);
    var pollAnswers = _.map(pollAnswersArray, function(answer){
      if (answer) {
        return {"answer": answer, "vote_count": 0};
      }
    });
    pollAnswers = _.without(pollAnswers, undefined);

    if(pollQuestion && pollAnswers.length) {
      poll = {
        "question": pollQuestion,
        "poll_answers": pollAnswers,
        "participation_count": "0"
      };
    }
    return poll;
  },

  createPostPreview: function() {
    var serializedForm = $("#new_status_message").serializeObject();
    var photos = this.getUploadedPhotos();
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
      "id": 0,
      "text": serializedForm["status_message[text]"],
      "public": serializedForm["aspect_ids[]"] === "public",
      "created_at": new Date().toISOString(),
      "interacted_at": new Date().toISOString(),
      "author": app.currentUser ? app.currentUser.attributes : {},
      "mentioned_people": this.mention.getMentionedPeople(),
      "photos": photos,
      "title": serializedForm["status_message[text]"],
      "location": location,
      "interactions": {"likes": [], "reshares": [], "comments_count": 0, "likes_count": 0, "reshares_count": 0},
      "poll": poll
    };

    var previewPost = new app.views.PreviewPost({model: new app.models.Post(previewMessage)}).render().el;
    return $("<div/>").append(previewPost).html();
  },

  keyDown : function(evt) {
    if (evt.which === Keycodes.ENTER && (evt.metaKey || evt.ctrlKey)) {
      this.$("form").submit();
      this.open();
      return false;
    }
  },

  clear : function() {
    // remove mentions
    this.mention.reset();

    // clear text
    this.inputEl.val("");
    this.inputEl.trigger("keyup")
                .trigger("keydown");
    autosize.update(this.inputEl);

    // remove photos
    this.photozoneEl.find("li").remove();
    this.$("input[name='photos[]']").remove();
    this.wrapperEl.removeClass("with_attachments");

    // empty upload-photo
    this.$("#fileInfo").empty();

    // remove preview and close publishing area (CSS)
    this.markdownEditor.hidePreview();
    this.close();

    // disable submitting
    this.checkSubmitAvailability();

    // hide spinner
    this.showSpinner(false);

    // enable input
    this.setInputEnabled(true);
    this.wrapperEl.removeClass("submitting");

    // enable buttons
    this.setButtonsEnabled(true);

    // clear location
    this.destroyLocation();

    // clear poll form
    this.viewPollCreator.clearInputs();

    // force textchange plugin to update lastValue
    this.inputEl.data("lastValue", "");

    return this;
  },

  tryClose : function(){
    // if it is not submittable and not in preview mode, close it.
    if (!this._submittable() && !this.markdownEditor.isPreviewMode()) {
      this.close();
    }
  },

  open : function() {
    if( this.disabled ) return;

    // visually 'open' the publisher
    this.$el.removeClass("closed");
    this.wrapperEl.addClass("active");
    autosize.update(this.inputEl);
    return this;
  },

  close : function() {
    $(this.el).addClass("closed");
    this.wrapperEl.removeClass("active");
    this.inputEl.css("height", "");
    autosize.update(this.inputEl);
    this.wrapperEl.removeClass("with-poll");
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
    if (this._submittable()) {
      this.setButtonsEnabled(true);
    } else {
      this.setButtonsEnabled(false);
    }
  },

  setEnabled: function(bool) {
    this.setInputEnabled(bool);
    this.disabled = !bool;
    this.checkSubmitAvailability();
  },

  setButtonsEnabled: function(bool) {
    if (bool) {
      this.submitEl.removeAttr("disabled");
    } else {
      this.submitEl.prop("disabled", true);
    }
  },

  setInputEnabled: function(bool) {
    if (bool) {
      this.inputEl.removeAttr("disabled");
    } else {
      this.inputEl.prop("disabled", true);
    }
  },

  // determine submit availability
  _submittable: function() {
    var onlyWhitespaces = ($.trim(this.inputEl.val()) === ""),
        isPhotoAttached = (this.photozoneEl.children().length > 0),
        isValidPoll = this.viewPollCreator.validatePoll();

    return (!onlyWhitespaces || isPhotoAttached) && isValidPoll && !this.disabled;
  },

  _beforeUnload: function(e) {
    if (this._submittable() && this.inputEl.val() !== this.prefillText) {
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

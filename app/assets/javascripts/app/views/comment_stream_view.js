// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.CommentStream = app.views.Base.extend({
  allowedExtensions: ["jpg", "jpeg", "png", "gif", "tif", "tiff"],
  sizeLimit: 4194304,  // bytes

  templateName: "comment-stream",

  className : "comment_stream",

  events: {
    "keydown .comment_box": "keyDownOnCommentBox",
    "submit form": "createComment",
    "focus .comment_box": "commentTextareaFocused",
    "input .comment_box": "setSubmitButtonState",
    "click .discard_comment": "discardComment",
    "click .toggle_post_comments": "expandComments"
  },

  initialize: function(options) {
    this.commentTemplate = options.commentTemplate;

    this.setupBindings();
  },

  setupBindings: function() {
    this.model.comments.bind('add', this.appendComment, this);
  },

  postRenderTemplate : function() {
    this.model.comments.each(this.appendComment, this);

    this.textareaWrapperEl = this.$(".publisher-textarea-wrapper");
    this.textareaEl = this.$("textarea");
    this.infoEl = this.$(".fileInfo");
    this.photozoneEl = this.$(".photodropzone");

    // add autoexpanders to new comment textarea
    this.updateTexareaValue(this.textareaValue);

    this.uploader = new qq.FileUploaderBasic({
      element: this.$(".file-upload")[0],
      button: this.$(".file-upload")[0],
      action: "/photos",
      params: {photo: { pending: true}},
      allowedExtensions: this.allowedExtensions,
      sizeLimit: this.sizeLimit,
      messages: {
        typeError: Diaspora.I18n.t("photo_uploader.invalid_ext"),
        sizeError: Diaspora.I18n.t("photo_uploader.size_error"),
        emptyError: Diaspora.I18n.t("photo_uploader.empty")
      },
      onProgress: _.bind(this.uploadProgressHandler, this),
      onSubmit: _.bind(this.uploadSubmitHandler, this),
      onComplete: _.bind(this.uploadCompleteHandler, this)
    });

    this.photozoneEl.on("click", ".x", _.bind(this._removePhoto, this));
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : (this.model.interactions.commentsCount() - 3),
      showExpandCommentsLink : (this.model.interactions.commentsCount() > 3),
      commentsCount : this.model.interactions.commentsCount()
    });
  },

  createComment: function(evt) {
    if(evt){ evt.preventDefault(); }

    var commentText = $.trim(this.textareaEl.val());

    this.updateTexareaValue(commentText);

    if(commentText) {
      this.model.comment(commentText);
      return this;
    } else {
      this.$(".comment_box").focus();
    }
  },

  keyDownOnCommentBox: function(evt) {
    if(evt.which === Keycodes.ENTER && evt.ctrlKey) {
      this.$("form").submit();
      return false;
    }
  },

  _insertPoint: 0, // An index of the comment added in the last call of this.appendComment

  // This adjusts this._insertPoint according to timestamp value
  _moveInsertPoint: function(timestamp, commentBlocks) {
    if (commentBlocks.length === 0) {
      this._insertPoint = 0;
      return;
    }

    if (this._insertPoint > commentBlocks.length) {
      this._insertPoint = commentBlocks.length;
    }

    while (this._insertPoint > 0 && timestamp < commentBlocks.eq(this._insertPoint - 1).find("time").attr("datetime")) {
      this._insertPoint--;
    }
    while (this._insertPoint < commentBlocks.length &&
        timestamp > commentBlocks.eq(this._insertPoint).find("time").attr("datetime")) {
      this._insertPoint++;
    }
  },

  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()});

    var commentHtml = new app.views.Comment({model: comment}).render().el;
    var commentBlocks = this.$(".comments div.comment.media");
    this._moveInsertPoint(comment.get("created_at"), commentBlocks);
    if (this._insertPoint === commentBlocks.length) {
      this.$(".comments").append(commentHtml);
    } else {
      commentBlocks.eq(this._insertPoint).before(commentHtml);
    }
    this._insertPoint++;

    if (this.photozoneEl) {
      this.photozoneEl.empty();
      this.discardComment();
    }
  },

  commentTextareaFocused: function(){
    this.$("form").removeClass("closed hidden").addClass("open");
  },

  discardComment: function() {
    // clear text
    this.updateTexareaValue("");

    // remove photos
    this.photozoneEl.find("li.publisher_photo").each(_.bind(function(index, element) {
      this.removePhoto($(element));
    }, this));

    // no more photos left...
    this.textareaWrapperEl.removeClass("with_attachments");

    // remove error message
    this.textareaWrapperEl.find(".upload_error").remove();

    // empty upload-photo
    this.infoEl.empty();

    // close publishing area (CSS)
    this.$("form").addClass("closed").removeClass("open");

    return this;
  },

  storeTextareaValue: function() {
    this.textareaValue = this.textareaEl.val();
  },

  updateTexareaValue: function(value) {
    this.textareaEl.val(value);
    this.storeTextareaValue();
    this.setSubmitButtonState();
    autosize.update(this.textareaEl);
  },

  expandComments: function(evt){
    if(evt){ evt.preventDefault(); }
    var self = this;

    this.model.comments.fetch({
      success : function(resp){
        self.$("div.comment.show_comments").addClass("hidden");

        self.model.trigger("commentsExpanded", self);
      }
    });
  },

  uploadProgressHandler: function(id, fileName, loaded, total) {
    var progress = Math.round(loaded / total * 100),
        progressBarEl = this.photozoneEl
          .find("li.loading img[data-id='" + id + "']")
          .siblings(".progress")
          .find(".progress-bar");

    this.infoEl.text(fileName + " " + progress + "%").fadeTo(200, 1);
    progressBarEl.width(progress + "%");
  },

  uploadSubmitHandler: function() {
    this.$el.addClass("loading");
    this._addPhotoPlaceholder();
  },

  uploadCompleteHandler: function(_id, fileName, response) {
    if (response.success) {
      this.infoEl.text(Diaspora.I18n.t("photo_uploader.completed", {file: fileName})).fadeTo(2000, 0);

      var id  = response.data.photo.id,
          url = response.data.photo.unprocessed_image.scaled_full.url;

      this._addFinishedPhoto(id, url);
      this.trigger("change");
    } else {
      this._cancelPhotoUpload();
      this.trigger("change");
      this.infoEl.text(Diaspora.I18n.t("photo_uploader.error", {file: fileName}));
      this.textareaWrapperEl.find(".photodropzone_container").first().after(
        "<div class=\"upload_error\">" +
        Diaspora.I18n.t("photo_uploader.error", {file: fileName}) +
        "</div>"
      );
    }
  },

  // add photo placeholder to the publisher to indicate an upload in progress
  _addPhotoPlaceholder: function() {
    var id = this.photozoneEl.find("li.publisher_photo").length;

    this.photozoneEl.append(
      "<li class=\"publisher_photo loading\" style=\"position:relative;\">" +
      "  <div class=\"progress\">" +
      "    <div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\"></div>" +
      "  </div>" +
      "  <img data-id=\"" + id +"\" src=\"\"+Handlebars.helpers.imageUrl(\"ajax-loader2.gif\")+\"\"" +
      "    class=\"ajax-loader\" alt=\"\" />" +
      "</li>"
    );
    this.textareaWrapperEl.addClass("with_attachments");
  },

  // replace the first photo placeholder with the finished uploaded image and
  // add the id to the publishers form
  _addFinishedPhoto: function(id, url) {
    // add form input element
    this.$el.append(
      "<input type=\"hidden\" value=\"" + id + "\" name=\"photos[]\" />"
    );

    // replace placeholder
    var placeholder = this.photozoneEl.find("li.loading").first(),
        imgEl = placeholder.find("img");

    placeholder
      .removeClass("loading")
      .prepend("<div class=\"x\"></div>");

    imgEl.attr({"src": url, "data-id": id}).removeClass("ajax-loader");

    placeholder.find("div.progress").remove();

    this.updateTexareaValue(
      this.textareaEl.val() + "![" +
      Diaspora.I18n.t("publisher.markdown_editor.texts.insert_image_description_text") +
      "](" + imgEl[0].src + " \"" +
      Diaspora.I18n.t("publisher.markdown_editor.texts.insert_image_title") + "\")"
    );
  },

  _cancelPhotoUpload: function() {
    var placeholder = this.photozoneEl.find("li.loading").first();

    placeholder
      .removeClass("loading")
      .find("img").remove();
  },

  // remove an already uploaded photo
  _removePhoto: function(evt) {
    var self = this;
    var photo = $(evt.target).parents(".publisher_photo");

    this.removePhoto(photo);

    return false;
  },

  removePhoto: function(photo) {
    photo.addClass("dim");

    var img = photo.find("img");

    if (!img.length) {
      photo.remove();
      return;
    }

    var imgUrl = img[0].src,
        markdownRegex = new RegExp("!\\[[^\\]]*\\]\\(" + imgUrl + "( *|( +\"[^\"]*\" *))?\\)", "g"),
        self = this;

    $.ajax({
      url: "/photos/" + img.attr("data-id"),
      dataType: "json",
      type: "DELETE",
      success: function() {
        $.when(photo.fadeOut(400)).then(function() {
          photo.remove();
          self.updateTexareaValue(self.textareaEl.val().replace(markdownRegex, ""));

          if (self.$(".publisher_photo").length === 0) {
            // no more photos left...
            self.textareaWrapperEl.removeClass("with_attachments");
          }

          self.trigger("change");
        });
      }
    });
  },

  // Disable submit button unless there's text or photo.
  setSubmitButtonState: function() {
    var onlyWhitespaces = $.trim(this.$(".comment_box").val()) === "",
        isPhotoAttached = this.photozoneEl.children().length > 0,
        isSubmittable = !onlyWhitespaces || isPhotoAttached;

    this.$(".submit_button").attr("disabled", !isSubmittable);
  }
});
// @license-end

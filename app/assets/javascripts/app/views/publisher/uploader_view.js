// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

// Uploader view for the publisher.
// Initializes the file uploader plugin and handles callbacks for the upload
// progress. Attaches previews of finished uploads to the publisher.

app.views.PublisherUploader = Backbone.View.extend({
  initialize: function(opts) {
    this.publisher = opts.publisher;

    this.info = $("<div id=\"fileInfo\" />");
    this.publisher.wrapperEl.before(this.info);
    this.publisher.photozoneEl.on("click", ".x", _.bind(this._removePhoto, this));

    // Initialize the PostPhotoUploader and subscribe its events
    this.uploader = new Diaspora.PostPhotoUploader(this.el);

    this.uploader.onUploadStarted = _.bind(this.uploadStartedHandler, this);
    this.uploader.onProgress = _.bind(this.progressHandler, this);
    this.uploader.onUploadCompleted = _.bind(this.uploadCompleteHandler, this);
  },

  // add photo placeholders to the publisher to indicate an upload in progress
  _addPhotoPlaceholder: function() {
    var publisher = this.publisher;
    publisher.setButtonsEnabled(false);

    publisher.wrapperEl.addClass("with_attachments");
    publisher.photozoneEl.append(
      "<li class=\"publisher_photo loading\" style=\"position:relative;\">" +
      "  <div class=\"progress\">" +
      "    <div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\"></div>"+
      "  </div>" +
      "  <img src=\"\"+Handlebars.helpers.imageUrl(\"ajax-loader2.gif\")+\"\" class=\"ajax-loader\" alt=\"\" />"+
      "</li>"
    );
  },

  uploadStartedHandler: function() {
    this.$el.addClass("loading");
    this._addPhotoPlaceholder();
  },

  progressHandler: function(fileName, progress) {
    this.info.text(fileName + " " + progress + "%").fadeTo(200, 1);
    this.publisher.photozoneEl
      .find("li.loading").first().find(".progress-bar")
      .width(progress + "%");
  },

  uploadCompleteHandler: function(_id, fileName, response) {
    if (response.success){
      this.info.text(Diaspora.I18n.t("photo_uploader.completed", {file: fileName})).fadeTo(2000, 0);

      var id  = response.data.photo.id,
          image = response.data.photo.unprocessed_image;

      this._addFinishedPhoto(id, image);
      this.trigger("change");
    } else {
      this._cancelPhotoUpload();
      this.trigger("change");
      this.info.text(Diaspora.I18n.t("photo_uploader.error", {file: fileName}));
      this.publisher.wrapperEl.find("#photodropzone_container").first().after(
        "<div id=\"upload_error\">" +
        Diaspora.I18n.t("photo_uploader.error", {file: fileName}) +
        "</div>"
      );
    }
  },

  // replace the first photo placeholder with the finished uploaded image and
  // add the id to the publishers form
  _addFinishedPhoto: function(id, image) {
    var publisher = this.publisher;

    // add form input element
    publisher.$(".content_creation form").append(
      "<input type=\"hidden\", value=\""+id+"\" name=\"photos[]\" />"
    );
    // replace placeholder
    var placeholder = publisher.photozoneEl.find("li.loading").first();
    placeholder
      .removeClass("loading")
      .prepend(
        "<div class=\"x\"></div>"+
        "<div class=\"circle\"></div>"
       )
      .find("img").attr(
      {
        "src": image.thumb_medium.url,
        "data-small": image.thumb_small.url,
        "data-scaled": image.scaled_full.url,
        "data-id": id
      }).removeClass("ajax-loader");
    placeholder
      .find("div.progress").remove();

    // no more placeholders? enable buttons
    if( publisher.photozoneEl.find("li.loading").length === 0 ) {
      this.$el.removeClass("loading");
      publisher.setButtonsEnabled(true);
    }
  },

  _cancelPhotoUpload: function() {
    var publisher = this.publisher;
    var placeholder = publisher.photozoneEl.find("li.loading").first();
    placeholder
      .removeClass("loading")
      .find("img").remove();
  },

  // remove an already uploaded photo
  _removePhoto: function(evt) {
    var self  = this;
    var photo = $(evt.target).parents(".publisher_photo");
    var img   = photo.find("img");

    photo.addClass("dim");
    $.ajax({
      url: "/photos/"+img.attr("data-id"),
      dataType: "json",
      type: "DELETE",
      success: function() {
        photo.fadeOut(400, function() {
          photo.remove();

          if( self.publisher.$(".publisher_photo").length === 0 ) {
            // no more photos left...
            self.publisher.wrapperEl.removeClass("with_attachments");
          }

          self.trigger("change");
        });
      }
    });

    return false;
  }

});
// @license-end

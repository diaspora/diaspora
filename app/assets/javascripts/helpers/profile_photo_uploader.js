// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.ProfilePhotoUploader = function() {
  this.initialize();
};

Diaspora.ProfilePhotoUploader.prototype = {
  constructor: Diaspora.ProfilePhotoUploader,

  initialize: function() {
    new qq.FileUploaderBasic({
      element: document.getElementById("file-upload"),
      params: {"photo": {"pending": true, "aspect_ids": "all", "set_profile_photo": true}},
      allowedExtensions: ["jpg", "jpeg", "png"],
      action: "/photos",
      button: document.getElementById("file-upload"),
      sizeLimit: 4194304,

      onProgress: function(id, fileName, loaded, total) {
        var progress = Math.round(loaded / total * 100);
        $("#fileInfo").text(fileName + " " + progress + "%");
      },

      messages: {
        typeError: Diaspora.I18n.t("photo_uploader.invalid_ext"),
        sizeError: Diaspora.I18n.t("photo_uploader.size_error"),
        emptyError: Diaspora.I18n.t("photo_uploader.empty")
      },

      onSubmit: function() {
        $("#file-upload").addClass("loading");
        $("#profile_photo_upload").find(".avatar").addClass("loading");
        $("#file-upload-spinner").removeClass("hidden");
        $("#fileInfo").show();
      },

      onComplete: function(_id, fileName, responseJSON) {
        $("#file-upload-spinner").addClass("hidden");
        $("#fileInfo").text(Diaspora.I18n.t("photo_uploader.completed", {"file": fileName}));
        $("#file-upload").removeClass("loading");

        /* flash message prompt */
        var message = Diaspora.I18n.t("photo_uploader.looking_good");
        if (app.flashMessages) { app.flashMessages.success(message); }

        var id = responseJSON.data.photo.id;
        var url = responseJSON.data.photo.unprocessed_image.url;
        var oldPhoto = $("#photo_id");
        if (oldPhoto.length === 0) {
          $("#update_profile_form").prepend("<input type='hidden' value='" + id + "' id='photo_id' name='photo_id'/>");
        } else {
          oldPhoto.val(id);
        }

        $("#profile_photo_upload").find(".avatar").removeClass("loading");
        $("#profile_photo_upload").find(".avatar").attr("src", url);
      }
    });
  }
};
// @license-end

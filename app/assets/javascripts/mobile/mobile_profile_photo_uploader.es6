// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.ProfilePhotoUploader = class {
  /**
   * Initializes a new instance of ProfilePhotoUploader
   */
  constructor() {
    // get several elements we will use a few times
    this.container = $("#profile_photo_upload");
    this.avatar = this.container.find(".avatar");
    this.button = $("#file-upload");
    this.fileInfo = $("#fileInfo");
    this.spinner = $("#file-upload-spinner");
    this.allowedExtensions = [".jpg", ".jpeg", ".png"];
    this.uppy = null;

    /**
     * Shows a message using flash messages or alert for mobile.
     * @param {string} type - The type of the message, e.g. "error" or "success".
     * @param text - The text to display.
     */
    this.showMessage = (type, text) => (app.flashMessages ? app.flashMessages[type](text) : alert(text));

    this.initUppy();
  }

  initUppy() {
    this.uppy = new window.Uppy.Core({
      id: "profile-photo-uppy",
      autoProceed: true,
      allowMultipleUploads: false,
      restrictions: {
        allowedFileTypes: this.allowedExtensions,
        maxFileSize: 4194304
      },
      locale: {
        strings: {
          exceedsSize: Diaspora.I18n.t("photo_uploader.size_error"),
          youCanOnlyUploadFileTypes: Diaspora.I18n.t("photo_uploader.invalid_ext").replace("{extensions}", "%{types}")
        }
      }
    });

    const fileInput = $(".uppy-file-picker");
    fileInput.attr("accept", this.allowedExtensions.join(","));

    fileInput.on("change", (event) => {
      const file = event.target.files[0];
      try {
        this.uppy.addFile({
          source: "file input",
          name: file.name,
          type: file.type,
          data: file
        });
      } catch (err) {
        this.showMessage("error", err.message.replace("{file}", file.name).replace("{sizeLimit}.", ""));
      }
    });

    this.uppy.setMeta({
      /* eslint-disable camelcase */
      authenticity_token: $("meta[name='csrf-token']").attr("content"),
      "photo[pending]": true,
      "photo[aspect_ids]": "all",
      "photo[set_profile_photo]": true
      /* eslint-enable camelcase */
    });

    this.uppy.use(window.Uppy.XHRUpload, {
      endpoint: Routes.photos(),
      fieldName: "file"
    });

    this.uppy.on("file-added", (file) => {
      this.uppy.setFileMeta(file.id, {
        totalfilesize: file.size,
        filename: file.name
      });
      this.button.addClass("loading");
      this.avatar.addClass("loading");
      this.spinner.removeClass("hidden");
      this.fileInfo.show();
    });

    this.uppy.on("upload-progress", (file, progress) =>
      this.fileInfo.text(`${file.name} ${Math.round(progress.bytesUploaded / progress.bytesTotal * 100)} %`)
    );

    this.uppy.on("upload-success", (file, response) => {
      this.spinner.addClass("hidden");
      this.fileInfo.text(Diaspora.I18n.t("photo_uploader.completed", {"file": file.name}));
      this.button.removeClass("loading");

      if (response.body.data !== undefined) {
        /* flash message prompt */
        var message = Diaspora.I18n.t("photo_uploader.looking_good");

        var photoId = response.body.data.photo.id;
        var url = response.body.data.photo.unprocessed_image.url;
        var oldPhoto = $("#photo_id");
        if (oldPhoto.length === 0) {
          $("#update_profile_form")
          .prepend(`<input type="hidden" value="${photoId}" id="photo_id" name="photo_id" />`);
        } else {
          oldPhoto.val(photoId);
        }

        this.avatar.attr("src", url);
        this.showMessage("success", message);
      }
      this.avatar.removeClass("loading");
    });

    this.uppy.on("complete", () => this.uppy.reset());

    this.uppy.on("upload-error", (file, error) =>
      this.showMessage("error", error.message)
    );
  }
};
// @license-end

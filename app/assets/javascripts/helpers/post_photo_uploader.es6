// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.PostPhotoUploader = class {
  /**
   * Initializes a new instance of PostPhotoUploader
   * This class handles uploading photos and provides client side scaling
   */
  constructor(el, aspectIds) {
    this.element = el;
    this.sizeLimit = 4194304;
    this.allowedExtensions = [".jpg", ".jpeg", ".png", ".gif"];
    this.aspectIds = aspectIds;

    this.onProgress = null;
    this.onUploadStarted = null;
    this.onUploadCompleted = null;
    this.uppy = null;

    /**
     * Shows a message using flash messages or alert for mobile.
     * @param {string} type - The type of the message, e.g. "error" or "success".
     * @param text - The text to display.
     */
    this.showMessage = (type, text) => (app.flashMessages ? app.flashMessages[type](text) : alert(text));

    /**
     * Returns true if the given parameter is a function
     * @param {param} - The object to check
     * @returns {boolean}
     */
    this.func = param => (typeof param === "function");

    this.initUppy();
  }

  /**
   * Initializes uppy
   */
  initUppy() {
    this.uppy = new window.Uppy.Core({
      id: "post-photo-uppy",
      autoProceed: true,
      allowMultipleUploads: true,
      restrictions: {
        maxFileSize: (window.Promise ? null : this.sizeLimit),
        allowedFileTypes: this.allowedExtensions
      },
      locale: {
        strings: {
          exceedsSize: Diaspora.I18n.t("photo_uploader.size_error"),
          youCanOnlyUploadFileTypes: Diaspora.I18n.t("photo_uploader.invalid_ext").replace("{extensions}", "%{types}")
        }
      },
    });

    const fileInput = $(".uppy-file-picker");
    fileInput.attr("accept", this.allowedExtensions.join(","));

    fileInput.on("change", (event) => {
      const files = event.target.files;

      for (let i = 0; i < files.length; i++) {
        let file = files[i];
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
      }
    });

    this.uppy.setMeta({
      /* eslint-disable camelcase */
      authenticity_token: $("meta[name='csrf-token']").attr("content"),
      "photo[pending]": true,
      "photo[aspect_ids]": this.aspectIds
      /* eslint-enable camelcase */
    });

    this.uppy.use(window.Uppy.XHRUpload, {
      endpoint: Routes.photos(),
      fieldName: "file",
      limit: 10
    });

    this.uppy.use(window.Resizer, {
      maxSize: 3072,
      maxFileSize: this.sizeLimit
    });

    this.uppy.on("file-added", (file) => {
      this.uppy.setFileMeta(file.id, {
        totalfilesize: file.size,
        filename: file.name
      });
    });

    this.uppy.on("upload", (data) =>
      this.func(this.onUploadStarted) && data.fileIDs.forEach(fileID => this.onUploadStarted(fileID))
    );

    this.uppy.on("upload-progress", (file, progress) => this.func(this.onProgress)
      && this.onProgress(file.id, file.name, Math.round(progress.bytesUploaded / progress.bytesTotal * 100))
    );

    this.uppy.on("upload-success", (file, response) => {
      this.func(this.onUploadCompleted) && this.onUploadCompleted(file.id, file.name, response.body);
    });

    this.uppy.on("upload-error", (file, error) => this.showMessage("error", error.message));
  }
};
// @license-end

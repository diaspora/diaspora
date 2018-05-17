// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.PostPhotoUploader = class {
  /**
   * Initializes a new instance of PostPhotoUploader
   * This class handles uploading photos and provides client side scaling
   */
  constructor(el, aspectIds) {
    this.element = el;
    this.sizeLimit = 4194304;
    this.aspectIds = aspectIds;

    this.onProgress = null;
    this.onUploadStarted = null;
    this.onUploadCompleted = null;

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

    this.initFineUploader();
  }

  /**
   * Initializes the fine uploader component
   */
  initFineUploader() {
    this.fineUploader = new qq.FineUploaderBasic({
      element: this.element,
      button: this.element,
      text: {
        fileInputTitle: Diaspora.I18n.t("photo_uploader.upload_photos")
      },
      request: {
        endpoint: Routes.photos(),
        params: {
          /* eslint-disable camelcase */
          authenticity_token: $("meta[name='csrf-token']").attr("content"),
          photo: {
            pending: true,
            aspect_ids: this.aspectIds
          }
          /* eslint-enable camelcase */
        }
      },
      validation: {
        allowedExtensions: ["jpg", "jpeg", "png", "gif"],
        sizeLimit: (window.Promise && qq.supportedFeatures.scaling ? null : this.sizeLimit)
      },
      messages: {
        typeError: Diaspora.I18n.t("photo_uploader.invalid_ext"),
        sizeError: Diaspora.I18n.t("photo_uploader.size_error"),
        emptyError: Diaspora.I18n.t("photo_uploader.empty")
      },
      callbacks: {
        onSubmit: (id, name) => this.onPictureSelected(id, name),
        onUpload: (id, name) => (this.func(this.onUploadStarted) && this.onUploadStarted(id, name)),
        onProgress: (id, fileName, loaded, total) =>
          (this.func(this.onProgress) && this.onProgress(id, fileName, Math.round(loaded / total * 100))),
        onComplete: (id, name, json) => (this.func(this.onUploadCompleted) && this.onUploadCompleted(id, name, json)),
        onError: (id, name, errorReason) => this.showMessage("error", errorReason)
      }
    });
  }

  /**
   * Called when a picture from user's device has been selected.
   * Scales the images using Pica if the image exceeds the file size limit
   * @param {number} id - The current file's id.
   * @param {string} name - The current file's name.
   */
  onPictureSelected(id, name) {
    // scale image because it's bigger than the size limit and the browser supports it
    if (this.fineUploader.getSize(id) > this.sizeLimit && window.Promise && qq.supportedFeatures.scaling) {
      this.fineUploader.scaleImage(id, {
        maxSize: 3072,
        customResizer: !qq.ios() && (i => window.pica().resize(i.sourceCanvas, i.targetCanvas))
      }).then(scaledImage => {
        this.fineUploader.addFiles({
          blob: scaledImage,
          name: name
        });
      });

      // since we are adding the smaller scaled image afterwards, we return false
      return false;
    }

    // return true to upload the image without scaling
    return true;
  }
};
// @license-end

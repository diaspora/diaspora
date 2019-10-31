// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.ProfilePhotoUploader = class {
  /**
   * Initializes a new instance of ProfilePhotoUploader
   */
  constructor() {
    // get several elements we will use a few times
    this.fileInput = document.querySelector("#file-upload");
    this.picture = document.querySelector("#profile_photo_upload .avatar");
    this.info = document.querySelector("#fileInfo");
    this.cropContainer = document.querySelector(".crop-container");
    this.spinner = document.querySelector("#file-upload-spinner");
    this.allowedExtensions = [".jpg", ".jpeg", ".png"];
    this.uppy = null;

    /**
     * Creates a button
     * @param {string} icon - The entypo icon class.
     * @param {function} onClick - Is called when button has been clicked.
     */
    this.createButton = (icon, onClick) =>
      ($(`<button class="btn btn-default" type="button"><i class="entypo-${icon}"></i></button>`)
        .on("click", onClick));

    /**
     * Shows a message using flash messages or alert for mobile.
     * @param {string} type - The type of the message, e.g. "error" or "success".
     * @param text - The text to display.
     */
    this.showMessage = (type, text) => (app.flashMessages ? app.flashMessages[type](text) : alert(text));

    this.initUppy();
  }

  /**
   * Initializes uppy
   */
  initUppy() {
    this.uppy = new window.Uppy.Core({
      id: "profile-photo-uppy",
      autoProceed: false,
      allowMultipleUploads: false,
      restrictions: {
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

    fileInput.change("change", (event) => {
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
      if (file.source === "file input") {
        this.onPictureSelected(file.id, file.name);
      }
    });

    this.uppy.on("upload-progress", (file, progress) => {
      this.info.innerText = `${file.name} ${Math.round(progress.bytesUploaded / progress.bytesTotal * 100)}%`;
    });

    this.uppy.on("upload-success", (file, response) =>
      this.onUploadCompleted(file.id, file.name, response.body)
    );

    this.uppy.on("upload-error", (file) =>
      this.showMessage("error", Diaspora.I18n.t("photo_uploader.error", {file: file.name}))
    );
  }

  /**
   * Called when a picture from user's device has been selected.
   * @param {number} id - The current file's id.
   * @param {string} name - The current file's name.
   */
  onPictureSelected(id, name) {
    this.setLoading(true);
    this.fileName = name;
    const file = this.uppy.getFile(id);

    // ensure browser's file reader support
    if (FileReader && file) {
      const fileReader = new FileReader();
      fileReader.onload = () => this.initCropper(fileReader.result);
      fileReader.readAsDataURL(file.data);
    } else {
      this.setLoading(false);
    }
  }

  /**
   * Initializes the cropper and all controls.
   * @param {object|string} imageData - The base64 image data
   */
  initCropper(imageData) {
    // cache the current picture source if the user cancels
    this.previousPicture = this.picture.getAttribute("src");

    this.mimeType = imageData.split(";base64")[0].substring(5);

    this.picture.onload = () => {
      // set the preferred size style of the cropper based on picture orientation
      const isPortrait = this.picture.naturalHeight > this.picture.naturalWidth;
      this.picture.setAttribute("style", (isPortrait ? "max-height:600px;max-width:none;" : "max-width:600px;"));
      this.buildControls();

      this.setLoading(false);

      // eslint-disable-next-line no-undef
      this.cropper = new Cropper(this.picture, {
        aspectRatio: 1,
        zoomable: false,
        autoCropArea: 1,
        preview: ".preview"
      });
    };
    this.picture.setAttribute("src", imageData);
  }

  /**
   * Creates image manipulation controls and previews.
   */
  buildControls() {
    this.controls = {
      rotateLeft: this.createButton("ccw", () => this.cropper.rotate(-45)),
      rotateRight: this.createButton("cw", () => this.cropper.rotate(45)),
      reset: this.createButton("cycle", () => this.cropper.reset()),
      accept: this.createButton("check", () => this.cropImage()),
      cancel: this.createButton("trash", () => this.cancel(true))
    };

    this.controlRow = $("<div class='controls'>").appendTo(this.cropContainer);

    // rotation buttons on the left
    this.controlRow.append($("<div class='btn-group buttons-left' role='group'>").append([
      this.controls.rotateLeft,
      this.controls.rotateRight
    ]));

    // preview images in the middle
    this.controlRow.append("<div class='preview'>");

    // main buttons on the right
    this.controlRow.append($("<div class='btn-group buttons-right' role='group'>").append([
      this.controls.reset,
      this.controls.cancel,
      this.controls.accept
    ]));
  }

  /**
   * Called when the user clicked accept button. Sets file data and triggers file upload.
   */
  cropImage() {
    const canvas = this.cropper.getCroppedCanvas();

    // replace the stored file with the new canvas
    this.uppy.reset();
    const pica = window.pica();
    pica.toBlob(canvas, "image/jpeg", 0.85)
      .then(blob => {
        // we never get PNGs, so we replace the extension in the file name if necessary
        this.uppy.addFile({
          source: "cropper",
          name: this.fileName.replace(/\.png$/i, ".jpg"),
          type: "image/jpeg",
          data: blob
        });
        // reset all controls
        this.cancel();
        this.picture.setAttribute("src", canvas.toDataURL(this.mimeType));

        // finally start uploading
        this.setLoading(true);
        this.uppy.upload();
      });
  }

  /**
   * Is called after the file upload has been completed and the profile photo changed.
   * @param {number} id - The current file's id.
   * @param {string} fileName - The current file's name.
   * @param {object} responseJSON - The server's json response.
   */
  onUploadCompleted(id, fileName, responseJSON) {
    this.setLoading(false);
    this.fileInput.classList.remove("hidden");

    if (responseJSON.data !== undefined) {
      /* flash message prompt */
      this.showMessage("success", Diaspora.I18n.t("photo_uploader.looking_good"));

      this.info.innerText = Diaspora.I18n.t("photo_uploader.completed", {"file": fileName});

      const photoId = responseJSON.data.photo.id;
      const url = responseJSON.data.photo.unprocessed_image.url;
      const oldPhoto = $("#photo_id");
      if (oldPhoto.length === 0) {
        $("#update_profile_form")
          .prepend(`<input type="hidden" value="${photoId}" id="photo_id" name="photo_id"/>`);
      } else {
        oldPhoto.val(photoId);
      }

      this.picture.setAttribute("src", url);
      $(`.avatar[alt="${gon.user.name}"]`).attr("src", url);
      this.cancel(true, true);
    } else {
      this.cancel();
    }
  }

  /**
   * Toggles loading state by hiding or showing several elements
   * @param {boolean} loading - True if loading state should be enabled.
   */
  setLoading(loading) {
    if (loading) {
      this.fileInput.classList.add("hidden");
      this.picture.classList.add("hidden");
      this.spinner.classList.remove("hidden");
    } else {
      this.picture.classList.remove("hidden");
      this.spinner.classList.add("hidden");
    }
  }

  /**
   * Destroys the cropper and resets all elements to initial state.
   */
  cancel(resetUppy = false, success = false) {
    this.cropper.destroy();
    this.picture.onload = null;
    this.picture.setAttribute("style", "");
    if (!success) {
      this.picture.setAttribute("src", this.previousPicture);
    }
    this.controlRow.remove();
    this.fileInput.classList.remove("hidden");
    this.info.innerText = "";
    if (resetUppy) {
      this.uppy.reset();
    }

    this.mimeType = null;
    this.name = null;
  }
};
// @license-end

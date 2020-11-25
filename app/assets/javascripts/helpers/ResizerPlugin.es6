// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
/**
 * Custom resizer plugin for Uppy. Resizes image files if necessary using Pica image processing library.
 */
window.Resizer = class extends window.Uppy.Core.Plugin {
  constructor(uppy, options) {
    super(uppy, options);
    this.id = options.id || "Resizer";
    this.type = "modifier";
    this.maxSize = options.maxSize;
    this.maxFileSize = options.maxFileSize;

    this.prepareUpload = this.prepareUpload.bind(this);
    this.resize = this.resize.bind(this);
    this.pica = window.pica();
  }

  /**
   * Resizes the file if necessary based on conditions.
   * If the file exceeds the file size limit it will either be resized to maximum dimensions
   * or only recompressed as JPEG (e.g. for huge PNG files not exceeding the dimension limit)
   * @param file The uppy file
   */
  resize(file) {
    return new Promise((resolve) => {
      const img = new Image();
      img.src = URL.createObjectURL(file.data);
      const canvas = document.createElement("canvas");

      img.onload = () => {
        if (img.width > this.maxSize || img.height > this.maxSize) {
          this.uppy.log(`[Resize] ${file.name}:
          Image dimensions ${img.width}x${img.height} are greater than max size ${this.maxSize}.
          Resizing image...`);
          let ratio;

          if (img.height > img.width) {
            ratio = img.width / img.height;
            canvas.width = this.maxSize * ratio;
            canvas.height = this.maxSize;
          } else {
            ratio = img.height / img.width;
            canvas.width = this.maxSize;
            canvas.height = this.maxSize * ratio;
          }
          this.uppy.log(`[Resize] ${file.name}: New image dimensions: ${canvas.width}x${canvas.height}...`);
        } else {
          this.uppy.log(`[Resize] ${file.name}:
          Image dimensions ${img.width}x${img.height} are smaller than max size ${this.maxSize}.
          Saving to JPEG without resizing...`);
          canvas.width = img.width;
          canvas.height = img.height;
        }

        this.pica.resize(img, canvas)
          .then(result => this.pica.toBlob(result, "image/jpeg", 0.85))
          .then(blob => resolve(blob));
      };
    });
  }

  prepareUpload(fileIDs) {
    const promises = fileIDs.map((fileID) => {
      const file = this.uppy.getFile(fileID);
      if (file.type.split("/")[0] !== "image" || (file.size <= this.maxFileSize)) {
        return Promise.resolve();
      }
      this.uppy.log(`[Resize] ${file.name}: File size ${file.size} exceeds max file size of ${this.maxFileSize}.`);

      return this.resize(file).then((blob) => {
        // since size and eventually type are changing,
        // we have to overwrite several redundant information in the file object
        const filename = file.name.replace(/\.png$/i, ".jpg");
        const processedFile = Object.assign({}, file, {
          data: blob,
          size: blob.size,
          progress: Object.assign({}, file.progress, {bytesTotal: blob.size}),
          type: blob.type,
          name: filename,
          extension: file.extension === "png" ? "jpg" : file.extension,
          meta: Object.assign({}, file.meta, {
            filename: filename,
            name: filename,
            totalfilesize: blob.size,
            type: blob.type
          })
        });
        this.uppy.log(`[Resize] ${filename}: New file size: ${processedFile.data.size}.`);
        this.uppy.setFileState(fileID, processedFile);
      });
    });
    return Promise.all(promises);
  }

  install() {
    this.uppy.addPreProcessor(this.prepareUpload);
  }

  uninstall() {
    this.uppy.removePreProcessor(this.prepareUpload);
  }
}
// @license-end

// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
//= require js_image_paths

function createUploader(){
  var aspectIds = gon.preloads.aspect_ids;
  var fileInfo = $("#fileInfo-publisher");

  // Initialize the PostPhotoUploader and subscribe its events
  this.uploader = new Diaspora.PostPhotoUploader(document.getElementById("file-upload-publisher"), aspectIds);

  this.uploader.onUploadStarted = _.bind(uploadStartedHandler, this);
  this.uploader.onProgress = _.bind(progressHandler, this);
  this.uploader.onUploadCompleted = _.bind(uploadCompletedHandler, this);

  function progressHandler(fileName, progress) {
    fileInfo.text(fileName + " " + progress + "%");
  }

  function uploadStartedHandler() {
    $("#publisher-textarea-wrapper").addClass("with_attachments");
    $("#photodropzone").append(
      "<li class='publisher_photo loading' style='position:relative;'>" +
      "<img alt='Ajax-loader2' src='" + ImagePaths.get("ajax-loader2.gif") + "' />" +
      "</li>"
    );
  }

  function uploadCompletedHandler(_id, fileName, responseJSON) {
    if (responseJSON.data === undefined) {
      return;
    }

    fileInfo.text(Diaspora.I18n.t("photo_uploader.completed", {"file": fileName}));
    var id = responseJSON.data.photo.id,
        image = responseJSON.data.photo.unprocessed_image,
        currentPlaceholder = $("li.loading").first();

    $("#publisher-textarea-wrapper").addClass("with_attachments");
    $("#new_status_message").append("<input type='hidden' value='" + id + "' name='photos[]' />");

    // replace image placeholders
    var img = currentPlaceholder.find("img");
    img.attr("src", image.thumb_medium.url);
    img.attr("data-small", image.thumb_small.url);
    img.attr("data-scaled", image.scaled_full.url);
    img.attr("data-id", id);
    currentPlaceholder.removeClass("loading");
    currentPlaceholder.append("<div class='x'>X</div>" +
      "<div class='circle'></div>");

    var publisher = $("#publisher");

    publisher.find("input[type='submit']").removeAttr("disabled");

    $(".x").bind("click", function() {
      var photo = $(this).closest(".publisher_photo");
      photo.addClass("dim");
      $.ajax({
        url: "/photos/" + photo.children("img").attr("data-id"),
        dataType: "json",
        type: "DELETE",
        success: function() {
          photo.fadeOut(400, function() {
            photo.remove();
            if ($(".publisher_photo").length === 0) {
              $("#publisher-textarea-wrapper").removeClass("with_attachments");
            }
          });
        }
      });
    });
  }
}
window.addEventListener("load", function() {
  createUploader();
});
// @license-end

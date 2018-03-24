// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
//= require js_image_paths

function createUploader(){
   var aspectIds = gon.preloads.aspect_ids;

  new qq.FineUploaderBasic({
    element: document.getElementById("file-upload-publisher"),
    request: {
      endpoint: Routes.photos(),
      params: {
        /* eslint-disable camelcase */
        authenticity_token: $("meta[name='csrf-token']").attr("content"),
        photo: {
          aspect_ids: aspectIds,
          /* eslint-enable camelcase */
          pending: true
        }
      }
    },
    validation: {
      allowedExtensions: ["jpg", "jpeg", "png", "gif"],
      sizeLimit: 4194304
    },
    button: document.getElementById("file-upload-publisher"),
    text: {
      fileInputTitle: Diaspora.I18n.t("photo_uploader.upload_photos")
    },

    callbacks: {
      onProgress: function(id, fileName, loaded, total) {
        var progress = Math.round(loaded / total * 100);
        $("#fileInfo-publisher").text(fileName + " " + progress + "%");
      },
      onSubmit: function() {
        $("#publisher-textarea-wrapper").addClass("with_attachments");
        $("#photodropzone").append(
          "<li class='publisher_photo loading' style='position:relative;'>" +
          "<img alt='Ajax-loader2' src='" + ImagePaths.get("ajax-loader2.gif") + "' />" +
          "</li>"
        );
      },
      onComplete: function(_id, fileName, responseJSON) {
        if (responseJSON.data === undefined) {
          return;
        }

        $("#fileInfo-publisher").text(Diaspora.I18n.t("photo_uploader.completed", {"file": fileName}));
        var id = responseJSON.data.photo.id,
            url = responseJSON.data.photo.unprocessed_image.url,
            currentPlaceholder = $("li.loading").first();

        $("#publisher-textarea-wrapper").addClass("with_attachments");
        $("#new_status_message").append("<input type='hidden' value='" + id + "' name='photos[]' />");

        // replace image placeholders
        var img = currentPlaceholder.find("img");
        img.attr("src", url);
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
      },
      onError: function(id, name, errorReason) {
        alert(errorReason);
      }
    },
    messages: {
      typeError: Diaspora.I18n.t("photo_uploader.invalid_ext"),
      sizeError: Diaspora.I18n.t("photo_uploader.size_error"),
      emptyError: Diaspora.I18n.t("photo_uploader.empty")
    }
  });
}
window.addEventListener("load", function() {
  createUploader();
});
// @license-end

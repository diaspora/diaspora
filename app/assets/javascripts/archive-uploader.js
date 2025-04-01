const profileFileChosen = $("#profile-file-chosen");
const photosFileChosen = $("#photos-file-chosen");

const checkProfileUploadButton = function() {
  let photoFiles = $("#profile-file-btn")[0].files;
  let profileFiles = $("#photos-file-btn")[0].files;

  $("#upload_profile_files")[0].disabled = (photoFiles.length + profileFiles.length === 0);
};

const getFilename = function(files) {
  if (files && files.length > 0) {
    return files[0].name;
  }
  return "";
};

$("#profile-file-btn").on("change", function() {
  profileFileChosen.text(getFilename(this.files));
  checkProfileUploadButton();
});

$("#photos-file-btn").on("change", function() {
  photosFileChosen.text(getFilename(this.files));
  checkProfileUploadButton();
});

$("#cancel-import").on("click", function() {
  $("#profile-file-btn").val("");
  profileFileChosen.text("");

  $("#photos-file-btn").val("");
  photosFileChosen.text("");
});


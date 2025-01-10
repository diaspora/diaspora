const checkProfileUploadButton = function() {
  let photoFiles = $("#profile-file-btn")[0].files;
  let profileFiles = $("#photos-file-btn")[0].files;
  if ((photoFiles.size + profileFiles.size) === 0) {
    $("#upload_profile_files").attr("disabled", "disabled");
  } else {
    $("#upload_profile_files").removeAttr("disabled");
  }
};
const profileFileChosen = $("#profile-file-chosen");
const photosFileChosen = $("#photos-file-chosen");

$("#profile-file-btn").on("change", function() {
  profileFileChosen.textContent = this.files[0].name;
  checkProfileUploadButton();
});

$("#photos-file-btn").on("change", function() {
  photosFileChosen.textContent = this.files[0].name;
  checkProfileUploadButton();
});

const checkProfileUploadButton = function() {
  let photoFiles = $("#profile-file-btn")[0].files;
  let profileFiles = $("#photos-file-btn")[0].files;
  if ((photoFiles.size + profileFiles.size) === 0) {
    $("#upload_profile_files").attr("disabled", "disabled");
  } else {
    $("#upload_profile_files").removeAttr("disabled");
  }
};
const profileFileButton = document.getElementById("profile-file-btn");
const profileFileChosen = document.getElementById("profile-file-chosen");

const photosFileButton = document.getElementById("photos-file-btn");
const photosFileChosen = document.getElementById("photos-file-chosen");

profileFileButton.addEventListener("change", function() {
  profileFileChosen.textContent = this.files[0].name;
  checkProfileUploadButton();
});

photosFileButton.addEventListener("change", function() {
  photosFileChosen.textContent = this.files[0].name;
  checkProfileUploadButton();
});

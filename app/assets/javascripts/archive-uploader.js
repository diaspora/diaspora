const profileFileBtn = document.getElementById("profile-file-btn");

const profileFileChosen = document.getElementById("profile-file-chosen");

profileFileBtn.addEventListener("change", function() {
  profileFileChosen.textContent = this.files[0].name;
});

const photosFileBtn = document.getElementById("photos-file-btn");

const photosFileChosen = document.getElementById("photos-file-chosen");

photosFileBtn.addEventListener("change", function() {
  photosFileChosen.textContent = this.files[0].name;
});

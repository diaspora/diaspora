// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

$(document).ready(function() {
  if (Diaspora.Page === "ProfilesEdit") {
    new Diaspora.TagsAutocomplete("#profile_tag_string", {preFill: gon.preloads.tagsArray});
    new Diaspora.ProfilePhotoUploader();
  } else if (Diaspora.Page === "UsersGettingStarted") {
    new Diaspora.TagsAutocomplete("#follow_tags", {preFill: gon.preloads.tagsArray});
    new Diaspora.ProfilePhotoUploader();
  }
});
// @license-end

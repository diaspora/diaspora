$(document).ready(function() {
  $("#aspect_ids_").multiselect({
    dropRight: true,
    enableClickableOptGroups: true,
    maxHeight: 200,
    nonSelectedText: Diaspora.I18n.t("aspect_dropdown.select_aspects"),
    numberDisplayed: 1,
    nSelectedText: "Aspects",
    onChange: function(option, checked) {
      var hasPublic = $(option).val() === "public";
      var hasAllAspects = $(option).val() === "all_aspects";

      if (hasPublic && checked) {
        $("#aspect_ids_").multiselect("deselectAll", false);
        $("#aspect_ids_").multiselect("select", "public");
      } else if (hasPublic && !checked) {
        $("#aspect_ids_").multiselect("select", "public");
      } else if (hasAllAspects && checked) {
        $("#aspect_ids_").multiselect("deselectAll", false);
        $("#aspect_ids_").multiselect("select", "all_aspects");
      } else if (hasAllAspects && !checked) {
        $("#aspect_ids_").multiselect("select", "all_aspects");
      } else if (checked) {
        $("#aspect_ids_").multiselect("deselect", "all_aspects");
        $("#aspect_ids_").multiselect("deselect", "public");
      }
    }
  });
});

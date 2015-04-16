// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*
 * Aspects view for the publishers aspect dropdown and the aspect membership dropdown.
 */
app.views.AspectsDropdown = app.views.Base.extend({
  _toggleCheckbox: function(target) {
    this.$('.dropdown-menu > li.radio').removeClass('selected');
    target.toggleClass('selected');
  },

  _toggleRadio: function(target) {
    this.$('.dropdown-menu > li').removeClass('selected');
    target.toggleClass('selected');
  },

  // select aspects in the dropdown by a given list of ids
  _selectAspects: function(ids) {
    this.$('.dropdown-menu > li').each(function() {
      var el = $(this);
      if (_.contains(ids, el.data('aspect_id'))) {
        el.addClass('selected');
      } else {
        el.removeClass('selected');
      }
    });
  },

  // change class and text of the dropdown button
  _updateButton: function(inAspectClass) {
    var button = this.$('.btn.dropdown-toggle'),
      selectedAspects = this.$(".dropdown-menu > li.selected").length,
      buttonText;

    if (selectedAspects === 0) {
      button.removeClass(inAspectClass).addClass('btn-default');
      buttonText = Diaspora.I18n.t("aspect_dropdown.select_aspects");
    } else {
      button.removeClass('btn-default').addClass(inAspectClass);
      if (selectedAspects === 1) {
        buttonText = this.$(".dropdown-menu > li.selected .text").first().text();
      } else {
        buttonText = Diaspora.I18n.t("aspect_dropdown.toggle", { count: selectedAspects.toString() });
      }
    }

    button.find('.text').text(buttonText);
  }
});
// @license-end


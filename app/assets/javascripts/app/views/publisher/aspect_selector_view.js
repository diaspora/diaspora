// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//= require ../aspects_dropdown_view

/*
 * Aspects view for the publisher.
 * Provides the ability to specify the visibility of posted content as public
 * or limited to selected aspects
 */
app.views.PublisherAspectSelector  = app.views.AspectsDropdown.extend({

  events: {
    "click .dropdown-menu > li": "toggleAspect"
  },

  initialize: function(opts) {
    this.form = opts.form;
  },

  // event handler for aspect selection
  toggleAspect: function(evt) {
    var target = $(evt.target).closest('li');

    // visually toggle the aspect selection
    if (target.is('.radio')) {
      this._toggleRadio(target);
    } else if (target.is('.aspect_selector')) {
      // don't close the dropdown
      evt.stopPropagation();
      this._toggleCheckbox(target);
    }

    this._updateSelectedAspectIds();
    this._updateButton('btn-default');

    // update the globe or lock icon
    var icon = this.$("#visibility-icon");
    if (target.find(".text").text().trim() === Diaspora.I18n.t("stream.public")) {
      icon.removeClass("entypo-lock");
      icon.addClass("entypo-globe");
    } else {
      icon.removeClass("entypo-globe");
      icon.addClass("entypo-lock");
    }
  },

  // select a (list of) aspects in the dropdown selector by the given list of ids
  updateAspectsSelector: function(ids){
    this._selectAspects(ids);
    this._updateSelectedAspectIds();
    this._updateButton('btn-default');
  },

  // take care of the form fields that will indicate the selected aspects
  _updateSelectedAspectIds: function() {
    var self = this;

    // remove previous selection
    this.form.find('input[name="aspect_ids[]"]').remove();

    // create fields for current selection
    this.$('li.selected').each(function() {
      var uid = _.uniqueId('aspect_ids_');
      var id = $(this).data('aspect_id');
      self.form.append(
        '<input id="'+uid+'" name="aspect_ids[]" type="hidden" value="'+id+'">'
      );
    });
  }
});
// @license-end


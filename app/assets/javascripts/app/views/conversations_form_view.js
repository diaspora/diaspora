// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ConversationsForm = Backbone.View.extend({

  initialize: function(opts) {
    this.contacts = _.has(opts, 'contacts') ? opts.contacts : null;
    this.prefill = [];
    if (_.has(opts, 'prefillName') && _.has(opts, 'prefillValue')) {
      this.prefill = [{name : opts.prefillName, 
                       value : opts.prefillValue}];
    }
    this.autocompleteInput = $("#contact_autocomplete");
    this.prepareAutocomplete(this.contacts);
  },

  prepareAutocomplete: function(data){
    this.autocompleteInput.autoSuggest(data, {
      selectedItemProp: "name",
      searchObjProps: "name",
      asHtmlID: "contact_ids",
      retrieveLimit: 10,
      minChars: 1,
      keyDelay: 0,
      startText: '',
      emptyText: Diaspora.I18n.t('no_results'),
      preFill: this.prefill 
    }).focus();
  }
});
// @license-end


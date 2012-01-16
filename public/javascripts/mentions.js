var Mentions = {
  initialize: function(mentionsInput) {
    Mentions.fetchContacts(function(data) {
      Mentions.contacts = data;
      mentionsInput.mentionsInput(Mentions.options);
    });
  },

  fetchContacts: function(callback) {
    $.getJSON($(".selected_contacts_link").attr("href"), callback);
  },

  options: {
    elastic: false,

    onDataRequest: function(mode, query, callback) {
      var filteredResults = _.filter(Mentions.contacts, function(item) { return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 });

      callback.call(this, filteredResults);
    },

    templates: {
      mentionItemSyntax: _.template("@{<%= mention.name %> ; <%= mention.handle %>}")
    }
  }
};

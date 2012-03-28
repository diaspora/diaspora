var Mentions = {
  initialize: function(mentionsInput) {
    return mentionsInput.mentionsInput(Mentions.options);
  },

  fetchContacts : function(){
    Mentions.contacts || $.getJSON("/contacts", function(data) {
      Mentions.contacts = data;
    });
  },

  options: {
    elastic: false,
    minChars: 1,

    onDataRequest: function(mode, query, callback) {
      var filteredResults = _.filter(Mentions.contacts, function(item) { return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 });

      callback.call(this, filteredResults.slice(0,5));
    },

    templates: {
      mentionItemSyntax: _.template("@{<%= mention.name %> ; <%= mention.handle %>}")
    }
  }
};

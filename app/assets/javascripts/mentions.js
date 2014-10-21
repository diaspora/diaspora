// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

var Mentions = {
  initialize: function(mentionsInput) {
    return mentionsInput.mentionsInput(Mentions.options);
  },

  // pre-fetch the list of contacts for the current user.
  // called by the initializer of the publisher, for faster ('offline')
  // execution of the filtering for mentions
  fetchContacts : function(){
    Mentions.contacts || $.getJSON("/contacts", function(data) {
      Mentions.contacts = Mentions.createList(data);
    });
  },

  // creates a list of mentions out of a list of contacts
  // @see _contactToMention
  createList: function(contacts) {
    return _.map(contacts, Mentions._contactToMention);
  },

  // takes a given contact object and modifies to fit the format
  // expected by the jQuery.mentionsInput plugin.
  // @see http://podio.github.com/jquery-mentions-input/
  _contactToMention: function(contact) {
    contact.value = contact.name;
    return contact;
  },

  // default options for jQuery.mentionsInput
  // @see http://podio.github.com/jquery-mentions-input/
  options: {
    elastic: false,
    minChars: 1,

    onDataRequest: function(mode, query, callback) {
      var filteredResults = _.filter(Mentions.contacts, function(item) { return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 });

      callback.call(this, filteredResults.slice(0,5));
    },

    templates: {
      mentionItemSyntax: _.template("@{<%= name %> ; <%= handle %>}")
    }
  }
};
// @license-end


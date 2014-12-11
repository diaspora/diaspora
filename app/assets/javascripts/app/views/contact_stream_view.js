// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ContactStream = Backbone.View.extend({
  initialize: function() {
    this.itemCount = 0;
    this.perPage = 25;
    this.query = '';
    this.resultList = this.collection.toArray();
    var throttledScroll = _.throttle(_.bind(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
    this.on('renderContacts', this.renderContacts, this);
  },

  render: function() {
    if( _.isEmpty(this.resultList) ) {
      var content = document.createDocumentFragment();
      content = '<div id="no_contacts" class="well">' +
                '  <h4>' +
                     Diaspora.I18n.t('contacts.search_no_results') +
                '  </h4>' +
                '</div>';
      this.$el.html(content);
    } else {
      this.$el.html('');
      this.renderContacts();
    }
  },

  renderContacts: function() {
    this.$el.addClass("loading");
    var content = document.createDocumentFragment();
    _.rest(_.first(this.resultList , this.itemCount + this.perPage), this.itemCount).forEach( function(item) {
      var view = new app.views.Contact({model: item});
      content.appendChild(view.render().el);
    });

    var size = _.size(this.resultList);
    if( this.itemCount + this.perPage >= size ){
      this.itemCount = size;
      this.off('renderContacts');
    } else {
      this.itemCount += this.perPage;
    }
    this.$el.append(content);
    this.$el.removeClass("loading");
  },

  search: function(query) {
    query = query.trim();
    if( query || this.query ) {
      this.off('renderContacts');
      this.on('renderContacts', this.renderContacts, this);
      this.itemCount = 0;
      if( query ) {
        this.query = query;
        var regex = new RegExp(query,'i');
        this.resultList = this.collection.filter(function(contact) {
          return regex.test(contact.get('person').name) ||
                 regex.test(contact.get('person').diaspora_id);
        });
      } else {
        this.resultList = this.collection.toArray();
        this.query = '';
      }
      this.render();
    }
  },

  infScroll: function() {
    if( this.$el.hasClass('loading') ) return;

    var distanceTop = $(window).height() + $(window).scrollTop(),
        distanceBottom = $(document).height() - distanceTop;
    if(distanceBottom < 300) this.trigger('renderContacts');
  }
});
// @license-end

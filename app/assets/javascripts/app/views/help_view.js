//TODO RS: Would be nice to have #faq as the root elem or something
app.views.Help = app.views.StaticContentView.extend({
  templateName : "help",

  events : {
    "click .faq-link" : "sectionClicked",
    "click .faq-link-getting-help" : "gettingHelp",
    "click .faq-link-sharing" : "sharing",
    "click .faq-link-posts-and-posting" : "postsAndPosting"
  },

  initialize : function(options) {
    // TODO RS: Hard coded links are not nice. Should be in a config or something.
    this.GETTING_HELP_SUBS = {
      getting_started_a: { tutorial_series: this.linkHtml("http://diasporafoundation.org/getting_started/sign_up", Diaspora.I18n.t( 'getting_started_tutorial' )) },
      get_support_a_website: { link: this.linkHtml("https://diasporafoundation.org/", Diaspora.I18n.t( 'foundation_website' ))},
      get_support_a_tutorials: { tutorials: this.linkHtml("https://diasporafoundation.org/tutorials", Diaspora.I18n.t( 'tutorials' ))},
      get_support_a_wiki: { link: this.linkHtml("https://wiki.diasporafoundation.org/Special:Search", Diaspora.I18n.t( 'wiki' ))},
      get_support_a_irc: { irc: this.linkHtml("https://wiki.diasporafoundation.org/How_We_Communicate#IRC", Diaspora.I18n.t( 'irc' ))},
      get_support_a_hashtag: { question: this.linkHtml("/tags/question", "#question")}, // TODO RS: Is this definitely hard coded?
	};

    this.POSTS_AND_POSTING_SUBS = {
      format_text_a: {
        markdown: this.linkHtml("http://diasporafoundation.org/formatting", Diaspora.I18n.t( 'markdown' )),
        here: this.linkHtml("http://daringfireball.net/projects/markdown/syntax", Diaspora.I18n.t( 'here' )),
      }
    };

    this.data = {
      title_getting_help: Diaspora.I18n.t( 'getting_help.title' ),
      title_account_and_data_management: Diaspora.I18n.t( 'account_and_data_management.title' ),
      title_aspects: Diaspora.I18n.t( 'aspects.title' ),
      title_mentions: Diaspora.I18n.t( 'mentions.title' ),
      title_pods: Diaspora.I18n.t( 'pods.title' ),
      title_posts_and_posting: Diaspora.I18n.t( 'posts_and_posting.title' ),
      title_private_posts: Diaspora.I18n.t( 'private_posts.title' ),
      title_private_profiles: Diaspora.I18n.t( 'private_profiles.title' ),
      title_public_posts: Diaspora.I18n.t( 'public_posts.title' ),
      title_public_profiles: Diaspora.I18n.t( 'public_profiles.title' ),
      title_resharing_posts: Diaspora.I18n.t( 'resharing_posts.title' ),
      title_sharing: Diaspora.I18n.t( 'sharing.title' ),
      title_tags: Diaspora.I18n.t( 'tags.title' ),
      title_miscellaneous: Diaspora.I18n.t( 'miscellaneous.title' ),
    }

    return this;
  },

  afterRender: function() {
    this.resetMenu(true);

    this.renderStaticSection("getting_help", "faq_getting_help", this.GETTING_HELP_SUBS);
  },

  showItems: function(el) {
    this.clearItems();
    var section = el.data('section');
    var items = el.data('items').split(" ");

    items.forEach(function(item, i){
      var qa = {
        className: "faq_question_" + section,
        question: this.getText(section, item, true),
        answer: this.getText(section, item, false)
      };
      item = new app.views.FaqQuestionView(qa);
      this.$el.find('#faq').append(item.render().el);
    }, this);

    this.setInitialVisibility();
  },

  getText: function(section, name, question){
    var q = question ? "_q" : "_a";
    return Diaspora.I18n.t( section + '.' + name + q);
  },

  setInitialVisibility: function() {
    this.$el.find('#faq .question.collapsible :first').addClass('opened').removeClass('collapsed');
    this.$el.find('#faq .question.collapsible .answer :first').show();
  },

  resetMenu: function(initial) {
  	$('#faq_nav').find('.section-unselected').show();
    $('#faq_nav').find('.section-selected').hide();
    if(initial){
      $('#faq_nav').find('.section-unselected :first').hide();
      $('#faq_nav').find('.section-selected :first').show();
    }
  },

  menuClicked: function(e) {
    this.resetMenu();
    $(e.target).hide();
    $(e.target).next().show();
  },

  clearItems: function() {
    this.$el.find('#faq').empty();
  },

  sectionClicked : function(e) {
    this.menuClicked(e);
    this.showItems($(e.target));

    e.preventDefault();
  },

  renderStaticSection: function(section, template, subs) {
    this.clearItems();
    data = $.extend(Diaspora.I18n.locale[section], { className: section });
    help_section = new app.views.HelpSectionView( template, data, subs );
    this.$el.find('#faq').append(help_section.render().el);
  },

  gettingHelp: function(e) {
    this.renderStaticSection("getting_help", "faq_getting_help", this.GETTING_HELP_SUBS);
    this.menuClicked(e);

    e.preventDefault();
  },

  sharing: function(e) {
    this.renderStaticSection("sharing", "faq_sharing", {});
    this.menuClicked(e);

    e.preventDefault();
  },

  postsAndPosting: function(e) {
    this.renderStaticSection("posts_and_posting", "faq_posts_and_posting", this.POSTS_AND_POSTING_SUBS);
    this.menuClicked(e);

    e.preventDefault();
  },

  linkHtml: function(url, text) {
    return "<a href=\"" + url + "\" target=\"_blank\">" + text + "</a>";
  },
});
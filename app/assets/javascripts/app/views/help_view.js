// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Help = app.views.StaticContentView.extend({
  templateName : "help",

  events : {
    "click .faq-link": "sectionClicked",
    "click .faq-link-getting-help": "gettingHelp",
    "click .faq-link-sharing": "sharing",
    "click .faq-link-posts-and-posting": "postsAndPosting",
    "click .faq-link-tags": "tags",
    "click .faq-link-keyboard-shortcuts": "keyboardShortcuts"
  },

  initialize : function() {
    this.GETTING_HELP_SUBS = {
      getting_started_a: {tutorial_series: this.linkHtml("http://diasporafoundation.org/getting_started/sign_up", Diaspora.I18n.t("getting_started_tutorial"))},
      get_support_a_website: {link: this.linkHtml("https://diasporafoundation.org/", Diaspora.I18n.t("foundation_website"))},
      get_support_a_tutorials: {tutorials: this.linkHtml("https://diasporafoundation.org/tutorials", Diaspora.I18n.t("tutorials"))},
      get_support_a_wiki: {link: this.linkHtml("https://wiki.diasporafoundation.org/Special:Search", Diaspora.I18n.t("wiki"))},
      get_support_a_irc: {irc: this.linkHtml("https://wiki.diasporafoundation.org/How_We_Communicate#IRC", Diaspora.I18n.t("irc"))},
      get_support_a_faq: {faq: this.linkHtml("https://wiki.diasporafoundation.org/FAQ_for_users", Diaspora.I18n.t("faq"))},
      get_support_a_hashtag: {question: this.linkHtml("/tags/question", "#question")},
      get_support_a_discourse: {discourse: this.linkHtml("https://discourse.diasporafoundation.org/c/support", "discussions & support")}
	};

    this.POSTS_AND_POSTING_SUBS = {
      post_report_a: {community_guidelines: this.linkHtml("https://diasporafoundation.org/community_guidelines", Diaspora.I18n.t("community_guidelines"))},
      format_text_a: {
        markdown: this.linkHtml("http://diasporafoundation.org/formatting", Diaspora.I18n.t( 'markdown' )),
        here: this.linkHtml("http://daringfireball.net/projects/markdown/syntax", Diaspora.I18n.t( 'here' ))
      }
    };

    this.TAGS_SUBS = {
      filter_tags_a: {
        third_party_tools: this.linkHtml("https://wiki.diasporafoundation.org/Tools_to_use_with_Diaspora", Diaspora.I18n.t( 'third_party_tools' ))
      }
    };

    this.data = {
      title_header: Diaspora.I18n.t("title_header"),
      title_getting_help: Diaspora.I18n.t("getting_help.title"),
      title_account_and_data_management: Diaspora.I18n.t("account_and_data_management.title"),
      title_aspects: Diaspora.I18n.t("aspects.title"),
      title_mentions: Diaspora.I18n.t("mentions.title"),
      title_pods: Diaspora.I18n.t("pods.title"),
      title_posts_and_posting: Diaspora.I18n.t("posts_and_posting.title"),
      title_private_posts: Diaspora.I18n.t("private_posts.title"),
      title_public_posts: Diaspora.I18n.t("public_posts.title"),
      title_resharing_posts: Diaspora.I18n.t("resharing_posts.title"),
      title_profile: Diaspora.I18n.t("profile.title"),
      title_sharing: Diaspora.I18n.t("sharing.title"),
      title_tags: Diaspora.I18n.t("tags.title"),
      title_keyboard_shortcuts: Diaspora.I18n.t("keyboard_shortcuts.title"),
      title_miscellaneous: Diaspora.I18n.t("miscellaneous.title")
    };

    return this;
  },

  render: function(section){
    var html = app.views.Base.prototype.render.apply(this, arguments);

    // After render actions
    this.resetMenu(true);
    this.renderStaticSection("getting_help", "faq_getting_help", this.GETTING_HELP_SUBS);

    var elTarget = this.findSection(section);
    if(elTarget !== null){ $(elTarget).click(); }

    return html;
  },

  showItems: function(el) {
    this.clearItems();
    var section = el.data('section');
    var items = el.data('items').split(" ");
    var self = this;

    $.each(items, function(i, item){
      var qa = {
        className: "faq_question_" + section,
        question: self.getText(section, item, true),
        answer: self.getText(section, item, false)
      };
      item = new app.views.FaqQuestionView(qa);
      self.$('#faq').append(item.render().el);
    });

    this.setInitialVisibility();
  },

  getText: function(section, name, question){
    var q = question ? "_q" : "_a";
    return Diaspora.I18n.t( section + '.' + name + q);
  },

  setInitialVisibility: function() {
    this.$('#faq .question.collapsible :first').addClass('opened').removeClass('collapsed');
    this.$('#faq .question.collapsible .answer :first').show();
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

    var data = $(e.target).data('section');
    app.router.navigate('help/' + data);
  },

  clearItems: function() {
    this.$('#faq').empty();
  },

  sectionClicked : function(e) {
    this.menuClicked(e);
    this.showItems($(e.target));

    e.preventDefault();
  },

  renderStaticSection: function(section, template, subs) {
    this.clearItems();
    var data = $.extend(Diaspora.I18n.resolve(section), { className: section });
    var help_section = new app.views.HelpSectionView({
      template: template,
      data: data,
      subs: subs
    });
    this.$('#faq').append(help_section.render().el);
  },

  /**
   * Returns The section title whose data-section property equals the given query
   * Returns null if nothing found
   * @param data Value for the data-section to find
   * @returns {jQuery}
   */
  findSection: function(data){
    var res = this.$('a[data-section=' + data + ']');
    if(res.length === 0){ return null; }
    return res;
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

  tags: function(e) {
    this.renderStaticSection("tags", "faq_tags", this.TAGS_SUBS);
    this.menuClicked(e);

    e.preventDefault();
  },

  keyboardShortcuts: function(e) {
    this.renderStaticSection("keyboard_shortcuts", "faq_keyboard_shortcuts", {});
    this.menuClicked(e);

    e.preventDefault();
  },

  linkHtml: function(url, text) {
    return "<a href=\"" + url + "\" target=\"_blank\">" + text + "</a>";
  }
});
// @license-end

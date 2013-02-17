/**
 * the aspects dropdown specifies the scope of a posted status message.
 *
 * this view is part of the publisher where users are presented the options
 * 'public', 'all aspects' and a list of their personal aspects, for limiting
 * 'the audience of created contents.
 */
app.views.AspectsDropdown = app.views.Base.extend({
  templateName : "aspects-dropdown",
  events : {
    "change .dropdown-menu input" : "setVisibility"
  },

  presenter : function(){
    var selectedAspects = this.model.get("aspect_ids")
      , parsedIds = _.map(selectedAspects, parseInt)

    return {
      aspects : _.map(app.currentUser.get('aspects'), function(aspect){
        return _.extend({}, aspect, {checked :_.include(parsedIds, aspect.id) })
      }),

      public :_.include(selectedAspects, "public"),
      'all-aspects' :_.include(selectedAspects, "all_aspects")
    }
  },

  postRenderTemplate : function(){
    if(this.model.get("aspect_ids")) {
      this.setDropdownText()
    } else {
      this.setVisibility({target : this.$("input[value='public']").first()})
    }
  },

  setVisibility : function(evt){
    var input = $(evt.target).closest("input")

    if(_.include(['public', 'all_aspects'], input.val())) {
      this.$("input").attr("checked", false)
      input.attr("checked", "checked")
    } else {
      this.$("input.public, input.all_aspects").attr("checked", false)
    }

    this.setDropdownText()
  },

  setDropdownText : function(){
    var selected = this.$("input").serializeArray()
      , text;

    switch (selected.length) {
      case 0:
        text = "Private"
        break
      case 1:
        text = selected[0].name
        break
      default:
        text = ["In", selected.length, "aspects"].join(" ")
        break
    }

    $.trim(this.$(".dropdown-toggle .text").text(text))
  }
});

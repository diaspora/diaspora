app.views.AspectsDropdown = app.views.Base.extend({
  templateName : "aspects-dropdown",
  events : {
    "click .dropdown-menu a" : "setVisibility"
  },

  postRenderTemplate : function(){
    this.setVisibility({target : this.$("a[data-visibility='all-aspects']").first()})
  },

  setVisibility : function(evt){
    var self = this
      , link = $(evt.target).closest("a")

    if(_.include(['public', 'all-aspects'], link.data('visibility'))) {
      deselectAll()
      link.parents("li").addClass("selected")
      self.setDropdownText(link.text())
    } else {
      deselectOverrides()
      link.parents("li").toggleClass("selected")
      evt.stopImmediatePropagation(); //stop dropdown from going awaay

      var selectedAspects = this.$("li.selected")
      if(selectedAspects.length > 1) {
        self.setDropdownText("In " + this.$("li.selected").length + " aspects")
      } else {
        self.setDropdownText(selectedAspects.text() || "Private")
      }
    }

    this.setAspectIds()

    function deselectOverrides() {
      self.$("a.public, a.all-aspects").parent().removeClass("selected")
    }

    function deselectAll() {
      self.$("li.selected").removeClass("selected")
    }
  },

  setDropdownText : function(text){
    $.trim(this.$(".dropdown-toggle .text").text(text))
  },

  setAspectIds : function(){
    var selectedAspects = this.$("li.selected a")
    var aspectIds = _.map(selectedAspects, function(aspect){
      return $(aspect).data("aspect-id")}
    )

    this.$("input.aspect_ids").val(aspectIds)
  }
})

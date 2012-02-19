app.views.Photo = app.views.StreamObject.extend({

  templateName: "photo",

  className : "photo loaded",

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));
    this.model.bind('remove', this.remove, this);
    return this;
  }
  
});
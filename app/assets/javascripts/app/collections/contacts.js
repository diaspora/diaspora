// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.collections.Contacts = Backbone.Collection.extend({
  model: app.models.Contact,

  comparator : function(con1, con2) {
    if( !con1.person || !con2.person ) return 1;

    if(app.aspect) {
      var inAspect1 = con1.inAspect(app.aspect.get('id'));
      var inAspect2 = con2.inAspect(app.aspect.get('id'));
      if(  inAspect1 && !inAspect2 ) return -1;
      if( !inAspect1 &&  inAspect2 ) return 1;
    }

    var n1 = con1.person.get('name');
    var n2 = con2.person.get('name');
    return n1.localeCompare(n2);
  }
});
// @license-end

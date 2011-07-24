Diaspora.ajax = {
  add_person_to_aspect: function(person_id, aspect_id){
    return $.post("/aspect_memberships.json", {
        "aspect_id": aspect_id,
        "person_id": person_id,
        "_method": "POST"
      })
      .success(function(data) {
        Diaspora.widgets.publish("person/aspectMembershipUpdated", [data]);
        Diaspora.widgets.publish("aspect/personAdded", [aspect_id, person_id]);
      });
  },

  remove_person_from_aspect: function(person_id, aspect_id){
    var routedId = '/42';
    return $.post("/aspect_memberships" + routedId + ".json", {
        "aspect_id": aspect_id,
        "person_id": person_id,
        "_method": "DELETE"
      })
      .success(function(data) {
        Diaspora.widgets.publish("person/aspectMembershipUpdated", [data]);
        Diaspora.widgets.publish("aspect/personRemoved", [aspect_id, person_id]);
      });
  },
};

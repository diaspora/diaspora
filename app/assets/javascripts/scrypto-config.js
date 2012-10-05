window.get_scrypto_config = function() {
	return {
		"entropy_dependent" : "[href='/conversations/new']",
		"secure_forms": {},
		"secure_fields" : "#conversation_text, #message_text",
		"symmetric_fields" : "#message_text",
		"decrypt_fields" : "#conversation_show div.ltr",
		"lookup_field" : "as-values-contact_ids",
		"lookup_url" : "/person_ids.json?contacts=",
		"mount_point" : "/scrypto",
		"owner" :
			((window.current_user_attributes !== undefined) && (window.current_user_attributes !== null)) ?
				{ "local" : window.current_user_attributes.id, "global" : window.current_user_attributes.guid } : null,

		"decryption_key" :
			((window.current_user_attributes !== undefined) && (window.current_user_attributes !== null) &&
			 (window.current_user_attributes.key_ring !== undefined) && (window.current_user_attributes.key_ring !== null)) ?
				window.current_user_attributes.key_ring.secured_decryption : null,

		"signing_key" :
			((window.current_user_attributes !== undefined) && (window.current_user_attributes !== null) &&
			 (window.current_user_attributes.key_ring !== undefined) && (window.current_user_attributes.key_ring !== null)) ?
				window.current_user_attributes.key_ring.secured_signing : null
	}
}

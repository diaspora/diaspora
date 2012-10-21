//= require scrypto-config
//= require scrypto/scrypto

$(document).ready(function() {
	if ($('#entropy-value').length > 0) {
		$(document).entropy(function(progress) {
			$('#entropy-value').text((progress * 100).toFixed(0) + "%")
		})
	}

	$(document).on("submit", "form[data-encryptable]", function(event) {
		$(this).each(function() {
			var ret = {}
			var fields = $(this).find('[data-encrypt]')

			fields.each(function() {
				ret[$(this).attr('id')] = $(this).val()
			})

			ret.recipients = $("#" + window.get_scrypto_config().lookup_field).val().split(',')
			ret = $(ret).encrypt_fields()

			for (var field in ret.fields) {
				var name = $("#" + field).attr('name')
				
				$("#" + field).removeAttr('name')
				
				$('<input/>', {
					type : 'hidden',
					name : name,
					value : ret.fields[field]
				}).appendTo($(this))
			}
			
			var keys = ret.keys.encrypted_recipient_keys
			$('<input/>', {
				type : 'hidden',
				name : 'recipient_keys',
				value : JSON.stringify(keys)
			}).appendTo($(this))
			
			return true
		})
	})
})


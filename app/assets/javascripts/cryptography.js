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

			$(ret).encrypt_fields()

			// ret should, at this point, contain rich 'fields' and 'keys' with encrypted data
		})
	})
})


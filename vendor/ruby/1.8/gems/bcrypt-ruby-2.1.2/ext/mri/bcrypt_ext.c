#include "ruby.h"
#include "bcrypt.h"

static VALUE mBCrypt;
static VALUE cBCryptEngine;

/* Define RSTRING_PTR for Ruby 1.8.5, ruby-core's idea of a point release is
   insane. */
#ifndef RSTRING_PTR
#  define    RSTRING_PTR(s)  (RSTRING(s)->ptr)
#endif

#ifdef RUBY_VM
#  define RUBY_1_9
#endif

#ifdef RUBY_1_9

	/* When on Ruby 1.9+, we will want to unlock the GIL while performing
	 * expensive calculations, for greater concurrency. Do not do this for
	 * cheap calculations because locking/unlocking the GIL incurs some overhead as well.
	 */
	#define GIL_UNLOCK_COST_THRESHOLD 9
	
	typedef struct {
		char       *output;
		const char *key;
		const char *salt;
	} BCryptArguments;
	
	static VALUE bcrypt_wrapper(void *_args) {
		BCryptArguments *args = (BCryptArguments *)_args;
		return (VALUE)bcrypt(args->output, args->key, args->salt);
	}

#endif /* RUBY_1_9 */

/* Given a logarithmic cost parameter, generates a salt for use with +bc_crypt+.
 */
static VALUE bc_salt(VALUE self, VALUE cost, VALUE seed) {
	int icost = NUM2INT(cost);
	char salt[BCRYPT_SALT_OUTPUT_SIZE];
	
	bcrypt_gensalt(salt, icost, (uint8_t *)RSTRING_PTR(seed));
	return rb_str_new2(salt);
}

/* Given a secret and a salt, generates a salted hash (which you can then store safely).
 */
static VALUE bc_crypt(VALUE self, VALUE key, VALUE salt, VALUE cost) {
	const char * safeguarded = RSTRING_PTR(key) ? RSTRING_PTR(key) : "";
	char output[BCRYPT_OUTPUT_SIZE];
	
	#ifdef RUBY_1_9
		int icost = NUM2INT(cost);
		if (icost >= GIL_UNLOCK_COST_THRESHOLD) {
			BCryptArguments args;
			VALUE ret;
		
			args.output = output;
			args.key    = safeguarded;
			args.salt   = RSTRING_PTR(salt);
			ret = rb_thread_blocking_region(bcrypt_wrapper, &args, RUBY_UBF_IO, 0);
			if (ret != (VALUE) 0) {
				return rb_str_new2(output);
			} else {
				return Qnil;
			}
		}
		/* otherwise, fallback to the non-GIL-unlocking code, just like on Ruby 1.8 */
	#endif
	
	if (bcrypt(output, safeguarded, (char *)RSTRING_PTR(salt)) != NULL) {
		return rb_str_new2(output);
	} else {
		return Qnil;
	}
}

/* Create the BCrypt and BCrypt::Engine modules, and populate them with methods. */
void Init_bcrypt_ext(){
	mBCrypt = rb_define_module("BCrypt");
	cBCryptEngine = rb_define_class_under(mBCrypt, "Engine", rb_cObject);
	
	rb_define_singleton_method(cBCryptEngine, "__bc_salt", bc_salt, 2);
	rb_define_singleton_method(cBCryptEngine, "__bc_crypt", bc_crypt, 3);
}

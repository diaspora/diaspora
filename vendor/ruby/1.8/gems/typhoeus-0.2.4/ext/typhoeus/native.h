#ifndef TYPHOEUS_NATIVE
#define TYPHOEUS_NATIVE

#include <ruby.h>
#include <curl/curl.h>
#include <curl/easy.h>
#include <curl/multi.h>

void Init_native();
extern VALUE mTyphoeus;
extern void init_typhoeus_easy();
extern void init_typhoeus_multi();
extern void init_typhoeus_form();

#endif

#ifndef RSTRING_PTR

#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#define RSTRING_LEN(s) (RSTRING(s)->len)

#endif
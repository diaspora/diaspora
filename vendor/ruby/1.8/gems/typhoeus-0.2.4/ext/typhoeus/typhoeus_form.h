#ifndef TYPHOEUS_FORM
#define TYPHOEUS_FORM

#include <native.h>

typedef struct {
  struct curl_httppost *first;
  struct curl_httppost *last;
} CurlForm;

void init_typhoeus_form();

#endif

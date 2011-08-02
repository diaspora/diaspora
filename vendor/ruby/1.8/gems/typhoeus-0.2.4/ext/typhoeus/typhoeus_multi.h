#ifndef TYPHOEUS_MULTI
#define TYPHOEUS_MULTI

#include <native.h>
#include <typhoeus_easy.h>

VALUE cTyphoeusMulti;
typedef struct {
  int running;
  int active;
  CURLM *multi;
} CurlMulti;

void init_typhoeus_multi();

#endif

#ifndef TYPHOEUS_EASY
#define TYPHOEUS_EASY

#include <native.h>
#include <typhoeus_form.h>

void init_typhoeus_easy();
typedef struct {
  const char *memory;
  int size;
  int read;
} RequestChunk;

typedef struct {
  RequestChunk *request_chunk;
  CURL *curl;
  struct curl_slist *headers;
} CurlEasy;

#endif

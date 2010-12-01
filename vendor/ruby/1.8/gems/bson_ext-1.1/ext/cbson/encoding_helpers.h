/*
 * Copyright 2009-2010 10gen, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ENCODING_HELPERS_H
#define ENCODING_HELPERS_H

typedef enum {
    VALID,
    NOT_UTF_8,
    HAS_NULL
} result_t;

result_t check_string(const unsigned char* string, const int length,
                      const char check_utf8, const char check_null);

#endif

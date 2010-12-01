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

#include <stdlib.h>
#include <string.h>

#include "buffer.h"

#define INITIAL_BUFFER_SIZE 256

struct buffer {
    char* buffer;
    int size;
    int position;
};

/* Allocate and return a new buffer.
 * Return NULL on allocation failure. */
buffer_t buffer_new(void) {
    buffer_t buffer;
    buffer = (buffer_t)malloc(sizeof(struct buffer));
    if (buffer == NULL) {
        return NULL;
    }

    buffer->size = INITIAL_BUFFER_SIZE;
    buffer->position = 0;
    buffer->buffer = (char*)malloc(sizeof(char) * INITIAL_BUFFER_SIZE);
    if (buffer->buffer == NULL) {
        free(buffer);
        return NULL;
    }

    return buffer;
}

/* Free the memory allocated for `buffer`.
 * Return non-zero on failure. */
int buffer_free(buffer_t buffer) {
    if (buffer == NULL) {
        return 1;
    }
    free(buffer->buffer);
    free(buffer);
    return 0;
}

/* Grow `buffer` to at least `min_length`.
 * Return non-zero on allocation failure. */
static int buffer_grow(buffer_t buffer, int min_length) {
    int size = buffer->size;
    char* old_buffer = buffer->buffer;
    if (size >= min_length) {
        return 0;
    }
    while (size < min_length) {
        size *= 2;
    }
    buffer->buffer = (char*)realloc(buffer->buffer, sizeof(char) * size);
    if (buffer->buffer == NULL) {
        free(old_buffer);
        free(buffer);
        return 1;
    }
    buffer->size = size;
    return 0;
}

/* Assure that `buffer` has at least `size` free bytes (and grow if needed).
 * Return non-zero on allocation failure. */
static int buffer_assure_space(buffer_t buffer, int size) {
    if (buffer->position + size <= buffer->size) {
        return 0;
    }
    return buffer_grow(buffer, buffer->position + size);
}

/* Save `size` bytes from the current position in `buffer` (and grow if needed).
 * Return offset for writing, or -1 on allocation failure. */
buffer_position buffer_save_space(buffer_t buffer, int size) {
    int position = buffer->position;
    if (buffer_assure_space(buffer, size) != 0) {
        return -1;
    }
    buffer->position += size;
    return position;
}

/* Write `size` bytes from `data` to `buffer` (and grow if needed).
 * Return non-zero on allocation failure. */
int buffer_write(buffer_t buffer, const char* data, int size) {
    if (buffer_assure_space(buffer, size) != 0) {
        return 1;
    }

    memcpy(buffer->buffer + buffer->position, data, size);
    buffer->position += size;
    return 0;
}

/* Write `size` bytes from `data` to `buffer` at position `position`.
 * Does not change the internal position of `buffer`.
 * Return non-zero if buffer isn't large enough for write. */
int buffer_write_at_position(buffer_t buffer, buffer_position position,
                             const char* data, int size) {
    if (position + size > buffer->size) {
        buffer_free(buffer);
        return 1;
    }

    memcpy(buffer->buffer + position, data, size);
    return 0;
}


int buffer_get_position(buffer_t buffer) {
    return buffer->position;
}

char* buffer_get_buffer(buffer_t buffer) {
    return buffer->buffer;
}

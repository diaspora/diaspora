
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
#include <assert.h>
#include <ruby.h>

#if defined(_WIN32)
#include <stddef.h>
#endif

#ifdef HAVE_RUBY_RE_H
#include <ruby/re.h>
#else
#include <re.h>
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
#define ENCODED_STR_NEW(ptr, len) \
    rb_enc_str_new(ptr, len, rb_utf8_encoding())
#else
#define ENCODED_STR_NEW(ptr, len) \
    rb_str_new(ptr, len)
#endif

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif

#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#define DATA_GET(FROM, TYPE, NAME) \
  Data_Get_Struct(FROM, TYPE, NAME); \
  if (NAME == NULL) { \
    rb_raise(rb_eArgError, "NULL found for " # NAME " when it shouldn't be."); \
  }
 
typedef struct lexer_state {
  int content_len;
  int line_number;
  int current_line;
  int start_col;
  size_t mark;
  size_t keyword_start;
  size_t keyword_end;
  size_t next_keyword_start;
  size_t content_start;
  size_t content_end;
  size_t query_start;
  size_t last_newline;
  size_t final_newline;
} lexer_state;

static VALUE mGherkin;
static VALUE mGherkinLexer;
static VALUE mCLexer;
static VALUE cI18nLexer;
static VALUE rb_eGherkinLexingError;

#define LEN(AT, P) (P - data - lexer->AT)
#define MARK(M, P) (lexer->M = (P) - data)
#define PTR_TO(P) (data + lexer->P)

#define STORE_KW_END_CON(EVENT) \
  store_multiline_kw_con(listener, # EVENT, \
    PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end - 1)), \
    PTR_TO(content_start), LEN(content_start, PTR_TO(content_end)), \
    lexer->current_line, lexer->start_col); \
    if (lexer->content_end != 0) { \
      p = PTR_TO(content_end - 1); \
    } \
    lexer->content_end = 0

#define STORE_ATTR(ATTR) \
    store_attr(listener, # ATTR, \
      PTR_TO(content_start), LEN(content_start, p), \
      lexer->line_number)


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
static const char _lexer_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 14, 1, 15, 1, 16, 1, 
	17, 1, 18, 1, 19, 1, 20, 1, 
	21, 2, 1, 16, 2, 11, 0, 2, 
	12, 13, 2, 15, 0, 2, 15, 2, 
	2, 15, 14, 2, 15, 17, 2, 16, 
	4, 2, 16, 5, 2, 16, 6, 2, 
	16, 7, 2, 16, 8, 2, 16, 14, 
	2, 18, 19, 2, 20, 0, 2, 20, 
	2, 2, 20, 14, 2, 20, 17, 3, 
	3, 12, 13, 3, 9, 12, 13, 3, 
	10, 12, 13, 3, 11, 12, 13, 3, 
	12, 13, 16, 3, 15, 12, 13, 4, 
	1, 12, 13, 16, 4, 15, 0, 12, 
	13
};

static const short _lexer_key_offsets[] = {
	0, 0, 12, 19, 20, 22, 23, 24, 
	25, 26, 28, 39, 40, 41, 45, 50, 
	55, 60, 65, 69, 73, 75, 76, 77, 
	78, 79, 80, 81, 82, 83, 84, 85, 
	86, 87, 88, 89, 90, 95, 102, 107, 
	111, 117, 120, 122, 128, 139, 141, 142, 
	143, 144, 145, 146, 147, 148, 149, 150, 
	151, 152, 153, 154, 155, 156, 157, 158, 
	159, 160, 161, 162, 163, 164, 165, 166, 
	167, 174, 176, 178, 180, 182, 184, 186, 
	188, 190, 192, 194, 205, 206, 207, 208, 
	209, 210, 211, 212, 213, 214, 215, 216, 
	217, 218, 219, 220, 221, 222, 231, 237, 
	239, 242, 244, 246, 248, 251, 253, 255, 
	257, 259, 261, 263, 265, 267, 269, 271, 
	273, 275, 277, 279, 281, 283, 285, 287, 
	289, 291, 293, 295, 299, 301, 303, 305, 
	307, 309, 311, 313, 315, 317, 319, 321, 
	323, 325, 327, 329, 331, 333, 335, 337, 
	339, 341, 343, 345, 347, 349, 351, 353, 
	355, 357, 359, 361, 363, 365, 367, 369, 
	371, 373, 375, 376, 379, 380, 381, 382, 
	383, 384, 385, 386, 387, 388, 389, 390, 
	391, 392, 393, 394, 395, 396, 397, 398, 
	399, 408, 414, 416, 419, 421, 423, 425, 
	428, 430, 432, 434, 436, 438, 440, 442, 
	444, 446, 448, 450, 452, 454, 456, 458, 
	460, 462, 464, 466, 468, 470, 472, 475, 
	477, 479, 481, 483, 485, 487, 489, 491, 
	493, 495, 497, 499, 501, 503, 505, 507, 
	509, 511, 513, 515, 517, 519, 521, 523, 
	525, 527, 529, 530, 531, 532, 533, 534, 
	535, 536, 537, 538, 546, 550, 552, 554, 
	556, 558, 560, 562, 564, 566, 568, 570, 
	572, 574, 576, 578, 580, 582, 584, 586, 
	590, 592, 594, 596, 598, 600, 602, 604, 
	606, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 626, 628, 630, 632, 634, 636, 
	638, 640, 642, 644, 646, 648, 650, 652, 
	654, 656, 658, 660, 662, 664, 665, 666, 
	667, 668, 669, 670, 671, 672, 673, 682, 
	689, 691, 694, 696, 698, 700, 703, 705, 
	707, 709, 711, 713, 715, 717, 719, 721, 
	723, 725, 727, 729, 731, 733, 735, 737, 
	739, 741, 743, 745, 747, 749, 751, 753, 
	755, 757, 761, 763, 765, 767, 769, 771, 
	773, 775, 777, 779, 781, 783, 785, 787, 
	789, 791, 793, 795, 797, 799, 801, 803, 
	805, 807, 809, 811, 813, 815, 817, 819, 
	821, 823, 825, 827, 829, 831, 833, 835, 
	836, 837
};

static const char _lexer_trans_keys[] = {
	-41, -17, 10, 32, 34, 35, 37, 42, 
	64, 124, 9, 13, -112, -111, -109, -107, 
	-101, -88, -86, -41, -111, -106, -41, -100, 
	32, 10, 10, 13, -41, 10, 32, 34, 
	35, 37, 42, 64, 124, 9, 13, 34, 
	34, 10, 32, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 13, 32, 64, 9, 10, 9, 
	10, 13, 32, 64, 11, 12, 10, 32, 
	64, 9, 13, 32, 124, 9, 13, 10, 
	32, 92, 124, 9, 13, 10, 92, 124, 
	10, 92, 10, 32, 92, 124, 9, 13, 
	-41, 10, 32, 34, 35, 37, 42, 64, 
	124, 9, 13, -41, 32, -103, -41, -108, 
	-41, -103, -41, -96, -41, -86, -41, -97, 
	-41, -107, -41, -110, -41, -98, -41, -112, 
	-41, -107, -41, -86, 58, 10, 10, -41, 
	10, 32, 35, 124, 9, 13, -86, 10, 
	-41, 10, -101, 10, -41, 10, -107, 10, 
	-41, 10, -96, 10, -41, 10, -108, 10, 
	10, 58, -41, 10, 32, 34, 35, 37, 
	42, 64, 124, 9, 13, -41, -110, -41, 
	-99, -41, -112, -41, -87, -41, -88, -41, 
	-89, -41, -94, 58, 10, 10, -41, 10, 
	32, 35, 37, 42, 64, 9, 13, -112, 
	-111, -107, -101, -86, 10, -41, 10, -111, 
	-106, 10, -41, 10, -100, 10, 10, 32, 
	-41, 10, 32, -103, 10, -41, 10, -108, 
	10, -41, 10, -103, 10, -41, 10, -96, 
	10, -41, 10, -86, 10, -41, 10, -97, 
	10, -41, 10, -110, 10, -41, 10, -99, 
	10, -41, 10, -112, 10, -41, 10, -87, 
	10, -41, 10, -88, 10, -41, 10, -111, 
	-101, -88, 10, -41, 10, -96, 10, -41, 
	10, -103, 10, -41, 10, -86, 10, 10, 
	32, -41, 10, -86, 10, -41, 10, -88, 
	10, -41, 10, -105, 10, -41, 10, -103, 
	10, -41, 10, -87, 10, 10, 58, -41, 
	10, -107, 10, -41, 10, -96, 10, -41, 
	10, -108, 10, 10, 95, 10, 70, 10, 
	69, 10, 65, 10, 84, 10, 85, 10, 
	82, 10, 69, 10, 95, 10, 69, 10, 
	78, 10, 68, 10, 95, 10, 37, -41, 
	-111, -101, -88, -41, -96, -41, -103, -41, 
	-86, 32, -41, -86, -41, -88, -41, -105, 
	-41, -103, -41, -87, 58, 10, 10, -41, 
	10, 32, 35, 37, 42, 64, 9, 13, 
	-112, -111, -107, -101, -86, 10, -41, 10, 
	-111, -106, 10, -41, 10, -100, 10, 10, 
	32, -41, 10, 32, -103, 10, -41, 10, 
	-108, 10, -41, 10, -103, 10, -41, 10, 
	-96, 10, -41, 10, -86, 10, -41, 10, 
	-97, 10, -41, 10, -110, 10, -41, 10, 
	-99, 10, -41, 10, -112, 10, -41, 10, 
	-87, 10, -41, 10, -88, 10, -41, 10, 
	-101, -88, 10, -41, 10, -107, 10, -41, 
	10, -96, 10, -41, 10, -108, 10, 10, 
	58, -41, 10, -105, 10, -41, 10, -103, 
	10, -41, 10, -87, 10, 10, 95, 10, 
	70, 10, 69, 10, 65, 10, 84, 10, 
	85, 10, 82, 10, 69, 10, 95, 10, 
	69, 10, 78, 10, 68, 10, 95, 10, 
	37, -41, -107, -41, -96, -41, -108, 58, 
	10, 10, -41, 10, 32, 35, 37, 64, 
	9, 13, -109, -88, -86, 10, -41, 10, 
	-107, 10, -41, 10, -110, 10, -41, 10, 
	-98, 10, -41, 10, -112, 10, -41, 10, 
	-107, 10, -41, 10, -86, 10, 10, 58, 
	-41, 10, -89, 10, -41, 10, -94, 10, 
	-41, 10, -111, -101, -88, 10, -41, 10, 
	-96, 10, -41, 10, -103, 10, -41, 10, 
	-86, 10, 10, 32, -41, 10, -86, 10, 
	-41, 10, -88, 10, -41, 10, -105, 10, 
	-41, 10, -103, 10, -41, 10, -87, 10, 
	-41, 10, -107, 10, -41, 10, -96, 10, 
	-41, 10, -108, 10, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	-41, -105, -41, -103, -41, -87, 58, 10, 
	10, -41, 10, 32, 35, 37, 42, 64, 
	9, 13, -112, -111, -107, -101, -88, -86, 
	10, -41, 10, -111, -106, 10, -41, 10, 
	-100, 10, 10, 32, -41, 10, 32, -103, 
	10, -41, 10, -108, 10, -41, 10, -103, 
	10, -41, 10, -96, 10, -41, 10, -86, 
	10, -41, 10, -97, 10, -41, 10, -110, 
	10, -41, 10, -99, 10, -41, 10, -112, 
	10, -41, 10, -87, 10, -41, 10, -88, 
	10, -41, 10, -89, 10, -41, 10, -94, 
	10, 10, 58, -41, 10, -111, -101, -88, 
	10, -41, 10, -96, 10, -41, 10, -103, 
	10, -41, 10, -86, 10, 10, 32, -41, 
	10, -86, 10, -41, 10, -88, 10, -41, 
	10, -105, 10, -41, 10, -103, 10, -41, 
	10, -87, 10, -41, 10, -107, 10, -41, 
	10, -96, 10, -41, 10, -108, 10, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, -69, -65, 0
};

static const char _lexer_single_lengths[] = {
	0, 10, 7, 1, 2, 1, 1, 1, 
	1, 2, 9, 1, 1, 2, 3, 3, 
	3, 3, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 3, 5, 3, 2, 
	4, 3, 2, 4, 9, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	5, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 9, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 7, 6, 2, 
	3, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 4, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 3, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	7, 6, 2, 3, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 6, 4, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 4, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 7, 7, 
	2, 3, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 4, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 1, 1, 1, 
	1, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 1, 1, 
	1, 0, 0, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 12, 20, 22, 25, 27, 29, 
	31, 33, 36, 47, 49, 51, 55, 60, 
	65, 70, 75, 79, 83, 86, 88, 90, 
	92, 94, 96, 98, 100, 102, 104, 106, 
	108, 110, 112, 114, 116, 121, 128, 133, 
	137, 143, 147, 150, 156, 167, 170, 172, 
	174, 176, 178, 180, 182, 184, 186, 188, 
	190, 192, 194, 196, 198, 200, 202, 204, 
	206, 208, 210, 212, 214, 216, 218, 220, 
	222, 229, 232, 235, 238, 241, 244, 247, 
	250, 253, 256, 259, 270, 272, 274, 276, 
	278, 280, 282, 284, 286, 288, 290, 292, 
	294, 296, 298, 300, 302, 304, 313, 320, 
	323, 327, 330, 333, 336, 340, 343, 346, 
	349, 352, 355, 358, 361, 364, 367, 370, 
	373, 376, 379, 382, 385, 388, 391, 394, 
	397, 400, 403, 406, 411, 414, 417, 420, 
	423, 426, 429, 432, 435, 438, 441, 444, 
	447, 450, 453, 456, 459, 462, 465, 468, 
	471, 474, 477, 480, 483, 486, 489, 492, 
	495, 498, 501, 504, 507, 510, 513, 516, 
	519, 522, 525, 527, 531, 533, 535, 537, 
	539, 541, 543, 545, 547, 549, 551, 553, 
	555, 557, 559, 561, 563, 565, 567, 569, 
	571, 580, 587, 590, 594, 597, 600, 603, 
	607, 610, 613, 616, 619, 622, 625, 628, 
	631, 634, 637, 640, 643, 646, 649, 652, 
	655, 658, 661, 664, 667, 670, 673, 677, 
	680, 683, 686, 689, 692, 695, 698, 701, 
	704, 707, 710, 713, 716, 719, 722, 725, 
	728, 731, 734, 737, 740, 743, 746, 749, 
	752, 755, 758, 760, 762, 764, 766, 768, 
	770, 772, 774, 776, 784, 789, 792, 795, 
	798, 801, 804, 807, 810, 813, 816, 819, 
	822, 825, 828, 831, 834, 837, 840, 843, 
	848, 851, 854, 857, 860, 863, 866, 869, 
	872, 875, 878, 881, 884, 887, 890, 893, 
	896, 899, 902, 905, 908, 911, 914, 917, 
	920, 923, 926, 929, 932, 935, 938, 941, 
	944, 947, 950, 953, 956, 959, 961, 963, 
	965, 967, 969, 971, 973, 975, 977, 986, 
	994, 997, 1001, 1004, 1007, 1010, 1014, 1017, 
	1020, 1023, 1026, 1029, 1032, 1035, 1038, 1041, 
	1044, 1047, 1050, 1053, 1056, 1059, 1062, 1065, 
	1068, 1071, 1074, 1077, 1080, 1083, 1086, 1089, 
	1092, 1095, 1100, 1103, 1106, 1109, 1112, 1115, 
	1118, 1121, 1124, 1127, 1130, 1133, 1136, 1139, 
	1142, 1145, 1148, 1151, 1154, 1157, 1160, 1163, 
	1166, 1169, 1172, 1175, 1178, 1181, 1184, 1187, 
	1190, 1193, 1196, 1199, 1202, 1205, 1208, 1211, 
	1213, 1215
};

static const short _lexer_trans_targs[] = {
	2, 399, 10, 10, 11, 20, 22, 7, 
	36, 39, 10, 0, 3, 47, 57, 84, 
	88, 94, 170, 0, 4, 0, 5, 45, 
	0, 6, 0, 7, 0, 8, 0, 0, 
	9, 10, 21, 9, 2, 10, 10, 11, 
	20, 22, 7, 36, 39, 10, 0, 12, 
	0, 13, 0, 14, 13, 13, 0, 15, 
	15, 16, 15, 15, 15, 15, 16, 15, 
	15, 15, 15, 17, 15, 15, 15, 15, 
	18, 15, 15, 10, 19, 19, 0, 10, 
	19, 19, 0, 10, 21, 20, 10, 0, 
	23, 0, 24, 0, 25, 0, 26, 0, 
	27, 0, 28, 0, 29, 0, 30, 0, 
	31, 0, 32, 0, 33, 0, 34, 0, 
	35, 0, 401, 0, 0, 0, 0, 0, 
	37, 38, 10, 38, 38, 36, 37, 37, 
	10, 38, 36, 38, 0, 39, 40, 39, 
	0, 44, 43, 42, 40, 43, 41, 0, 
	42, 40, 41, 0, 42, 41, 44, 43, 
	42, 40, 43, 41, 2, 44, 44, 11, 
	20, 22, 7, 36, 39, 44, 0, 46, 
	8, 0, 7, 0, 48, 0, 49, 0, 
	50, 0, 51, 0, 52, 0, 53, 0, 
	54, 0, 55, 0, 56, 0, 7, 0, 
	58, 0, 59, 0, 60, 0, 61, 0, 
	62, 0, 63, 0, 64, 0, 65, 0, 
	66, 0, 67, 0, 68, 0, 69, 0, 
	70, 0, 72, 71, 72, 71, 73, 72, 
	72, 10, 10, 72, 71, 74, 72, 71, 
	75, 72, 71, 76, 72, 71, 77, 72, 
	71, 78, 72, 71, 79, 72, 71, 80, 
	72, 71, 81, 72, 71, 82, 72, 71, 
	72, 83, 71, 2, 10, 10, 11, 20, 
	22, 7, 36, 39, 10, 0, 85, 0, 
	86, 0, 87, 0, 7, 0, 89, 0, 
	90, 0, 91, 0, 92, 0, 93, 0, 
	7, 0, 95, 0, 96, 0, 97, 0, 
	98, 0, 99, 0, 101, 100, 101, 100, 
	102, 101, 101, 10, 156, 107, 10, 101, 
	100, 103, 110, 120, 124, 130, 101, 100, 
	104, 101, 100, 105, 108, 101, 100, 106, 
	101, 100, 107, 101, 100, 101, 83, 100, 
	109, 101, 83, 100, 107, 101, 100, 111, 
	101, 100, 112, 101, 100, 113, 101, 100, 
	114, 101, 100, 115, 101, 100, 116, 101, 
	100, 117, 101, 100, 118, 101, 100, 119, 
	101, 100, 107, 101, 100, 121, 101, 100, 
	122, 101, 100, 123, 101, 100, 107, 101, 
	100, 125, 101, 100, 126, 101, 100, 127, 
	101, 100, 128, 101, 100, 129, 101, 100, 
	107, 101, 100, 131, 101, 100, 132, 150, 
	143, 101, 100, 133, 101, 100, 134, 101, 
	100, 135, 101, 100, 136, 101, 100, 137, 
	101, 100, 138, 101, 100, 101, 139, 100, 
	140, 101, 100, 141, 101, 100, 142, 101, 
	100, 143, 101, 100, 144, 101, 100, 145, 
	101, 100, 146, 101, 100, 147, 101, 100, 
	148, 101, 100, 149, 101, 100, 101, 83, 
	100, 151, 101, 100, 152, 101, 100, 153, 
	101, 100, 154, 101, 100, 155, 101, 100, 
	149, 101, 100, 101, 157, 100, 101, 158, 
	100, 101, 159, 100, 101, 160, 100, 101, 
	161, 100, 101, 162, 100, 101, 163, 100, 
	101, 164, 100, 101, 165, 100, 101, 166, 
	100, 101, 167, 100, 101, 168, 100, 101, 
	169, 100, 101, 10, 100, 171, 0, 172, 
	250, 317, 0, 173, 0, 174, 0, 175, 
	0, 176, 0, 177, 0, 178, 0, 179, 
	0, 180, 0, 181, 0, 182, 0, 183, 
	0, 184, 0, 185, 0, 186, 0, 187, 
	0, 188, 0, 189, 0, 190, 0, 192, 
	191, 192, 191, 193, 192, 192, 10, 236, 
	198, 10, 192, 191, 194, 201, 211, 215, 
	221, 192, 191, 195, 192, 191, 196, 199, 
	192, 191, 197, 192, 191, 198, 192, 191, 
	192, 83, 191, 200, 192, 83, 191, 198, 
	192, 191, 202, 192, 191, 203, 192, 191, 
	204, 192, 191, 205, 192, 191, 206, 192, 
	191, 207, 192, 191, 208, 192, 191, 209, 
	192, 191, 210, 192, 191, 198, 192, 191, 
	212, 192, 191, 213, 192, 191, 214, 192, 
	191, 198, 192, 191, 216, 192, 191, 217, 
	192, 191, 218, 192, 191, 219, 192, 191, 
	220, 192, 191, 198, 192, 191, 222, 192, 
	191, 223, 230, 192, 191, 224, 192, 191, 
	225, 192, 191, 226, 192, 191, 227, 192, 
	191, 228, 192, 191, 229, 192, 191, 192, 
	83, 191, 231, 192, 191, 232, 192, 191, 
	233, 192, 191, 234, 192, 191, 235, 192, 
	191, 229, 192, 191, 192, 237, 191, 192, 
	238, 191, 192, 239, 191, 192, 240, 191, 
	192, 241, 191, 192, 242, 191, 192, 243, 
	191, 192, 244, 191, 192, 245, 191, 192, 
	246, 191, 192, 247, 191, 192, 248, 191, 
	192, 249, 191, 192, 10, 191, 251, 0, 
	252, 0, 253, 0, 254, 0, 255, 0, 
	256, 0, 257, 0, 259, 258, 259, 258, 
	260, 259, 259, 10, 303, 10, 259, 258, 
	261, 274, 278, 259, 258, 262, 259, 258, 
	263, 259, 258, 264, 259, 258, 265, 259, 
	258, 266, 259, 258, 267, 259, 258, 268, 
	259, 258, 269, 259, 258, 270, 259, 258, 
	271, 259, 258, 272, 259, 258, 273, 259, 
	258, 259, 83, 258, 275, 259, 258, 276, 
	259, 258, 277, 259, 258, 273, 259, 258, 
	279, 259, 258, 280, 297, 291, 259, 258, 
	281, 259, 258, 282, 259, 258, 283, 259, 
	258, 284, 259, 258, 285, 259, 258, 286, 
	259, 258, 259, 287, 258, 288, 259, 258, 
	289, 259, 258, 290, 259, 258, 291, 259, 
	258, 292, 259, 258, 293, 259, 258, 294, 
	259, 258, 295, 259, 258, 296, 259, 258, 
	273, 259, 258, 298, 259, 258, 299, 259, 
	258, 300, 259, 258, 301, 259, 258, 302, 
	259, 258, 273, 259, 258, 259, 304, 258, 
	259, 305, 258, 259, 306, 258, 259, 307, 
	258, 259, 308, 258, 259, 309, 258, 259, 
	310, 258, 259, 311, 258, 259, 312, 258, 
	259, 313, 258, 259, 314, 258, 259, 315, 
	258, 259, 316, 258, 259, 10, 258, 318, 
	0, 319, 0, 320, 0, 321, 0, 322, 
	0, 323, 0, 324, 0, 326, 325, 326, 
	325, 327, 326, 326, 10, 385, 332, 10, 
	326, 325, 328, 335, 345, 349, 355, 360, 
	326, 325, 329, 326, 325, 330, 333, 326, 
	325, 331, 326, 325, 332, 326, 325, 326, 
	83, 325, 334, 326, 83, 325, 332, 326, 
	325, 336, 326, 325, 337, 326, 325, 338, 
	326, 325, 339, 326, 325, 340, 326, 325, 
	341, 326, 325, 342, 326, 325, 343, 326, 
	325, 344, 326, 325, 332, 326, 325, 346, 
	326, 325, 347, 326, 325, 348, 326, 325, 
	332, 326, 325, 350, 326, 325, 351, 326, 
	325, 352, 326, 325, 353, 326, 325, 354, 
	326, 325, 332, 326, 325, 356, 326, 325, 
	357, 326, 325, 358, 326, 325, 359, 326, 
	325, 326, 83, 325, 361, 326, 325, 362, 
	379, 373, 326, 325, 363, 326, 325, 364, 
	326, 325, 365, 326, 325, 366, 326, 325, 
	367, 326, 325, 368, 326, 325, 326, 369, 
	325, 370, 326, 325, 371, 326, 325, 372, 
	326, 325, 373, 326, 325, 374, 326, 325, 
	375, 326, 325, 376, 326, 325, 377, 326, 
	325, 378, 326, 325, 359, 326, 325, 380, 
	326, 325, 381, 326, 325, 382, 326, 325, 
	383, 326, 325, 384, 326, 325, 359, 326, 
	325, 326, 386, 325, 326, 387, 325, 326, 
	388, 325, 326, 389, 325, 326, 390, 325, 
	326, 391, 325, 326, 392, 325, 326, 393, 
	325, 326, 394, 325, 326, 395, 325, 326, 
	396, 325, 326, 397, 325, 326, 398, 325, 
	326, 10, 325, 400, 0, 10, 0, 0, 
	0
};

static const char _lexer_trans_actions[] = {
	25, 0, 47, 0, 5, 1, 0, 25, 
	1, 31, 0, 39, 0, 0, 0, 0, 
	0, 0, 0, 39, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 39, 
	50, 99, 19, 0, 25, 47, 0, 5, 
	1, 0, 25, 1, 31, 0, 39, 0, 
	39, 0, 39, 47, 0, 0, 39, 119, 
	41, 41, 41, 3, 111, 29, 29, 29, 
	0, 111, 29, 29, 29, 0, 111, 29, 
	0, 29, 0, 95, 7, 7, 39, 47, 
	0, 0, 39, 103, 21, 0, 47, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 39, 39, 39, 39, 
	0, 23, 107, 23, 23, 44, 23, 0, 
	47, 0, 1, 0, 39, 0, 0, 0, 
	39, 47, 33, 33, 80, 33, 33, 39, 
	0, 35, 0, 39, 0, 0, 47, 0, 
	0, 35, 0, 0, 89, 47, 0, 86, 
	83, 37, 89, 83, 92, 0, 39, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 124, 50, 47, 0, 77, 47, 
	0, 74, 74, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	47, 17, 0, 56, 115, 27, 53, 50, 
	27, 56, 50, 59, 27, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	77, 47, 0, 65, 29, 77, 65, 0, 
	0, 0, 0, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 47, 11, 0, 
	0, 47, 11, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 47, 11, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 11, 0, 0, 39, 0, 
	0, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 77, 47, 0, 71, 29, 
	77, 71, 0, 0, 0, 0, 0, 0, 
	0, 47, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	47, 15, 0, 0, 47, 15, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	15, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 15, 0, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	77, 47, 0, 62, 29, 62, 0, 0, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 47, 9, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 9, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 124, 50, 47, 
	0, 77, 47, 0, 68, 29, 77, 68, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	13, 0, 0, 47, 13, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 47, 13, 0, 0, 47, 0, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 13, 0, 0, 39, 0, 39, 0, 
	0
};

static const char _lexer_eof_actions[] = {
	0, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 401;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"

static VALUE 
unindent(VALUE con, int start_col)
{
  VALUE re;
  // Gherkin will crash gracefully if the string representation of start_col pushes the pattern past 32 characters
  char pat[32]; 
  snprintf(pat, 32, "^[\t ]{0,%d}", start_col); 
  re = rb_reg_regcomp(rb_str_new2(pat));
  rb_funcall(con, rb_intern("gsub!"), 2, re, rb_str_new2(""));

  return Qnil;

}

static void 
store_kw_con(VALUE listener, const char * event_name, 
             const char * keyword_at, size_t keyword_length, 
             const char * at,         size_t length, 
             int current_line)
{
  VALUE con = Qnil, kw = Qnil;
  kw = ENCODED_STR_NEW(keyword_at, keyword_length);
  con = ENCODED_STR_NEW(at, length);
  rb_funcall(con, rb_intern("strip!"), 0);
  rb_funcall(listener, rb_intern(event_name), 3, kw, con, INT2FIX(current_line)); 
}

static void
store_multiline_kw_con(VALUE listener, const char * event_name,
                      const char * keyword_at, size_t keyword_length,
                      const char * at,         size_t length,
                      int current_line, int start_col)
{
  VALUE split;
  VALUE con = Qnil, kw = Qnil, name = Qnil, desc = Qnil;

  kw = ENCODED_STR_NEW(keyword_at, keyword_length);
  con = ENCODED_STR_NEW(at, length);

  unindent(con, start_col);
  
  split = rb_str_split(con, "\n");

  name = rb_funcall(split, rb_intern("shift"), 0);
  desc = rb_ary_join(split, rb_str_new2( "\n" ));

  if( name == Qnil ) 
  {
    name = rb_str_new2("");
  }
  if( rb_funcall(desc, rb_intern("size"), 0) == 0) 
  {
    desc = rb_str_new2("");
  }
  rb_funcall(name, rb_intern("strip!"), 0);
  rb_funcall(desc, rb_intern("rstrip!"), 0);
  rb_funcall(listener, rb_intern(event_name), 4, kw, name, desc, INT2FIX(current_line)); 
}

static void 
store_attr(VALUE listener, const char * attr_type,
           const char * at, size_t length, 
           int line)
{
  VALUE val = ENCODED_STR_NEW(at, length);
  rb_funcall(listener, rb_intern(attr_type), 2, val, INT2FIX(line));
}

static void 
store_pystring_content(VALUE listener, 
          int start_col, 
          const char *at, size_t length, 
          int current_line)
{
  VALUE re2;
  VALUE unescape_escaped_quotes;
  VALUE con = ENCODED_STR_NEW(at, length);

  unindent(con, start_col);

  re2 = rb_reg_regcomp(rb_str_new2("\r\\Z"));
  unescape_escaped_quotes = rb_reg_regcomp(rb_str_new2("\\\\\"\\\\\"\\\\\""));
  rb_funcall(con, rb_intern("sub!"), 2, re2, rb_str_new2(""));
  rb_funcall(con, rb_intern("gsub!"), 2, unescape_escaped_quotes, rb_str_new2("\"\"\""));
  rb_funcall(listener, rb_intern("doc_string"), 2, con, INT2FIX(current_line));
}

static void 
raise_lexer_error(const char * at, int line)
{ 
  rb_raise(rb_eGherkinLexingError, "Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information.", line, at);
}

static void lexer_init(lexer_state *lexer) {
  lexer->content_start = 0;
  lexer->content_end = 0;
  lexer->content_len = 0;
  lexer->mark = 0;
  lexer->keyword_start = 0;
  lexer->keyword_end = 0;
  lexer->next_keyword_start = 0;
  lexer->line_number = 1;
  lexer->last_newline = 0;
  lexer->final_newline = 0;
  lexer->start_col = 0;
}

static VALUE CLexer_alloc(VALUE klass)
{
  VALUE obj;
  lexer_state *lxr = ALLOC(lexer_state);
  lexer_init(lxr);

  obj = Data_Wrap_Struct(klass, NULL, -1, lxr);

  return obj;
}

static VALUE CLexer_init(VALUE self, VALUE listener)
{
  lexer_state *lxr; 
  rb_iv_set(self, "@listener", listener);
  
  lxr = NULL;
  DATA_GET(self, lexer_state, lxr);
  lexer_init(lxr);
  
  return self;
}

static VALUE CLexer_scan(VALUE self, VALUE input)
{
  VALUE input_copy;
  char *data;
  size_t len;
  VALUE listener = rb_iv_get(self, "@listener");

  lexer_state *lexer;
  lexer = NULL;
  DATA_GET(self, lexer_state, lexer);

  input_copy = rb_str_dup(input);

  rb_str_append(input_copy, rb_str_new2("\n%_FEATURE_END_%"));
  data = RSTRING_PTR(input_copy);
  len = RSTRING_LEN(input_copy);
  
  if (len == 0) { 
    rb_raise(rb_eGherkinLexingError, "No content to lex.");
  } else {

    const char *p, *pe, *eof;
    int cs = 0;
    
    VALUE current_row = Qnil;

    p = data;
    pe = data + len;
    eof = pe;
    
    assert(*pe == '\0' && "pointer does not end on NULL");
    
    
#line 970 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
    
#line 977 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _lexer_trans_keys + _lexer_key_offsets[cs];
	_trans = _lexer_index_offsets[cs];

	_klen = _lexer_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _lexer_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	cs = _lexer_trans_targs[_trans];

	if ( _lexer_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _lexer_actions + _lexer_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    VALUE re_pipe, re_newline, re_backslash;
    VALUE con = ENCODED_STR_NEW(PTR_TO(content_start), LEN(content_start, p));
    rb_funcall(con, rb_intern("strip!"), 0);
    re_pipe      = rb_reg_regcomp(rb_str_new2("\\\\\\|"));
    re_newline   = rb_reg_regcomp(rb_str_new2("\\\\n"));
    re_backslash = rb_reg_regcomp(rb_str_new2("\\\\\\\\"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_pipe,      rb_str_new2("|"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_newline,   rb_str_new2("\n"));
    rb_funcall(con, rb_intern("gsub!"), 2, re_backslash, rb_str_new2("\\"));

    rb_ary_push(current_row, con);
  }
	break;
	case 20:
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    int line;
    if (cs < lexer_first_final) {
      size_t count = 0;
      VALUE newstr_val;
      char *newstr;
      int newstr_count = 0;        
      size_t len;
      const char *buff;
      if (lexer->last_newline != 0) {
        len = LEN(last_newline, eof);
        buff = PTR_TO(last_newline);
      } else {
        len = strlen(data);
        buff = data;
      }

      // Allocate as a ruby string so that it gets cleaned up by GC
      newstr_val = rb_str_new(buff, len);
      newstr = RSTRING_PTR(newstr_val);


      for (count = 0; count < len; count++) {
        if(buff[count] == 10) {
          newstr[newstr_count] = '\0'; // terminate new string at first newline found
          break;
        } else {
          if (buff[count] == '%') {
            newstr[newstr_count++] = buff[count];
            newstr[newstr_count] = buff[count];
          } else {
            newstr[newstr_count] = buff[count];
          }
        }
        newstr_count++;
      }

      line = lexer->line_number;
      lexer_init(lexer); // Re-initialize so we can scan again with the same lexer
      raise_lexer_error(newstr, line);
    } else {
      rb_funcall(listener, rb_intern("eof"), 0);
    }
  }
	break;
#line 1253 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	const char *__acts = _lexer_actions + _lexer_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"
	{
    int line;
    if (cs < lexer_first_final) {
      size_t count = 0;
      VALUE newstr_val;
      char *newstr;
      int newstr_count = 0;        
      size_t len;
      const char *buff;
      if (lexer->last_newline != 0) {
        len = LEN(last_newline, eof);
        buff = PTR_TO(last_newline);
      } else {
        len = strlen(data);
        buff = data;
      }

      // Allocate as a ruby string so that it gets cleaned up by GC
      newstr_val = rb_str_new(buff, len);
      newstr = RSTRING_PTR(newstr_val);


      for (count = 0; count < len; count++) {
        if(buff[count] == 10) {
          newstr[newstr_count] = '\0'; // terminate new string at first newline found
          break;
        } else {
          if (buff[count] == '%') {
            newstr[newstr_count++] = buff[count];
            newstr[newstr_count] = buff[count];
          } else {
            newstr[newstr_count] = buff[count];
          }
        }
        newstr_count++;
      }

      line = lexer->line_number;
      lexer_init(lexer); // Re-initialize so we can scan again with the same lexer
      raise_lexer_error(newstr, line);
    } else {
      rb_funcall(listener, rb_intern("eof"), 0);
    }
  }
	break;
#line 1316 "ext/gherkin_lexer_he/gherkin_lexer_he.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/he.c.rl"

    assert(p <= pe && "data overflow after parsing execute");
    assert(lexer->content_start <= len && "content starts after data end");
    assert(lexer->mark < len && "mark is after data end");
    
    // Reset lexer by re-initializing the whole thing
    lexer_init(lexer);

    if (cs == lexer_error) {
      rb_raise(rb_eGherkinLexingError, "Invalid format, lexing fails.");
    } else {
      return Qtrue;
    }
  }
}

void Init_gherkin_lexer_he()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "He", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}


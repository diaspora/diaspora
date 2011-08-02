
#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_fi/gherkin_lexer_fi.c"
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
	0, 0, 17, 18, 19, 35, 36, 37, 
	41, 46, 51, 56, 61, 65, 69, 71, 
	72, 73, 74, 75, 76, 77, 78, 79, 
	80, 81, 82, 83, 84, 85, 86, 87, 
	88, 90, 95, 102, 107, 108, 109, 110, 
	111, 112, 113, 114, 115, 117, 118, 119, 
	120, 121, 122, 123, 124, 125, 126, 127, 
	128, 129, 130, 131, 132, 133, 134, 143, 
	145, 147, 149, 151, 153, 155, 157, 159, 
	161, 163, 165, 167, 169, 171, 173, 175, 
	177, 179, 181, 183, 185, 187, 189, 191, 
	207, 208, 210, 211, 212, 214, 215, 216, 
	217, 218, 219, 220, 227, 229, 231, 233, 
	235, 237, 239, 241, 243, 245, 247, 249, 
	250, 251, 265, 267, 269, 271, 273, 275, 
	277, 279, 281, 283, 285, 287, 289, 291, 
	293, 295, 297, 299, 301, 303, 305, 307, 
	309, 311, 314, 316, 318, 320, 322, 324, 
	326, 328, 330, 332, 334, 336, 338, 340, 
	342, 344, 346, 349, 351, 353, 355, 358, 
	360, 362, 364, 366, 368, 370, 372, 373, 
	374, 375, 376, 377, 378, 379, 393, 395, 
	397, 399, 401, 403, 405, 407, 409, 411, 
	413, 415, 417, 419, 421, 423, 425, 427, 
	429, 431, 433, 435, 437, 439, 442, 444, 
	446, 448, 450, 452, 454, 456, 458, 460, 
	462, 464, 466, 468, 470, 472, 474, 476, 
	478, 479, 480, 481, 482, 483, 484, 498, 
	500, 502, 504, 506, 508, 510, 512, 514, 
	516, 518, 520, 522, 524, 526, 528, 530, 
	532, 534, 536, 538, 540, 542, 544, 547, 
	549, 551, 553, 555, 557, 559, 561, 563, 
	565, 567, 569, 571, 573, 575, 577, 579, 
	581, 583, 585, 587, 590, 592, 594, 596, 
	598, 602, 608, 611, 613, 619, 635, 637, 
	640, 642, 644, 647, 649, 651, 653, 656, 
	658, 660, 662, 664, 666, 668, 670
};

static const char _lexer_trans_keys[] = {
	-17, 10, 32, 34, 35, 37, 42, 64, 
	74, 75, 77, 78, 79, 84, 124, 9, 
	13, -69, -65, 10, 32, 34, 35, 37, 
	42, 64, 74, 75, 77, 78, 79, 84, 
	124, 9, 13, 34, 34, 10, 32, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 9, 
	13, 10, 32, 9, 13, 10, 13, 10, 
	95, 70, 69, 65, 84, 85, 82, 69, 
	95, 69, 78, 68, 95, 37, 32, 10, 
	10, 13, 13, 32, 64, 9, 10, 9, 
	10, 13, 32, 64, 11, 12, 10, 32, 
	64, 9, 13, 97, 117, 110, 117, 116, 
	116, 105, 105, 108, 109, 101, 116, 101, 
	116, 97, 97, 105, 110, 97, 105, 115, 
	117, 117, 115, 58, 10, 10, 10, 32, 
	35, 37, 64, 79, 84, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 109, 10, 105, 10, 
	110, 10, 97, 10, 105, 10, 115, 10, 
	117, 10, 117, 10, 115, 10, 58, 10, 
	32, 34, 35, 37, 42, 64, 74, 75, 
	77, 78, 79, 84, 124, 9, 13, 97, 
	112, 117, 97, 117, 107, 115, 115, 101, 
	116, 58, 10, 10, 10, 32, 35, 79, 
	124, 9, 13, 10, 109, 10, 105, 10, 
	110, 10, 97, 10, 105, 10, 115, 10, 
	117, 10, 117, 10, 115, 10, 58, 58, 
	97, 10, 10, 10, 32, 35, 37, 42, 
	64, 74, 75, 77, 78, 79, 84, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	97, 10, 117, 10, 110, 10, 117, 10, 
	116, 10, 116, 10, 105, 10, 105, 10, 
	108, 109, 10, 101, 10, 116, 10, 101, 
	10, 116, 10, 97, 10, 97, 10, 105, 
	10, 110, 10, 97, 10, 105, 10, 115, 
	10, 117, 10, 117, 10, 115, 10, 58, 
	10, 97, 10, 112, 117, 10, 97, 10, 
	117, 10, 115, 10, 58, 97, 10, 105, 
	10, 104, 10, 105, 10, 111, 10, 115, 
	10, 116, 10, 97, 105, 104, 105, 111, 
	58, 10, 10, 10, 32, 35, 37, 42, 
	64, 74, 75, 77, 78, 79, 84, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	97, 10, 117, 10, 110, 10, 117, 10, 
	116, 10, 116, 10, 105, 10, 105, 10, 
	108, 109, 10, 101, 10, 116, 10, 101, 
	10, 116, 10, 97, 10, 97, 10, 105, 
	10, 110, 10, 97, 10, 105, 10, 115, 
	10, 117, 10, 117, 10, 115, 10, 58, 
	10, 97, 10, 112, 10, 97, 115, 116, 
	97, 58, 10, 10, 10, 32, 35, 37, 
	42, 64, 74, 75, 77, 78, 79, 84, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 97, 10, 117, 10, 110, 10, 117, 
	10, 116, 10, 116, 10, 105, 10, 105, 
	10, 108, 109, 10, 101, 10, 116, 10, 
	101, 10, 116, 10, 97, 10, 97, 10, 
	105, 10, 110, 10, 97, 10, 105, 10, 
	115, 10, 117, 10, 117, 10, 115, 10, 
	58, 10, 97, 10, 112, 10, 97, 10, 
	117, 10, 115, 10, 58, 97, 10, 105, 
	10, 104, 10, 105, 10, 111, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, 10, 32, 34, 35, 37, 
	42, 64, 74, 75, 77, 78, 79, 84, 
	124, 9, 13, 10, 97, 10, 112, 117, 
	10, 97, 10, 117, 10, 107, 115, 10, 
	115, 10, 101, 10, 116, 10, 58, 97, 
	10, 105, 10, 104, 10, 105, 10, 111, 
	10, 115, 10, 116, 10, 97, 0
};

static const char _lexer_single_lengths[] = {
	0, 15, 1, 1, 14, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 7, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 14, 
	1, 2, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 5, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 12, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 12, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 12, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 4, 3, 2, 4, 14, 2, 3, 
	2, 2, 3, 2, 2, 2, 3, 2, 
	2, 2, 2, 2, 2, 2, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 1, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
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
	1, 1, 0, 0, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 17, 19, 21, 37, 39, 41, 
	45, 50, 55, 60, 65, 69, 73, 76, 
	78, 80, 82, 84, 86, 88, 90, 92, 
	94, 96, 98, 100, 102, 104, 106, 108, 
	110, 113, 118, 125, 130, 132, 134, 136, 
	138, 140, 142, 144, 146, 149, 151, 153, 
	155, 157, 159, 161, 163, 165, 167, 169, 
	171, 173, 175, 177, 179, 181, 183, 192, 
	195, 198, 201, 204, 207, 210, 213, 216, 
	219, 222, 225, 228, 231, 234, 237, 240, 
	243, 246, 249, 252, 255, 258, 261, 264, 
	280, 282, 285, 287, 289, 292, 294, 296, 
	298, 300, 302, 304, 311, 314, 317, 320, 
	323, 326, 329, 332, 335, 338, 341, 344, 
	346, 348, 362, 365, 368, 371, 374, 377, 
	380, 383, 386, 389, 392, 395, 398, 401, 
	404, 407, 410, 413, 416, 419, 422, 425, 
	428, 431, 435, 438, 441, 444, 447, 450, 
	453, 456, 459, 462, 465, 468, 471, 474, 
	477, 480, 483, 487, 490, 493, 496, 500, 
	503, 506, 509, 512, 515, 518, 521, 523, 
	525, 527, 529, 531, 533, 535, 549, 552, 
	555, 558, 561, 564, 567, 570, 573, 576, 
	579, 582, 585, 588, 591, 594, 597, 600, 
	603, 606, 609, 612, 615, 618, 622, 625, 
	628, 631, 634, 637, 640, 643, 646, 649, 
	652, 655, 658, 661, 664, 667, 670, 673, 
	676, 678, 680, 682, 684, 686, 688, 702, 
	705, 708, 711, 714, 717, 720, 723, 726, 
	729, 732, 735, 738, 741, 744, 747, 750, 
	753, 756, 759, 762, 765, 768, 771, 775, 
	778, 781, 784, 787, 790, 793, 796, 799, 
	802, 805, 808, 811, 814, 817, 820, 823, 
	826, 829, 832, 835, 839, 842, 845, 848, 
	851, 855, 861, 865, 868, 874, 890, 893, 
	897, 900, 903, 907, 910, 913, 916, 920, 
	923, 926, 929, 932, 935, 938, 941
};

static const short _lexer_trans_targs[] = {
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 37, 39, 42, 44, 88, 272, 4, 
	0, 3, 0, 4, 0, 4, 4, 5, 
	14, 16, 30, 33, 36, 37, 39, 42, 
	44, 88, 272, 4, 0, 6, 0, 7, 
	0, 8, 7, 7, 0, 9, 9, 10, 
	9, 9, 9, 9, 10, 9, 9, 9, 
	9, 11, 9, 9, 9, 9, 12, 9, 
	9, 4, 13, 13, 0, 4, 13, 13, 
	0, 4, 15, 14, 4, 0, 17, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 23, 0, 24, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	294, 0, 31, 0, 0, 32, 4, 15, 
	32, 0, 0, 0, 0, 34, 35, 4, 
	35, 35, 33, 34, 34, 4, 35, 33, 
	35, 0, 30, 0, 38, 0, 30, 0, 
	40, 0, 41, 0, 36, 0, 43, 0, 
	38, 0, 45, 51, 0, 46, 0, 47, 
	0, 48, 0, 49, 0, 50, 0, 38, 
	0, 52, 0, 53, 0, 54, 0, 55, 
	0, 56, 0, 57, 0, 58, 0, 59, 
	0, 60, 0, 62, 61, 62, 61, 62, 
	62, 4, 63, 4, 77, 278, 62, 61, 
	62, 64, 61, 62, 65, 61, 62, 66, 
	61, 62, 67, 61, 62, 68, 61, 62, 
	69, 61, 62, 70, 61, 62, 71, 61, 
	62, 72, 61, 62, 73, 61, 62, 74, 
	61, 62, 75, 61, 62, 76, 61, 62, 
	4, 61, 62, 78, 61, 62, 79, 61, 
	62, 80, 61, 62, 81, 61, 62, 82, 
	61, 62, 83, 61, 62, 84, 61, 62, 
	85, 61, 62, 86, 61, 62, 87, 61, 
	4, 4, 5, 14, 16, 30, 33, 36, 
	37, 39, 42, 44, 88, 272, 4, 0, 
	89, 0, 90, 216, 0, 91, 0, 92, 
	0, 93, 110, 0, 94, 0, 95, 0, 
	96, 0, 97, 0, 99, 98, 99, 98, 
	99, 99, 4, 100, 4, 99, 98, 99, 
	101, 98, 99, 102, 98, 99, 103, 98, 
	99, 104, 98, 99, 105, 98, 99, 106, 
	98, 99, 107, 98, 99, 108, 98, 99, 
	109, 98, 99, 87, 98, 111, 166, 0, 
	113, 112, 113, 112, 113, 113, 4, 114, 
	128, 4, 129, 130, 132, 135, 137, 153, 
	113, 112, 113, 115, 112, 113, 116, 112, 
	113, 117, 112, 113, 118, 112, 113, 119, 
	112, 113, 120, 112, 113, 121, 112, 113, 
	122, 112, 113, 123, 112, 113, 124, 112, 
	113, 125, 112, 113, 126, 112, 113, 127, 
	112, 113, 4, 112, 113, 87, 112, 113, 
	128, 112, 113, 131, 112, 113, 128, 112, 
	113, 133, 112, 113, 134, 112, 113, 129, 
	112, 113, 136, 112, 113, 131, 112, 113, 
	138, 144, 112, 113, 139, 112, 113, 140, 
	112, 113, 141, 112, 113, 142, 112, 113, 
	143, 112, 113, 131, 112, 113, 145, 112, 
	113, 146, 112, 113, 147, 112, 113, 148, 
	112, 113, 149, 112, 113, 150, 112, 113, 
	151, 112, 113, 152, 112, 113, 87, 112, 
	113, 154, 112, 113, 155, 163, 112, 113, 
	156, 112, 113, 157, 112, 113, 158, 112, 
	113, 87, 159, 112, 113, 160, 112, 113, 
	161, 112, 113, 162, 112, 113, 152, 112, 
	113, 164, 112, 113, 165, 112, 113, 152, 
	112, 167, 0, 168, 0, 169, 0, 170, 
	0, 171, 0, 173, 172, 173, 172, 173, 
	173, 4, 174, 188, 4, 189, 190, 192, 
	195, 197, 213, 173, 172, 173, 175, 172, 
	173, 176, 172, 173, 177, 172, 173, 178, 
	172, 173, 179, 172, 173, 180, 172, 173, 
	181, 172, 173, 182, 172, 173, 183, 172, 
	173, 184, 172, 173, 185, 172, 173, 186, 
	172, 173, 187, 172, 173, 4, 172, 173, 
	87, 172, 173, 188, 172, 173, 191, 172, 
	173, 188, 172, 173, 193, 172, 173, 194, 
	172, 173, 189, 172, 173, 196, 172, 173, 
	191, 172, 173, 198, 204, 172, 173, 199, 
	172, 173, 200, 172, 173, 201, 172, 173, 
	202, 172, 173, 203, 172, 173, 191, 172, 
	173, 205, 172, 173, 206, 172, 173, 207, 
	172, 173, 208, 172, 173, 209, 172, 173, 
	210, 172, 173, 211, 172, 173, 212, 172, 
	173, 87, 172, 173, 214, 172, 173, 215, 
	172, 173, 210, 172, 217, 0, 218, 0, 
	219, 0, 220, 0, 222, 221, 222, 221, 
	222, 222, 4, 223, 237, 4, 238, 239, 
	241, 244, 246, 262, 222, 221, 222, 224, 
	221, 222, 225, 221, 222, 226, 221, 222, 
	227, 221, 222, 228, 221, 222, 229, 221, 
	222, 230, 221, 222, 231, 221, 222, 232, 
	221, 222, 233, 221, 222, 234, 221, 222, 
	235, 221, 222, 236, 221, 222, 4, 221, 
	222, 87, 221, 222, 237, 221, 222, 240, 
	221, 222, 237, 221, 222, 242, 221, 222, 
	243, 221, 222, 238, 221, 222, 245, 221, 
	222, 240, 221, 222, 247, 253, 221, 222, 
	248, 221, 222, 249, 221, 222, 250, 221, 
	222, 251, 221, 222, 252, 221, 222, 240, 
	221, 222, 254, 221, 222, 255, 221, 222, 
	256, 221, 222, 257, 221, 222, 258, 221, 
	222, 259, 221, 222, 260, 221, 222, 261, 
	221, 222, 87, 221, 222, 263, 221, 222, 
	264, 221, 222, 265, 221, 222, 266, 221, 
	222, 267, 221, 222, 87, 268, 221, 222, 
	269, 221, 222, 270, 221, 222, 271, 221, 
	222, 261, 221, 272, 273, 272, 0, 277, 
	276, 275, 273, 276, 274, 0, 275, 273, 
	274, 0, 275, 274, 277, 276, 275, 273, 
	276, 274, 277, 277, 5, 14, 16, 30, 
	33, 36, 37, 39, 42, 44, 88, 272, 
	277, 0, 62, 279, 61, 62, 280, 291, 
	61, 62, 281, 61, 62, 282, 61, 62, 
	283, 286, 61, 62, 284, 61, 62, 285, 
	61, 62, 86, 61, 62, 87, 287, 61, 
	62, 288, 61, 62, 289, 61, 62, 290, 
	61, 62, 86, 61, 62, 292, 61, 62, 
	293, 61, 62, 86, 61, 0, 0
};

static const char _lexer_trans_actions[] = {
	0, 47, 0, 5, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 31, 0, 
	39, 0, 39, 0, 39, 47, 0, 5, 
	1, 0, 25, 1, 25, 25, 25, 25, 
	25, 25, 31, 0, 39, 0, 39, 0, 
	39, 47, 0, 0, 39, 119, 41, 41, 
	41, 3, 111, 29, 29, 29, 0, 111, 
	29, 29, 29, 0, 111, 29, 0, 29, 
	0, 95, 7, 7, 39, 47, 0, 0, 
	39, 103, 21, 0, 47, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 39, 50, 99, 19, 
	0, 39, 39, 39, 39, 0, 23, 107, 
	23, 23, 44, 23, 0, 47, 0, 1, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 47, 
	0, 62, 29, 62, 77, 77, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	9, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 9, 0, 
	115, 27, 53, 50, 27, 56, 50, 56, 
	56, 56, 56, 56, 56, 59, 27, 39, 
	0, 39, 0, 0, 39, 0, 39, 0, 
	39, 0, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	47, 0, 74, 77, 74, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 17, 0, 0, 0, 39, 
	124, 50, 47, 0, 47, 0, 68, 29, 
	77, 68, 77, 77, 77, 77, 77, 77, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 13, 0, 47, 13, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 13, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 13, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 47, 
	0, 71, 29, 77, 71, 77, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 15, 0, 47, 
	15, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 15, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	47, 0, 65, 29, 77, 65, 77, 77, 
	77, 77, 77, 77, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 11, 0, 
	47, 11, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 11, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 11, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 0, 0, 39, 47, 
	33, 33, 80, 33, 33, 39, 0, 35, 
	0, 39, 0, 0, 47, 0, 0, 35, 
	0, 0, 47, 0, 86, 83, 37, 89, 
	83, 89, 89, 89, 89, 89, 89, 92, 
	0, 39, 47, 0, 0, 47, 0, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 9, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 0, 0
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
	39, 39, 39, 39, 39, 39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 294;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"

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
    
    
#line 809 "ext/gherkin_lexer_fi/gherkin_lexer_fi.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
    
#line 816 "ext/gherkin_lexer_fi/gherkin_lexer_fi.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
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
#line 1092 "ext/gherkin_lexer_fi/gherkin_lexer_fi.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"
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
#line 1155 "ext/gherkin_lexer_fi/gherkin_lexer_fi.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/fi.c.rl"

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

void Init_gherkin_lexer_fi()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Fi", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}



#line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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


#line 242 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"


/** Data **/

#line 87 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
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
	0, 0, 16, 19, 20, 21, 22, 23, 
	24, 26, 41, 44, 45, 46, 47, 48, 
	50, 51, 52, 53, 55, 56, 57, 58, 
	59, 60, 61, 62, 63, 76, 79, 81, 
	83, 85, 87, 102, 103, 104, 106, 107, 
	108, 109, 110, 111, 112, 113, 114, 127, 
	130, 132, 134, 136, 138, 140, 142, 144, 
	146, 150, 152, 154, 156, 158, 161, 163, 
	165, 167, 170, 172, 174, 176, 178, 180, 
	182, 184, 186, 188, 190, 192, 194, 196, 
	198, 200, 202, 204, 206, 208, 210, 212, 
	214, 216, 218, 220, 222, 224, 226, 228, 
	230, 232, 234, 236, 238, 240, 242, 244, 
	245, 246, 247, 248, 249, 250, 251, 255, 
	260, 265, 270, 275, 279, 283, 285, 286, 
	287, 288, 289, 290, 291, 292, 293, 294, 
	295, 296, 297, 298, 299, 300, 301, 306, 
	313, 318, 322, 328, 331, 333, 339, 354, 
	356, 358, 360, 362, 366, 368, 370, 372, 
	374, 377, 379, 381, 383, 385, 387, 389, 
	391, 393, 395, 397, 399, 401, 403, 405, 
	407, 409, 411, 413, 415, 417, 419, 421, 
	423, 425, 427, 429, 431, 433, 435, 437, 
	439, 441, 443, 445, 447, 448, 449, 462, 
	465, 467, 469, 471, 473, 475, 477, 479, 
	481, 485, 487, 489, 491, 493, 496, 498, 
	500, 502, 505, 507, 509, 511, 513, 515, 
	517, 519, 521, 523, 525, 527, 529, 531, 
	533, 535, 538, 540, 542, 544, 546, 548, 
	550, 552, 554, 556, 558, 560, 562, 564, 
	566, 568, 570, 572, 574, 576, 578, 580, 
	582, 584, 586, 588, 589, 590, 591, 592, 
	593, 594, 604, 606, 608, 610, 612, 614, 
	616, 619, 622, 624, 626, 628, 631, 633, 
	635, 637, 639, 641, 643, 645, 647, 649, 
	651, 653, 655, 657, 659, 661, 663, 665, 
	667, 669, 671, 673, 675, 677, 679, 681, 
	683, 685, 687, 689, 691, 693, 694, 695, 
	696, 697, 698, 699, 700, 701, 702, 703, 
	704, 705, 706, 707, 708, 715, 717, 719, 
	721, 723, 725, 727, 728, 729
};

static const char _lexer_trans_keys[] = {
	-28, -27, -25, -24, -23, -17, 10, 32, 
	34, 35, 37, 42, 64, 124, 9, 13, 
	-72, -67, -66, -90, -28, -72, -108, 10, 
	10, 13, -28, -27, -25, -24, -23, 10, 
	32, 34, 35, 37, 42, 64, 124, 9, 
	13, -127, -118, -96, -121, -24, -88, -83, 
	-121, -97, -26, -100, -84, -27, 58, -92, 
	-89, -25, -74, -79, 58, 10, 10, -28, 
	-27, -25, -24, -23, 10, 32, 35, 37, 
	42, 64, 9, 13, -72, -67, 10, -90, 
	10, -28, 10, -72, 10, -108, 10, -28, 
	-27, -25, -24, -23, 10, 32, 34, 35, 
	37, 42, 64, 124, 9, 13, -107, -74, 
	-128, -125, -116, -116, -26, -103, -81, 58, 
	10, 10, -28, -27, -25, -24, -23, 10, 
	32, 35, 37, 42, 64, 9, 13, -72, 
	-67, 10, -90, 10, -28, 10, -72, 10, 
	-108, 10, -122, 10, -26, 10, -104, 10, 
	-81, 10, -127, -118, -96, 10, -121, 10, 
	-24, 10, -88, 10, -83, 10, -121, -97, 
	10, -26, 10, -100, 10, -84, 10, -27, 
	10, 58, -92, 10, -89, 10, -25, 10, 
	-74, 10, -79, 10, 10, 58, -24, 10, 
	-125, 10, -67, 10, -76, 10, -26, 10, 
	-103, 10, -81, 10, -107, 10, -74, 10, 
	-128, 10, -116, 10, -126, 10, -93, 10, 
	-23, 10, -70, 10, -68, 10, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, -126, -93, -23, -70, 
	-68, 34, 34, 10, 32, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 34, 9, 13, 10, 32, 
	34, 9, 13, 10, 32, 9, 13, 10, 
	32, 9, 13, 10, 13, 10, 95, 70, 
	69, 65, 84, 85, 82, 69, 95, 69, 
	78, 68, 95, 37, 32, 13, 32, 64, 
	9, 10, 9, 10, 13, 32, 64, 11, 
	12, 10, 32, 64, 9, 13, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, -28, -27, -25, -24, -23, 
	10, 32, 34, 35, 37, 42, 64, 124, 
	9, 13, -122, 10, -26, 10, -104, 10, 
	-81, 10, -127, -118, -96, 10, -121, 10, 
	-24, 10, -88, 10, -83, 10, -121, -97, 
	10, -26, 10, -100, 10, -84, 10, 10, 
	58, -24, 10, -125, 10, -67, 10, -76, 
	10, -26, 10, -103, 10, -81, 10, -107, 
	10, -74, 10, -128, 10, -116, 10, -126, 
	10, -93, 10, -23, 10, -70, 10, -68, 
	10, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 32, 10, 
	10, -28, -27, -25, -24, -23, 10, 32, 
	35, 37, 42, 64, 9, 13, -72, -67, 
	10, -90, 10, -28, 10, -72, 10, -108, 
	10, -122, 10, -26, 10, -104, 10, -81, 
	10, -127, -118, -96, 10, -121, 10, -24, 
	10, -88, 10, -83, 10, -121, -97, 10, 
	-26, 10, -100, 10, -84, 10, -27, 10, 
	58, -92, 10, -89, 10, -25, 10, -74, 
	10, -79, 10, 10, 58, -24, 10, -125, 
	10, -67, 10, -76, 10, -26, 10, -103, 
	10, -81, 10, -107, 10, -74, 10, -128, 
	-125, 10, -116, 10, -116, 10, -26, 10, 
	-103, 10, -81, 10, -126, 10, -93, 10, 
	-23, 10, -70, 10, -68, 10, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, -24, -125, -67, 58, 
	10, 10, -28, -27, -24, 10, 32, 35, 
	37, 64, 9, 13, -66, 10, -117, 10, 
	-27, 10, -83, 10, -112, 10, 10, 58, 
	-118, -96, 10, -121, -97, 10, -26, 10, 
	-100, 10, -84, 10, -27, 10, 58, -92, 
	10, -89, 10, -25, 10, -74, 10, -79, 
	10, -24, 10, -125, 10, -67, 10, -76, 
	10, -26, 10, -103, 10, -81, 10, -125, 
	10, -116, 10, -26, 10, -103, 10, -81, 
	10, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, -76, -26, -103, 
	-81, -122, -26, -104, -81, -117, -27, -83, 
	-112, 58, 10, 10, -27, 10, 32, 35, 
	124, 9, 13, -118, 10, -97, 10, -24, 
	10, -125, 10, -67, 10, 10, 58, -69, 
	-65, 0
};

static const char _lexer_single_lengths[] = {
	0, 14, 3, 1, 1, 1, 1, 1, 
	2, 13, 3, 1, 1, 1, 1, 2, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 11, 3, 2, 2, 
	2, 2, 13, 1, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 11, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 2, 2, 2, 2, 3, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 2, 3, 
	3, 3, 3, 2, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 3, 5, 
	3, 2, 4, 3, 2, 4, 13, 2, 
	2, 2, 2, 4, 2, 2, 2, 2, 
	3, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 1, 1, 11, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	4, 2, 2, 2, 2, 3, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 8, 2, 2, 2, 2, 2, 2, 
	3, 3, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 5, 2, 2, 2, 
	2, 2, 2, 1, 1, 0
};

static const char _lexer_range_lengths[] = {
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	1, 1, 1, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	1, 1, 1, 0, 0, 1, 1, 0, 
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
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0
};

static const short _lexer_index_offsets[] = {
	0, 0, 16, 20, 22, 24, 26, 28, 
	30, 33, 48, 52, 54, 56, 58, 60, 
	63, 65, 67, 69, 72, 74, 76, 78, 
	80, 82, 84, 86, 88, 101, 105, 108, 
	111, 114, 117, 132, 134, 136, 139, 141, 
	143, 145, 147, 149, 151, 153, 155, 168, 
	172, 175, 178, 181, 184, 187, 190, 193, 
	196, 201, 204, 207, 210, 213, 217, 220, 
	223, 226, 230, 233, 236, 239, 242, 245, 
	248, 251, 254, 257, 260, 263, 266, 269, 
	272, 275, 278, 281, 284, 287, 290, 293, 
	296, 299, 302, 305, 308, 311, 314, 317, 
	320, 323, 326, 329, 332, 335, 338, 341, 
	343, 345, 347, 349, 351, 353, 355, 359, 
	364, 369, 374, 379, 383, 387, 390, 392, 
	394, 396, 398, 400, 402, 404, 406, 408, 
	410, 412, 414, 416, 418, 420, 422, 427, 
	434, 439, 443, 449, 453, 456, 462, 477, 
	480, 483, 486, 489, 494, 497, 500, 503, 
	506, 510, 513, 516, 519, 522, 525, 528, 
	531, 534, 537, 540, 543, 546, 549, 552, 
	555, 558, 561, 564, 567, 570, 573, 576, 
	579, 582, 585, 588, 591, 594, 597, 600, 
	603, 606, 609, 612, 615, 617, 619, 632, 
	636, 639, 642, 645, 648, 651, 654, 657, 
	660, 665, 668, 671, 674, 677, 681, 684, 
	687, 690, 694, 697, 700, 703, 706, 709, 
	712, 715, 718, 721, 724, 727, 730, 733, 
	736, 739, 743, 746, 749, 752, 755, 758, 
	761, 764, 767, 770, 773, 776, 779, 782, 
	785, 788, 791, 794, 797, 800, 803, 806, 
	809, 812, 815, 818, 820, 822, 824, 826, 
	828, 830, 840, 843, 846, 849, 852, 855, 
	858, 862, 866, 869, 872, 875, 879, 882, 
	885, 888, 891, 894, 897, 900, 903, 906, 
	909, 912, 915, 918, 921, 924, 927, 930, 
	933, 936, 939, 942, 945, 948, 951, 954, 
	957, 960, 963, 966, 969, 972, 974, 976, 
	978, 980, 982, 984, 986, 988, 990, 992, 
	994, 996, 998, 1000, 1002, 1009, 1012, 1015, 
	1018, 1021, 1024, 1027, 1029, 1031
};

static const short _lexer_trans_targs[] = {
	2, 10, 35, 37, 103, 323, 9, 9, 
	108, 117, 119, 133, 134, 137, 9, 0, 
	3, 305, 309, 0, 4, 0, 5, 0, 
	6, 0, 7, 0, 0, 8, 9, 118, 
	8, 2, 10, 35, 37, 103, 9, 9, 
	108, 117, 119, 133, 134, 137, 9, 0, 
	11, 15, 301, 0, 12, 0, 13, 0, 
	14, 0, 7, 0, 16, 251, 0, 17, 
	0, 18, 0, 19, 0, 20, 188, 0, 
	21, 0, 22, 0, 23, 0, 24, 0, 
	25, 0, 26, 0, 28, 27, 28, 27, 
	29, 147, 164, 166, 168, 28, 28, 9, 
	173, 187, 9, 28, 27, 30, 143, 28, 
	27, 31, 28, 27, 32, 28, 27, 33, 
	28, 27, 34, 28, 27, 2, 10, 35, 
	37, 103, 9, 9, 108, 117, 119, 133, 
	134, 137, 9, 0, 36, 0, 7, 0, 
	38, 39, 0, 4, 0, 40, 0, 41, 
	0, 42, 0, 43, 0, 44, 0, 46, 
	45, 46, 45, 47, 56, 79, 81, 83, 
	46, 46, 9, 88, 102, 9, 46, 45, 
	48, 52, 46, 45, 49, 46, 45, 50, 
	46, 45, 51, 46, 45, 34, 46, 45, 
	53, 46, 45, 54, 46, 45, 55, 46, 
	45, 34, 46, 45, 57, 61, 75, 46, 
	45, 58, 46, 45, 59, 46, 45, 60, 
	46, 45, 34, 46, 45, 62, 72, 46, 
	45, 63, 46, 45, 64, 46, 45, 65, 
	46, 45, 66, 46, 34, 45, 67, 46, 
	45, 68, 46, 45, 69, 46, 45, 70, 
	46, 45, 71, 46, 45, 46, 34, 45, 
	73, 46, 45, 74, 46, 45, 71, 46, 
	45, 76, 46, 45, 77, 46, 45, 78, 
	46, 45, 65, 46, 45, 80, 46, 45, 
	34, 46, 45, 82, 46, 45, 49, 46, 
	45, 84, 46, 45, 85, 46, 45, 86, 
	46, 45, 87, 46, 45, 34, 46, 45, 
	46, 89, 45, 46, 90, 45, 46, 91, 
	45, 46, 92, 45, 46, 93, 45, 46, 
	94, 45, 46, 95, 45, 46, 96, 45, 
	46, 97, 45, 46, 98, 45, 46, 99, 
	45, 46, 100, 45, 46, 101, 45, 46, 
	9, 45, 46, 34, 45, 104, 0, 105, 
	0, 106, 0, 107, 0, 7, 0, 109, 
	0, 110, 0, 111, 110, 110, 0, 112, 
	112, 113, 112, 112, 112, 112, 113, 112, 
	112, 112, 112, 114, 112, 112, 112, 112, 
	115, 112, 112, 9, 116, 116, 0, 9, 
	116, 116, 0, 9, 118, 117, 9, 0, 
	120, 0, 121, 0, 122, 0, 123, 0, 
	124, 0, 125, 0, 126, 0, 127, 0, 
	128, 0, 129, 0, 130, 0, 131, 0, 
	132, 0, 325, 0, 7, 0, 0, 0, 
	0, 0, 135, 136, 9, 136, 136, 134, 
	135, 135, 9, 136, 134, 136, 0, 137, 
	138, 137, 0, 142, 141, 140, 138, 141, 
	139, 0, 140, 138, 139, 0, 140, 139, 
	142, 141, 140, 138, 141, 139, 2, 10, 
	35, 37, 103, 142, 142, 108, 117, 119, 
	133, 134, 137, 142, 0, 144, 28, 27, 
	145, 28, 27, 146, 28, 27, 34, 28, 
	27, 148, 152, 160, 28, 27, 149, 28, 
	27, 150, 28, 27, 151, 28, 27, 34, 
	28, 27, 153, 157, 28, 27, 154, 28, 
	27, 155, 28, 27, 156, 28, 27, 28, 
	34, 27, 158, 28, 27, 159, 28, 27, 
	156, 28, 27, 161, 28, 27, 162, 28, 
	27, 163, 28, 27, 156, 28, 27, 165, 
	28, 27, 34, 28, 27, 167, 28, 27, 
	31, 28, 27, 169, 28, 27, 170, 28, 
	27, 171, 28, 27, 172, 28, 27, 34, 
	28, 27, 28, 174, 27, 28, 175, 27, 
	28, 176, 27, 28, 177, 27, 28, 178, 
	27, 28, 179, 27, 28, 180, 27, 28, 
	181, 27, 28, 182, 27, 28, 183, 27, 
	28, 184, 27, 28, 185, 27, 28, 186, 
	27, 28, 9, 27, 28, 34, 27, 190, 
	189, 190, 189, 191, 200, 223, 225, 231, 
	190, 190, 9, 236, 250, 9, 190, 189, 
	192, 196, 190, 189, 193, 190, 189, 194, 
	190, 189, 195, 190, 189, 34, 190, 189, 
	197, 190, 189, 198, 190, 189, 199, 190, 
	189, 34, 190, 189, 201, 205, 219, 190, 
	189, 202, 190, 189, 203, 190, 189, 204, 
	190, 189, 34, 190, 189, 206, 216, 190, 
	189, 207, 190, 189, 208, 190, 189, 209, 
	190, 189, 210, 190, 34, 189, 211, 190, 
	189, 212, 190, 189, 213, 190, 189, 214, 
	190, 189, 215, 190, 189, 190, 34, 189, 
	217, 190, 189, 218, 190, 189, 215, 190, 
	189, 220, 190, 189, 221, 190, 189, 222, 
	190, 189, 209, 190, 189, 224, 190, 189, 
	34, 190, 189, 226, 227, 190, 189, 193, 
	190, 189, 228, 190, 189, 229, 190, 189, 
	230, 190, 189, 215, 190, 189, 232, 190, 
	189, 233, 190, 189, 234, 190, 189, 235, 
	190, 189, 34, 190, 189, 190, 237, 189, 
	190, 238, 189, 190, 239, 189, 190, 240, 
	189, 190, 241, 189, 190, 242, 189, 190, 
	243, 189, 190, 244, 189, 190, 245, 189, 
	190, 246, 189, 190, 247, 189, 190, 248, 
	189, 190, 249, 189, 190, 9, 189, 190, 
	34, 189, 252, 0, 253, 0, 254, 0, 
	255, 0, 257, 256, 257, 256, 258, 264, 
	282, 257, 257, 9, 287, 9, 257, 256, 
	259, 257, 256, 260, 257, 256, 261, 257, 
	256, 262, 257, 256, 263, 257, 256, 257, 
	34, 256, 265, 278, 257, 256, 266, 275, 
	257, 256, 267, 257, 256, 268, 257, 256, 
	269, 257, 256, 270, 257, 34, 256, 271, 
	257, 256, 272, 257, 256, 273, 257, 256, 
	274, 257, 256, 263, 257, 256, 276, 257, 
	256, 277, 257, 256, 263, 257, 256, 279, 
	257, 256, 280, 257, 256, 281, 257, 256, 
	269, 257, 256, 283, 257, 256, 284, 257, 
	256, 285, 257, 256, 286, 257, 256, 263, 
	257, 256, 257, 288, 256, 257, 289, 256, 
	257, 290, 256, 257, 291, 256, 257, 292, 
	256, 257, 293, 256, 257, 294, 256, 257, 
	295, 256, 257, 296, 256, 257, 297, 256, 
	257, 298, 256, 257, 299, 256, 257, 300, 
	256, 257, 9, 256, 302, 0, 303, 0, 
	304, 0, 19, 0, 306, 0, 307, 0, 
	308, 0, 7, 0, 310, 0, 311, 0, 
	312, 0, 313, 0, 314, 0, 316, 315, 
	316, 315, 317, 316, 316, 9, 9, 316, 
	315, 318, 316, 315, 319, 316, 315, 320, 
	316, 315, 321, 316, 315, 322, 316, 315, 
	316, 34, 315, 324, 0, 9, 0, 0, 
	0
};

static const char _lexer_trans_actions[] = {
	25, 25, 25, 25, 25, 0, 47, 0, 
	5, 1, 0, 25, 1, 31, 0, 39, 
	0, 0, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 39, 50, 99, 19, 
	0, 25, 25, 25, 25, 25, 47, 0, 
	5, 1, 0, 25, 1, 31, 0, 39, 
	0, 0, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 124, 50, 47, 0, 
	77, 77, 77, 77, 77, 47, 0, 71, 
	29, 77, 71, 0, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 15, 47, 0, 56, 56, 56, 
	56, 56, 115, 27, 53, 50, 27, 56, 
	50, 59, 27, 39, 0, 39, 0, 39, 
	0, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 77, 77, 77, 77, 77, 
	47, 0, 65, 29, 77, 65, 0, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 11, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 11, 47, 0, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 11, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 11, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 47, 11, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	11, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 11, 47, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	11, 0, 47, 11, 0, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 47, 0, 0, 39, 119, 
	41, 41, 41, 3, 111, 29, 29, 29, 
	0, 111, 29, 29, 29, 0, 111, 29, 
	0, 29, 0, 95, 7, 7, 39, 47, 
	0, 0, 39, 103, 21, 0, 47, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 39, 39, 
	39, 39, 0, 23, 107, 23, 23, 44, 
	23, 0, 47, 0, 1, 0, 39, 0, 
	0, 0, 39, 47, 33, 33, 80, 33, 
	33, 39, 0, 35, 0, 39, 0, 0, 
	47, 0, 0, 35, 0, 0, 89, 89, 
	89, 89, 89, 47, 0, 86, 83, 37, 
	89, 83, 92, 0, 39, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 15, 47, 
	0, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 15, 
	47, 0, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	15, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 15, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 15, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 15, 0, 47, 15, 0, 124, 
	50, 47, 0, 77, 77, 77, 77, 77, 
	47, 0, 68, 29, 77, 68, 0, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 13, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 13, 47, 0, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 13, 47, 0, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 13, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 47, 13, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	13, 47, 0, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 13, 47, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 13, 0, 47, 
	13, 0, 0, 39, 0, 39, 0, 39, 
	0, 39, 124, 50, 47, 0, 77, 77, 
	77, 47, 0, 62, 29, 62, 0, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 47, 
	9, 0, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 9, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 9, 0, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 124, 50, 
	47, 0, 77, 47, 0, 74, 74, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	47, 17, 0, 0, 39, 0, 39, 0, 
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
	39, 39, 39, 39, 39, 39
};

static const int lexer_start = 1;
static const int lexer_first_final = 325;
static const int lexer_error = 0;

static const int lexer_en_main = 1;


#line 246 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"

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
    
    
#line 861 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
	{
	cs = lexer_start;
	}

#line 410 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
    
#line 868 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
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
#line 81 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
		MARK(content_start, p);
    lexer->current_line = lexer->line_number;
    lexer->start_col = lexer->content_start - lexer->last_newline - (lexer->keyword_end - lexer->keyword_start) + 2;
  }
	break;
	case 1:
#line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(content_start, p);
  }
	break;
	case 2:
#line 91 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    lexer->current_line = lexer->line_number;
    lexer->start_col = p - data - lexer->last_newline;
  }
	break;
	case 3:
#line 96 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    int len = LEN(content_start, PTR_TO(final_newline));

    if (len < 0) len = 0;

    store_pystring_content(listener, lexer->start_col, PTR_TO(content_start), len, lexer->current_line);
  }
	break;
	case 4:
#line 104 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(feature);
  }
	break;
	case 5:
#line 108 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(background);
  }
	break;
	case 6:
#line 112 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(scenario);
  }
	break;
	case 7:
#line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(scenario_outline);
  }
	break;
	case 8:
#line 120 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_KW_END_CON(examples);
  }
	break;
	case 9:
#line 124 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    store_kw_con(listener, "step",
      PTR_TO(keyword_start), LEN(keyword_start, PTR_TO(keyword_end)),
      PTR_TO(content_start), LEN(content_start, p), 
      lexer->current_line);
  }
	break;
	case 10:
#line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_ATTR(comment);
    lexer->mark = 0;
  }
	break;
	case 11:
#line 136 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    STORE_ATTR(tag);
    lexer->mark = 0;
  }
	break;
	case 12:
#line 141 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    lexer->line_number += 1;
    MARK(final_newline, p);
  }
	break;
	case 13:
#line 146 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(last_newline, p + 1);
  }
	break;
	case 14:
#line 150 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    if (lexer->mark == 0) {
      MARK(mark, p);
    }
  }
	break;
	case 15:
#line 156 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(keyword_end, p);
    MARK(keyword_start, PTR_TO(mark));
    MARK(content_start, p + 1);
    lexer->mark = 0;
  }
	break;
	case 16:
#line 163 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    MARK(content_end, p);
  }
	break;
	case 17:
#line 167 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    p = p - 1;
    lexer->current_line = lexer->line_number;
    current_row = rb_ary_new();
  }
	break;
	case 18:
#line 173 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
		MARK(content_start, p);
  }
	break;
	case 19:
#line 177 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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
#line 191 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
	{
    rb_funcall(listener, rb_intern("row"), 2, current_row, INT2FIX(lexer->current_line));
  }
	break;
	case 21:
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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
#line 1144 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
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
#line 195 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"
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
#line 1207 "ext/gherkin_lexer_zh_tw/gherkin_lexer_zh_tw.c"
		}
	}
	}

	_out: {}
	}

#line 411 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/zh_tw.c.rl"

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

void Init_gherkin_lexer_zh_tw()
{
  mGherkin = rb_define_module("Gherkin");
  mGherkinLexer = rb_define_module_under(mGherkin, "Lexer");
  rb_eGherkinLexingError = rb_const_get(mGherkinLexer, rb_intern("LexingError"));

  mCLexer = rb_define_module_under(mGherkin, "CLexer");
  cI18nLexer = rb_define_class_under(mCLexer, "Zh_tw", rb_cObject);
  rb_define_alloc_func(cI18nLexer, CLexer_alloc);
  rb_define_method(cI18nLexer, "initialize", CLexer_init, 1);
  rb_define_method(cI18nLexer, "scan", CLexer_scan, 1);
}


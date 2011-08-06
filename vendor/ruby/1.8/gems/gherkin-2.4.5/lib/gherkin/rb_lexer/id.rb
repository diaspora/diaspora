
# line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
require 'gherkin/lexer/i18n_lexer'

module Gherkin
  module RbLexer
    class Id #:nodoc:
      
# line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"

 
      def initialize(listener)
        @listener = listener
        
# line 16 "lib/gherkin/rb_lexer/id.rb"
class << self
	attr_accessor :_lexer_actions
	private :_lexer_actions, :_lexer_actions=
end
self._lexer_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 14, 1, 15, 1, 16, 1, 
	17, 1, 18, 1, 19, 1, 20, 1, 
	21, 2, 2, 16, 2, 11, 0, 2, 
	12, 13, 2, 15, 0, 2, 15, 1, 
	2, 15, 14, 2, 15, 17, 2, 16, 
	4, 2, 16, 5, 2, 16, 6, 2, 
	16, 7, 2, 16, 8, 2, 16, 14, 
	2, 18, 19, 2, 20, 0, 2, 20, 
	1, 2, 20, 14, 2, 20, 17, 3, 
	3, 12, 13, 3, 9, 12, 13, 3, 
	10, 12, 13, 3, 11, 12, 13, 3, 
	12, 13, 16, 3, 15, 12, 13, 4, 
	2, 12, 13, 16, 4, 15, 0, 12, 
	13
]

class << self
	attr_accessor :_lexer_key_offsets
	private :_lexer_key_offsets, :_lexer_key_offsets=
end
self._lexer_key_offsets = [
	0, 0, 18, 19, 20, 37, 38, 39, 
	43, 48, 53, 58, 63, 67, 71, 73, 
	74, 75, 76, 77, 78, 79, 80, 81, 
	82, 83, 84, 85, 86, 87, 88, 89, 
	90, 92, 97, 104, 109, 110, 111, 112, 
	113, 114, 115, 116, 117, 124, 126, 128, 
	130, 132, 134, 151, 153, 155, 156, 157, 
	158, 159, 160, 174, 176, 178, 180, 182, 
	184, 186, 188, 190, 192, 194, 196, 198, 
	200, 202, 204, 207, 209, 211, 213, 215, 
	217, 219, 221, 223, 225, 227, 229, 231, 
	233, 235, 237, 239, 241, 243, 245, 247, 
	249, 251, 254, 256, 258, 260, 262, 264, 
	266, 268, 270, 272, 273, 274, 275, 276, 
	277, 278, 279, 280, 281, 282, 283, 294, 
	296, 298, 300, 302, 304, 306, 308, 310, 
	312, 314, 316, 318, 320, 322, 324, 326, 
	328, 330, 332, 334, 336, 338, 340, 342, 
	344, 346, 348, 350, 352, 354, 356, 358, 
	360, 362, 365, 367, 369, 371, 373, 375, 
	377, 378, 379, 380, 381, 382, 383, 384, 
	385, 386, 387, 388, 389, 390, 392, 393, 
	394, 395, 396, 397, 398, 399, 400, 401, 
	415, 417, 419, 421, 423, 425, 427, 429, 
	431, 433, 435, 437, 439, 441, 443, 445, 
	448, 450, 452, 454, 456, 458, 460, 462, 
	464, 466, 468, 470, 472, 474, 476, 478, 
	480, 482, 484, 486, 488, 490, 492, 494, 
	496, 498, 499, 500, 514, 516, 518, 520, 
	522, 524, 526, 528, 530, 532, 534, 536, 
	538, 540, 542, 544, 547, 550, 552, 554, 
	556, 558, 560, 562, 564, 566, 568, 570, 
	572, 574, 576, 578, 580, 582, 584, 586, 
	588, 590, 592, 594, 596, 599, 601, 603, 
	605, 607, 609, 611, 613, 615, 617, 618, 
	619, 620, 624, 630, 633, 635, 641, 658
]

class << self
	attr_accessor :_lexer_trans_keys
	private :_lexer_trans_keys, :_lexer_trans_keys=
end
self._lexer_trans_keys = [
	-17, 10, 32, 34, 35, 37, 42, 64, 
	67, 68, 70, 75, 77, 83, 84, 124, 
	9, 13, -69, -65, 10, 32, 34, 35, 
	37, 42, 64, 67, 68, 70, 75, 77, 
	83, 84, 124, 9, 13, 34, 34, 10, 
	32, 9, 13, 10, 32, 34, 9, 13, 
	10, 32, 34, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 9, 13, 10, 32, 9, 13, 10, 
	13, 10, 95, 70, 69, 65, 84, 85, 
	82, 69, 95, 69, 78, 68, 95, 37, 
	32, 10, 10, 13, 13, 32, 64, 9, 
	10, 9, 10, 13, 32, 64, 11, 12, 
	10, 32, 64, 9, 13, 111, 110, 116, 
	111, 104, 58, 10, 10, 10, 32, 35, 
	70, 124, 9, 13, 10, 105, 10, 116, 
	10, 117, 10, 114, 10, 58, 10, 32, 
	34, 35, 37, 42, 64, 67, 68, 70, 
	75, 77, 83, 84, 124, 9, 13, 97, 
	101, 110, 115, 97, 114, 58, 10, 10, 
	10, 32, 35, 37, 42, 64, 68, 70, 
	75, 77, 83, 84, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 32, 10, 97, 101, 10, 
	110, 10, 110, 10, 103, 10, 97, 10, 
	105, 10, 116, 10, 117, 10, 114, 10, 
	58, 10, 101, 10, 116, 10, 105, 10, 
	107, 10, 97, 10, 97, 10, 107, 10, 
	101, 10, 110, 10, 97, 10, 114, 10, 
	105, 10, 111, 10, 32, 58, 10, 107, 
	10, 111, 10, 110, 10, 115, 10, 101, 
	10, 112, 10, 97, 10, 112, 10, 105, 
	110, 103, 97, 110, 105, 116, 117, 114, 
	58, 10, 10, 10, 32, 35, 37, 64, 
	67, 68, 70, 83, 9, 13, 10, 95, 
	10, 70, 10, 69, 10, 65, 10, 84, 
	10, 85, 10, 82, 10, 69, 10, 95, 
	10, 69, 10, 78, 10, 68, 10, 95, 
	10, 37, 10, 111, 10, 110, 10, 116, 
	10, 111, 10, 104, 10, 58, 10, 97, 
	10, 115, 10, 97, 10, 114, 10, 105, 
	10, 116, 10, 117, 10, 107, 10, 101, 
	10, 110, 10, 97, 10, 114, 10, 105, 
	10, 111, 10, 32, 58, 10, 107, 10, 
	111, 10, 110, 10, 115, 10, 101, 10, 
	112, 101, 116, 105, 107, 97, 97, 107, 
	101, 110, 97, 114, 105, 111, 32, 58, 
	107, 111, 110, 115, 101, 112, 58, 10, 
	10, 10, 32, 35, 37, 42, 64, 68, 
	70, 75, 77, 83, 84, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, 10, 97, 101, 
	10, 110, 10, 110, 10, 103, 10, 97, 
	10, 105, 10, 116, 10, 117, 10, 114, 
	10, 58, 10, 101, 10, 116, 10, 105, 
	10, 107, 10, 97, 10, 97, 10, 107, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 10, 97, 10, 112, 
	10, 105, 10, 10, 10, 32, 35, 37, 
	42, 64, 68, 70, 75, 77, 83, 84, 
	9, 13, 10, 95, 10, 70, 10, 69, 
	10, 65, 10, 84, 10, 85, 10, 82, 
	10, 69, 10, 95, 10, 69, 10, 78, 
	10, 68, 10, 95, 10, 37, 10, 32, 
	10, 97, 101, 10, 110, 115, 10, 97, 
	10, 114, 10, 58, 10, 110, 10, 103, 
	10, 97, 10, 110, 10, 105, 10, 116, 
	10, 117, 10, 101, 10, 116, 10, 105, 
	10, 107, 10, 97, 10, 97, 10, 107, 
	10, 101, 10, 110, 10, 97, 10, 114, 
	10, 105, 10, 111, 10, 32, 58, 10, 
	107, 10, 111, 10, 110, 10, 115, 10, 
	101, 10, 112, 10, 97, 10, 112, 10, 
	105, 97, 112, 105, 32, 124, 9, 13, 
	10, 32, 92, 124, 9, 13, 10, 92, 
	124, 10, 92, 10, 32, 92, 124, 9, 
	13, 10, 32, 34, 35, 37, 42, 64, 
	67, 68, 70, 75, 77, 83, 84, 124, 
	9, 13, 0
]

class << self
	attr_accessor :_lexer_single_lengths
	private :_lexer_single_lengths, :_lexer_single_lengths=
end
self._lexer_single_lengths = [
	0, 16, 1, 1, 15, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 1, 1, 1, 1, 
	1, 1, 1, 1, 5, 2, 2, 2, 
	2, 2, 15, 2, 2, 1, 1, 1, 
	1, 1, 12, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 3, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 9, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 3, 2, 2, 2, 2, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 12, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 3, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 1, 12, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 1, 1, 
	1, 2, 4, 3, 2, 4, 15, 0
]

class << self
	attr_accessor :_lexer_range_lengths
	private :_lexer_range_lengths, :_lexer_range_lengths=
end
self._lexer_range_lengths = [
	0, 1, 0, 0, 1, 0, 0, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 1, 
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
	0, 1, 1, 0, 0, 1, 1, 0
]

class << self
	attr_accessor :_lexer_index_offsets
	private :_lexer_index_offsets, :_lexer_index_offsets=
end
self._lexer_index_offsets = [
	0, 0, 18, 20, 22, 39, 41, 43, 
	47, 52, 57, 62, 67, 71, 75, 78, 
	80, 82, 84, 86, 88, 90, 92, 94, 
	96, 98, 100, 102, 104, 106, 108, 110, 
	112, 115, 120, 127, 132, 134, 136, 138, 
	140, 142, 144, 146, 148, 155, 158, 161, 
	164, 167, 170, 187, 190, 193, 195, 197, 
	199, 201, 203, 217, 220, 223, 226, 229, 
	232, 235, 238, 241, 244, 247, 250, 253, 
	256, 259, 262, 266, 269, 272, 275, 278, 
	281, 284, 287, 290, 293, 296, 299, 302, 
	305, 308, 311, 314, 317, 320, 323, 326, 
	329, 332, 336, 339, 342, 345, 348, 351, 
	354, 357, 360, 363, 365, 367, 369, 371, 
	373, 375, 377, 379, 381, 383, 385, 396, 
	399, 402, 405, 408, 411, 414, 417, 420, 
	423, 426, 429, 432, 435, 438, 441, 444, 
	447, 450, 453, 456, 459, 462, 465, 468, 
	471, 474, 477, 480, 483, 486, 489, 492, 
	495, 498, 502, 505, 508, 511, 514, 517, 
	520, 522, 524, 526, 528, 530, 532, 534, 
	536, 538, 540, 542, 544, 546, 549, 551, 
	553, 555, 557, 559, 561, 563, 565, 567, 
	581, 584, 587, 590, 593, 596, 599, 602, 
	605, 608, 611, 614, 617, 620, 623, 626, 
	630, 633, 636, 639, 642, 645, 648, 651, 
	654, 657, 660, 663, 666, 669, 672, 675, 
	678, 681, 684, 687, 690, 693, 696, 699, 
	702, 705, 707, 709, 723, 726, 729, 732, 
	735, 738, 741, 744, 747, 750, 753, 756, 
	759, 762, 765, 768, 772, 776, 779, 782, 
	785, 788, 791, 794, 797, 800, 803, 806, 
	809, 812, 815, 818, 821, 824, 827, 830, 
	833, 836, 839, 842, 845, 849, 852, 855, 
	858, 861, 864, 867, 870, 873, 876, 878, 
	880, 882, 886, 892, 896, 899, 905, 922
]

class << self
	attr_accessor :_lexer_trans_targs
	private :_lexer_trans_targs, :_lexer_trans_targs=
end
self._lexer_trans_targs = [
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 51, 111, 160, 165, 166, 278, 281, 
	4, 0, 3, 0, 4, 0, 4, 4, 
	5, 14, 16, 30, 33, 36, 51, 111, 
	160, 165, 166, 278, 281, 4, 0, 6, 
	0, 7, 0, 8, 7, 7, 0, 9, 
	9, 10, 9, 9, 9, 9, 10, 9, 
	9, 9, 9, 11, 9, 9, 9, 9, 
	12, 9, 9, 4, 13, 13, 0, 4, 
	13, 13, 0, 4, 15, 14, 4, 0, 
	17, 0, 18, 0, 19, 0, 20, 0, 
	21, 0, 22, 0, 23, 0, 24, 0, 
	25, 0, 26, 0, 27, 0, 28, 0, 
	29, 0, 287, 0, 31, 0, 0, 32, 
	4, 15, 32, 0, 0, 0, 0, 34, 
	35, 4, 35, 35, 33, 34, 34, 4, 
	35, 33, 35, 0, 37, 0, 38, 0, 
	39, 0, 40, 0, 41, 0, 42, 0, 
	44, 43, 44, 43, 44, 44, 4, 45, 
	4, 44, 43, 44, 46, 43, 44, 47, 
	43, 44, 48, 43, 44, 49, 43, 44, 
	50, 43, 4, 4, 5, 14, 16, 30, 
	33, 36, 51, 111, 160, 165, 166, 278, 
	281, 4, 0, 52, 107, 0, 30, 53, 
	0, 54, 0, 55, 0, 56, 0, 58, 
	57, 58, 57, 58, 58, 4, 59, 73, 
	4, 74, 79, 84, 89, 90, 104, 58, 
	57, 58, 60, 57, 58, 61, 57, 58, 
	62, 57, 58, 63, 57, 58, 64, 57, 
	58, 65, 57, 58, 66, 57, 58, 67, 
	57, 58, 68, 57, 58, 69, 57, 58, 
	70, 57, 58, 71, 57, 58, 72, 57, 
	58, 4, 57, 58, 50, 57, 58, 75, 
	76, 57, 58, 73, 57, 58, 77, 57, 
	58, 78, 57, 58, 75, 57, 58, 80, 
	57, 58, 81, 57, 58, 82, 57, 58, 
	83, 57, 58, 50, 57, 58, 85, 57, 
	58, 86, 57, 58, 87, 57, 58, 88, 
	57, 58, 73, 57, 58, 87, 57, 58, 
	91, 57, 58, 92, 57, 58, 93, 57, 
	58, 94, 57, 58, 95, 57, 58, 96, 
	57, 58, 97, 57, 58, 98, 50, 57, 
	58, 99, 57, 58, 100, 57, 58, 101, 
	57, 58, 102, 57, 58, 103, 57, 58, 
	83, 57, 58, 105, 57, 58, 106, 57, 
	58, 73, 57, 108, 0, 109, 0, 110, 
	0, 30, 0, 112, 0, 113, 0, 114, 
	0, 115, 0, 116, 0, 118, 117, 118, 
	117, 118, 118, 4, 119, 4, 133, 139, 
	143, 146, 118, 117, 118, 120, 117, 118, 
	121, 117, 118, 122, 117, 118, 123, 117, 
	118, 124, 117, 118, 125, 117, 118, 126, 
	117, 118, 127, 117, 118, 128, 117, 118, 
	129, 117, 118, 130, 117, 118, 131, 117, 
	118, 132, 117, 118, 4, 117, 118, 134, 
	117, 118, 135, 117, 118, 136, 117, 118, 
	137, 117, 118, 138, 117, 118, 50, 117, 
	118, 140, 117, 118, 141, 117, 118, 142, 
	117, 118, 138, 117, 118, 144, 117, 118, 
	145, 117, 118, 142, 117, 118, 147, 117, 
	118, 148, 117, 118, 149, 117, 118, 150, 
	117, 118, 151, 117, 118, 152, 117, 118, 
	153, 117, 118, 154, 50, 117, 118, 155, 
	117, 118, 156, 117, 118, 157, 117, 118, 
	158, 117, 118, 159, 117, 118, 138, 117, 
	161, 0, 162, 0, 163, 0, 164, 0, 
	30, 0, 163, 0, 167, 0, 168, 0, 
	169, 0, 170, 0, 171, 0, 172, 0, 
	173, 0, 174, 225, 0, 175, 0, 176, 
	0, 177, 0, 178, 0, 179, 0, 180, 
	0, 181, 0, 183, 182, 183, 182, 183, 
	183, 4, 184, 198, 4, 199, 204, 209, 
	214, 215, 222, 183, 182, 183, 185, 182, 
	183, 186, 182, 183, 187, 182, 183, 188, 
	182, 183, 189, 182, 183, 190, 182, 183, 
	191, 182, 183, 192, 182, 183, 193, 182, 
	183, 194, 182, 183, 195, 182, 183, 196, 
	182, 183, 197, 182, 183, 4, 182, 183, 
	50, 182, 183, 200, 201, 182, 183, 198, 
	182, 183, 202, 182, 183, 203, 182, 183, 
	200, 182, 183, 205, 182, 183, 206, 182, 
	183, 207, 182, 183, 208, 182, 183, 50, 
	182, 183, 210, 182, 183, 211, 182, 183, 
	212, 182, 183, 213, 182, 183, 198, 182, 
	183, 212, 182, 183, 216, 182, 183, 217, 
	182, 183, 218, 182, 183, 219, 182, 183, 
	220, 182, 183, 221, 182, 183, 208, 182, 
	183, 223, 182, 183, 224, 182, 183, 198, 
	182, 227, 226, 227, 226, 227, 227, 4, 
	228, 242, 4, 243, 252, 255, 260, 261, 
	275, 227, 226, 227, 229, 226, 227, 230, 
	226, 227, 231, 226, 227, 232, 226, 227, 
	233, 226, 227, 234, 226, 227, 235, 226, 
	227, 236, 226, 227, 237, 226, 227, 238, 
	226, 227, 239, 226, 227, 240, 226, 227, 
	241, 226, 227, 4, 226, 227, 50, 226, 
	227, 244, 248, 226, 227, 242, 245, 226, 
	227, 246, 226, 227, 247, 226, 227, 50, 
	226, 227, 249, 226, 227, 250, 226, 227, 
	251, 226, 227, 242, 226, 227, 253, 226, 
	227, 254, 226, 227, 246, 226, 227, 256, 
	226, 227, 257, 226, 227, 258, 226, 227, 
	259, 226, 227, 242, 226, 227, 258, 226, 
	227, 262, 226, 227, 263, 226, 227, 264, 
	226, 227, 265, 226, 227, 266, 226, 227, 
	267, 226, 227, 268, 226, 227, 269, 50, 
	226, 227, 270, 226, 227, 271, 226, 227, 
	272, 226, 227, 273, 226, 227, 274, 226, 
	227, 247, 226, 227, 276, 226, 227, 277, 
	226, 227, 242, 226, 279, 0, 280, 0, 
	30, 0, 281, 282, 281, 0, 286, 285, 
	284, 282, 285, 283, 0, 284, 282, 283, 
	0, 284, 283, 286, 285, 284, 282, 285, 
	283, 286, 286, 5, 14, 16, 30, 33, 
	36, 51, 111, 160, 165, 166, 278, 281, 
	286, 0, 0, 0
]

class << self
	attr_accessor :_lexer_trans_actions
	private :_lexer_trans_actions, :_lexer_trans_actions=
end
self._lexer_trans_actions = [
	0, 47, 0, 3, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 31, 
	0, 39, 0, 39, 0, 39, 47, 0, 
	3, 1, 0, 25, 1, 25, 25, 25, 
	25, 25, 25, 25, 31, 0, 39, 0, 
	39, 0, 39, 47, 0, 0, 39, 119, 
	41, 41, 41, 5, 111, 29, 29, 29, 
	0, 111, 29, 29, 29, 0, 111, 29, 
	0, 29, 0, 95, 7, 7, 39, 47, 
	0, 0, 39, 103, 21, 0, 47, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 39, 50, 
	99, 19, 0, 39, 39, 39, 39, 0, 
	23, 107, 23, 23, 44, 23, 0, 47, 
	0, 1, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	124, 50, 47, 0, 47, 0, 74, 77, 
	74, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	17, 0, 115, 27, 53, 50, 27, 56, 
	50, 56, 56, 56, 56, 56, 56, 56, 
	59, 27, 39, 0, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 47, 0, 65, 29, 77, 
	65, 77, 77, 77, 77, 77, 77, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 11, 0, 47, 11, 0, 47, 0, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 11, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 11, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 124, 50, 47, 
	0, 47, 0, 62, 29, 62, 77, 77, 
	77, 77, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 9, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 9, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 9, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 124, 50, 47, 0, 47, 
	0, 71, 29, 77, 71, 77, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 15, 0, 47, 
	15, 0, 47, 0, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 15, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 124, 50, 47, 0, 47, 0, 68, 
	29, 77, 68, 77, 77, 77, 77, 77, 
	77, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 13, 0, 47, 13, 0, 
	47, 0, 0, 0, 47, 0, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 13, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 13, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 0, 39, 0, 39, 
	0, 39, 0, 0, 0, 39, 47, 33, 
	33, 80, 33, 33, 39, 0, 35, 0, 
	39, 0, 0, 47, 0, 0, 35, 0, 
	0, 47, 0, 86, 83, 37, 89, 83, 
	89, 89, 89, 89, 89, 89, 89, 92, 
	0, 39, 0, 0
]

class << self
	attr_accessor :_lexer_eof_actions
	private :_lexer_eof_actions, :_lexer_eof_actions=
end
self._lexer_eof_actions = [
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
	39, 39, 39, 39, 39, 39, 39, 39
]

class << self
	attr_accessor :lexer_start
end
self.lexer_start = 1;
class << self
	attr_accessor :lexer_first_final
end
self.lexer_first_final = 287;
class << self
	attr_accessor :lexer_error
end
self.lexer_error = 0;

class << self
	attr_accessor :lexer_en_main
end
self.lexer_en_main = 1;


# line 121 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
      end
 
      def scan(data)
        data = (data + "\n%_FEATURE_END_%").unpack("c*") # Explicit EOF simplifies things considerably
        eof = pe = data.length
 
        @line_number = 1
        @last_newline = 0
 
        
# line 622 "lib/gherkin/rb_lexer/id.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = lexer_start
end

# line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
        
# line 631 "lib/gherkin/rb_lexer/id.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _lexer_key_offsets[cs]
	_trans = _lexer_index_offsets[cs]
	_klen = _lexer_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _lexer_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _lexer_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _lexer_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _lexer_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _lexer_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _lexer_trans_targs[_trans]
	if _lexer_trans_actions[_trans] != 0
		_acts = _lexer_trans_actions[_trans]
		_nacts = _lexer_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _lexer_actions[_acts - 1]
when 0 then
# line 9 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @content_start = p
          @current_line = @line_number
          @start_col = p - @last_newline - "#{@keyword}:".length
        		end
when 1 then
# line 15 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @current_line = @line_number
          @start_col = p - @last_newline
        		end
when 2 then
# line 20 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @content_start = p
        		end
when 3 then
# line 24 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          con = unindent(@start_col, utf8_pack(data[@content_start...@next_keyword_start-1]).sub(/(\r?\n)?([\t ])*\Z/, '').gsub(/\\"\\"\\"/, '"""'))
          @listener.doc_string(con, @current_line) 
        		end
when 4 then
# line 29 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          p = store_keyword_content(:feature, data, p, eof)
        		end
when 5 then
# line 33 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          p = store_keyword_content(:background, data, p, eof)
        		end
when 6 then
# line 37 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          p = store_keyword_content(:scenario, data, p, eof)
        		end
when 7 then
# line 41 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          p = store_keyword_content(:scenario_outline, data, p, eof)
        		end
when 8 then
# line 45 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          p = store_keyword_content(:examples, data, p, eof)
        		end
when 9 then
# line 49 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.step(@keyword, con, @current_line)
        		end
when 10 then
# line 54 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.comment(con, @line_number)
          @keyword_start = nil
        		end
when 11 then
# line 60 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.tag(con, @current_line)
          @keyword_start = nil
        		end
when 12 then
# line 66 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @line_number += 1
        		end
when 13 then
# line 70 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @last_newline = p + 1
        		end
when 14 then
# line 74 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @keyword_start ||= p
        		end
when 15 then
# line 78 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @keyword = utf8_pack(data[@keyword_start...p]).sub(/:$/,'')
          @keyword_start = nil
        		end
when 16 then
# line 83 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @next_keyword_start = p
        		end
when 17 then
# line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          p = p - 1
          current_row = []
          @current_line = @line_number
        		end
when 18 then
# line 93 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @content_start = p
        		end
when 19 then
# line 97 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          current_row << con.gsub(/\\\|/, "|").gsub(/\\n/, "\n").gsub(/\\\\/, "\\")
        		end
when 20 then
# line 102 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          @listener.row(current_row, @current_line)
        		end
when 21 then
# line 106 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          if cs < lexer_first_final
            content = current_line_content(data, p)
            raise Gherkin::Lexer::LexingError.new("Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information." % [@line_number, content])
          else
            @listener.eof
          end
        		end
# line 861 "lib/gherkin/rb_lexer/id.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	__acts = _lexer_eof_actions[cs]
	__nacts =  _lexer_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _lexer_actions[__acts - 1]
when 21 then
# line 106 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
		begin

          if cs < lexer_first_final
            content = current_line_content(data, p)
            raise Gherkin::Lexer::LexingError.new("Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information." % [@line_number, content])
          else
            @listener.eof
          end
        		end
# line 900 "lib/gherkin/rb_lexer/id.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 132 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/id.rb.rl"
      end

      def unindent(startcol, text)
        text.gsub(/^[\t ]{0,#{startcol}}/, "")
      end

      def store_keyword_content(event, data, p, eof)
        end_point = (!@next_keyword_start or (p == eof)) ? p : @next_keyword_start
        content = unindent(@start_col + 2, utf8_pack(data[@content_start...end_point])).rstrip
        content_lines = content.split("\n")
        name = content_lines.shift || ""
        name.strip!
        description = content_lines.join("\n")
        @listener.__send__(event, @keyword, name, description, @current_line)
        @next_keyword_start ? @next_keyword_start - 1 : p
      ensure
        @next_keyword_start = nil
      end
      
      def current_line_content(data, p)
        rest = data[@last_newline..-1]
        utf8_pack(rest[0..rest.index(10)||-1]).strip # 10 is \n
      end

      if (RUBY_VERSION =~ /^1\.9/)
        def utf8_pack(array)
          array.pack("c*").force_encoding("UTF-8")
        end
      else
        def utf8_pack(array)
          array.pack("c*")
        end
      end
    end
  end
end

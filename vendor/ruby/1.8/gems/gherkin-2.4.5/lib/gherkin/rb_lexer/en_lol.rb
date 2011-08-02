
# line 1 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
require 'gherkin/lexer/i18n_lexer'

module Gherkin
  module RbLexer
    class En_lol #:nodoc:
      
# line 116 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"

 
      def initialize(listener)
        @listener = listener
        
# line 16 "lib/gherkin/rb_lexer/en_lol.rb"
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
	0, 0, 19, 20, 21, 39, 40, 41, 
	45, 50, 55, 60, 65, 69, 73, 75, 
	76, 77, 78, 79, 80, 81, 82, 83, 
	84, 85, 86, 87, 88, 89, 90, 91, 
	92, 94, 99, 106, 111, 112, 114, 115, 
	116, 117, 132, 134, 136, 138, 140, 142, 
	144, 146, 148, 150, 152, 154, 156, 158, 
	160, 162, 180, 181, 182, 183, 184, 185, 
	186, 187, 188, 189, 190, 197, 199, 201, 
	203, 205, 207, 209, 210, 211, 212, 213, 
	214, 215, 216, 217, 218, 219, 220, 221, 
	222, 224, 225, 226, 227, 228, 229, 230, 
	231, 232, 247, 249, 251, 253, 255, 257, 
	259, 261, 263, 265, 267, 269, 271, 273, 
	275, 277, 279, 281, 283, 285, 287, 289, 
	291, 293, 295, 297, 299, 301, 303, 305, 
	307, 309, 311, 313, 315, 317, 319, 321, 
	323, 324, 325, 340, 342, 344, 346, 348, 
	350, 352, 354, 356, 358, 360, 362, 364, 
	366, 368, 370, 372, 375, 377, 379, 381, 
	383, 385, 387, 389, 391, 393, 395, 397, 
	399, 401, 403, 405, 407, 410, 412, 414, 
	416, 418, 420, 422, 424, 426, 428, 430, 
	431, 432, 433, 434, 435, 436, 437, 438, 
	449, 451, 453, 455, 457, 459, 461, 463, 
	465, 467, 469, 471, 473, 475, 477, 479, 
	481, 483, 485, 487, 489, 491, 493, 495, 
	497, 499, 501, 503, 506, 508, 510, 512, 
	514, 516, 518, 520, 522, 524, 526, 530, 
	536, 539, 541, 547, 565, 567, 569, 571, 
	573, 575, 577, 579, 581, 583, 585, 587, 
	589, 591, 593, 595, 597, 599, 602, 604, 
	606, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 625
]

class << self
	attr_accessor :_lexer_trans_keys
	private :_lexer_trans_keys, :_lexer_trans_keys=
end
self._lexer_trans_keys = [
	-17, 10, 32, 34, 35, 37, 42, 64, 
	65, 66, 68, 69, 73, 77, 79, 87, 
	124, 9, 13, -69, -65, 10, 32, 34, 
	35, 37, 42, 64, 65, 66, 68, 69, 
	73, 77, 79, 87, 124, 9, 13, 34, 
	34, 10, 32, 9, 13, 10, 32, 34, 
	9, 13, 10, 32, 34, 9, 13, 10, 
	32, 34, 9, 13, 10, 32, 34, 9, 
	13, 10, 32, 9, 13, 10, 32, 9, 
	13, 10, 13, 10, 95, 70, 69, 65, 
	84, 85, 82, 69, 95, 69, 78, 68, 
	95, 37, 32, 10, 10, 13, 13, 32, 
	64, 9, 10, 9, 10, 13, 32, 64, 
	11, 12, 10, 32, 64, 9, 13, 78, 
	52, 85, 58, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 66, 68, 73, 77, 
	79, 87, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 32, 34, 35, 37, 42, 
	64, 65, 66, 68, 69, 73, 77, 79, 
	87, 124, 9, 13, 69, 88, 65, 77, 
	80, 76, 90, 58, 10, 10, 10, 32, 
	35, 79, 124, 9, 13, 10, 72, 10, 
	32, 10, 72, 10, 65, 10, 73, 10, 
	58, 32, 67, 65, 78, 32, 72, 65, 
	90, 73, 83, 72, 85, 78, 32, 58, 
	83, 82, 83, 76, 89, 58, 10, 10, 
	10, 32, 35, 37, 42, 64, 65, 66, 
	68, 73, 77, 79, 87, 9, 13, 10, 
	95, 10, 70, 10, 69, 10, 65, 10, 
	84, 10, 85, 10, 82, 10, 69, 10, 
	95, 10, 69, 10, 78, 10, 68, 10, 
	95, 10, 37, 10, 32, 10, 78, 10, 
	85, 10, 84, 10, 69, 10, 32, 10, 
	67, 10, 65, 10, 78, 10, 32, 10, 
	72, 10, 65, 10, 90, 10, 73, 10, 
	83, 10, 72, 10, 85, 10, 78, 10, 
	58, 10, 72, 10, 32, 10, 72, 10, 
	65, 10, 73, 10, 10, 10, 32, 35, 
	37, 42, 64, 65, 66, 68, 73, 77, 
	79, 87, 9, 13, 10, 95, 10, 70, 
	10, 69, 10, 65, 10, 84, 10, 85, 
	10, 82, 10, 69, 10, 95, 10, 69, 
	10, 78, 10, 68, 10, 95, 10, 37, 
	10, 32, 10, 78, 10, 52, 85, 10, 
	58, 10, 84, 10, 69, 10, 32, 10, 
	67, 10, 65, 10, 78, 10, 32, 10, 
	72, 10, 65, 10, 90, 10, 73, 10, 
	83, 10, 72, 10, 85, 10, 78, 10, 
	32, 58, 10, 83, 10, 82, 10, 83, 
	10, 76, 10, 89, 10, 72, 10, 32, 
	10, 72, 10, 65, 10, 73, 72, 32, 
	72, 65, 73, 58, 10, 10, 10, 32, 
	35, 37, 64, 66, 69, 77, 79, 9, 
	13, 10, 95, 10, 70, 10, 69, 10, 
	65, 10, 84, 10, 85, 10, 82, 10, 
	69, 10, 95, 10, 69, 10, 78, 10, 
	68, 10, 95, 10, 37, 10, 52, 10, 
	58, 10, 88, 10, 65, 10, 77, 10, 
	80, 10, 76, 10, 90, 10, 73, 10, 
	83, 10, 72, 10, 85, 10, 78, 10, 
	32, 58, 10, 83, 10, 82, 10, 83, 
	10, 76, 10, 89, 10, 72, 10, 32, 
	10, 72, 10, 65, 10, 73, 32, 124, 
	9, 13, 10, 32, 92, 124, 9, 13, 
	10, 92, 124, 10, 92, 10, 32, 92, 
	124, 9, 13, 10, 32, 34, 35, 37, 
	42, 64, 65, 66, 68, 69, 73, 77, 
	79, 87, 124, 9, 13, 10, 78, 10, 
	85, 10, 84, 10, 69, 10, 32, 10, 
	67, 10, 65, 10, 78, 10, 32, 10, 
	72, 10, 65, 10, 90, 10, 73, 10, 
	83, 10, 72, 10, 85, 10, 78, 10, 
	32, 58, 10, 83, 10, 82, 10, 83, 
	10, 76, 10, 89, 10, 58, 10, 72, 
	10, 32, 10, 72, 10, 65, 10, 73, 
	84, 0
]

class << self
	attr_accessor :_lexer_single_lengths
	private :_lexer_single_lengths, :_lexer_single_lengths=
end
self._lexer_single_lengths = [
	0, 17, 1, 1, 16, 1, 1, 2, 
	3, 3, 3, 3, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 3, 5, 3, 1, 2, 1, 1, 
	1, 13, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 16, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 5, 2, 2, 2, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 13, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	1, 1, 13, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 3, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 1, 
	1, 1, 1, 1, 1, 1, 1, 9, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 3, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 4, 
	3, 2, 4, 16, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 2, 2, 2, 2, 3, 2, 2, 
	2, 2, 2, 2, 2, 2, 2, 2, 
	2, 1, 0
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
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
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
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0
]

class << self
	attr_accessor :_lexer_index_offsets
	private :_lexer_index_offsets, :_lexer_index_offsets=
end
self._lexer_index_offsets = [
	0, 0, 19, 21, 23, 41, 43, 45, 
	49, 54, 59, 64, 69, 73, 77, 80, 
	82, 84, 86, 88, 90, 92, 94, 96, 
	98, 100, 102, 104, 106, 108, 110, 112, 
	114, 117, 122, 129, 134, 136, 139, 141, 
	143, 145, 160, 163, 166, 169, 172, 175, 
	178, 181, 184, 187, 190, 193, 196, 199, 
	202, 205, 223, 225, 227, 229, 231, 233, 
	235, 237, 239, 241, 243, 250, 253, 256, 
	259, 262, 265, 268, 270, 272, 274, 276, 
	278, 280, 282, 284, 286, 288, 290, 292, 
	294, 297, 299, 301, 303, 305, 307, 309, 
	311, 313, 328, 331, 334, 337, 340, 343, 
	346, 349, 352, 355, 358, 361, 364, 367, 
	370, 373, 376, 379, 382, 385, 388, 391, 
	394, 397, 400, 403, 406, 409, 412, 415, 
	418, 421, 424, 427, 430, 433, 436, 439, 
	442, 444, 446, 461, 464, 467, 470, 473, 
	476, 479, 482, 485, 488, 491, 494, 497, 
	500, 503, 506, 509, 513, 516, 519, 522, 
	525, 528, 531, 534, 537, 540, 543, 546, 
	549, 552, 555, 558, 561, 565, 568, 571, 
	574, 577, 580, 583, 586, 589, 592, 595, 
	597, 599, 601, 603, 605, 607, 609, 611, 
	622, 625, 628, 631, 634, 637, 640, 643, 
	646, 649, 652, 655, 658, 661, 664, 667, 
	670, 673, 676, 679, 682, 685, 688, 691, 
	694, 697, 700, 703, 707, 710, 713, 716, 
	719, 722, 725, 728, 731, 734, 737, 741, 
	747, 751, 754, 760, 778, 781, 784, 787, 
	790, 793, 796, 799, 802, 805, 808, 811, 
	814, 817, 820, 823, 826, 829, 833, 836, 
	839, 842, 845, 848, 851, 854, 857, 860, 
	863, 866, 868
]

class << self
	attr_accessor :_lexer_trans_targs
	private :_lexer_trans_targs, :_lexer_trans_targs=
end
self._lexer_trans_targs = [
	2, 4, 4, 5, 14, 16, 30, 33, 
	36, 37, 58, 59, 75, 83, 183, 58, 
	230, 4, 0, 3, 0, 4, 0, 4, 
	4, 5, 14, 16, 30, 33, 36, 37, 
	58, 59, 75, 83, 183, 58, 230, 4, 
	0, 6, 0, 7, 0, 8, 7, 7, 
	0, 9, 9, 10, 9, 9, 9, 9, 
	10, 9, 9, 9, 9, 11, 9, 9, 
	9, 9, 12, 9, 9, 4, 13, 13, 
	0, 4, 13, 13, 0, 4, 15, 14, 
	4, 0, 17, 0, 18, 0, 19, 0, 
	20, 0, 21, 0, 22, 0, 23, 0, 
	24, 0, 25, 0, 26, 0, 27, 0, 
	28, 0, 29, 0, 266, 0, 31, 0, 
	0, 32, 4, 15, 32, 0, 0, 0, 
	0, 34, 35, 4, 35, 35, 33, 34, 
	34, 4, 35, 33, 35, 0, 30, 0, 
	38, 265, 0, 39, 0, 41, 40, 41, 
	40, 41, 41, 4, 42, 56, 4, 236, 
	237, 239, 240, 248, 260, 239, 41, 40, 
	41, 43, 40, 41, 44, 40, 41, 45, 
	40, 41, 46, 40, 41, 47, 40, 41, 
	48, 40, 41, 49, 40, 41, 50, 40, 
	41, 51, 40, 41, 52, 40, 41, 53, 
	40, 41, 54, 40, 41, 55, 40, 41, 
	4, 40, 41, 57, 40, 4, 4, 5, 
	14, 16, 30, 33, 36, 37, 58, 59, 
	75, 83, 183, 58, 230, 4, 0, 36, 
	0, 60, 0, 61, 0, 62, 0, 63, 
	0, 64, 0, 65, 0, 66, 0, 68, 
	67, 68, 67, 68, 68, 4, 69, 4, 
	68, 67, 68, 70, 67, 68, 71, 67, 
	68, 72, 67, 68, 73, 67, 68, 74, 
	67, 68, 57, 67, 76, 0, 77, 0, 
	78, 0, 79, 0, 80, 0, 81, 0, 
	82, 0, 30, 0, 84, 0, 85, 0, 
	86, 0, 87, 0, 88, 0, 89, 136, 
	0, 90, 0, 91, 0, 92, 0, 93, 
	0, 94, 0, 95, 0, 97, 96, 97, 
	96, 97, 97, 4, 98, 112, 4, 113, 
	114, 116, 117, 125, 131, 116, 97, 96, 
	97, 99, 96, 97, 100, 96, 97, 101, 
	96, 97, 102, 96, 97, 103, 96, 97, 
	104, 96, 97, 105, 96, 97, 106, 96, 
	97, 107, 96, 97, 108, 96, 97, 109, 
	96, 97, 110, 96, 97, 111, 96, 97, 
	4, 96, 97, 57, 96, 97, 112, 96, 
	97, 115, 96, 97, 112, 96, 97, 113, 
	96, 97, 118, 96, 97, 119, 96, 97, 
	120, 96, 97, 121, 96, 97, 122, 96, 
	97, 123, 96, 97, 124, 96, 97, 112, 
	96, 97, 126, 96, 97, 127, 96, 97, 
	128, 96, 97, 129, 96, 97, 130, 96, 
	97, 57, 96, 97, 132, 96, 97, 133, 
	96, 97, 134, 96, 97, 135, 96, 97, 
	130, 96, 138, 137, 138, 137, 138, 138, 
	4, 139, 153, 4, 154, 155, 158, 159, 
	167, 178, 158, 138, 137, 138, 140, 137, 
	138, 141, 137, 138, 142, 137, 138, 143, 
	137, 138, 144, 137, 138, 145, 137, 138, 
	146, 137, 138, 147, 137, 138, 148, 137, 
	138, 149, 137, 138, 150, 137, 138, 151, 
	137, 138, 152, 137, 138, 4, 137, 138, 
	57, 137, 138, 153, 137, 138, 156, 157, 
	137, 138, 57, 137, 138, 153, 137, 138, 
	154, 137, 138, 160, 137, 138, 161, 137, 
	138, 162, 137, 138, 163, 137, 138, 164, 
	137, 138, 165, 137, 138, 166, 137, 138, 
	153, 137, 138, 168, 137, 138, 169, 137, 
	138, 170, 137, 138, 171, 137, 138, 172, 
	137, 138, 173, 57, 137, 138, 174, 137, 
	138, 175, 137, 138, 176, 137, 138, 177, 
	137, 138, 156, 137, 138, 179, 137, 138, 
	180, 137, 138, 181, 137, 138, 182, 137, 
	138, 156, 137, 184, 0, 185, 0, 186, 
	0, 187, 0, 188, 0, 189, 0, 191, 
	190, 191, 190, 191, 191, 4, 192, 4, 
	206, 208, 214, 225, 191, 190, 191, 193, 
	190, 191, 194, 190, 191, 195, 190, 191, 
	196, 190, 191, 197, 190, 191, 198, 190, 
	191, 199, 190, 191, 200, 190, 191, 201, 
	190, 191, 202, 190, 191, 203, 190, 191, 
	204, 190, 191, 205, 190, 191, 4, 190, 
	191, 207, 190, 191, 57, 190, 191, 209, 
	190, 191, 210, 190, 191, 211, 190, 191, 
	212, 190, 191, 213, 190, 191, 207, 190, 
	191, 215, 190, 191, 216, 190, 191, 217, 
	190, 191, 218, 190, 191, 219, 190, 191, 
	220, 57, 190, 191, 221, 190, 191, 222, 
	190, 191, 223, 190, 191, 224, 190, 191, 
	207, 190, 191, 226, 190, 191, 227, 190, 
	191, 228, 190, 191, 229, 190, 191, 207, 
	190, 230, 231, 230, 0, 235, 234, 233, 
	231, 234, 232, 0, 233, 231, 232, 0, 
	233, 232, 235, 234, 233, 231, 234, 232, 
	235, 235, 5, 14, 16, 30, 33, 36, 
	37, 58, 59, 75, 83, 183, 58, 230, 
	235, 0, 41, 56, 40, 41, 238, 40, 
	41, 56, 40, 41, 236, 40, 41, 241, 
	40, 41, 242, 40, 41, 243, 40, 41, 
	244, 40, 41, 245, 40, 41, 246, 40, 
	41, 247, 40, 41, 56, 40, 41, 249, 
	40, 41, 250, 40, 41, 251, 40, 41, 
	252, 40, 41, 253, 40, 41, 254, 57, 
	40, 41, 255, 40, 41, 256, 40, 41, 
	257, 40, 41, 258, 40, 41, 259, 40, 
	41, 57, 40, 41, 261, 40, 41, 262, 
	40, 41, 263, 40, 41, 264, 40, 41, 
	259, 40, 30, 0, 0, 0
]

class << self
	attr_accessor :_lexer_trans_actions
	private :_lexer_trans_actions, :_lexer_trans_actions=
end
self._lexer_trans_actions = [
	0, 47, 0, 3, 1, 0, 25, 1, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	31, 0, 39, 0, 39, 0, 39, 47, 
	0, 3, 1, 0, 25, 1, 25, 25, 
	25, 25, 25, 25, 25, 25, 31, 0, 
	39, 0, 39, 0, 39, 47, 0, 0, 
	39, 119, 41, 41, 41, 5, 111, 29, 
	29, 29, 0, 111, 29, 29, 29, 0, 
	111, 29, 0, 29, 0, 95, 7, 7, 
	39, 47, 0, 0, 39, 103, 21, 0, 
	47, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	39, 50, 99, 19, 0, 39, 39, 39, 
	39, 0, 23, 107, 23, 23, 44, 23, 
	0, 47, 0, 1, 0, 39, 0, 39, 
	0, 0, 39, 0, 39, 124, 50, 47, 
	0, 47, 0, 65, 29, 77, 65, 77, 
	77, 77, 77, 77, 77, 77, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	11, 0, 47, 11, 0, 115, 27, 53, 
	50, 27, 56, 50, 56, 56, 56, 56, 
	56, 56, 56, 56, 59, 27, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 47, 0, 74, 77, 74, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 17, 0, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 39, 
	0, 39, 0, 39, 0, 39, 0, 0, 
	39, 0, 39, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 124, 50, 47, 
	0, 47, 0, 71, 29, 77, 71, 77, 
	77, 77, 77, 77, 77, 77, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	15, 0, 47, 15, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 15, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 124, 50, 47, 0, 47, 0, 
	68, 29, 77, 68, 77, 77, 77, 77, 
	77, 77, 77, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 13, 0, 47, 
	13, 0, 47, 0, 0, 47, 0, 0, 
	0, 47, 13, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 13, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 0, 39, 0, 39, 0, 
	39, 0, 39, 0, 39, 0, 39, 124, 
	50, 47, 0, 47, 0, 62, 29, 62, 
	77, 77, 77, 77, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 9, 0, 
	47, 0, 0, 47, 9, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 9, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 0, 0, 0, 39, 47, 33, 33, 
	80, 33, 33, 39, 0, 35, 0, 39, 
	0, 0, 47, 0, 0, 35, 0, 0, 
	47, 0, 86, 83, 37, 89, 83, 89, 
	89, 89, 89, 89, 89, 89, 89, 92, 
	0, 39, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 0, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 11, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 47, 0, 0, 47, 0, 0, 
	47, 11, 0, 47, 0, 0, 47, 0, 
	0, 47, 0, 0, 47, 0, 0, 47, 
	0, 0, 0, 39, 0, 0
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
	39, 39, 39
]

class << self
	attr_accessor :lexer_start
end
self.lexer_start = 1;
class << self
	attr_accessor :lexer_first_final
end
self.lexer_first_final = 266;
class << self
	attr_accessor :lexer_error
end
self.lexer_error = 0;

class << self
	attr_accessor :lexer_en_main
end
self.lexer_en_main = 1;


# line 121 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
      end
 
      def scan(data)
        data = (data + "\n%_FEATURE_END_%").unpack("c*") # Explicit EOF simplifies things considerably
        eof = pe = data.length
 
        @line_number = 1
        @last_newline = 0
 
        
# line 594 "lib/gherkin/rb_lexer/en_lol.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = lexer_start
end

# line 131 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
        
# line 603 "lib/gherkin/rb_lexer/en_lol.rb"
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
# line 9 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @content_start = p
          @current_line = @line_number
          @start_col = p - @last_newline - "#{@keyword}:".length
        		end
when 1 then
# line 15 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @current_line = @line_number
          @start_col = p - @last_newline
        		end
when 2 then
# line 20 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @content_start = p
        		end
when 3 then
# line 24 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          con = unindent(@start_col, utf8_pack(data[@content_start...@next_keyword_start-1]).sub(/(\r?\n)?([\t ])*\Z/, '').gsub(/\\"\\"\\"/, '"""'))
          @listener.doc_string(con, @current_line) 
        		end
when 4 then
# line 29 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          p = store_keyword_content(:feature, data, p, eof)
        		end
when 5 then
# line 33 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          p = store_keyword_content(:background, data, p, eof)
        		end
when 6 then
# line 37 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          p = store_keyword_content(:scenario, data, p, eof)
        		end
when 7 then
# line 41 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          p = store_keyword_content(:scenario_outline, data, p, eof)
        		end
when 8 then
# line 45 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          p = store_keyword_content(:examples, data, p, eof)
        		end
when 9 then
# line 49 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.step(@keyword, con, @current_line)
        		end
when 10 then
# line 54 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.comment(con, @line_number)
          @keyword_start = nil
        		end
when 11 then
# line 60 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          @listener.tag(con, @current_line)
          @keyword_start = nil
        		end
when 12 then
# line 66 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @line_number += 1
        		end
when 13 then
# line 70 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @last_newline = p + 1
        		end
when 14 then
# line 74 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @keyword_start ||= p
        		end
when 15 then
# line 78 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @keyword = utf8_pack(data[@keyword_start...p]).sub(/:$/,'')
          @keyword_start = nil
        		end
when 16 then
# line 83 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @next_keyword_start = p
        		end
when 17 then
# line 87 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          p = p - 1
          current_row = []
          @current_line = @line_number
        		end
when 18 then
# line 93 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @content_start = p
        		end
when 19 then
# line 97 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          con = utf8_pack(data[@content_start...p]).strip
          current_row << con.gsub(/\\\|/, "|").gsub(/\\n/, "\n").gsub(/\\\\/, "\\")
        		end
when 20 then
# line 102 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          @listener.row(current_row, @current_line)
        		end
when 21 then
# line 106 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          if cs < lexer_first_final
            content = current_line_content(data, p)
            raise Gherkin::Lexer::LexingError.new("Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information." % [@line_number, content])
          else
            @listener.eof
          end
        		end
# line 833 "lib/gherkin/rb_lexer/en_lol.rb"
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
# line 106 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
		begin

          if cs < lexer_first_final
            content = current_line_content(data, p)
            raise Gherkin::Lexer::LexingError.new("Lexing error on line %d: '%s'. See http://wiki.github.com/cucumber/gherkin/lexingerror for more information." % [@line_number, content])
          else
            @listener.eof
          end
        		end
# line 872 "lib/gherkin/rb_lexer/en_lol.rb"
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

# line 132 "/Users/ahellesoy/scm/gherkin/tasks/../ragel/i18n/en_lol.rb.rl"
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

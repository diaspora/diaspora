// line 1 "http11_parser.java.rl"
package org.jruby.mongrel;

import org.jruby.util.ByteList;

public class Http11Parser {

/** Machine **/

// line 64 "http11_parser.java.rl"


/** Data **/

// line 16 "../../ext/http11_java/org/jruby/mongrel/Http11Parser.java"
private static void init__http_parser_actions_0( byte[] r )
{
	r[0]=0; r[1]=1; r[2]=0; r[3]=1; r[4]=1; r[5]=1; r[6]=2; r[7]=1; 
	r[8]=3; r[9]=1; r[10]=4; r[11]=1; r[12]=5; r[13]=1; r[14]=6; r[15]=1; 
	r[16]=7; r[17]=1; r[18]=8; r[19]=1; r[20]=10; r[21]=1; r[22]=11; r[23]=1; 
	r[24]=12; r[25]=2; r[26]=9; r[27]=6; r[28]=2; r[29]=11; r[30]=6; r[31]=3; 
	r[32]=8; r[33]=9; r[34]=6; 
}

private static byte[] create__http_parser_actions( )
{
	byte[] r = new byte[35];
	init__http_parser_actions_0( r );
	return r;
}

private static final byte _http_parser_actions[] = create__http_parser_actions();


private static void init__http_parser_key_offsets_0( short[] r )
{
	r[0]=0; r[1]=0; r[2]=8; r[3]=17; r[4]=27; r[5]=29; r[6]=30; r[7]=31; 
	r[8]=32; r[9]=33; r[10]=34; r[11]=36; r[12]=39; r[13]=41; r[14]=44; r[15]=45; 
	r[16]=61; r[17]=62; r[18]=78; r[19]=80; r[20]=81; r[21]=90; r[22]=99; r[23]=105; 
	r[24]=111; r[25]=121; r[26]=130; r[27]=136; r[28]=142; r[29]=153; r[30]=159; r[31]=165; 
	r[32]=175; r[33]=181; r[34]=187; r[35]=196; r[36]=205; r[37]=211; r[38]=217; r[39]=226; 
	r[40]=235; r[41]=244; r[42]=253; r[43]=262; r[44]=271; r[45]=280; r[46]=289; r[47]=298; 
	r[48]=307; r[49]=316; r[50]=325; r[51]=334; r[52]=343; r[53]=352; r[54]=361; r[55]=370; 
	r[56]=379; r[57]=380; 
}

private static short[] create__http_parser_key_offsets( )
{
	short[] r = new short[58];
	init__http_parser_key_offsets_0( r );
	return r;
}

private static final short _http_parser_key_offsets[] = create__http_parser_key_offsets();


private static void init__http_parser_trans_keys_0( char[] r )
{
	r[0]=36; r[1]=95; r[2]=45; r[3]=46; r[4]=48; r[5]=57; r[6]=65; r[7]=90; 
	r[8]=32; r[9]=36; r[10]=95; r[11]=45; r[12]=46; r[13]=48; r[14]=57; r[15]=65; 
	r[16]=90; r[17]=42; r[18]=43; r[19]=47; r[20]=58; r[21]=45; r[22]=57; r[23]=65; 
	r[24]=90; r[25]=97; r[26]=122; r[27]=32; r[28]=35; r[29]=72; r[30]=84; r[31]=84; 
	r[32]=80; r[33]=47; r[34]=48; r[35]=57; r[36]=46; r[37]=48; r[38]=57; r[39]=48; 
	r[40]=57; r[41]=13; r[42]=48; r[43]=57; r[44]=10; r[45]=13; r[46]=33; r[47]=124; 
	r[48]=126; r[49]=35; r[50]=39; r[51]=42; r[52]=43; r[53]=45; r[54]=46; r[55]=48; 
	r[56]=57; r[57]=65; r[58]=90; r[59]=94; r[60]=122; r[61]=10; r[62]=33; r[63]=58; 
	r[64]=124; r[65]=126; r[66]=35; r[67]=39; r[68]=42; r[69]=43; r[70]=45; r[71]=46; 
	r[72]=48; r[73]=57; r[74]=65; r[75]=90; r[76]=94; r[77]=122; r[78]=13; r[79]=32; 
	r[80]=13; r[81]=32; r[82]=37; r[83]=60; r[84]=62; r[85]=127; r[86]=0; r[87]=31; 
	r[88]=34; r[89]=35; r[90]=32; r[91]=37; r[92]=60; r[93]=62; r[94]=127; r[95]=0; 
	r[96]=31; r[97]=34; r[98]=35; r[99]=48; r[100]=57; r[101]=65; r[102]=70; r[103]=97; 
	r[104]=102; r[105]=48; r[106]=57; r[107]=65; r[108]=70; r[109]=97; r[110]=102; r[111]=43; 
	r[112]=58; r[113]=45; r[114]=46; r[115]=48; r[116]=57; r[117]=65; r[118]=90; r[119]=97; 
	r[120]=122; r[121]=32; r[122]=34; r[123]=35; r[124]=37; r[125]=60; r[126]=62; r[127]=127; 
	r[128]=0; r[129]=31; r[130]=48; r[131]=57; r[132]=65; r[133]=70; r[134]=97; r[135]=102; 
	r[136]=48; r[137]=57; r[138]=65; r[139]=70; r[140]=97; r[141]=102; r[142]=32; r[143]=34; 
	r[144]=35; r[145]=37; r[146]=59; r[147]=60; r[148]=62; r[149]=63; r[150]=127; r[151]=0; 
	r[152]=31; r[153]=48; r[154]=57; r[155]=65; r[156]=70; r[157]=97; r[158]=102; r[159]=48; 
	r[160]=57; r[161]=65; r[162]=70; r[163]=97; r[164]=102; r[165]=32; r[166]=34; r[167]=35; 
	r[168]=37; r[169]=60; r[170]=62; r[171]=63; r[172]=127; r[173]=0; r[174]=31; r[175]=48; 
	r[176]=57; r[177]=65; r[178]=70; r[179]=97; r[180]=102; r[181]=48; r[182]=57; r[183]=65; 
	r[184]=70; r[185]=97; r[186]=102; r[187]=32; r[188]=34; r[189]=35; r[190]=37; r[191]=60; 
	r[192]=62; r[193]=127; r[194]=0; r[195]=31; r[196]=32; r[197]=34; r[198]=35; r[199]=37; 
	r[200]=60; r[201]=62; r[202]=127; r[203]=0; r[204]=31; r[205]=48; r[206]=57; r[207]=65; 
	r[208]=70; r[209]=97; r[210]=102; r[211]=48; r[212]=57; r[213]=65; r[214]=70; r[215]=97; 
	r[216]=102; r[217]=32; r[218]=36; r[219]=95; r[220]=45; r[221]=46; r[222]=48; r[223]=57; 
	r[224]=65; r[225]=90; r[226]=32; r[227]=36; r[228]=95; r[229]=45; r[230]=46; r[231]=48; 
	r[232]=57; r[233]=65; r[234]=90; r[235]=32; r[236]=36; r[237]=95; r[238]=45; r[239]=46; 
	r[240]=48; r[241]=57; r[242]=65; r[243]=90; r[244]=32; r[245]=36; r[246]=95; r[247]=45; 
	r[248]=46; r[249]=48; r[250]=57; r[251]=65; r[252]=90; r[253]=32; r[254]=36; r[255]=95; 
	r[256]=45; r[257]=46; r[258]=48; r[259]=57; r[260]=65; r[261]=90; r[262]=32; r[263]=36; 
	r[264]=95; r[265]=45; r[266]=46; r[267]=48; r[268]=57; r[269]=65; r[270]=90; r[271]=32; 
	r[272]=36; r[273]=95; r[274]=45; r[275]=46; r[276]=48; r[277]=57; r[278]=65; r[279]=90; 
	r[280]=32; r[281]=36; r[282]=95; r[283]=45; r[284]=46; r[285]=48; r[286]=57; r[287]=65; 
	r[288]=90; r[289]=32; r[290]=36; r[291]=95; r[292]=45; r[293]=46; r[294]=48; r[295]=57; 
	r[296]=65; r[297]=90; r[298]=32; r[299]=36; r[300]=95; r[301]=45; r[302]=46; r[303]=48; 
	r[304]=57; r[305]=65; r[306]=90; r[307]=32; r[308]=36; r[309]=95; r[310]=45; r[311]=46; 
	r[312]=48; r[313]=57; r[314]=65; r[315]=90; r[316]=32; r[317]=36; r[318]=95; r[319]=45; 
	r[320]=46; r[321]=48; r[322]=57; r[323]=65; r[324]=90; r[325]=32; r[326]=36; r[327]=95; 
	r[328]=45; r[329]=46; r[330]=48; r[331]=57; r[332]=65; r[333]=90; r[334]=32; r[335]=36; 
	r[336]=95; r[337]=45; r[338]=46; r[339]=48; r[340]=57; r[341]=65; r[342]=90; r[343]=32; 
	r[344]=36; r[345]=95; r[346]=45; r[347]=46; r[348]=48; r[349]=57; r[350]=65; r[351]=90; 
	r[352]=32; r[353]=36; r[354]=95; r[355]=45; r[356]=46; r[357]=48; r[358]=57; r[359]=65; 
	r[360]=90; r[361]=32; r[362]=36; r[363]=95; r[364]=45; r[365]=46; r[366]=48; r[367]=57; 
	r[368]=65; r[369]=90; r[370]=32; r[371]=36; r[372]=95; r[373]=45; r[374]=46; r[375]=48; 
	r[376]=57; r[377]=65; r[378]=90; r[379]=32; r[380]=0; 
}

private static char[] create__http_parser_trans_keys( )
{
	char[] r = new char[381];
	init__http_parser_trans_keys_0( r );
	return r;
}

private static final char _http_parser_trans_keys[] = create__http_parser_trans_keys();


private static void init__http_parser_single_lengths_0( byte[] r )
{
	r[0]=0; r[1]=2; r[2]=3; r[3]=4; r[4]=2; r[5]=1; r[6]=1; r[7]=1; 
	r[8]=1; r[9]=1; r[10]=0; r[11]=1; r[12]=0; r[13]=1; r[14]=1; r[15]=4; 
	r[16]=1; r[17]=4; r[18]=2; r[19]=1; r[20]=5; r[21]=5; r[22]=0; r[23]=0; 
	r[24]=2; r[25]=7; r[26]=0; r[27]=0; r[28]=9; r[29]=0; r[30]=0; r[31]=8; 
	r[32]=0; r[33]=0; r[34]=7; r[35]=7; r[36]=0; r[37]=0; r[38]=3; r[39]=3; 
	r[40]=3; r[41]=3; r[42]=3; r[43]=3; r[44]=3; r[45]=3; r[46]=3; r[47]=3; 
	r[48]=3; r[49]=3; r[50]=3; r[51]=3; r[52]=3; r[53]=3; r[54]=3; r[55]=3; 
	r[56]=1; r[57]=0; 
}

private static byte[] create__http_parser_single_lengths( )
{
	byte[] r = new byte[58];
	init__http_parser_single_lengths_0( r );
	return r;
}

private static final byte _http_parser_single_lengths[] = create__http_parser_single_lengths();


private static void init__http_parser_range_lengths_0( byte[] r )
{
	r[0]=0; r[1]=3; r[2]=3; r[3]=3; r[4]=0; r[5]=0; r[6]=0; r[7]=0; 
	r[8]=0; r[9]=0; r[10]=1; r[11]=1; r[12]=1; r[13]=1; r[14]=0; r[15]=6; 
	r[16]=0; r[17]=6; r[18]=0; r[19]=0; r[20]=2; r[21]=2; r[22]=3; r[23]=3; 
	r[24]=4; r[25]=1; r[26]=3; r[27]=3; r[28]=1; r[29]=3; r[30]=3; r[31]=1; 
	r[32]=3; r[33]=3; r[34]=1; r[35]=1; r[36]=3; r[37]=3; r[38]=3; r[39]=3; 
	r[40]=3; r[41]=3; r[42]=3; r[43]=3; r[44]=3; r[45]=3; r[46]=3; r[47]=3; 
	r[48]=3; r[49]=3; r[50]=3; r[51]=3; r[52]=3; r[53]=3; r[54]=3; r[55]=3; 
	r[56]=0; r[57]=0; 
}

private static byte[] create__http_parser_range_lengths( )
{
	byte[] r = new byte[58];
	init__http_parser_range_lengths_0( r );
	return r;
}

private static final byte _http_parser_range_lengths[] = create__http_parser_range_lengths();


private static void init__http_parser_index_offsets_0( short[] r )
{
	r[0]=0; r[1]=0; r[2]=6; r[3]=13; r[4]=21; r[5]=24; r[6]=26; r[7]=28; 
	r[8]=30; r[9]=32; r[10]=34; r[11]=36; r[12]=39; r[13]=41; r[14]=44; r[15]=46; 
	r[16]=57; r[17]=59; r[18]=70; r[19]=73; r[20]=75; r[21]=83; r[22]=91; r[23]=95; 
	r[24]=99; r[25]=106; r[26]=115; r[27]=119; r[28]=123; r[29]=134; r[30]=138; r[31]=142; 
	r[32]=152; r[33]=156; r[34]=160; r[35]=169; r[36]=178; r[37]=182; r[38]=186; r[39]=193; 
	r[40]=200; r[41]=207; r[42]=214; r[43]=221; r[44]=228; r[45]=235; r[46]=242; r[47]=249; 
	r[48]=256; r[49]=263; r[50]=270; r[51]=277; r[52]=284; r[53]=291; r[54]=298; r[55]=305; 
	r[56]=312; r[57]=314; 
}

private static short[] create__http_parser_index_offsets( )
{
	short[] r = new short[58];
	init__http_parser_index_offsets_0( r );
	return r;
}

private static final short _http_parser_index_offsets[] = create__http_parser_index_offsets();


private static void init__http_parser_indicies_0( byte[] r )
{
	r[0]=0; r[1]=0; r[2]=0; r[3]=0; r[4]=0; r[5]=1; r[6]=2; r[7]=3; 
	r[8]=3; r[9]=3; r[10]=3; r[11]=3; r[12]=1; r[13]=4; r[14]=5; r[15]=6; 
	r[16]=7; r[17]=5; r[18]=5; r[19]=5; r[20]=1; r[21]=8; r[22]=9; r[23]=1; 
	r[24]=10; r[25]=1; r[26]=11; r[27]=1; r[28]=12; r[29]=1; r[30]=13; r[31]=1; 
	r[32]=14; r[33]=1; r[34]=15; r[35]=1; r[36]=16; r[37]=15; r[38]=1; r[39]=17; 
	r[40]=1; r[41]=18; r[42]=17; r[43]=1; r[44]=19; r[45]=1; r[46]=20; r[47]=21; 
	r[48]=21; r[49]=21; r[50]=21; r[51]=21; r[52]=21; r[53]=21; r[54]=21; r[55]=21; 
	r[56]=1; r[57]=22; r[58]=1; r[59]=23; r[60]=24; r[61]=23; r[62]=23; r[63]=23; 
	r[64]=23; r[65]=23; r[66]=23; r[67]=23; r[68]=23; r[69]=1; r[70]=26; r[71]=27; 
	r[72]=25; r[73]=26; r[74]=28; r[75]=29; r[76]=31; r[77]=1; r[78]=1; r[79]=1; 
	r[80]=1; r[81]=1; r[82]=30; r[83]=29; r[84]=33; r[85]=1; r[86]=1; r[87]=1; 
	r[88]=1; r[89]=1; r[90]=32; r[91]=34; r[92]=34; r[93]=34; r[94]=1; r[95]=32; 
	r[96]=32; r[97]=32; r[98]=1; r[99]=35; r[100]=36; r[101]=35; r[102]=35; r[103]=35; 
	r[104]=35; r[105]=1; r[106]=8; r[107]=1; r[108]=9; r[109]=37; r[110]=1; r[111]=1; 
	r[112]=1; r[113]=1; r[114]=36; r[115]=38; r[116]=38; r[117]=38; r[118]=1; r[119]=36; 
	r[120]=36; r[121]=36; r[122]=1; r[123]=39; r[124]=1; r[125]=41; r[126]=42; r[127]=43; 
	r[128]=1; r[129]=1; r[130]=44; r[131]=1; r[132]=1; r[133]=40; r[134]=45; r[135]=45; 
	r[136]=45; r[137]=1; r[138]=40; r[139]=40; r[140]=40; r[141]=1; r[142]=8; r[143]=1; 
	r[144]=9; r[145]=47; r[146]=1; r[147]=1; r[148]=48; r[149]=1; r[150]=1; r[151]=46; 
	r[152]=49; r[153]=49; r[154]=49; r[155]=1; r[156]=46; r[157]=46; r[158]=46; r[159]=1; 
	r[160]=50; r[161]=1; r[162]=52; r[163]=53; r[164]=1; r[165]=1; r[166]=1; r[167]=1; 
	r[168]=51; r[169]=54; r[170]=1; r[171]=56; r[172]=57; r[173]=1; r[174]=1; r[175]=1; 
	r[176]=1; r[177]=55; r[178]=58; r[179]=58; r[180]=58; r[181]=1; r[182]=55; r[183]=55; 
	r[184]=55; r[185]=1; r[186]=2; r[187]=59; r[188]=59; r[189]=59; r[190]=59; r[191]=59; 
	r[192]=1; r[193]=2; r[194]=60; r[195]=60; r[196]=60; r[197]=60; r[198]=60; r[199]=1; 
	r[200]=2; r[201]=61; r[202]=61; r[203]=61; r[204]=61; r[205]=61; r[206]=1; r[207]=2; 
	r[208]=62; r[209]=62; r[210]=62; r[211]=62; r[212]=62; r[213]=1; r[214]=2; r[215]=63; 
	r[216]=63; r[217]=63; r[218]=63; r[219]=63; r[220]=1; r[221]=2; r[222]=64; r[223]=64; 
	r[224]=64; r[225]=64; r[226]=64; r[227]=1; r[228]=2; r[229]=65; r[230]=65; r[231]=65; 
	r[232]=65; r[233]=65; r[234]=1; r[235]=2; r[236]=66; r[237]=66; r[238]=66; r[239]=66; 
	r[240]=66; r[241]=1; r[242]=2; r[243]=67; r[244]=67; r[245]=67; r[246]=67; r[247]=67; 
	r[248]=1; r[249]=2; r[250]=68; r[251]=68; r[252]=68; r[253]=68; r[254]=68; r[255]=1; 
	r[256]=2; r[257]=69; r[258]=69; r[259]=69; r[260]=69; r[261]=69; r[262]=1; r[263]=2; 
	r[264]=70; r[265]=70; r[266]=70; r[267]=70; r[268]=70; r[269]=1; r[270]=2; r[271]=71; 
	r[272]=71; r[273]=71; r[274]=71; r[275]=71; r[276]=1; r[277]=2; r[278]=72; r[279]=72; 
	r[280]=72; r[281]=72; r[282]=72; r[283]=1; r[284]=2; r[285]=73; r[286]=73; r[287]=73; 
	r[288]=73; r[289]=73; r[290]=1; r[291]=2; r[292]=74; r[293]=74; r[294]=74; r[295]=74; 
	r[296]=74; r[297]=1; r[298]=2; r[299]=75; r[300]=75; r[301]=75; r[302]=75; r[303]=75; 
	r[304]=1; r[305]=2; r[306]=76; r[307]=76; r[308]=76; r[309]=76; r[310]=76; r[311]=1; 
	r[312]=2; r[313]=1; r[314]=1; r[315]=0; 
}

private static byte[] create__http_parser_indicies( )
{
	byte[] r = new byte[316];
	init__http_parser_indicies_0( r );
	return r;
}

private static final byte _http_parser_indicies[] = create__http_parser_indicies();


private static void init__http_parser_trans_targs_wi_0( byte[] r )
{
	r[0]=2; r[1]=0; r[2]=3; r[3]=38; r[4]=4; r[5]=24; r[6]=28; r[7]=25; 
	r[8]=5; r[9]=20; r[10]=6; r[11]=7; r[12]=8; r[13]=9; r[14]=10; r[15]=11; 
	r[16]=12; r[17]=13; r[18]=14; r[19]=15; r[20]=16; r[21]=17; r[22]=57; r[23]=17; 
	r[24]=18; r[25]=19; r[26]=14; r[27]=18; r[28]=19; r[29]=5; r[30]=21; r[31]=22; 
	r[32]=21; r[33]=22; r[34]=23; r[35]=24; r[36]=25; r[37]=26; r[38]=27; r[39]=5; 
	r[40]=28; r[41]=20; r[42]=29; r[43]=31; r[44]=34; r[45]=30; r[46]=31; r[47]=32; 
	r[48]=34; r[49]=33; r[50]=5; r[51]=35; r[52]=20; r[53]=36; r[54]=5; r[55]=35; 
	r[56]=20; r[57]=36; r[58]=37; r[59]=39; r[60]=40; r[61]=41; r[62]=42; r[63]=43; 
	r[64]=44; r[65]=45; r[66]=46; r[67]=47; r[68]=48; r[69]=49; r[70]=50; r[71]=51; 
	r[72]=52; r[73]=53; r[74]=54; r[75]=55; r[76]=56; 
}

private static byte[] create__http_parser_trans_targs_wi( )
{
	byte[] r = new byte[77];
	init__http_parser_trans_targs_wi_0( r );
	return r;
}

private static final byte _http_parser_trans_targs_wi[] = create__http_parser_trans_targs_wi();


private static void init__http_parser_trans_actions_wi_0( byte[] r )
{
	r[0]=1; r[1]=0; r[2]=11; r[3]=0; r[4]=1; r[5]=1; r[6]=1; r[7]=1; 
	r[8]=13; r[9]=13; r[10]=1; r[11]=0; r[12]=0; r[13]=0; r[14]=0; r[15]=0; 
	r[16]=0; r[17]=0; r[18]=19; r[19]=0; r[20]=0; r[21]=3; r[22]=23; r[23]=0; 
	r[24]=5; r[25]=7; r[26]=9; r[27]=7; r[28]=0; r[29]=15; r[30]=1; r[31]=1; 
	r[32]=0; r[33]=0; r[34]=0; r[35]=0; r[36]=0; r[37]=0; r[38]=0; r[39]=28; 
	r[40]=0; r[41]=28; r[42]=0; r[43]=21; r[44]=21; r[45]=0; r[46]=0; r[47]=0; 
	r[48]=0; r[49]=0; r[50]=31; r[51]=17; r[52]=31; r[53]=17; r[54]=25; r[55]=0; 
	r[56]=25; r[57]=0; r[58]=0; r[59]=0; r[60]=0; r[61]=0; r[62]=0; r[63]=0; 
	r[64]=0; r[65]=0; r[66]=0; r[67]=0; r[68]=0; r[69]=0; r[70]=0; r[71]=0; 
	r[72]=0; r[73]=0; r[74]=0; r[75]=0; r[76]=0; 
}

private static byte[] create__http_parser_trans_actions_wi( )
{
	byte[] r = new byte[77];
	init__http_parser_trans_actions_wi_0( r );
	return r;
}

private static final byte _http_parser_trans_actions_wi[] = create__http_parser_trans_actions_wi();


static final int http_parser_start = 1;
static final int http_parser_first_final = 57;
static final int http_parser_error = 0;

static final int http_parser_en_main = 1;

// line 68 "http11_parser.java.rl"

   public static interface ElementCB {
     public void call(Object data, int at, int length);
   }

   public static interface FieldCB {
     public void call(Object data, int field, int flen, int value, int vlen);
   }

   public static class HttpParser {
      int cs;
      int body_start;
      int content_len;
      int nread;
      int mark;
      int field_start;
      int field_len;
      int query_start;

      Object data;
      ByteList buffer;

      public FieldCB http_field;
      public ElementCB request_method;
      public ElementCB request_uri;
      public ElementCB fragment;
      public ElementCB request_path;
      public ElementCB query_string;
      public ElementCB http_version;
      public ElementCB header_done;

      public void init() {
          cs = 0;

          
// line 330 "../../ext/http11_java/org/jruby/mongrel/Http11Parser.java"
	{
	cs = http_parser_start;
	}
// line 103 "http11_parser.java.rl"

          body_start = 0;
          content_len = 0;
          mark = 0;
          nread = 0;
          field_len = 0;
          field_start = 0;
      }
   }

   public final HttpParser parser = new HttpParser();

   public int execute(ByteList buffer, int off) {
     int p, pe;
     int cs = parser.cs;
     int len = buffer.realSize;
     assert off<=len : "offset past end of buffer";

     p = off;
     pe = len;
     byte[] data = buffer.bytes;
     parser.buffer = buffer;

     
// line 359 "../../ext/http11_java/org/jruby/mongrel/Http11Parser.java"
	{
	int _klen;
	int _trans;
	int _acts;
	int _nacts;
	int _keys;

	if ( p != pe ) {
	if ( cs != 0 ) {
	_resume: while ( true ) {
	_again: do {
	_match: do {
	_keys = _http_parser_key_offsets[cs];
	_trans = _http_parser_index_offsets[cs];
	_klen = _http_parser_single_lengths[cs];
	if ( _klen > 0 ) {
		int _lower = _keys;
		int _mid;
		int _upper = _keys + _klen - 1;
		while (true) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( data[p] < _http_parser_trans_keys[_mid] )
				_upper = _mid - 1;
			else if ( data[p] > _http_parser_trans_keys[_mid] )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				break _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _http_parser_range_lengths[cs];
	if ( _klen > 0 ) {
		int _lower = _keys;
		int _mid;
		int _upper = _keys + (_klen<<1) - 2;
		while (true) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( data[p] < _http_parser_trans_keys[_mid] )
				_upper = _mid - 2;
			else if ( data[p] > _http_parser_trans_keys[_mid+1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				break _match;
			}
		}
		_trans += _klen;
	}
	} while (false);

	_trans = _http_parser_indicies[_trans];
	cs = _http_parser_trans_targs_wi[_trans];

	if ( _http_parser_trans_actions_wi[_trans] == 0 )
		break _again;

	_acts = _http_parser_trans_actions_wi[_trans];
	_nacts = (int) _http_parser_actions[_acts++];
	while ( _nacts-- > 0 )
	{
		switch ( _http_parser_actions[_acts++] )
		{
	case 0:
// line 13 "http11_parser.java.rl"
	{parser.mark = p; }
	break;
	case 1:
// line 15 "http11_parser.java.rl"
	{ parser.field_start = p; }
	break;
	case 2:
// line 16 "http11_parser.java.rl"
	{ 
    parser.field_len = p-parser.field_start;
  }
	break;
	case 3:
// line 20 "http11_parser.java.rl"
	{ parser.mark = p; }
	break;
	case 4:
// line 21 "http11_parser.java.rl"
	{ 
    if(parser.http_field != null) {
      parser.http_field.call(parser.data, parser.field_start, parser.field_len, parser.mark, p-parser.mark);
    }
  }
	break;
	case 5:
// line 26 "http11_parser.java.rl"
	{ 
    if(parser.request_method != null) 
      parser.request_method.call(parser.data, parser.mark, p-parser.mark);
  }
	break;
	case 6:
// line 30 "http11_parser.java.rl"
	{ 
    if(parser.request_uri != null)
      parser.request_uri.call(parser.data, parser.mark, p-parser.mark);
  }
	break;
	case 7:
// line 34 "http11_parser.java.rl"
	{ 
    if(parser.fragment != null)
      parser.fragment.call(parser.data, parser.mark, p-parser.mark);
  }
	break;
	case 8:
// line 39 "http11_parser.java.rl"
	{parser.query_start = p; }
	break;
	case 9:
// line 40 "http11_parser.java.rl"
	{ 
    if(parser.query_string != null)
      parser.query_string.call(parser.data, parser.query_start, p-parser.query_start);
  }
	break;
	case 10:
// line 45 "http11_parser.java.rl"
	{	
    if(parser.http_version != null)
      parser.http_version.call(parser.data, parser.mark, p-parser.mark);
  }
	break;
	case 11:
// line 50 "http11_parser.java.rl"
	{
    if(parser.request_path != null)
      parser.request_path.call(parser.data, parser.mark, p-parser.mark);
  }
	break;
	case 12:
// line 55 "http11_parser.java.rl"
	{ 
    parser.body_start = p + 1; 
    if(parser.header_done != null)
      parser.header_done.call(parser.data, p + 1, pe - p - 1);
    if (true) break _resume;
  }
	break;
// line 513 "../../ext/http11_java/org/jruby/mongrel/Http11Parser.java"
		}
	}

	} while (false);
	if ( cs == 0 )
		break _resume;
	if ( ++p == pe )
		break _resume;
	}
	}	}
	}
// line 127 "http11_parser.java.rl"

     parser.cs = cs;
     parser.nread += (p - off);
     
     assert p <= pe                  : "buffer overflow after parsing execute";
     assert parser.nread <= len      : "nread longer than length";
     assert parser.body_start <= len : "body starts after buffer end";
     assert parser.mark < len        : "mark is after buffer end";
     assert parser.field_len <= len  : "field has length longer than whole buffer";
     assert parser.field_start < len : "field starts after buffer end";

     if(parser.body_start>0) {
        /* final \r\n combo encountered so stop right here */
        
// line 540 "../../ext/http11_java/org/jruby/mongrel/Http11Parser.java"
// line 141 "http11_parser.java.rl"
        parser.nread++;
     }

     return parser.nread;
   }

   public int finish() {
     int cs = parser.cs;

     
// line 552 "../../ext/http11_java/org/jruby/mongrel/Http11Parser.java"
// line 151 "http11_parser.java.rl"

     parser.cs = cs;
 
    if(has_error()) {
      return -1;
    } else if(is_finished()) {
      return 1;
    } else {
      return 0;
    }
  }

  public boolean has_error() {
    return parser.cs == http_parser_error;
  }

  public boolean is_finished() {
    return parser.cs == http_parser_first_final;
  }
}

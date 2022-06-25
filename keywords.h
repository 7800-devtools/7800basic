// Provided under the GPL v2 license. See the included LICENSE.txt for details.

#ifndef KEYWORDS_H
#define KEYWORDS_H

#define MAXCONSTANTS 80000

char includespath[500];
char incbasepath[500];
int ongosub;
int condpart;
int smartbranching;
int collisionwrap;
int sprites_barfed;
int superchip;
int decimal;
int romat4k;
int includesfile_already_done;
int bankcount;
int currentbank;
int doublebufferused;
int boxcollisionused;
int multisprite;
int lifekernel;
int numfors;
int extra;
int extralabel;
int extraactive;
int macroactive;
int tallspritemode;
char user_includes[1000];
char sprite_data[5000][50];
int sprite_index;
int playfield_index[50];
int playfield_number;
char forvar[50][50];
char forlabel[50][50];
char forstep[50][50];
char forend[50][50];
char fixpoint44[2][500][50];
char fixpoint88[2][500][50];
char multtablename[100][100];
int multtablewidth[100];
int multtableheight[100];
int multtableindex;
void keywords(char **);
char redefined_variables[80000][100];
char constants[MAXCONSTANTS][100];
char bannerfilenames[1000][100];
int bannerheights[1000];
int bannerwidths[1000];
int bannerpixelwidth[1000];
char palettefilenames[1000][100];
int graphicfilepalettes[1000];
int graphicfilemodes[1000];
int kernel_options;
int numfixpoint44;
int numfixpoint88;
int numredefvars;
int optimization;
int numconstants;
int numthens;
int ors;
int line;
int numjsrs;
int numelses;
int doingfunction;
char Areg[200];
int branchtargetnumber;
unsigned char graphicsdata[16][256][100];
char graphicslabels[16][256][80];
unsigned char graphicsinfo[16][256];
unsigned char graphicsmode[16][256];
char currentcharset[256];
int graphicsdatawidth[16];
char charactersetchars[257];
int dmaplain;
int templabel;
int doublewide;
int zoneheight;
int zonelocking;

#endif

// Provided under the GPL v2 license. See the included LICENSE.txt for details.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "statements.h"
#include "keywords.h"
#include <math.h>

char stdoutfilename[256];
char backupname[256];
FILE *stdoutfilepointer;
FILE *preprocessedfd = NULL;

extern int currentbank;
extern int currentdmahole;
extern int numredefvars;
extern int numconstants;
extern char constants[MAXCONSTANTS][CONSTANTLEN];
extern char incbasepath[500];
extern char redefined_variables[80000][100];
extern char bannerfilenames[1000][100];
extern char palettefilenames[1000][100];
extern char currentcharset[256];
extern int graphicsdatawidth[16];
extern char charactersetchars[257];
extern int passes;
extern int line;
extern int savelevel;
extern int dmaplain;
extern int templabel;
extern int plotlabel;
extern int tallspritecount;
extern int fourbitfade_alreadyused;
extern int zonelocking;
extern int multtableindex;
extern int numfixpoint44;
extern int numfixpoint88;
extern int numjsrs;
extern int doingfunction;
extern int branchtargetnumber;
extern int banksetrom;
extern FILE *stderrfilepointer;
extern int condpart;
extern int ongosub;
extern int includesfile_already_done;
extern int fourbitfade_alreadyused;
extern int numfors;
extern int ors;
extern int numelses;
extern int numthens;
extern int extra;
extern int extralabel;
extern int dumpgraphics;
extern int doublebufferused;
extern int boxcollisionused;
extern int romsize_already_set;
extern int firstfourbyte;
extern int firstcompress;
extern int dumpgraphics_index;
extern int TIGHTPACKBORDER;
extern int changedmaholescalled;
int maxpasses = 2;

#define BASIC_VERSION_INFO "7800basic v0.36"

int main (int argc, char *argv[])
{
    char **statement;
    char **deallocate_mem;
    int i, j, k;
    int def_idx;
    int unnamed, defcount, defi;
    char *c;
    char single;
    char code[500];
    char displaycode[500];
    FILE *header = NULL;
    int multiplespace = 0;
    char *includes_file = "default.inc";
    char *filename = "7800basic_variable_redefs.h";
    char *prefilename = NULL;
    char *path = 0;
    char def[500][100];
    char defr[500][100];
    char finalcode[500];
    char *codeadd;
    char mycode[500];
    path = NULL;
    backupname[0] = 0;
    maxpasses = 2;

    // get command line arguments
    while ((i = getopt (argc, argv, "i:b:r:p:v")) != -1)
    {
	switch (i)
	{
	case 'i':
	    path = optarg;
	    break;
	case 'b':
	    strncpy (backupname, optarg, 256);
	    break;
	case 'r':
	    filename = optarg;
	    break;
	case 'p':
	    prefilename = optarg;
	    break;
	case 'v':
	    printf ("%s (%s, %s)\n", BASIC_VERSION_INFO, __TIME__, __DATE__);
	    exit (0);
	case '?':
	    fprintf (stderr, "usage: %s -r <variable redefs file> -i <includes path>\n", argv[0]);
	    exit (1);
	}
    }

    if (prefilename == NULL)
    {
        // we were called without the "-p" switch, so revert to the historic
        // single-pass behavior, since the basic source is coming from stdin,
        // and we can't rewind stdin.
	prwarn ("7800basic was launched without -p. Using single-pass only.");
	maxpasses=1;
        preprocessedfd = stdin;
    }
    else
    {
        preprocessedfd=fopen(prefilename,"rb");
        if (preprocessedfd == NULL)
        {
	    fprintf (stderr, "unable to open preprocessed basic file: %s\n",prefilename);
	    exit (2);
        }
    }
   
    // this is the info we're trying to extract from the first pass, 
    // so we initialize it prior to the pass loop
    bannerfilenames[0][0] = 0;  // incbanner reverse lookup
    palettefilenames[0][0] = 0; // incbanner reverse lookup
    tallspritecount = 0;
    memset(constants,0,MAXCONSTANTS*CONSTANTLEN);

    for(passes=0;passes<maxpasses;passes++)
    {
        if(stderrfilepointer!=NULL)
        {
            fclose(stderrfilepointer);
            stderrfilepointer=NULL;
        }

        if (prefilename != NULL) // rewind if we can
	    fseek(preprocessedfd,0,SEEK_SET);

	// these asm files are produced dynamically, so as to allow out-of-order
	// assembly with dasm. Their mere presence will affect the compile process
	// so we start off by wiping them, if they exist from a previous compile.
	remove ("7800hole.0.asm");
	remove ("7800hole.1.asm");
	remove ("7800hole.2.asm");
	remove ("banksetrom.asm");
	remove ("banksetstrings.asm");
	remove ("message.log");

        prout ("%s %s %s\n", BASIC_VERSION_INFO, __DATE__, __TIME__);

        // a bunch of vars that should be reset each pass.
        changedmaholescalled = 0;
        numredefvars = 0;
        numconstants = 0;
	incbasepath[0] = 0;
	currentcharset[0] = 0;
	line = 0;
	savelevel = 0;
	unnamed = 0;
	defcount = 0;
	multiplespace = 0;
	defi = 0;
	dmaplain = 0;
	templabel = 0;
	plotlabel = 0;
	currentbank = 0;
	branchtargetnumber = 0;
	doingfunction = 0;
	fourbitfade_alreadyused = 0;
	zonelocking = 0;
	multtableindex = 0;
	numfixpoint44 = 0;
	numfixpoint88 = 0;
	numjsrs = 0;
	doingfunction = 0;
	banksetrom = 0;
	condpart = 0;
	ongosub = 0;
	includesfile_already_done = 0;
	fourbitfade_alreadyused = 0;
	numfors = 0;
	extra = 0;
	extralabel = 0;
	dumpgraphics = 0;
	doublebufferused = 0;
	boxcollisionused = 0;
	romsize_already_set = 0;
	dumpgraphics_index = 0;
	ors = 0;
	numelses = 0;
	numthens = 0;
	firstfourbyte = 1;
	firstcompress = 1;
	TIGHTPACKBORDER = 0;

        // global variable init...
        strcpy (redefined_variables[numredefvars++], "collisionwrap = 1");

	for (i = 0; i < 16; i++)
	    graphicsdatawidth[i] = 0;

	strcpy (charactersetchars, " abcdefghijklmnopqrstuvwxyz.!?,\"$():");

	// redirect STDOUT to 7800.asm, overwriting if it exists... 
	strcpy (stdoutfilename, "7800.asm");
	if ((stdoutfilepointer = freopen (stdoutfilename, "w", stdout)) == NULL)
	{
	    prerror ("couldn't create the 7800.asm file.");
	}

	printf ("SPACEOVERFLOW SET 0\n");
	printf (" ifnconst SPACEOVERFLOWPASS\n");
	printf ("SPACEOVERFLOWPASS SET 0\n");
	printf (" endif SPACEOVERFLOWPASS\n");


	char removefile[256];
	int t;
	for (t = 0; t < 100; t++)
	{
	    sprintf (removefile, "dump_gfx_%02d.bin", t);
	    if (remove (removefile))
		break;
	    sprintf (removefile, "dump_gfx_%02d.asm", t);
	    remove (removefile);
	}


	create_a78info ();	// wipe/create a78 parameter file

	printf ("game\n");	// label for start of game
	init_includes (path);

	statement = (char **) malloc (sizeof (char *) * STATEMENTCOUNT);
	deallocate_mem = statement;
	for (i = 0; i < STATEMENTCOUNT; ++i)
	{
	    statement[i] = (char *) malloc (sizeof (char) * (SIZEOFSTATEMENT + 1));
	    memset (statement[i], 0, (SIZEOFSTATEMENT + 1));
	}

	while (1)
	{			// clear out statement cache
	    for (i = 0; i < STATEMENTCOUNT; ++i)
	    {
		for (j = 0; j < SIZEOFSTATEMENT; ++j)
		{
		    statement[i][j] = '\0';
		}
	    }
	    c = fgets (code, 500, preprocessedfd);	// get next line from input
	    incline ();
	    strcpy (displaycode, code);

	    // look for defines and remember them
	    strcpy (mycode, code);
	    int k_def_search;
            for (k_def_search = 0; k_def_search < 495; ++k_def_search)
	        if (code[k_def_search] == ' ')
		    break;
	    if (k_def_search < 495 && code[k_def_search] == ' ' && 
	    (k_def_search + 4 < 499) && code[k_def_search + 1] == 'd' && 
	    code[k_def_search + 2] == 'e' && code[k_def_search + 3] == 'f' &&
	    code[k_def_search + 4] == ' ')
	    {			// found a define
	        int current_pos = k_def_search + 5; // current_pos now points to start of define name.
	        if (defi >= 499) { // Max 500 defines
		    fprintf(stderr, "(%d) ERROR: Maximum number of defines (500) reached.\n", bbgetline());
		    exit(1);
		}
	        for (j = 0; current_pos < 499 && code[current_pos] != ' ' && code[current_pos] != '\0' && code[current_pos] != '\n' && code[current_pos] != '\r'; current_pos++)
		{
		    if (j >= 99) {
		        fprintf(stderr, "(%d) ERROR: Define name too long (max 99 chars).\n", bbgetline());
		        exit(1);
		    }
		    def[defi][j++] = code[current_pos];
		}
		def[defi][j] = '\0';

		if (j == 0) { // Empty define name
		     fprintf(stderr, "(%d) ERROR: Malformed define statement. Empty define name.\n", bbgetline());
		     exit(1);
		}

		// Expect " = " sequence after define name
		if (!(current_pos < 497 && code[current_pos] == ' ' && code[current_pos+1] == '=' && code[current_pos+2] == ' ')) {
		    fprintf(stderr, "(%d) ERROR: Malformed define statement. Expected \" = \" after define name '%s'.\n",
		            bbgetline(), def[defi]);
		    exit(1);
		}
		current_pos += 3; // Skip " = "

		for (j = 0; current_pos < 499 && code[current_pos] != '\0' && code[current_pos] != '\n' && code[current_pos] != '\r'; current_pos++)
		{
		    if (j >= 99) {
		        fprintf(stderr, "(%d) ERROR: Define replacement string too long (max 99 chars) for define '%s'.\n", bbgetline(), def[defi]);
		        exit(1);
		    }
		    defr[defi][j++] = code[current_pos];
		}
		defr[defi][j] = '\0';
		removeCR (defr[defi]);
	        printf (";PARSED_DEFINE: .%s. = .%s.\n", def[defi], defr[defi]);
		defi++;
	    }
	    else if (defi) // This 'i' refers to the outer loop variable for iterating through existing defines
	    {
		for (def_idx = 0; def_idx < defi; ++def_idx)
		{
		    codeadd = NULL;
		    finalcode[0] = '\0';
		    defcount = 0;
		    while (1)
		    {
			if (defcount++ > 250)
			{
			    fprintf (stderr,
				     "(%d) Infinitely repeating definition or too many instances of a definition\n",
				     bbgetline ());
			    exit (1);
			}
	                codeadd = strstr (mycode, def[def_idx]);
			if (codeadd == NULL)
			    break;
			for (j = 0; j < 500; ++j)
			    finalcode[j] = '\0';
			strncpy (finalcode, mycode, 500);
			finalcode[(strlen (mycode) - strlen (codeadd))] = 0;
	                strcat (finalcode, defr[def_idx]);
	                strcat (finalcode, codeadd + strlen (def[def_idx]));
			strcpy (mycode, finalcode);
		    }
		}
	    }
	    if (strcmp (mycode, code))
		strcpy (code, mycode);
	    if (!c)
		break;		//end of file

	    // preprocessing removed in favor of a simplistic lex-based preprocessor

            // fprintf(stderr,"%s",code); // DEBUG

	    i = 0;
	    j = 0;
	    k = 0;

	    // look for spaces, reject multiples
	    while (code[i] != '\0')
	    {
		single = code[i++];
		if (single == ' ')
		{
		    if (!multiplespace)
		    {
			j++;
			k = 0;
		    }
		    multiplespace++;
		}
		else
		{
		    multiplespace = 0;
		    if (k < (SIZEOFSTATEMENT - 1))	// avoid overrun when users use REM with long horizontal separators
			statement[j][k++] = single;
		}

	    }
	    if (j > 150)
	    {
		fprintf (stderr, "(%d) Warning: long line\n", bbgetline ());
	    }
	    if (statement[0][0] == '\0')
	    {
		sprintf (statement[0], "L0%d", unnamed++);
	    }
	    if (strncmp (statement[0], "end\0", 3))
		printf (".%s ;;line %d;; %s\n", statement[0], line, displaycode);
	    else
		doend ();

	    keywords (statement);
	    if (numconstants == (MAXCONSTANTS - 1))
	    {
		fprintf (stderr, "(%d) Maximum number of constants exceeded.\n", bbgetline ());
		exit (1);
	    }
	}


	printf ("DMAHOLEEND%d SET .\n", currentdmahole);

	//if stdout is redirected, change it back to 7800.asm so the gameend label goes in the right spot...
	if (strcmp (stdoutfilename, "7800.asm") != 0)
	{
	    strcpy (stdoutfilename, "7800.asm");
	    if ((stdoutfilepointer = freopen (stdoutfilename, "a", stdout)) == NULL)
	    {
		prerror ("couldn't reopen the 7800.asm file.");
	    }
	}

	printf ("gameend\n");

	barf_graphic_file ();
	barfmultiplicationtables ();

	printf (" if SPACEOVERFLOW > 0\n");
	printf ("  echo \"\"\n");
	printf ("  echo \"######## ERROR: space overflow detected in\",[SPACEOVERFLOW]d,\"areas.\"\n");
	printf ("  echo \"######## look above for areas with negative ROM space left.\"\n");
	printf (" endif\n");

	printf (" \n\n");

	prout ("7800basic compilation complete.\n");
	freemem (deallocate_mem);
    }

    header_write (header, filename);
    create_includes (includes_file);

    lastrites ();

    return 0;
}

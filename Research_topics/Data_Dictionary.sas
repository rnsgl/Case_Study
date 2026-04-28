/* ====================================================================== */
/* DATA DICTIONARY - SAS Metadata Extraction Program                      */
/* Purpose: Generate a comprehensive data dictionary for database tables  */
/*          showing all columns, types, lengths, labels, and formats     */
/* ====================================================================== */

/* ====================================================================== */
/* SECTION 1: DEFINE MACRO VARIABLES                                      */
/* ====================================================================== */

/* Library and table name to analyze */
%let lib = OUT;           /* SAS library name */
%let name = ORDERS;       /* Table/dataset name */

/* ====================================================================== */
/* SECTION 2: QUERY DATA DICTIONARY METADATA                              */
/* ====================================================================== */

/* Extract comprehensive metadata from SAS DICTIONARY tables */
/* Shows all column characteristics for the specified table */
proc sql;
	SELECT a.libname,           /* SAS library name */
			a.memname,          /* Dataset/table name */
			a.memtype,          /* Table type (DATA, VIEW, etc.) */
			b.name,             /* Column/variable name */
			b.type,             /* Variable type (char, num) */
			b.length,           /* Variable length in bytes */
			b.npos,             /* Column position in table */
			b.varnum,           /* Variable number */
			b.label,            /* Variable label/description */
			b.format,           /* Output format */
			b.informat,         /* Input format */
			b.sortedby          /* Sort order if applied */
	FROM dictionary.tables as a     /* Table metadata */
	INNER JOIN dictionary.columns as b  /* Column metadata */
	ON a.libname = b.libname and
	   a.memname = b.memname
	WHERE a.libname = "&lib"        /* Filter by specified library */
		and a.memname = "&name";    /* Filter by specified table */
run;

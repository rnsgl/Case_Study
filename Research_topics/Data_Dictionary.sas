%let lib = OUT;
%let name = ORDERS;



proc sql;
	select a.libname,
			a.memname,
			a.memtype,
			b.name,
			b.type,
			b.length,
			b.npos,
			b.varnum,
			b.label,
			b.format,
			b.informat,
			b.sortedby
	from dictionary.tables as a 
	inner join dictionary.columns as b
	on a.libname = b.libname and
	a.memname = b.memname
	where a.libname = "&lib"
		and a.memname = "&name";
run;

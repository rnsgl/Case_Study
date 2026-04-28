libname out "/home/student/casuser";

proc import datafile='/home/student/orders.xlsx'
	out=out.orders
	DBMS=XLSX;
RUN;

proc import datafile='/home/student/organization.csv'
	out=out.organization
	DBMS=CSV;
run;

proc import datafile='/home/student/products.txt'
	out=out.products
	dbms=dlm;
	delimiter='09'x;
	getnames=yes;
run;

libname prod xlsx '/home/student/product_level.xlsx';

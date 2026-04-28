ods graphics on;

filename tmeppdf temp;

/* Option 2: Using %sysfunc to get the work path */
ods html5 file=temppdf;



proc sort data=out.orderdetails;
	by Customer_Country;
run;

data out.Orders_By_Country;
	set out.orderdetails(rename = (Customer_Country = ID));
	by ID;
	Quantity+Quatity;
	if last.ID then do;
		output;
		Quantity = 0;
	end;
	
	where ID ne "";
	
	keep ID Quantity;
run;

data out.Orders_By_Country;
	merge out.Orders_By_Country mapsgfk.world;
	by ID;
run;

title1 "Geographic Map";

proc sgmap mapdata=mapsgfk.world maprespdata=out.Orders_By_Country;
	choromap Quantity / mapid=ID;
run;


ods html5 close;
ods graphics off;

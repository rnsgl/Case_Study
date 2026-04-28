/* ====================================================================== */
/* MAP ORDERS - SAS Geographic Visualization Program                      */
/* Purpose: Create a choropleth map showing order quantities by country   */
/* ====================================================================== */

/* ====================================================================== */
/* SECTION 1: INITIALIZE GRAPHICS AND OUTPUT                              */
/* ====================================================================== */

/* Enable ODS Graphics for high-resolution visualization */
ods graphics on;

/* Create a temporary file reference for HTML5 output */
filename temppdf temp;

/* Open HTML5 output destination for map generation */
ods html5 file=temppdf;

/* ====================================================================== */
/* SECTION 2: AGGREGATE ORDER DATA BY COUNTRY                             */
/* ====================================================================== */

/* Sort order details by customer country for by-group processing */
proc sort data=out.orderdetails;
	by Customer_Country;
run;

/* Aggregate order quantities by country */
/* Creates summary showing total quantity ordered per country */
data out.Orders_By_Country;
	set out.orderdetails(rename = (Customer_Country = ID));
	by ID;
	
	/* Accumulate quantities within each country group */
	Quantity + Quatity;
	
	/* Output aggregated record at end of each country group */
	if last.ID then do;
		output;
		Quantity = 0;  /* Reset for next country */
	end;
	
	/* Exclude records with missing country values */
	where ID ne "";
	
	/* Keep only country ID and total quantity */
	keep ID Quantity;
run;

/* ====================================================================== */
/* SECTION 3: MERGE WITH GEOGRAPHIC MAP DATA                              */
/* ====================================================================== */

/* Merge aggregated order data with world map geographic data */
/* Links country orders with map coordinates and boundaries */
data out.Orders_By_Country;
	merge out.Orders_By_Country mapsgfk.world;
	by ID;
run;

/* ====================================================================== */
/* SECTION 4: CREATE CHOROPLETH MAP VISUALIZATION                         */
/* ====================================================================== */

title1 "Geographic Map";

/* Generate choropleth map showing order quantities by country */
/* Color intensity represents quantity ordered in each country */
proc sgmap mapdata=mapsgfk.world maprespdata=out.Orders_By_Country;
	choromap Quantity / mapid=ID;
run;

/* ====================================================================== */
/* SECTION 5: CLOSE OUTPUT                                                */
/* ====================================================================== */

/* Close HTML5 output destination */
ods html5 close;

/* Disable ODS Graphics after map generation */
ods graphics off;

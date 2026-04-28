/* ====================================================================== */
/* ORDER REPORTS - SAS Analysis Program                                   */
/* Purpose: Generate product sales and revenue reports segmented by       */
/*          country/type and age groups                                   */
/* ====================================================================== */

/* Define macro variables for report segmentation */
%let by = Country;           /* Grouping variable for reports */
%let target = Product_line;  /* Target analysis dimension */
%let profitable = "True";    /* Flag to include revenue calculations */

/* ====================================================================== */
/* SECTION 1: PRODUCT QUANTITY REPORT                                     */
/* ====================================================================== */

title1 "Product Quantity Report";
title2 "Sorted by Quantity in Descending Order";

/* Query to get top 5 products by total quantity ordered */
proc sql outobs=5;
	SELECT Product_id, 
		   Sum(input(Quatity, best.)) AS Quantity
		FROM out.orders
			Group by Product_id
				ORDER BY Quantity DESC;
quit;

/* ====================================================================== */
/* SECTION 2: PRODUCT LINE REVENUE REPORT                                 */
/* ====================================================================== */

title1 "Product Line Revenue Report";
title2 "Quantity and Revenue Analysis";

/* Create table with product line totals: quantity and revenue */
/* Revenue calculated conditionally based on profitable flag */
proc sql outobs=5;
	CREATE TABLE out.Line_By_Quantity AS 
	SELECT Product_line,
		   Sum(input(Quatity,best.)) AS Quantity,
		   CASE 
			   WHEN &profitable LIKE "True" THEN
			   SUM(input(Quatity,best.)* input(CostPrice_per_unit,best.))
			   ELSE .
		   END 
	   AS Revenue
		FROM out.ordersLine
			Group by Product_line
				ORDER BY Quantity DESC;
quit;

/* ====================================================================== */
/* SECTION 3: QUANTITY BY PRODUCT LINE AND ORDER TYPE                    */
/* ====================================================================== */

title1 "Quantity by Product Line and Type";
title2 "Temporary Table Creation";

/* Create temporary table for quantity breakdown by product line & type */
proc sql outobs=5;
	CREATE TABLE qtn_by_type as
		SELECT Product_line, 
			   Order_Type, 
			   Sum(input(Quatity,best.)) AS Quantity
			FROM out.ordersLine
				Group by Order_Type, Product_line 
					ORDER BY Quantity DESC;
quit;

/* ====================================================================== */
/* SECTION 4: MAXIMUM QUANTITY BY PRODUCT LINE AND TYPE                  */
/* ====================================================================== */

title1 "Maximum Quantity by Product Line and Type";

/* Find maximum quantity for each product line using subquery */
proc sql outobs=5;
	SELECT Product_line, 
		   Type, 
		   Quantity
		FROM qtn_by_type as a
			WHERE a.Quantity = (
				SELECT MAX(b.Quantity)
					FROM qtn_by_type as b
						WHERE a.Product_line = b.Product_line
						)
						order by Product_line;
quit;

/* ====================================================================== */
/* SECTION 5: PRODUCT LINE SALES SUMMARY                                  */
/* ====================================================================== */

/* Sort data by product line for by-group processing */
proc sort data=out.ordersLine;
	by Product_line;
run;

/* Calculate total quantity sold per product line */
data out.ProductLine_Sales;
	set out.ordersLine;
	where not missing(Product_line);  /* Exclude missing product lines */
	by Product_line;

	if first.Product_line then
		Quantity = 0;                 /* Initialize quantity */
	Quantity + Quatity;               /* Accumulate quantity */

	if last.Product_line;             /* Keep only last record per line */
	keep Product_line Quantity;
run;

/* Sort by quantity in descending order */
proc sort data=out.ProductLine_Sales;
	by descending Quantity;
run;

/* ====================================================================== */
/* SECTION 6: PRODUCT SALES SUMMARY                                       */
/* ====================================================================== */

/* Sort orders by product ID */
proc sort data=out.orders;
	by Product_id;
run;

/* Calculate total quantity sold per product */
data out.ProductSales;
	set out.orders;
	where Product_id ne '.';          /* Exclude missing product IDs */
	by Product_id;

	if first.Product_id then
		Quantity = 0;                 /* Initialize quantity */
	Quantity + Quatity;               /* Accumulate quantity */

	if last.Product_id;               /* Keep only last record per product */
	keep Product_id Quantity;
run;

/* Sort by quantity in descending order */
proc sort data=out.ProductSales;
	by descending Quantity;
run;

/* ====================================================================== */
/* SECTION 7: PURCHASE ANALYSIS BY CUSTOMER AGE GROUP                     */
/* ====================================================================== */

/* Create age groups based on customer birth date */
data out.Purchase_by_Age_Group;
	set out.ordersline;
	format Date date9.;
	Date = input(Customer_BirthDate,date9.);

	/* Assign customers to age groups using year difference calculation */
	if 15<=yrdif(Date, today(),'30/360')<=30 then
		Age_Group = '15 to 30';
	else if 31<=yrdif(Date, today(),'30/360')<=45 then
		Age_Group = '31 to 45';
	else if 46<=yrdif(Date, today(),'30/360')<=60 then
		Age_Group = '46 to 60';
	else if 61<=yrdif(Date, today(),'30/360')<=75 then
		Age_Group = '61 to 75';
	else if 76<=yrdif(Date, today(),'30/360')<=90 then
		Age_Group = '76 to 90';
	else Age_Group = 'other';
	
run;

/* Sort by grouping variable (Country/Type) for subsequent processing */
proc sort data= out.ordersLine;
	by &by;
	keep Order_ID Customer_BirthDate Date &by;
run;

/* Sort age group data by Order ID */
proc sort data= out.Purchase_by_Age_Group;
	by Order_ID;
run;

/* Create purchase data segmented by grouping variable */
data out.Purchase_by_&by;
	set out.ordersLine;
	by &by;
run;

/* Re-sort for by-group processing */
proc sort data= out.ordersLine;
	by &by;
run;

/* Extract relevant fields for detailed purchase analysis */
data out.Purchase_by_&by;
	set out.ordersLine;
	by &by;
	keep Customer_Type Quatity Product_line Order_ID &by;
run;

/* Sort age group data by grouping variable */
proc sort data=out.Purchase_by_Age_Group;
	by &by;
run;

/* Sort purchase data by grouping variable and product line */
proc sort data= out.Purchase_by_&by;
	by &by Product_line;
run;

/* Initialize most popular line by type analysis */
data out.most_Line_&by;

/* Re-sort orders by Order ID */
proc sort data= out.ordersLine;
	by Order_ID;
run;

/* Sort age group data by grouping variable */
proc sort data=out.Purchase_by_Age_Group;
	by &by;
run;

/* Sort purchase data by grouping variable and product line */
proc sort data= out.Purchase_by_&by;
	by &by Product_line;
run;

/* Aggregate quantity by grouping variable and product line */
/* Keep only top product line per group after filtering */
data out.most_Line_by_Type_clean;
	set out.Purchase_by_&by;
	where not missing(Product_line);  /* Exclude missing product lines */
	by &by Product_line;

	if first.&by or first.Product_line then
		Quantity = 0;                 /* Initialize quantity */
	Quantity + Quatity;               /* Accumulate quantity */

	if last.&by or last.Product_line; /* Keep aggregate record */
	keep Product_line &by Quantity;
run;

/* Sort aggregated data by grouping variable and quantity */
proc sort data=out.most_Line_&by;
	by &by Quantity;
run;

/* Create final report dataset with aggregated metrics */
data out.Final_report_&by;
	set out.most_Line_&by;

/* Re-sort clean data by grouping variable and quantity */
proc sort data=out.most_Line_by_Type_clean;
	by &by Quantity;
run;

/* Generate final filtered report with quantity threshold */
data out.Final_report;
	set out.most_Line_by_Type_clean;
	where Quantity le 3000;           /* Filter to quantities <= 3000 */
	by &by;

	if last.&by;                      /* Keep last record per group */
	keep Product_line &by Quantity;
run;

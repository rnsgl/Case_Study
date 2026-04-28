%let by = Country;
%let target = Product_line;


%let profitable = "True";

title1 "Product Quantity Report";
title2 "Sorted by Quantity in Descending Order";
proc sql outobs=5;

%let profitable = "True";

proc sql;
	SELECT Product_id, Sum(input(Quatity, best.)) AS Quantity
		FROM out.orders
			Group by Product_id
				ORDER BY Quantity DESC;
quit;

title1 "Product Line Revenue Report";
title2 "Quantity and Revenue Analysis";
proc sql outobs=5;
CREATE TABLE out.Line_By_Quantity AS 
proc sql;
	SELECT Product_line,Sum(input(Quatity,best.)) AS Quantity ,
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

title1 "Quantity by Product Line and Type";
title2 "Temporary Table Creation";
proc sql outobs=5;
	CREATE TABLE qtn_by_type as
		SELECT Product_line, Order_Type, Sum(input(Quatity,best.)) AS Quantity
			FROM out.ordersLine
				Group by Order_Type, Product_line 
					ORDER BY Quantity DESC;
quit;

title1 "Maximum Quantity by Product Line and Type";
proc sql outobs=5;
	SELECT Product_line, Order_Type, Quantity
proc sql;
	SELECT Product_line, Type, Quantity
		FROM qtn_by_type as a
			WHERE a.Quantity = (
				SELECT MAX(b.Quantity)
					FROM qtn_by_type as b
						WHERE a.Product_line = b.Product_line
							)
						order by Product_line;
quit;

proc sort data=out.ordersLine;
	by Product_line;
run;

data out.ProductLine_Sales;
	set out.ordersLine;
	where not missing(Product_line);
	by Product_line;

	if first.Product_line then
		Quantity =0;
	Quantity + Quatity;

	if last.Product_line;
	keep Product_line Quantity;
run;

proc sort data=out.ProductLine_Sales;
	by descending Quantity;
run;

proc sort data=out.orders;
	by Product_id;
run;

data out.ProductSales;
	set out.orders;
	where Product_id ne '.';
	by Product_id;

	if first.Product_id then
		Quantity =0;
	Quantity + Quatity;

	if last.Product_id;
	keep Product_id Quantity;
run;

proc sort data=out.ProductSales;
	by descending Quantity;
run;

data out.Purchase_by_Age_Group;
	set out.ordersline;
	format Date date9.;
	Date = input(Customer_BirthDate,date9.);

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

proc sort data= out.ordersLine;
	by &by;
	keep Order_ID Customer_BirthDate Date &by;
run;

proc sort data= out.Purchase_by_Age_Group;
	by Order_ID;
run;



data out.Purchase_by_&by;
	set out.ordersLine;
	by &by;
run;


proc sort data= out.ordersLine;
	by &by;
run;

data out.Purchase_by_&by;
	set out.ordersLine;
	by &by;
	keep Customer_Type Quatity Product_line Order_ID &by;
run;

proc sort data=out.Purchase_by_Age_Group;
	by &by;
run;

proc sort data= out.Purchase_by_&by;
	by &by Product_line;
run;

data out.most_Line_&by;
proc sort data= out.ordersLine;
	by Order_ID;
run;

proc sort data=out.Purchase_by_Age_Group;
	by &by;
run;

proc sort data= out.Purchase_by_&by;
	by &by Product_line;
run;

data out.most_Line_by_Type_clean;
	set out.Purchase_by_&by;
	where not missing(Product_line);
	by &by Product_line;

	if first.&by or first.Product_line then
		Quantity =0;
	Quantity + Quatity;

	if last.&by or last.Product_line;
	keep Product_line &by Quantity;
run;

proc sort data=out.most_Line_&by;
	by &by Quantity;
run;

data out.Final_report_&by;
	set out.most_Line_&by;
proc sort data=out.most_Line_by_Type_clean;
	by &by Quantity;
run;

data out.Final_report;
	set out.most_Line_by_Type_clean;
	where Quantity le 3000;
	by &by;

	if last.&by;
	keep Product_line &by Quantity;
run;












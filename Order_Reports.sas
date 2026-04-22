%let by = Name;
%let target = Product_line;

proc sql;
	SELECT Product_id, Sum(input(Quatity, best.)) AS Quantity
		FROM out.orders
			Group by Product_id
				ORDER BY Quantity DESC;
quit;

proc sql outobs=3;
	SELECT Product_line,Sum(input(Quatity,best.)) AS Quantity
		FROM out.ordersLine
			Group by Product_line
				ORDER BY Quantity DESC;
quit;

proc sql;
	CREATE TABLE qtn_by_type as
		SELECT Product_line, Type, Sum(input(Quatity,best.)) AS Quantity
			FROM out.ordersLine
				Group by Type, Product_line 
					ORDER BY Quantity DESC;
quit;

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
	keep Order_ID Customer_BirthDate Date Age_Group Product_line Quatity Customer_Type Customer_Activity Name;
run;

proc sort data= out.Purchase_by_Age_Group;
	by Order_ID;
run;

proc sort data= out.ordersLine;
	by Customer_Type;
run;

data out.Purchase_by_Customer_type;
	set out.ordersLine;
	by Customer_Type;
	keep Customer_Type Quatity Product_line Order_ID;
run;

proc sort data= out.ordersLine;
	by Customer_Activity;
run;

data out.Purchase_by_Customer_Activity;
	set out.ordersLine;
	by Customer_Activity;
	keep Customer_Type Quatity Product_line Order_ID Customer_Activity;
run;

proc sort data= out.ordersLine;
	by Name;
run;

data out.Purchase_by_Name;
	set out.ordersLine;
	by Name;
	keep Customer_Type Quatity Product_line Order_ID Customer_Activity Name;
run;


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













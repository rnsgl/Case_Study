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

data out.Purchase_by_age;
	set out.orders;
	format Date date9.;
	Date = input(Customer_BirthDate,date9.); 
	if 15<=yrdif(Date, today(),'30/360')<=30 then Age_Group = '15 to 30';
	else if 31<=yrdif(Date, today(),'30/360')<=45 then Age_Group = '31 to 45';
	else if 46<=yrdif(Date, today(),'30/360')<=60 then Age_Group = '46 to 60';
	else if 61<=yrdif(Date, today(),'30/360')<=75 then Age_Group = '61 to 75';
	else if 76<=yrdif(Date, today(),'30/360')<=90 then Age_Group = '76 to 90';
	else Age_Group = 'other';
	
	keep Order_ID Customer_BirthDate Date Age_Group;
run;

proc sort data= out.Purchase_by_age;
	by Order_ID;
run;

proc sort data= out.ordersLine;
	by Order_ID;
run;

data out.most_Line_by_Age;
	merge out.ordersLine out.Purchase_by_age;
	by Order_ID;
run;

proc sort data=out.most_Line_by_Age;
	by Age_Group Product_line;
run;
data out.most_Line_by_age_clean;
	set out.most_Line_by_Age;
	
	where not missing(Product_line);
	
	by Age_Group Product_line;

	if first.Age_Group or first.Product_line then
		Quantity =0;
	Quantity + Quatity;

	if last.Age_Group or last.Product_line;
	keep Product_line Age_Group Quantity;
run;

proc sort data=out.most_Line_by_age_clean;
	by Age_Group Quantity;
run;

data out.most_Line_by_age_clean_sorted;
	set out.most_Line_by_Age_clean;
	
	
	
	by Age_Group;

	

	if last.Age_Group;
	keep Product_line Age_Group Quantity;
run;

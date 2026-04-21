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

proc sort data=out.orders;
	by Product_id;
	
run;

data out.ProductSales;
	set out.orders;
	by Product_id;
	if first.Product_id then Quantity =0;
	Quantity + Quatity;
	if last.Product_id;
	keep Product_id Quantity;
run;

proc sort data=out.ProductSales;
	by descending Quantity;
	
run;

proc sort data=out.orders;
	by Product_id;
	
run;

data out.ProductSales;
	set out.orders;
	where Product_id ne '.';    
	by Product_id;
	if first.Product_id then Quantity =0;
	Quantity + Quatity;
	if last.Product_id;
	keep Product_id Quantity;
run;

proc sort data=out.ProductSales;
	by descending Quantity;
run;

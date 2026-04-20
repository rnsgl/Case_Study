proc sort data=out.orders;
	by Product_id;
run;

proc sort data=out.productdetails;
	by Product_id;
run;

data out.ordersLine;
	merge out.orders out.productdetails;
	by Product_id;
run

proc sort data=out.orders;
	by Product_id;
run;

proc sort data=out.productdetails;
	by Product_id;
run;

data out.ordersValidated;
	merge out.orders(in=left) out.productdetails (in=right);
	by Product_id;
	if left;
	if right;
run;

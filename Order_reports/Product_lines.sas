/*proc sort data=out.orders;
	by Product_id;
run;

proc sort data=out.productdetails;
	by Product_id;
run;

data out.ordersLine;
	merge out.orders out.productdetails;
	by Product_id;
run; */

data out.ordersLine;

	set out.orders;
	length
		Product_Group $50
		Product_category $50
		Product_line $50;

	if _N_ = 1 then do;
		declare hash h(dataset: "out.productdetails");
		h.definekey('Product_id');
		h.definedata('Product_name');
		h.definedata('Product_Group');
		h.definedata('Product_category');
		h.definedata('Product_line');
		h.definedone();
	end;

	rc = h.find();
	if rc = 0 then output;
run;

data out.ordersLine;
	set out.ordersLine;
	where not missing(Product_line) and not missing(Order_ID) ;
run;

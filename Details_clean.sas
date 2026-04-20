data out.orderDetails;
	set out.orders;
	order_details = tranwrd(order_details,':','');
	order_details = tranwrd(order_details,',','');
	Product_id = Scan(order_details,8,'"');
	Quatity = Scan(order_details,8,' ');
	CostPrice_per_unit = Scan(order_details,12,' ');
	Total_retail_price = Scan(order_details,16, ' ');
	Total_retail_price = tranwrd(Total_retail_price, ']','');
	Total_retail_price = tranwrd(Total_retail_price, '}','');
run;

data out.suplierDetails;
	set out.products(keep=Supplier);
	Name = Scan(Supplier, 8, '"');
	Country = Scan(Supplier, 16, '"');
	Suplier_ID = Scan(Supplier, 24, '"');
	drop Supplier;
run;

data out.ProductDetails;
	set out.products(keep=Product);
	Product_name = Scan(Product, 6, '"');
	Product_Group = Scan(Product, 12, '"');
	Product_category = Scan(Product, 18, '"');
	Product_line = Scan(Product, 24, '"');
	Product_id = Scan(Product, 30, '"');
	drop Product;
run;

data out.jobs;
	set out.organization(keep=Job);
	division= Scan(Job, 6, '"');
	sub_division = Scan(Job, 12, '"');
	department = Scan(Job, 18, '"');
	group = Scan(Job, 24, '"');
	job_role = Scan(Job, 30, '"');
	 
	drop Job;
run;

data out.ManagerHierarchy;
	set out.organization(keep=Manager_Hierarchy);
	Employee_id = Scan(Manager_Hierarchy, 6, '"');
	Superior = Scan(Manager_Hierarchy, 12, '"');
	drop Manager_Hierarchy;
run;

data out.orders;
	merge out.orders out.orderdetails;
	drop order_details;
run;

data out.product_cleaned;
	merge out.productdetails (keep=Product_id Product_name) out.suplierdetails (keep=Suplier_ID);
run;

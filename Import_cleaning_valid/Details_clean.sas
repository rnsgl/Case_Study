data out.orderDetails;
	set out.orders;
	where Quatity ne '3000';
	order_details = tranwrd(order_details,':','');
	order_details = tranwrd(order_details,',','');
	Product_id = Scan(order_details,8,'"');
	Quatity = Scan(order_details,8,' ');
	CostPrice_per_unit = Scan(order_details,12,' ');
	Total_retail_price = Scan(order_details,16, ' ');
	Total_retail_price = tranwrd(Total_retail_price, ']','');
	Total_retail_price = tranwrd(Total_retail_price, '}','');
run;

proc sort data=out.orderDetails;
	by descending Quatity;
run;

data out.suplierDetails;
	set out.products(keep=Supplier);

	do i=4 to 20 by 8;
		if scan(Supplier, i, '"') = 'Name' then
			Name = scan(Supplier, i+4, '"');

		if scan(Supplier, i, '"') = 'Country' then
			Country = Scan(Supplier, i+4, '"');

		if scan(Supplier, i, '"') = 'ID' then
			Suplier_ID = Scan(Supplier, i+4, '"');
	end;

	drop Supplier;
run;

data out.ProductDetails;
	set out.products(keep=Product);

	do i= 3 to 27 by 3;
		if  scan(Product, i, '"') = ':1,' then
			Product_name = Scan(Product, i+3, '"');

		if scan(Product, i, '"') = ':2,' then
			Product_Group = Scan(Product, i+3, '"');

		if scan(Product, i, '"') = ':3,' then
			Product_category = Scan(Product, i+3, '"');

		if scan(Product, i, '"') = ':4,' then
			Product_line = Scan(Product, i+3, '"');

		if scan(Product, i, '"') = ':5,' then
			Product_id = Scan(Product, i+3, '"');
	end;

	drop Product i;
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
	where Quatity ne '3000';
	Customer_type = tranwrd(Customer_type, '  ', ' ');
	length Customer_Activity $30;

	if Name = 'L\u00fcna sastreria S.A.' then Name = 'Lüna sastreria S.A.';
	
	if index(Customer_type, 'medium activity')>0  than do;
	Customer_Activity = 'Medium activity' ;
	Customer_type=tranwrd(Customer_type,'medium activity','');
	end;
	
	else if index(Customer_type, 'high activity')>0  than do;
	Customer_Activity = 'High activity';
	Customer_type=tranwrd(Customer_type,'high activity','');
	end;
	else if  index(Customer_type, 'low activity')>0 than do;
	Customer_Activity = 'Low activity';
	Customer_type=tranwrd(Customer_type,'low activity','');
	end;
	else if index(Customer_type, 'Internet')>0 than do;
		Customer_Activity = 'Not applicable';
	end;
	
	else if index(Customer_type, 'high activity')>0  than do;
	Customer_Activity = 'High activity';
	Customer_type=tranwrd(Customer_type,'high activity','');
	end;
	else if  index(Customer_type, 'low activity')>0 than do;
	Customer_Activity = 'Low activity';
	Customer_type=tranwrd(Customer_type,'low activity','');
	end;
	else Customer_Activity = 'Not available';
run;

data out.product_cleaned;
	merge out.productdetails (keep=Product_id Product_name) out.suplierdetails (keep=Suplier_ID);
run;

proc sort data=out.product_cleaned;
	by Suplier_ID;
run;

proc sort data=out.suplierdetails;
	by Suplier_ID;
run;

data out.product_with_suppliername;
	merge out.product_cleaned out.suplierdetails;
	by Suplier_ID;
run;

proc sort data=out.orders;
	by Product_id;
run;

proc sort data=out.product_with_suppliername;
	by Product_id;
run;

data out.orders;
	merge out.product_with_suppliername out.orders;
	by Product_id;
run;

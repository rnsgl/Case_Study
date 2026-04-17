data out.orderDetails;
	set out.orders(keep=order_details);
	order_details = tranwrd(order_details,':','');
	order_details = tranwrd(order_details,',','');
	Product_id = Scan(order_details,8,'"');
	Quatity = Scan(order_details,8,' ');
	CostPrice_per_unit = Scan(order_details,12,' ');
	Total_retail_price = Scan(order_details,16, ' ');
	Total_retail_price = tranwrd(Total_retail_price, ']','');
	Total_retail_price = tranwrd(Total_retail_price, '}','');
	drop order_details;
run;


data out.suplierDetails;
	set out.products(keep=Supplier);
	Name = Scan(Supplier, 8, '"');
	Country = Scan(Supplier, 16, '"'); 
	ID = Scan(Supplier, 24, '"'); 
	drop Supplier;
run;

data out.ProductDetails;
	set out.products(keep=Product);
	Product_name = Scan(Product, 6, '"');
	
	drop Product;
run;

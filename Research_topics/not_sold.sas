
title1 "Products not sold in not-customized form";
proc sql;
CREATE TABLE out.Products_not_sold as 
	SELECT Product_id, Product_name,Product_Group, Product_category, Product_line
	FROM out.productdetails
	WHERE Product_id not in (SELECT a.Product_id
	FROM out.product_cleaned a
	INNER JOIN out.orderdetails b
	ON a.product_id = b.product_id);
quit;


proc freq data=out.Products_not_sold order=freq;
	tables Product_Group Product_category Product_line /nocum;
run;

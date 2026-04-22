%let productCategory = Children Sports;
%let SecontProdutctCategory = Shoes;


proc sql;
	CREATE TABLE out.Filter_Order as
		SELECT a.Product_id, a.Order_ID, a.Customer_Name, input(a.CostPrice_per_unit,best.) * input(a.Quatity,best.) as Total_price, a.Order_Date,  b.Product_category
		FROM out.orderdetails as a
		LEFT JOIN out.productdetails as b
		on a.Product_id = b.product_id
		WHERE b.Product_category LIKE "&productCategory" or b.Product_category LIKE "&SecontProdutctCategory";
quit;

/* ====================================================================== */
/* NOT SOLD PRODUCTS REPORT - SAS Analysis Program                        */
/* Purpose: Identify products that have never been sold in their          */
/*          standard/non-customized form and analyze distribution         */
/* ====================================================================== */

/* ====================================================================== */
/* SECTION 1: CREATE NOT SOLD PRODUCTS TABLE                              */
/* ====================================================================== */

title1 "Products not sold in not-customized form";

/* Create table of products that exist in product details but have */
/* no corresponding orders in the order history                    */
proc sql;
	CREATE TABLE out.Products_not_sold as 
	SELECT Product_id,      /* Product identifier */
		   Product_name,    /* Product name */
		   Product_Group,   /* Product group classification */
		   Product_category,/* Product category */
		   Product_line     /* Product line */
	FROM out.productdetails
	/* Find products NOT in the cleaned product/order join */
	WHERE Product_id not in (
		SELECT a.Product_id
		FROM out.product_cleaned a
		INNER JOIN out.orderdetails b
		ON a.product_id = b.product_id
	);
quit;

/* ====================================================================== */
/* SECTION 2: ANALYZE DISTRIBUTION OF NOT SOLD PRODUCTS                  */
/* ====================================================================== */

/* Generate frequency distribution of products not sold */
/* Breaks down by Product Group, Category, and Product Line */
proc freq data=out.Products_not_sold order=freq;
	tables Product_Group Product_category Product_line /nocum;
run;

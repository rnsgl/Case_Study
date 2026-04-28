/* ====================================================================== */
/* FILTER ORDER REPORT - SAS Analysis Program                             */
/* Purpose: Filter orders by specific product categories (Children Sports */
/*          and Shoes) and create a detailed order summary table          */
/* ====================================================================== */

/* Define macro variables for product category filtering */
%let productCategory = Children Sports;      /* Primary product category */
%let SecontProdutctCategory = Shoes;         /* Secondary product category */

/* ====================================================================== */
/* SECTION 1: CREATE FILTERED ORDER DATASET                              */
/* ====================================================================== */

/* Create filtered table with orders matching specific product categories */
/* Joins order details with product details to filter by category        */
proc sql;
	CREATE TABLE out.Filter_Order as
		SELECT a.Product_id,                                    /* Product identifier */
			   a.Order_ID,                                      /* Order identifier */
			   a.Customer_Name,                                 /* Customer name */
			   input(a.CostPrice_per_unit,best.) * 
			   input(a.Quatity,best.) as Total_price,          /* Total price = unit cost * quantity */
			   a.Order_Date,                                    /* Order date */
			   b.Product_category                               /* Product category from product table */
			FROM out.orderdetails as a
			LEFT JOIN out.productdetails as b
				on a.Product_id = b.product_id
			WHERE b.Product_category LIKE "&productCategory" 
				or b.Product_category LIKE "&SecontProdutctCategory";
quit;

proc sql outobs=5;
	SELECT Product_id,Count(Quatity) AS Quantity
	FROM out.orders
	Group by Product_id
	ORDER BY Quantity DESC;
quit;

proc sql outobs=3;
	SELECT Product_line,Count(Quatity) AS Quantity
	FROM out.ordersLine
	Group by Product_line
	ORDER BY Quantity DESC;
quit;

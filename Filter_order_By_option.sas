%let option = customer ;
%let country = "US", "AU";

data out.OrderDetailsReport;
	set out.purchase_by_age_group;
	%if "&option" = "customer" %then %do;
		keep Customer_Country Age_Group Customer_Type Customer_Activity;
	%end;

	%if "&option" = "product" %then %do;
		keep Product_line Product_category Product_Group Product_name;
	%end;

	
	%if "&option" = "financial" %then %do;
			keep Total_retail_price Quatity;
	%end;

	%if "&country" ne "" %then %do;
		where Customer_Country in (&country);
	%end;

run;

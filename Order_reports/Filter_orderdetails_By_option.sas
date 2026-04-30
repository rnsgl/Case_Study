ods pdf file="/home/student/report_filter.pdf";


ods graphics on;


%let option = customer ;
%let country = "US", "AU";




data out.OrderDetailsReport;
	set out.purchase_by_age_group;
	%if "&option" = "customer" %then %do;
		keep Customer_Country Age_Group Customer_Type Customer_Activity;
		array PanelBy(*) $ Customer_Country Age_Group Customer_Type Customer_Activity;
	%end;	

	%if "&option" = "product" %then %do;
		keep Product_line Product_category Product_Group Product_name;
		array PanelBy(*) $ Product_line Product_category Product_Group Product_name;
	%end;

	
	%if "&option" = "financial" %then %do;
			keep Total_retail_price Quatity;
			array PanelBy(2) Total_retail_price Quatity;
	%end;

	%if &country ne "" %then %do;
		where Customer_Country in (&country);

	%end;

run;

%macro make_graphs(panelBy);

	proc sgpanel data=out.OrderDetailsReport;
		panelby &panelBy;
		Hbar Customer_Country ;
	run;

%mend make_graphs;


%macro make_Allgraphs();

	%do i=1 %to dim(PanelBy);
		proc sgpanel data=out.OrderDetailsReport;
			panelby PanelBy(i);
			Hbar Customer_Country ;
		run;
	%end

%mend make_Allgraphs;


%make_Allgraphs;




ods graphics off;
ods pdf close;




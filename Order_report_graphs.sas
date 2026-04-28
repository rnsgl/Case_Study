
ods pdf file="/home/student/report.pdf";
%put &=sysuserid;

ods graphics on;
%let by = Customer_Type;
%let target = Product_line;

proc sgplot data=out.Line_By_Quantity;
	vbar Product_line/ response=Quantity;
run;

proc sgplot data=out.Line_By_Quantity;
	vbar Product_line/ response=Revenue;
run;

proc sgpanel data=out.most_Line_&by;	
	panelby &by;
	Hbar Product_line / response = Quantity;
run;

proc sgpanel data=out.Final_report_&by;	
	panelby &by;
	Hbar Product_line / response = Quantity;
run;

ods graphics off;
ods pdf close;

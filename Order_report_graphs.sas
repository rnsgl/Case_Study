/* ====================================================================== */
/* ORDER REPORT GRAPHS - SAS Visualization Program                        */
/* Purpose: Generate PDF report with visualizations of product sales      */
/*          data including bar charts and panel charts by customer type   */
/* ====================================================================== */

/* ====================================================================== */
/* SECTION 1: PDF OUTPUT SETUP                                            */
/* ====================================================================== */

/* Open PDF output file for generating report */
ods pdf file="/home/student/report.pdf";

/* Display SAS user ID in the log */
%put &=sysuserid;

/* Enable ODS Graphics for high-resolution chart production */
ods graphics on;

/* ====================================================================== */
/* SECTION 2: DEFINE MACRO VARIABLES                                      */
/* ====================================================================== */

/* Define macro variables for chart segmentation */
%let by = Customer_Type;      /* Variable used to segment panel charts */
%let target = Product_line;   /* Target dimension for analysis */

/* ====================================================================== */
/* SECTION 3: PRODUCT LINE QUANTITY CHART                                */
/* ====================================================================== */

/* Create vertical bar chart showing quantity by product line */
proc sgplot data=out.Line_By_Quantity;
	vbar Product_line/ response=Quantity;
run;

/* ====================================================================== */
/* SECTION 4: PRODUCT LINE REVENUE CHART                                  */
/* ====================================================================== */

/* Create vertical bar chart showing revenue by product line */
proc sgplot data=out.Line_By_Quantity;
	vbar Product_line/ response=Revenue;
run;

/* ====================================================================== */
/* SECTION 5: QUANTITY BY CUSTOMER TYPE PANEL CHART                      */
/* ====================================================================== */

/* Create horizontal bar chart paneled by customer type */
/* Displays quantity for each product line within each customer type */
proc sgpanel data=out.most_Line_&by;	
	panelby &by;
	Hbar Product_line / response = Quantity;
run;

/* ====================================================================== */
/* SECTION 6: FINAL REPORT BY CUSTOMER TYPE PANEL CHART                  */
/* ====================================================================== */

/* Create horizontal bar chart paneled by customer type from final report */
/* Shows filtered and aggregated quantity metrics */
proc sgpanel data=out.Final_report_&by;	
	panelby &by;
	Hbar Product_line / response = Quantity;
run;

/* ====================================================================== */
/* SECTION 7: CLOSE OUTPUT                                                */
/* ====================================================================== */

/* Disable ODS Graphics after chart generation */
ods graphics off;

/* Close PDF output file */
ods pdf close;

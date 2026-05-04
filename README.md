# Case_Study

This readme explains the contains of each program and how to run them. 

You should run them by the following order:

Import_to_tables.sas -> Details_clean.sas -> Validating_data.sas

Here is the content of every program:

Import_to_tables.sas: Imports all the data to multiple sas tables. Also inicializes the out librabry.

Details_clean.sas: This is where all the data cleaning and transformations were made.

Validating_data.sas: All the data validation required is here.

Order reports:

Product_lines.sas -> Order_reports.sas -> (Filter_order_Report.sas|Filter_orderDetails_by_option.sas|Order_report_graphs.sas)

Product_lines.sas: Merge of the tables order and orderDetail to help with report (specifically the most frequently purchased product line report).

Order_reports.sas: This is where all the order reports tables are made. Also, there are tables made here that are used in other scripts.

Filter_Order_Report.sas: Reports with one or two categories selected.

Filter_orderDetails_by_option.sas: Report order details by option and country.





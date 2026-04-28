/*age of customers*/
data work.orders_age;
    set out.orders;
    BirthDate = input(Customer_BirthDate, date9.);
    format BirthDate date9.;
    Age = intck('year', BirthDate, today(), 'c');
run;


/*customer age group*/
proc format;
    value agegrp_fmt
        low - <18   = 'Under 18'
        18  - 24    = '18-24'
        25  - 34    = '25-34'
        35  - 44    = '35-44'
        45  - 54    = '45-54'
        55  - 64    = '55-64'
        65  - high  = '65+';
run;



/*  Tirar lista única de produtos vendidos */
proc sort data=out.orderdetails(keep=Product_ID)
          out=work.sold_products
          nodupkey;
    by Product_ID;
run;

/*  Ordenar tabela de produtos */
proc sort data=out.productdetails
          out=work.all_products;
    by Product_ID;
run;

/*Encontrar produtos não vendidos */
data out.unsold_products_report;
    merge work.all_products(in=a)
          work.sold_products(in=b);
    by Product_ID;

    if a and not b;
run;

/* Ordenar o report de forma mais apropriada */
proc sort data=out.unsold_products_report;
    by Product_Group Product_Category Product_Line Product_Name;
run;

/*graph of unsold products by product group*/
proc sgplot data=out.unsold_products_report;
    vbar Product_Group / stat=freq;
    title "Unsold Products by Product Group";
run;

/*graph of unsold products by category*/
proc sgplot data=out.unsold_products_report;
    vbar Product_Category / stat=freq;
    title "Unsold Products by Category";
run;

/*graph of unsold products by product line*/
proc sgplot data=out.unsold_products_report;
    vbar Product_Line / stat=freq;
    title "Unsold Products by Product Line";
run;

/*graph of unsold products by group and category*/
proc sgplot data=out.unsold_products_report;
    vbar Product_Group / group=Product_Category groupdisplay=cluster;
    title "Unsold Products by Group and Category";
run;

ods pdf file="/home/&sysuserid/unsold_products_reportRT.pdf" style=journal;

title "Unsold Products Report";

proc report data=out.unsold_products_report nowd
    style(report)={background=cxF2F2F2}
    style(header)={background=cx5B9BD5 foreground=white fontweight=bold}
    style(column)={background=white};
    columns Product_Group Product_Category Product_Line Product_Name;
    compute Product_Group;
        if Product_Group = 'Electronics' then
            call define(_row_, 'style', 'style={background=lightblue}');
    endcomp;
run;

/*table of customers by age group*/
title "Customers by Age Group";

proc report data=work.orders_age nowd
    style(report)={background=cxF2F2F2}
    style(header)={background=cx5B9BD5 foreground=white fontweight=bold}
    style(column)={background=white};

    columns Customer_ID Age;

    define Customer_ID / display "Customer ID";
    define Age / display format=agegrp_fmt. "Customer Age Group";
run;

/*graph of customer by age group*/
proc sgplot data=work.orders_age;
    vbar Age / stat=freq;
    format Age agegrp_fmt.;
    title "Customers by Age Group";
run;

ods pdf close;
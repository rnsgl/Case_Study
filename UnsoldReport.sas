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



proc sgplot data=out.unsold_products_report;
    vbar Product_Group / stat=freq;
    title "Unsold Products by Product Group";
run;

proc sgplot data=out.unsold_products_report;
    vbar Product_Category / stat=freq;
    title "Unsold Products by Category";
run;

proc sgplot data=out.unsold_products_report;
    vbar Product_Line / stat=freq;
    title "Unsold Products by Product Line";
run;

proc sgplot data=out.unsold_products_report;
    vbar Product_Group / group=Product_Category groupdisplay=cluster;
    title "Unsold Products by Group and Category";
run;

ods pdf file="/home/&sysuserid/unsold_products_report.pdf";

title "Unsold Products Report";

/* Tabela */
proc report data=out.unsold_products_report;
run;

/* Gráfico 1 */
proc sgplot data=out.unsold_products_report;
    vbar Product_Group / stat=freq;
    title "Unsold Products by Product Group";
run;

/* Gráfico 2 */
proc sgplot data=out.unsold_products_report;
    vbar Product_Category / stat=freq;
    title "Unsold Products by Category";
run;

/* Gráfico 3 */
proc sgplot data=out.unsold_products_report;
    vbar Product_Line / stat=freq;
    title "Unsold Products by Product Line";
run;

/* Gráfico 4 */
proc sgplot data=out.unsold_products_report;
    vbar Product_Group / group=Product_Category groupdisplay=cluster;
    title "Unsold Products by Group and Category";
run;

ods pdf close;
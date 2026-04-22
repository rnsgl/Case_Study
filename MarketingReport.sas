data out.marketing_campaign_report;
    set out.orders;

    length First_Name $20 Last_Name $20 Salutation $30 Birth_Month $15;
    
    /* Separar primeiro e último nome */
    First_Name = scan(Customer_Name, 1, ' ');
    Last_Name  = scan(Customer_Name, -1, ' ');

    /* Criar saudação com base no género */
    if upcase(strip(Customer_Gender)) = 'M' then
        Salutation = cats('Mr. ', Last_Name);
    else if upcase(strip(Customer_Gender)) = 'F' then
        Salutation = cats('Ms. ', Last_Name);
    else
        Salutation = cats('Dear ', First_Name);

    /* Converter data de nascimento para data */
    BirthDate_SAS = input(Customer_BirthDate, date9.);
    format BirthDate_SAS date9.;

    /* Extrair mês de nascimento */
    Birth_Month = put(BirthDate_SAS, monname.);

    keep Customer_ID First_Name Last_Name Customer_Gender Salutation Birth_Month;
run;

proc report data=out.marketing_campaign_report;
run;

proc sgplot data=out.marketing_campaign_report;
    vbar Birth_Month / stat=freq;
    title "Customers by Birth Month";
run;

proc sgplot data=out.marketing_campaign_report;
    vbar Customer_Gender / stat=freq;
    title "Customer Distribution by Gender";
run;

proc sgplot data=out.marketing_campaign_report;
    vbar Birth_Month / group=Customer_Gender groupdisplay=cluster;
    title "Customers by Birth Month and Gender";
run;

ods pdf file="/home/&sysuserid/marketing_report.pdf";

title "Marketing Campaign Report";

proc report data=out.marketing_campaign_report;
run;

/* Gráfico 1 */
proc sgplot data=out.marketing_campaign_report;
    vbar Birth_Month / stat=freq;
    title "Customers by Birth Month";
run;

/* Gráfico 2 */
proc sgplot data=out.marketing_campaign_report;
    vbar Customer_Gender / stat=freq;
    title "Customer Distribution by Gender";
run;

/* Gráfico 3 */
proc sgplot data=out.marketing_campaign_report;
    vbar Birth_Month / group=Customer_Gender groupdisplay=cluster;
    title "Customers by Birth Month and Gender";
run;

ods pdf close;
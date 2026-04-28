title "Top 5 Sellers - Total Sales and Bonus";
footnote "Report generated on &SYSDATE9 at &SYSTIME by &SYSUSERID.";

proc print data=out.Top5_Sellers_Bonus label noobs;
    var Employee_ID Total_Sales Bonus;

    label 
        Employee_ID = "Employee ID"
        Total_Sales = "Total Sales (€)"
        Bonus       = "5% Bonus (€)";
run;

title;
footnote;

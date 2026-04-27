*tabela só com vendedores;
proc sort data=out.orders;
   by Employee_ID;
run;

proc sort data=out.organization;
   by Employee_ID;
run;

data out.ambos;
   merge out.orders(in=a)
         out.organization(in=b);
   by Employee_ID;
   if a and b;
run;

*extração da hierarquia dos managers;
data out.Employee_Superiors;
    set out.ambos(keep=Employee_ID Manager_Hierarchy);

    length Direct_Manager_ID
           Indirect_Manager1_ID
           Indirect_Manager2_ID
           Indirect_Manager3_ID 8;

    do i = 1 to countw(Manager_Hierarchy, '"');

        if scan(Manager_Hierarchy, i, '"') = 'level' then do;

            level = scan(Manager_Hierarchy, i+1, '"');
            manager_id = input(scan(Manager_Hierarchy, i+4, '"'), best12.);

            if level = ":1," then Direct_Manager_ID = manager_id;
            else if level = ":2," then Indirect_Manager1_ID = manager_id;
            else if level = ":3," then Indirect_Manager2_ID = manager_id;
            else if level = ":4," then Indirect_Manager3_ID = manager_id;

        end;
    end;

    drop i level manager_id Manager_Hierarchy;
run;

*extrair informação do role;
data out.jobs_Employee;
    set out.ambos(keep=Employee_ID Job);

    division     = scan(Job, 6, '"');
    sub_division = scan(Job, 12, '"');
    department   = scan(Job, 18, '"');
    group        = scan(Job, 24, '"');
    job_role     = scan(Job, 30, '"');

    drop Job;
run;

*merge da hierarquia com detalhes do role;
proc sort data=out.Employee_Superiors;
    by Employee_ID;
run;

proc sort data=out.jobs_Employee;
    by Employee_ID;
run;

data out.Employee_Superiors_Jobs;
    merge out.Employee_Superiors(in=a)
          out.jobs_Employee(in=b);
    by Employee_ID;
    if a and b;
run;

*tabela com nomes dos managers diretos indiretos + info do role;
proc sql;
    create table out.Employee_Jobs_Superior_Final as
    select 
        e.Employee_ID,
        e.division,
        e.sub_division,
        e.department,
        e.group,
        e.job_role,

        d.Employee_Name  as Direct_Manager_Name,
        i1.Employee_Name as Indirect_Manager1_Name,
        i2.Employee_Name as Indirect_Manager2_Name,
        i3.Employee_Name as Indirect_Manager3_Name

    from out.Employee_Superiors_Jobs e

    left join out.organization d
        on e.Direct_Manager_ID = d.Employee_ID

    left join out.organization i1
        on e.Indirect_Manager1_ID = i1.Employee_ID

    left join out.organization i2
        on e.Indirect_Manager2_ID = i2.Employee_ID

    left join out.organization i3
        on e.Indirect_Manager3_ID = i3.Employee_ID
    ;
quit;

*Total_retail_price passa a numérico;
data out.orderdetails_num;
    set out.orderdetails;

    Total_retail_price_num = input(Total_retail_price, comma12.);
    drop Total_retail_price;
    rename Total_retail_price_num = Total_retail_price;
run;

*Total de vendas por vendedor;
proc sql;
    create table out.Sales_By_Employee as
    select
        o.Employee_ID,
        sum(o.Total_retail_price) as Total_Sales format=comma12.2
    from out.orderdetails_num o
    inner join out.ambos a
        on o.Employee_ID = a.Employee_ID
    group by o.Employee_ID;
quit;

*Top 5 sellers;
proc sort data=out.Sales_By_Employee
          out=out.Top5_Sellers;
    by descending Total_Sales;
run;

data out.Top5_Sellers;
    set out.Top5_Sellers(obs=5);
run;


*Calcular bonus;
proc sql;
    create table out.Top5_Sellers_Bonus as
    select
        Employee_ID,
        Total_Sales,
        Total_Sales * 0.05 as Bonus format=comma12.2
    from out.Top5_Sellers;
quit;


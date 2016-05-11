--Momodou Lamin Keita
--Database Test 3
-----------------------------------------------------------------------------
--Question 1
select departments.department_name as "Department Name",
max(employees.salary) as MaxSalary
from employees
inner join departments on Departments.Department_Id = employees.department_id
group by departments.department_name
order by MaxSalary desc;

--Question 2
select distinct E.Employee_Id  as EmployeeID,
e.first_name as firstName,
e.last_name as LastName,
E.First_Name || ' ' || E.Last_Name as ManagerName
from EMPLOYEES e
inner join Job_History JobHis on E.Employee_Id = Jobhis.Employee_Id
inner join EMPLOYEES m on m.EMPLOYEE_ID = e.MANAGER_ID
order by LastName;

--Question 3
select  Departments.Department_name  as "Department Name",
round(Coalesce(avg(employees.salary),0),2) as AverageSalary
from Departments
left join employees on Departments.Department_Id = Employees.Department_Id
group by Departments.Department_name
order by AverageSalary desc,Departments.Department_name asc ;

--Question 4
SELECT Regions.Region_Name as REGION_NAME,
COUNT(employees.employee_id) AS EMPLOYEE_TOTAL
FROM regions
LEFT JOIN countries ON Regions.Region_Id = Countries.Region_Id
LEFT JOIN locations ON Locations.Country_Id = Countries.Country_Id
LEFT JOIN departments ON Locations.Location_Id = Departments.Location_Id
LEFT JOIN employees ON Employees.Department_Id = Departments.Department_Id
GROUP BY Regions.Region_Name
ORDER BY EMPLOYEE_TOTAL DESC;

--Question 5
select employees.employee_id as Employee_ID,
employees.first_name as FirstName,
employees.last_name as LastName,
Departments.department_name as DepartmentName,
employees.salary as Salary
from Employees
inner join departments on Departments.Department_Id = Employees.Department_Id
where Departments.department_name = 'Sales'and employees.salary > (
select avg(employees.salary)
from employees
inner join departments on Departments.Department_Id = Employees.Department_Id
where Departments.department_name = 'Sales')
order by employees.salary desc,employees.last_name asc  ;

--Bonus 1
SELECT NVL( Regions.Region_Name,'(NO REGION Assigned)') as REGION_NAME,
COUNT(employees.employee_id) AS EMPLOYEE_TOTAL
FROM regions
LEFT JOIN countries ON Regions.Region_Id = Countries.Region_Id
LEFT JOIN locations ON Locations.Country_Id = Countries.Country_Id
LEFT JOIN departments ON Locations.Location_Id = Departments.Location_Id
FULL OUTER JOIN employees ON Employees.Department_Id = Departments.Department_Id
GROUP BY Regions.Region_Name
ORDER BY EMPLOYEE_TOTAL DESC;

--Bonus 2
select  Departments.Department_name  as "Department Name",
TO_CHAR(round(Coalesce(avg(employees.salary),0),2) ,'$999,999.00') as AverageSalary
from Departments
left join employees on Departments.Department_Id = Employees.Department_Id
group by Departments.Department_name
order by AverageSalary desc,Departments.Department_name asc ;


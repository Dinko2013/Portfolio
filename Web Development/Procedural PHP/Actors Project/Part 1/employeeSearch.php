<?php
    // Let's simulate a slow page load from the Server
    //sleep(2);

    $searchValue = "";

    if(!empty($_GET['q']))
    {
        $searchValue = $_GET['q'];

        include("dbConn.php");

        connectToDB();

        selectEmployees($searchValue);
?>
<table class="bordered">
    <thead>
    <tr>
        <th>Employee ID</th>
        <th>Employee DOB</th>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Gender</th>
        <th>Hire Date</th>
    </tr>
    </thead>
    <tbody>
<?php


        while ($row = fetchFilms())
        {
            ?>

    <tr>
    <td><?php echo $row['emp_no']?></td>
    <td><?php echo $row['birth_date']?></td>
    <td><?php echo $row['first_name']?></td>
    <td><?php echo $row['last_name']?></td>
    <td><?php echo $row['gender']?></td>
    <td><?php echo $row['hire_date']?></td>
    </tr>
<?php
        }
        closeDB();
    }
?>

<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/11/15
* Time: 4:13 PM
*/
require('includes/authentication.php');
require("includes/header.php");
$search = $_POST['search'];
?>
<div class="row" align="center">
<div class="col s4 offset-s4"
<form name="search" method="post" action="handleSearch.php">
    <div class="row">
        <input id="search" type="text" name="search" value="<?php echo $search?>">
        <label for="search">Search:</label>
    </div>
    <div class="row" align="center">
    <button class="btn waves-effect waves-light btn-large" type="submit" name="action">Search
    </button>
    </div>
</form>
</div>
</div>
<div class="container" >
<div class="col s12">
    <table class="bordered">
        <thead>
        <tr>
            <th>Employee ID</th>
            <th>Employee DOB</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Gender</th>
            <th>Hire Date</th>
            <th>Update</th>
            <th>Delete</th>
        </tr>
        </thead>
        <tbody>

        <?php

        $sqlQuery = "SELECT * FROM employees where first_name like '%$search%' or last_name like '%$search%' limit 0,25";
        $queryResult = mysqli_query($con,$sqlQuery);

        if(!$queryResult)
        {
            die('Could not retrieve records from the Employees Table: ' . mysqli_connect_error());
        }
        while ($row = mysqli_fetch_assoc($queryResult))
        {
            ?>
            <tr>

                <td><?php echo $row['emp_no']?></td>
                <td><?php echo $row['birth_date']?></td>
                <td><?php echo $row['first_name']?></td>
                <td><?php echo $row['last_name']?></td>
                <td><?php echo $row['gender']?></td>
                <td><?php echo $row['hire_date']?></td>
                <?php
                $emp=$row['emp_no'];
                $level =  $_SESSION['SESS_LEVEL_PERM'];
                if ($level == "1")
                {
                    echo "<td><form method='post'action='update.php' >
                            <input type='hidden' name='update_ID' value='$emp' />
                            <button class='btn-floating waves-effect waves-light yellow' type='submit'>
                            <i class='material-icons'>swap_vertical_circle</i>
                        </button>
                            </form>
                    </td>
                    <td>
                        <form method='post' action='delete.php'>
                            <input type='hidden' name='delete_ID' value='$emp' />
                            <button class='btn-floating waves-effect waves-light red' type='submit'>
                                <i class='material-icons'>delete</i>
                                </button>
                        </form>
                    </td>";
                }
                else  if ($level == "2")
                {
                    echo "<td><form method='post'action='update.php' >
                            <input type='hidden' name='update_ID' value='$emp' />
                            <button class='btn-floating waves-effect waves-light yellow' type='submit'>
                            <i class='material-icons'>swap_vertical_circle</i>
                        </button>
                            </form>
                    </td>";
                }
                ?>
            </tr>
        <?php
        }
        ?>

        </tbody>
    </table>
    </div>
    </div>
    <div class='fixed-action-btn' style='bottom: 25px; right: 10px;'>
                     <a class='btn-floating btn-large green' href='home.php'>
                    <i class='large material-icons'>home</i>
                    </a>
                    </div>
       <?php
require("includes/footer.php");
?>
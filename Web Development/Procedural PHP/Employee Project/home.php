<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/10/15
* Time: 1:48 PM
*/

require('includes/authentication.php');
require('includes/header.php');
$query = "SELECT COUNT(*) as num FROM employees";
$total_pages = mysqli_fetch_array(mysqli_query($con,$query));
$total_pages = $total_pages[num];
$targetpage = "home.php"; 	//your file name  (the name of this file)
$limit = 25; 								//how many items to show per page
$page = $_GET['page'];
$adjacents = 4;
if($page)
$start = ($page - 1) * $limit; 			//first item to display on this page
else
$start = 0;
/* Setup vars for query. */

?>
<div class="row" >
    <div class="col s9">
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

            $sqlQuery = "SELECT * FROM employees LIMIT  $start,$limit";
            $queryResult = mysqli_query($con,$sqlQuery);
            if(!$queryResult)
            {
                die('Could not retrieve records from the Employees Table: ' . mysqli_connect_error());
            }
            while ($row = mysqli_fetch_assoc($queryResult)) {
                $emp_ID= $row['emp_no'];
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
                    </td>
                    <div class='fixed-action-btn' style='bottom: 25px; right: 10px;'>
                     <a class='btn-floating btn-large green' href='insert.php'>
                    <i class='large material-icons'>open_in_new</i>
                    </a>
                    </div>
";
                        }
                       else  if ($level == "2")
                        {
                            echo "<td><form method='post'action='update.php' >
                            <input type='hidden' name='update_ID' value='$emp' />
                            <button class='btn-floating waves-effect waves-light yellow' type='submit'>
                            <i class='material-icons'>swap_vertical_circle</i>
                        </button>
                            </form>
                    </td>
                    </tr>

                    <div class='fixed-action-btn'>
                    <a class='btn-floating btn-large green' href='insert.php'>
                    <i class='large material-icons'>open_in_new</i>
                    </a>
                    </div>";
                        }
                        ?>


            <?php
            }
            ?>

            </tbody>
        </table>
        <?php
        /* Setup page vars for display. */
        if ($page == 0) $page = 1;					//if no page var is given, default to 1.
        $prev = $page - 1;							//previous page is page - 1
        $next = $page + 1;							//next page is page + 1
        $lastpage = ceil($total_pages/$limit);		//lastpage is = total pages / items per page, rounded up.
        $lpm1 = $lastpage - 1;						//last page minus 1

        /*
        Now we apply our rules and draw the pagination object.
        We're actually saving the code to a variable in case we want to draw it more than once.
        */
        $pagination = "";
        if($lastpage > 1)
        {

        $pagination .= "<ul class='pagination'>";
            //previous button
            if ($page > 1)
            $pagination.= "<li class='active'><a href=\"$targetpage?page=$prev\"></a></li>";
            else
            $pagination.= "<li class='disabled'><a href=\"$targetpage?page=$prev\"><i class='material-icons'>chevron_left</i></a></li>";

            //pages
            if ($lastpage < 7 + ($adjacents * 2))	//not enough pages to bother breaking it up
            {
            for ($counter = 1; $counter <= $lastpage; $counter++)
            {
            if ($counter == $page)
            $pagination.= "<li class='active'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            else

            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            }
            }
            elseif($lastpage > 5 + ($adjacents * 2))	//enough pages to hide some
            {
            //close to beginning; only hide later pages
            if($page < 1 + ($adjacents * 2))
            {
            for ($counter = 1; $counter < 4 + ($adjacents * 2); $counter++)
            {
            if ($counter == $page)
            $pagination.= "<li class='active'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            else
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            }
            $pagination.= "...";
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$lpm1\">$lpm1</a></li>";
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$lastpage\">$lastpage</a></li>";
            }
            //in middle; hide some front and some back
            elseif($lastpage - ($adjacents * 2) > $page && $page > ($adjacents * 2))
            {
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=1\">1</a></li>";
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=2\">2</a></li>";
            $pagination.= "...";
            for ($counter = $page - $adjacents; $counter <= $page + $adjacents; $counter++)
            {
            if ($counter == $page)
            $pagination.= "<li class='active'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            else
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            }
            $pagination.= "...";
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$lpm1\">$lpm1</a></li>";
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$lastpage\">$lastpage</a></li>";
            }
            //close to end; only hide early pages
            else
            {
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=1\">1</a></li>";
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=2\">2</a></li>";
            $pagination.= "...";
            for ($counter = $lastpage - (2 + ($adjacents * 2)); $counter <= $lastpage; $counter++)
            {
            if ($counter == $page)
            $pagination.= "<li class='active'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            else
            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$counter\">$counter</a></li>";
            }
            }
            }

            //next button
            if ($page < $counter - 1)

            $pagination.= "<li class='waves-effect'><a href=\"$targetpage?page=$next\"></a><i class='material-icons'>chevron_right</i></a></li>";
            else
            $pagination.= "<li class='disabled'><a href=''><i class='material-icons'>chevron_left</i></a></li>";
            $pagination.= "</ul>";
            echo "<p align='center'>$pagination</p>";
        }
        ?>
    </div>

        <div class="col s3">
        <p>Welcome User : <em><?php echo $_SESSION['SESS_FIRST_NAME']?></em></p>
        <form name="search" method="post" action="handleSearch.php" onsubmit="return validateSearch()">
            <div class="row">
                <input placeholder="First OR Last Name" id="search" type="text" name="search">
                <label for="search">Search:</label>
            </div>
            <div class="row" align="center">
                <button class="btn waves-effect waves-light btn-large" type="submit" name="action">Search
                </button>
            </div>
        </form>
    </div>
</div>
<?php
require("includes/footer.php");
?>
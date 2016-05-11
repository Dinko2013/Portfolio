<?php
/**
 * Created by PhpStorm.
 * User: inet2005
 * Date: 10/10/15
 * Time: 9:17 PM
 */
require('includes/authentication.php');
require("includes/header.php");
$firstName = $_POST['fn'];
$lastName = $_POST['ln'];
$date  = strtotime($_POST['dob']);
$DOB =date("y-m-d", $date);
$date1= strtotime($_POST['date_hired']);
$hire_date =date("y-m-d", $date1);
$gender =$_POST['gender'];
$sqlQuery = "INSERT INTO employees(birth_date,first_name,last_name,gender,hire_date) VALUES('$DOB','$firstName','$lastName','$gender','$hire_date')";
$queryResult = mysqli_query($con,$sqlQuery);
if(!$queryResult)
{
    die('Could not Insert record into the Actor Table: ' . mysqli_connect_error());
}
?>
<div class="col s12">
<div class="card-panel">
          <span class="black-text">
              <a href="home.php">Back</a>
            </span>
</div>
<?php require("includes/footer.php");?>

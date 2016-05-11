<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/10/15
* Time: 9:59 PM
*/
require('includes/authentication.php');
require("includes/header.php");
$employeeID = $_POST['update_id'];
$firstName = $_POST['fn'];
$lastName = $_POST['ln'];
$hireDate = $_POST['hireDate'];
$DOB = $_POST['DOB'];
$gender = $_POST['gender'];

$sqlQuery = "UPDATE employees SET first_name = '$firstName', last_name = '$lastName' ,birth_date = '$DOB', hire_date = '$hireDate',gender = '$gender' WHERE emp_no = '$employeeID'";
$queryResult = mysqli_query($con,$sqlQuery);
if(!$queryResult)
{
die('Could not Update this Record ' . mysqli_connect_error());
}
?>
<div class="container">
<div class="row">
    <div class="card-panel">
      <span class="black-text">
          <?php
          echo "Successfully Updated: ". mysqli_affected_rows($con)."Record(s)";
          ?>
          <a href="home.php">Back To Employees List</a>
      </span>
    </div>
</div>
</div>
<?php
include('includes/footer.php');
?>
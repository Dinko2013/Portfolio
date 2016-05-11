<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/11/15
* Time: 3:53 PM
*/
require('includes/authentication.php');
require("includes/header.php");
$idToDelete = $_POST['delete_ID'];
$sqlQuery = "DELETE FROM employees WHERE emp_no = '$idToDelete'";
$queryResult = mysqli_query($con,$sqlQuery);
if(!$queryResult)
{
die('Could not Delete this Record ' . mysqli_connect_error());
}
?>
<body>
<div class="container">
<div class="row">
    <div class="card-panel">
      <span class="black-text">
          <?php
          echo "Successfully deleted: ". mysqli_affected_rows($con)."Record(s)";
          ?>
          <a href="home.php">Back To Employees List</a>
      </span>
    </div>
</div>
</div>
<?php
include('includes/footer.php');
?>
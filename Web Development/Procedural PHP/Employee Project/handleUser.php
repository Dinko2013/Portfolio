<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/11/15
* Time: 9:54 PM
*/
require('includes/authentication.php');
require("includes/header.php");
$username = $_POST['Username'];
$firstname = $_POST['fname'];
$lastname  =$_POST['lname'];
$password =hash( 'sha512', $_POST['password']);
$access= $_POST['permission'];

$sqlQuery = "INSERT INTO users(username,first_name,last_name,password,permission) VALUES('$username','$firstname','$lastname','$password','$access')";
$queryResult = mysqli_query($con,$sqlQuery);
if(!$queryResult)
{
die('Could not Insert record into the users Table: ' . mysqli_connect_error());
}
?>
<div class="col s12">
<div class="card-panel">
      <span class="black-text">
          <a href="home.php">Back</a>
        </span>
</div>
<?php require("includes/footer.php");?>
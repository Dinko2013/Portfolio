<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/10/15
* Time: 7:28 PM
*/

require('includes/authentication.php');
include('includes/header.php');
$update_ID = $_POST['update_ID'];
$sqlQuery = "SELECT * FROM employees WHERE emp_no =$update_ID";
$queryResult = mysqli_query($con,$sqlQuery);
if(!$queryResult)
{
die('Could not Find Record: '.mysqli_connect_errno());
}
while ($row = mysqli_fetch_assoc($queryResult))
{
?>

<body>
<div class="container">
<h1>Update Employee Record</h1>
<form name="update" method="post" action="handleUpdate.php" onsubmit="return validateUpdate()">
    <input type="hidden" name="update_id"  value="<?php echo $row['emp_no'];?>" />
    <div class="row">
        <input placeholder="" id="fn" type="text" name="fn" value="<?php echo $row['first_name']; ?>">
        <label for="fn">Employee First Name</label><span id="fsn" style="color: red"> </span>
    </div>
    <div class="row">
        <input placeholder="" id="ln" type="text" name="ln" value="<?php echo $row['last_name']; ?>">
        <label for=" ln">Employee Last Name</label><span id="sln" style="color: red"> </span>
    </div>
    <div class="row">
        <select name="gender" id ="gender">
            <option value="<?php echo $row['gender']; ?>"><?php echo $row['gender']; ?></option>
            <option value="M">Male</option>
            <option value="F">Female</option>
        </select>
        <label>Gender</label><span id="sgender" style="color: red"> </span>
    </div>
    <div class="row">
        <input placeholder="" id="dob" type="text" name="DOB" value="<?php echo $row['birth_date']; ?>">
        <label for="DOB">DOB</label><span id="sdob" style="color: red"></span>
    </div>
    <div class="row">
        <input placeholder="" id="date_hired" type="text" name="hireDate" value="<?php echo $row['hire_date']; ?>">
        <label for=" hireDate">Hire Date</label><span id="sdate_hired" style="color: red"></span>
    </div>
    <div class="row" align="center">
        <button class="btn waves-effect waves-light btn-large" type="submit" name="action">Update
        </button>
    </div>
</form>
<div class="fixed-action-btn" style="bottom: 25px; right: 10px;">
    <a class="btn-floating btn-large green" href="home.php">
        <i class="large material-icons">home</i>
    </a>
</div>
<?php
}
require("includes/footer.php");
?>

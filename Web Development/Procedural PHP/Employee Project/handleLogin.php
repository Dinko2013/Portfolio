<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/11/15
* Time: 10:34 PM
*/
include("includes/header.php");

$username = $_POST['username'];
$password = $_POST['password'];


$username = stripslashes($username);
$password = stripslashes($password);

$username = mysqli_real_escape_string($con,$username);
$password =mysqli_real_escape_string($con,$password);


$hash = hash('sha512',$password);


$sqlQuery = "select * from users where username ='$username' and password ='$hash'";
$queryResult = mysqli_query($con,$sqlQuery);

if($queryResult) {

if(mysqli_num_rows($queryResult) == 1) {
    //Login Successful
    session_regenerate_id();
    $member = mysqli_fetch_assoc($queryResult);
    $_SESSION['SESS_MEMBER_ID'] = $member['user_id'];
    $_SESSION['SESS_FIRST_NAME'] = $member['first_name'];
    $_SESSION['SESS_LAST_NAME'] = $member['last_name'];
    $_SESSION['SESS_USER_LOGIN'] = $member['username'];
    $_SESSION['SESS_LEVEL_PERM'] = $member['permission'];
    session_write_close();
    header("location:home.php");
    exit();
}else {
    //Login failed
    header("location: index.php");
    exit();
}
}else {
die("Query failed");

}
    ?>
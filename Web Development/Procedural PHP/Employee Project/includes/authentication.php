<?php
/**
 * Created by PhpStorm.
 * User: inet2005
 * Date: 10/11/15
 * Time: 11:27 PM
 */
session_start();

//Check whether the session variable SESS_MEMBER_ID is present or not
if(!isset($_SESSION['SESS_MEMBER_ID']) || (trim($_SESSION['SESS_MEMBER_ID']) == '')) {
    header("location: access_denied.php");
    exit();
}
?>
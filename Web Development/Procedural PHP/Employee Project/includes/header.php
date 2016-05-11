<?php
/**
 * Created by PhpStorm.
 * User: inet2005
 * Date: 10/10/15
 * Time: 1:37 PM
 */
session_start();
require("dbconnection.php");
$level =  $_SESSION['SESS_LEVEL_PERM'];
?>
<!DOCTYPE html>
<html>
<head>
    <!--Import Google Icon Font-->
    <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <!--Import materialize.css-->
    <link type="text/css" rel="stylesheet" href="css/materialize.css"  media="screen,projection"/>
    <!--Let browser know website is optimized for mobile-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <script type="text/javascript" src="js/validation.js"></script>
    <title>Assignment 1</title>
</head>
<nav>
    <div class="nav-wrapper">

        <a href="home.php" class="brand-logo">Assignment 1</a>
        <ul id="nav-mobile" class="right hide-on-med-and-down">
            <?php
            if($level==1)
            {
                echo "<li><a href='insert.php'>Add New Record</a></li>";
                echo "<li><a href='addusers.php'>New Account</a></li>";
            }
            if($level==2)
            {
                echo "<li><a href='insert.php'>Add New Record</a></li>";
            }
            ?>
            <li><a href="logout.php">Log out</a></li>

        </ul>
    </div>
</nav>
<body>

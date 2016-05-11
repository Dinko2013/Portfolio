<?php
/**
 * Created by PhpStorm.
 * User: inet2005
 * Date: 10/12/15
 * Time: 12:04 AM
 */
session_start();
session_destroy();
header('location:index.php');
?>
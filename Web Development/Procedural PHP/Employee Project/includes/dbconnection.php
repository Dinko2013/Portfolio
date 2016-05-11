<?php
/**
 * Created by PhpStorm.
 * User: Mo
 * Date: 2015-10-10
 * Time: 5:03 PM
 */
$DB_NAME = 'employees';
$DB_USERNAME = 'root';
$DB_HOST = 'localhost';
$DB_PASSWORD ='inet2005';


$con = mysqli_connect($DB_HOST,$DB_USERNAME,$DB_PASSWORD,$DB_NAME);
if (!$con)
{
    die('Could not connect to employees Database: ' . mysqli_connect_error());
}
?>
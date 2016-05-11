    <?php
    /**
     * Created by PhpStorm.
     * User: inet2005
     * Date: 10/10/15
     * Time: 7:28 PM
     */
    require('includes/authentication.php');
    include('includes/header.php');
    $delete_ID = $_POST['delete_ID'];
    $sqlQuery = "SELECT * FROM employees WHERE emp_no =$delete_ID";
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
        <h1>Delete Employee Record</h1>
        <form name="delete" method="post" action="handleDelete.php">
            <input type="hidden" name="delete_ID" value="<?php echo $row['emp_no'];?>" />
            <div class="row">
                <input placeholder="" id="fn" type="text" name="fn" disabled value="<?php echo $row['first_name']; ?>">
                <label for="fn">Employee First Name</label>
            </div>
            <div class="row">
                <input placeholder="" id="ln" type="text" name="ln" disabled value="<?php echo $row['last_name']; ?>">
                <label for=" ln">Employee Last Name</label>
            </div>
            <div class="row">
                <input placeholder="" id="gender" type="text" name="gender" disabled value="<?php echo $row['gender']; ?>">
                <label for=" gender">Gender</label>
            </div>
            <div class="row">
                <input placeholder="" id="DOB" type="text" name="DOB" disabled value="<?php echo $row['birth_date']; ?>">
                <label for="DOB">DOB</label>
            </div>
            <div class="row">
                <input placeholder="" id="hireDate" type="text" name="hireDate" disabled value="<?php echo $row['hire_date']; ?>">
                <label for=" hireDate">Hire Date</label>
            </div>
            <div class="row" align="center">
                <button class="btn waves-effect waves-light btn-large" type="submit" name="action">Confirm Delete
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

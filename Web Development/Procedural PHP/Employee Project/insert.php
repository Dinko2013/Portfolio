<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/10/15
* Time: 8:11 PM
*/
require('includes/authentication.php');
include('includes/header.php');
?>
<div class="container">
<h1>Insert New Employee Record</h1>
<div class="row">
          <form name="Insert" action="handleInsert.php" method="post" onsubmit="return validateInsert()">
              <div class="row">
                  <input placeholder="First Name" id="fn" type="text" name="fn" >
                  <label for="fn">First Name</label><span id="fsn" style="color: red"> </span>
              </div>
              <div class="row">
                  <input placeholder="Last Name" id="ln" type="text" name="ln">
                  <label for="ln">LastName</label><span id="sln" style="color: red"> </span>
              </div>
              <div class="row">
                  <select name="gender" id="gender">
                      <option value="" disabled selected>Choose A Gender</option>
                      <option value="M">Male</option>
                      <option value="F">Female</option>
                  </select>
                  <label>Gender</label><span id="sgender" style="color: red"> </span>
              </div>
              <div class="row">
                  <input placeholder="Date of Birth"  id="dob" type="Date" class="datepicker" name="dob">
                  <label for="dob">DOB</label><span id="sdob" style="color: red"></span>
              </div>
              <div class="row">
                  <input placeholder="Hired Date" id="date_hired" type="Date" class ="datepicker" name="date_hired">
                  <label for="date_hired">Hired Date</label><span id="sdate_hired" style="color: red"></span>
              </div>
              <div class="row" align="center">
                  <button class="btn waves-effect waves-light btn-large" type="submit" name="action">Insert
                  </button>
              </div>
          </form>
    </div>
</div>
    <div class="fixed-action-btn" style="bottom: 25px; right: 10px;">
        <a class="btn-floating btn-large green" href="home.php">
            <i class="large material-icons">home</i>
        </a>
    </div>
<?php
include('includes/footer.php');
?>
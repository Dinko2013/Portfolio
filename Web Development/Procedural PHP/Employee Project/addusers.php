<?php
/**
* Created by PhpStorm.
* User: inet2005
* Date: 10/11/15
* Time: 9:46 PM
*/
require('includes/authentication.php');
include('includes/header.php');
?>
<div class="container">
<h1>Add a User Account</h1>
<div class="row">
          <form name="InsertUser" action="handleUser.php" method="post" onsubmit=" return validateAddUser()">
              <div class="row">
                  <input placeholder="Username" id="Username" type="text" name="Username">
                  <label for="Username">Username</label><span id="uname" style="color: red"> </span>
              </div>
              <div class="row">
                  <input placeholder="First Name" id="fname" type="text" name="fname" onfocus="firstLetterCaptial(this.id);">
                  <label for="fname">First Name</label><span id="sfname" style="color: red"> </span>
              </div>
              <div class="row">
                  <input placeholder="Last Name" id="ln" type="text" name="lname">
                  <label for="lname">Last Name</label><span id="sln" style="color: red"> </span>
              </div>
              <div class="row">
                  <input placeholder=""  id="password" type="password"  name="password">
                  <label for="password">password</label><span id="spassword" style="color: red"> </span>
              </div>
              <div class="row">
                  <select name="permission" id ="perm">
                      <option value="" disabled selected>Select an Access Level</option>
                      <option value="1">Administrator</option>
                      <option value="2">Staff</option>
                      <option value="3">Public</option>
                  </select>
                  <label>Permission Level</label><span id="sperm" style="color: red"> </span>
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
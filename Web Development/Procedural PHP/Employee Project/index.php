<!DOCTYPE html>
<html>
<head>
    <!--Import Google Icon Font-->
    <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <!--Import materialize.css-->
    <link type="text/css" rel="stylesheet" href="css/materialize.css"  media="screen,projection"/>
    <!--Let browser know website is optimized for mobile-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Assignment 1</title>
</head>
<nav>
    <div class="nav-wrapper">
        <a href="index.php" class="brand-logo">Assignment 1</a>
        <ul id="nav-mobile" class="right hide-on-med-and-down">
        </ul>
    </div>
</nav>
<body>
<div class="row" align="center">
<h1>Welcome to the Employees Records System</h1>
</div>
<div class="row" align="center">
<form name="login" method="post" action="handleLogin.php">
    <div class="row" >
        <div class="col s8 offset-s2"
        <div class="card-panel blue">
         <div class="row">
                  <input placeholder=XXXXX id="username" type="text" name="username">
                  <label for="fn">username</label>
              </div>
              <div class="row">
                  <input placeholder="***********" id="password" type="password" name="password">
                  <label for="password">Password</label>
              </div>
              <div class="row" align="center">
                  <button class="btn waves-effect waves-light btn-large" type="submit" name="action">Login
                  </button>
              </div>
        </div>
        </div>
    </div>
</form>
</div>
</body>
</html>
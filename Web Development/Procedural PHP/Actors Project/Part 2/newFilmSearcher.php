<?php
header("Cache-Control: no-cache");

$results = "";
$searchExpr = "";


if(!empty($_GET['searchExpr']))
{
    $searchExpr = $_GET['searchExpr'];

    include("dbConn.php");

    connectToDB();

    selectFilmsWithNameStartingWith($searchExpr);

    while ($row = fetchFilms())
    {
        ?>
        <ul class="collapsible" data-collapsible="accordion">
        <li>
      <div class="collapsible-header">
          <i class="material-icons">filter_drama</i>
          <?php echo $results .= $row['title']?>
      </div>
      <div class="collapsible-body">
          <p> Description:
              <?php
              echo $row['description']
              ?>
          </p>
          <p> Rating:
              <?php
              echo $row['rating']
              ?>
          </p>
          <p> Rental Rate:
          <?php
              echo $row['rental_rate']
          ?>
          </p>
          <p> Length(Minutes):
              <?php
              echo $row['length']
              ?>
          </p>
      </div>
    </li></ul>
<?php
    }

    closeDB();
}

echo $results;


?>



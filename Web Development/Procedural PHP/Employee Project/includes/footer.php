<?php
/**
 * Created by PhpStorm.
 * User: inet2005
 * Date: 10/10/15
 * Time: 1:54 PM
 */

?>
<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
<script type="text/javascript" src="js/materialize.min.js"></script>
<script type="text/javascript" src="../js/validation.js"></script>
<script type="text/javascript">
    $(document).ready(function(){
        // the "href" attribute of .modal-trigger must specify the modal ID that wants to be triggered
        $('.modal-trigger').leanModal();
    });

</script>
<script type="text/javascript">
    $(document).ready(function() {
        $('select').material_select();
    });

</script>
<script type="text/javascript">
$('.datepicker').pickadate({
selectMonths: true, // Creates a dropdown to control month
selectYears: 100 // Creates a dropdown of 15 years to control year
});
</script>
</body>
</html>

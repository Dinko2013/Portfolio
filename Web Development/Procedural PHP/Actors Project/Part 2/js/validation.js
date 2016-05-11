/**
 * Created by inet2005 on 10/13/15.
 */
 var val
function validateSearch() {
    if (document.forms["search"].search.value.length == 0)
    {
        document.getElementById("search").style.borderColor="red";
        document.getElementById("search").style.borderWidth='4px';
        return false;
    }
    else {
        return true;
    }

}

function validateInsert()
{
    var targetSpan1 = document.getElementById('fsn');
    if (document.forms["Insert"].fn.value.length == 0 )
    {
        document.getElementById("fn").style.borderColor = "red";
        document.getElementById("fn").style.borderWidth = '4px';
        targetSpan1.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["Insert"].fn.value.length != 0)
    {
        var b = isNameValid(fn.value);
        if(b==false)
        {

            document.getElementById("fn").style.borderColor = "red";
            document.getElementById("fn").style.borderWidth = '4px';
            targetSpan1.innerHTML = " * First Letter Must Be Capital";
            return false;

        }
        else
        {
            document.getElementById("fn").style.borderColor = "green";
            document.getElementById("fn").style.borderWidth = '4px';
            targetSpan1.innerHTML = "";
        }
    }

    var targetSpan = document.getElementById('sln');
    if (document.forms["Insert"].ln.value.length ==0)
    {
        document.getElementById("ln").style.borderColor="red";
        document.getElementById("ln").style.borderWidth='4px';
        targetSpan.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["Insert"].ln.value.length != 0)
    {
        var a = isNameValid(ln.value);
        if(a==false)
        {
            document.getElementById("ln").style.borderColor = "red";
            document.getElementById("ln").style.borderWidth = '4px';
            targetSpan.innerHTML = " * First Letter Must Be Capital";
            return false;

        }
        else
        {
            document.getElementById("ln").style.borderColor = "green";
            document.getElementById("ln").style.borderWidth = '4px';
            targetSpan.innerHTML = "";
        }
    }

    var targetSpan2 = document.getElementById('sgender');
    if(document.forms["Insert"].gender.selectedIndex==0)
    {
        document.getElementById("gender").style.borderColor="red";
        document.getElementById("gender").style.borderWidth='4px';
        targetSpan2.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["Insert"].gender.selectedIndex!=0)
    {
        document.getElementById("gender").style.borderColor = "green";
        document.getElementById("gender").style.borderWidth = '4px';
        targetSpan2.innerHTML = "";
    }
    var targetSpan3 = document.getElementById('sdob');
    if(document.forms["Insert"].dob.value.length==0)
    {
        document.getElementById("dob").style.borderColor="red";
        document.getElementById("dob").style.borderWidth='4px';
        targetSpan3.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["Insert"].dob.selectedIndex!=0)
    {
        document.getElementById("dob").style.borderColor = "green";
        document.getElementById("dob").style.borderWidth = '4px';
        targetSpan3.innerHTML = "";
    }
    var targetSpan4 = document.getElementById('sdate_hired');
    if(document.forms["Insert"].date_hired.value.length==0)
    {
        document.getElementById("date_hired").style.borderColor="red";
        document.getElementById("date_hired").style.borderWidth='4px';
        targetSpan4.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["Insert"].date_hired.selectedIndex!=0)
    {
        document.getElementById("date_hired").style.borderColor = "green";
        document.getElementById("date_hired").style.borderWidth = '4px';
        targetSpan4.innerHTML = "";
    }

    else {
        return true;
    }

}
function validateUpdate()
{
    var targetSpan1 = document.getElementById('fsn');
    if (document.forms["update"].fn.value.length == 0 )
    {
        document.getElementById("fn").style.borderColor = "red";
        document.getElementById("fn").style.borderWidth = '4px';
        targetSpan1.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["update"].fn.value.length != 0)
    {
        var b = isNameValid(fn.value);
        if(b==false)
        {

            document.getElementById("fn").style.borderColor = "red";
            document.getElementById("fn").style.borderWidth = '4px';
            targetSpan1.innerHTML = " * First Letter Must Be Capital";
            return false;

        }
        else
        {
            document.getElementById("fn").style.borderColor = "green";
            document.getElementById("fn").style.borderWidth = '4px';
            targetSpan1.innerHTML = "";
        }
    }

    var targetSpan = document.getElementById('sln');
    if (document.forms["update"].ln.value.length ==0)
    {
        document.getElementById("ln").style.borderColor="red";
        document.getElementById("ln").style.borderWidth='4px';
        targetSpan.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["update"].ln.value.length != 0)
    {
        var a = isNameValid(ln.value);
        if(a==false)
        {
            document.getElementById("ln").style.borderColor = "red";
            document.getElementById("ln").style.borderWidth = '4px';
            targetSpan.innerHTML = " * First Letter Must Be Capital";
            return false;

        }
        else
        {
            document.getElementById("ln").style.borderColor = "green";
            document.getElementById("ln").style.borderWidth = '4px';
            targetSpan.innerHTML = "";
        }
    }

    var targetSpan2 = document.getElementById('sgender');
    if(document.forms["update"].gender.selectedIndex==0)
    {
        document.getElementById("gender").style.borderColor="red";
        document.getElementById("gender").style.borderWidth='4px';
        targetSpan2.innerHTML = " * Required";
        return false;sUsername
    }
    else if(document.forms["update"].gender.selectedIndex!=0)
    {
        document.getElementById("gender").style.borderColor = "green";
        document.getElementById("gender").style.borderWidth = '4px';
        targetSpan2.innerHTML = "";
    }
    var targetSpan3 = document.getElementById('sdob');
    if(document.forms["update"].dob.value.length==0)
    {
        document.getElementById("dob").style.borderColor="red";
        document.getElementById("dob").style.borderWidth='4px';
        targetSpan3.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["update"].dob.selectedIndex!=0)
    {
        document.getElementById("dob").style.borderColor = "green";
        document.getElementById("dob").style.borderWidth = '4px';
        targetSpan3.innerHTML = "";
    }
    var targetSpan4 = document.getElementById('sdate_hired');
    if(document.forms["update"].date_hired.value.length==0)
    {
        document.getElementById("date_hired").style.borderColor="red";
        document.getElementById("date_hired").style.borderWidth='4px';
        targetSpan4.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["update"].date_hired.selectedIndex!=0)
    {
        document.getElementById("date_hired").style.borderColor = "green";
        document.getElementById("date_hired").style.borderWidth = '4px';
        targetSpan4.innerHTML = "";
    }

    else {
        return true;
    }
}

function validateAddUser()
{
    var targetSpan = document.getElementById('uname');
    if (document.forms["InsertUser"].Username.value.length == 0)
    {
        document.getElementById("Username").style.borderColor = "red";
        document.getElementById("Username").style.borderWidth = '4px';
        targetSpan.innerHTML = " * Required";
        return false;
    }
    else
    {
        document.getElementById("Username").style.borderColor = "green";
        document.getElementById("Username").style.borderWidth = '4px';
        targetSpan.innerHTML = "";
    }
    var targetSpan1 = document.getElementById('sfname');
    if(document.forms["InsertUser"].fname.value.length ==0)
    {
        document.getElementById("fname").style.borderColor="red";
        document.getElementById("fname").style.borderWidth='4px';
        targetSpan1.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["update"].fname.value.length != 0)
    {
        var a = isNameValid(fname.value);
        if(a==false)
        {
            document.getElementById("fname").style.borderColor = "red";
            document.getElementById("fname").style.borderWidth = '4px';
            targetSpan1.innerHTML = " * First Letter Must Be Capital";
            return false;

        }
        else
        {
            document.getElementById("fname").style.borderColor = "green";
            document.getElementById("fname").style.borderWidth = '4px';
            targetSpan.innerHTML = "";
        }
    }
    var targetSpan2 = document.getElementById('sln')
    if (document.forms["update"].ln.value.length ==0)
    {
        document.getElementById("ln").style.borderColor="red";
        document.getElementById("ln").style.borderWidth='4px';
        targetSpan2.innerHTML = " * Required";
        return false;
    }
    else if(document.forms["update"].ln.value.length != 0)
    {
        var a = isNameValid(ln.value);
        if(a==false)
        {
            document.getElementById("ln").style.borderColor = "red";
            document.getElementById("ln").style.borderWidth = '4px';
            targetSpan2.innerHTML = " * First Letter Must Be Capital";
            return false;

        }
        else
        {
            document.getElementById("ln").style.borderColor = "green";
            document.getElementById("ln").style.borderWidth = '4px';
            targetSpan2.innerHTML = "";
        }
    }
    var targetSpan3 = document.getElementById('spassword');
    if(document.forms["InsertUser"].password.value.length== 0)
    {
        document.getElementById("password").style.borderColor="red";
        document.getElementById("password").style.borderWidth='4px';
        return false;
    }
    else
    {
        document.getElementById("dob").style.borderColor = "green";
        document.getElementById("dob").style.borderWidth = '4px';
        targetSpan3.innerHTML = "";
    }
    var targetSpan3 = document.getElementById('sperm');
    if(document.forms["InsertUser"].perm.selectedIndex==0)
    {
        document.getElementById("perm").style.borderColor="red";
        document.getElementById("perm").style.borderWidth='4px';
        alert("You must Select a Permission Level");
        return false;
    }

    else
    {
        return true;
    }

}

function isDate(txtDate)
{
    // STRING FORMAT yyyy-mm-dd
    if(txtDate=="" || txtDate==null) {
        return false;
    }

    // m[1] is year 'YYYY' * m[2] is month 'MM' * m[3] is day 'DD'
    var m = txtDate.match(/(\d{4})-(\d{2})-(\d{2})/);

    // STR IS NOT FIT m IS NOT OBJECT
    if( m === null || typeof m !== 'object'){return false;}

    // CHECK m TYPE
    if (typeof m !== 'object' && m !== null && m.size!==3){return false;}

    var ret = true; //RETURN VALUE
    var thisYear = new Date().getFullYear(); //YEAR NOW
    var minYear = 1900; //MIN YEAR

    // YEAR CHECK
    if( (m[1].length < 4) || m[1] < minYear || m[1] > thisYear){ret = false;}
    // MONTH CHECK
    if( (m[1].length < 2) || m[2] < 1 || m[2] > 12){ret = false;}
    // DAY CHECK
    if( (m[1].length < 2) || m[3] < 1 || m[3] > 31){ret = false;}

    return ret;
}

function isNameValid(name)
{

    var nameRegEx =/^[A-Z][a-z]+/;
    if (name.match(nameRegEx))
    {
        return true;
    }
    else
    {
        return false;
    }
}

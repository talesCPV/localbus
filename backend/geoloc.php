<?php   

	if (IsSet($_POST["carid"]) && IsSet($_POST["lat"]) && IsSet($_POST["lon"])){
        $path = getcwd()."/../files/test.txt";
//echo $path;        
        $carid = $_POST["carid"];
        $lat = $_POST["lat"];
        $lon = $_POST["lon"];

        $info = getdate();
        $day = str_pad($info['mday'],2,0,STR_PAD_LEFT);
        $month = str_pad($info['mon'],2,0,STR_PAD_LEFT);
        $hour = str_pad($info['hours'],2,0,STR_PAD_LEFT);
        $min = str_pad($info['minutes'],2,0,STR_PAD_LEFT);
        $sec = str_pad($info['seconds'],2,0,STR_PAD_LEFT);

        $curdate = $day."/".$month."/".$info['year']." ".$hour.":".$min.":".$sec;

        $fp = fopen($path, "a");
        fwrite($fp,$curdate." Car ID:".$carid." Lat:".$lat." Long:".$lon."\r\n");
        fclose($fp); 

//        print("Car ID:".$carid." Lat:".$lat." Long:".$lon);
    }        
    


?>
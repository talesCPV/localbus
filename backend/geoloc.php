<?php   

        function saveTXT($token,$lat,$lon){
                $path = getcwd()."/../files/test.txt";
        //echo $path;        
    
        
                $info = getdate();
                $day = str_pad($info['mday'],2,0,STR_PAD_LEFT);
                $month = str_pad($info['mon'],2,0,STR_PAD_LEFT);
                $hour = str_pad($info['hours'],2,0,STR_PAD_LEFT);
                $min = str_pad($info['minutes'],2,0,STR_PAD_LEFT);
                $sec = str_pad($info['seconds'],2,0,STR_PAD_LEFT);
        
                $curdate = $day."/".$month."/".$info['year']." ".$hour.":".$min.":".$sec;
        
                $fp = fopen($path, "a");
                fwrite($fp,$curdate." Car ID:".$token." Lat:".$lat." Long:".$lon."\r\n");
                fclose($fp); 
        }

        if (IsSet($_POST["token"]) && IsSet($_POST["lat"]) && IsSet($_POST["lon"])){

                include_once "connect.php";

                $query = " CALL sp_set_gps_data(\"".$_POST["token"]."\",\"".$_POST["lat"]."\",\"".$_POST["lon"]."\");";

//echo $query;
                
                $result = mysqli_query($conexao, $query);
                $qtd_lin = $result->num_rows;
                $conexao->close();  

//                saveTXT($_POST["token"],$_POST["lat"],$_POST["lon"]);
        

        }

     
    


?>
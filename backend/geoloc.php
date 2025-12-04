<?php   

        function saveDB($token,$lat,$lon){
               
                        include_once "connect.php";
        
                        $rows = array();
                        $query = " CALL sp_set_gps_data(\"".$token."\",\"".$lat."\",\"".$lon."\");";

                        $result = mysqli_query($conexao, $query);
                        if(is_object($result)){
//var_dump($result);
                                if($result->num_rows > 0){			
                                        while($r = mysqli_fetch_assoc($result)) {
                                                $rows[] = $r;
                                        }
                                }        
                        }
                        $conexao->close(); 
                        
                        $out = '';
                        foreach($result as $row) {
                                return$row['markpoint'];
                        }
                }


        function errorlog($token,$lat,$lon){

                $info = getdate();
                $day = str_pad($info['mday'],2,0,STR_PAD_LEFT);
                $month = str_pad($info['mon'],2,0,STR_PAD_LEFT);
                $hour = str_pad($info['hours'],2,0,STR_PAD_LEFT);
                $min = str_pad($info['minutes'],2,0,STR_PAD_LEFT);
                $sec = str_pad($info['seconds'],2,0,STR_PAD_LEFT);
                
                $filename = $info['year']."_".$month."_".$day.".txt";
                $curdate = $day."/".$month."/".$info['year']." ".$hour.":".$min.":".$sec;

                $path = getcwd()."/../files/error_log/";
        
                mkdir($path, 0777, true);

                $fp = fopen($path.$filename, "a");
                fwrite($fp,$curdate." - Token:".$token." Lat:".$lat." Long:".$lon."\r\n");
                fclose($fp); 
        }

        if (IsSet($_POST["token"]) && IsSet($_POST["lat"]) && IsSet($_POST["lon"])){
                if(saveDB($_POST["token"],$_POST["lat"],$_POST["lon"]) == '0'){                        
                        errorlog($_POST["token"],$_POST["lat"],$_POST["lon"]);
                }
        
        }

     
    


?>
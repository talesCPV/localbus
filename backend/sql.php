<?php

    $query_db = array(
        /* LOGIN */
        "LOG-0"  => 'CALL sp_login("x00", "x01");', // USER, PASS

        /* USERS */
        "USR-0"  => 'CALL sp_viewUser(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "USR-1"  => 'CALL sp_setUser(@access,@hash,x00,"x01","x02","x03",x04);', // ID, NOME, EMAIL, PASS, ACCESS
        "USR-2"  => 'CALL sp_updatePass(@hash,"x00","x01");', // NOME, PASS

        /* SISTEMA */
        "SYS-0"  => 'CALL sp_set_usr_perm_perf(@access,@hash,x00,"x01");', // ID, NOME
        "SYS-1"  => 'CALL sp_view_usr_perm_perf(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE

        /* FROTA */
        "FRT-0"  => 'CALL sp_view_frota(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "FRT-1"  => 'CALL sp_set_frota(@access,@hash,x00,"x01","x02","x03","x04");', // ID,NOME,PLACA,MODELO,GRUPO

        "FRT-2"  => 'CALL sp_view_em_transito(@access,@hash,"x00","x01","x02",x03);', // FIELD,SIGNAL,VALUE,OPEN(0=close, 1=open, 2=all)
        "FRT-3"  => 'CALL sp_set_em_transito(@access,@hash,x00,x01,"x02");', // ID_FROTA,ID_USUARIO,OPEN_TIME(0=new register)
        "FRT-4"  => 'CALL sp_view_free(@access,@hash,x00);', // free (0=motoristas, 1=veiculos)

        /* GPS */
        "GPS-0"  => 'CALL sp_view_open_track(x00);', // ID_FROTA




    );

?>
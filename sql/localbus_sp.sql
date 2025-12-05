
 DROP PROCEDURE sp_allow;
DELIMITER $$
	CREATE PROCEDURE sp_allow(
		IN Iallow varchar(80),
		IN Ihash varchar(64)
    )
	BEGIN    
		SET @access = (SELECT IF(COUNT(access),COALESCE(access,0),-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @quer =CONCAT('SET @allow = (SELECT ',@access,' IN ',Iallow,');');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
	END $$
DELIMITER ;

/* LOGIN */

 DROP PROCEDURE IF EXISTS sp_login;
DELIMITER $$
	CREATE PROCEDURE sp_login(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @hash = (SELECT SHA2(CONCAT(Iemail, Isenha), 256));
		SELECT *, IF(nome="",SUBSTRING_INDEX(email,"@",1),nome) AS nome FROM tb_usuario WHERE hash=@hash;
	END $$
DELIMITER ;

/* USER */

 DROP PROCEDURE sp_setUser;
DELIMITER $$
	CREATE PROCEDURE sp_setUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Inome varchar(30),
		IN Iemail varchar(80),
		IN Isenha varchar(30),
        IN Iaccess int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iemail="")THEN
				DELETE FROM tb_usuario WHERE id=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_usuario (nome,email,hash,access)VALUES(Inome,Iemail,SHA2(CONCAT(Iemail, Isenha), 256),Iaccess);            
                ELSE
					IF(Isenha="")THEN
						UPDATE tb_usuario SET nome=Inome, access=Iaccess WHERE id=Iid;
                    ELSE
						UPDATE tb_usuario SET nome=Inome, email=Iemail, hash=SHA2(CONCAT(Iemail, Isenha), 256), access=Iaccess WHERE id=Iid;
                    END IF;
                END IF;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_viewUser;
DELIMITER $$
	CREATE PROCEDURE sp_viewUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT id,nome,email,access, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil FROM tb_usuario AS USR WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS id_func, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_updatePass;
DELIMITER $$
	CREATE PROCEDURE sp_updatePass(	
		IN Ihash varchar(64),
        IN Inome varchar(30),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @call_id = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@call_id > 0)THEN
			IF(Isenha="")THEN
				UPDATE tb_usuario SET nome=Inome WHERE id=@call_id;
            ELSE
				UPDATE tb_usuario SET hash = SHA2(CONCAT(email, Isenha), 256), nome=Inome WHERE id=@call_id;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

	/* PERMISSÂO */

 DROP PROCEDURE sp_set_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_set_usr_perm_perf(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid int(11),
		IN Inome varchar(30)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
        IF(@allow)THEN
			IF(Iid = 0 AND Inome != "")THEN
				INSERT INTO tb_usr_perm_perfil (nome) VALUES (Inome);
			ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_usr_perm_perfil WHERE id=Iid;
				ELSE
					UPDATE tb_usr_perm_perfil SET nome = Inome WHERE id=Iid;
				END IF;
			END IF;			
			SELECT * FROM tb_usr_perm_perfil;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_view_usr_perm_perf(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
        IF(@allow)THEN
			SET @quer = CONCAT('SELECT * FROM tb_usr_perm_perfil WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

/* FROTA */

 DROP PROCEDURE IF EXISTS sp_view_frota;
DELIMITER $$
	CREATE PROCEDURE sp_view_frota(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN            
			SET @quer = CONCAT('SELECT * FROM tb_frota WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_frota;
DELIMITER $$
	CREATE PROCEDURE sp_set_frota(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11),
		IN Inome varchar(30),
		IN Iplaca varchar(7),
		IN Imodelo varchar(30),
		IN Igrupo varchar(15)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Inome="")THEN
				DELETE FROM tb_frota WHERE id=Iid;
            ELSE
				IF(Iid=0)THEN
					INSERT INTO tb_frota (nome,placa,modelo,grupo) 
					VALUES (Inome,Iplaca,Imodelo,Igrupo);
				ELSE
					UPDATE tb_frota 
                    SET nome=Inome, modelo=Imodelo, placa=Iplaca, grupo=Igrupo, hash=SHA2(CONCAT(Inome, Iplaca), 256)
                    WHERE id=Iid;                
                END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

/* EM TRANSITO */

 DROP PROCEDURE IF EXISTS sp_view_em_transito;
DELIMITER $$
	CREATE PROCEDURE sp_view_em_transito(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Iopen int
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iopen=0)THEN            
				SET @open = 'IF(COALESCE(close_time, 1)=1,0,1)';
			ELSE 
				IF(Iopen=1)THEN
					SET @open = 'IF(COALESCE(close_time, 1)=1,1,0)';
                ELSE 
					SET @open = '1=1';
                END IF;
			END IF;
            
			SET @quer = CONCAT('SELECT * FROM vw_em_transito WHERE ',Ifield,' ',Isignal,' ',Ivalue,' AND ',@open,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_em_transito;
DELIMITER $$
	CREATE PROCEDURE sp_set_em_transito(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_frota int(11),
		IN Iid_usuario int(11),
		IN Iopen_time datetime
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iopen_time>0)THEN
				UPDATE tb_em_transito SET close_time=CURRENT_TIMESTAMP WHERE id_frota=Iid_frota AND  id_usuario=Iid_usuario AND open_time=Iopen_time;
            ELSE
				SET @exist_user = (SELECT COUNT(*) FROM tb_usuario WHERE id=Iid_usuario);
				SET @exist_frota = (SELECT COUNT(*) FROM tb_frota WHERE id=Iid_frota);
				SET @open = (SELECT COUNT(*) FROM tb_em_transito WHERE (id_frota=Iid_frota OR id_usuario=Iid_usuario) AND IF(COALESCE(close_time, 1)=1,1,0));
				IF(@open=0 AND @exist_user AND @exist_frota)THEN
					SET @token = SHA2(CONCAT(Iid_frota, Iid_usuario,CURRENT_TIMESTAMP), 256);
					INSERT INTO tb_em_transito (id_frota, id_usuario,token) 
					VALUES (Iid_frota, Iid_usuario,@token);
				END IF;
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_free;
DELIMITER $$
	CREATE PROCEDURE sp_view_free(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Icar boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Icar)THEN            
				SELECT * FROM vw_free_car;
			ELSE 
				SELECT * FROM vw_free_driver;
			END IF;
        END IF;
	END $$
DELIMITER ;

/* GEO POSICIONAMENTO */

 DROP PROCEDURE IF EXISTS sp_set_gps_data;
DELIMITER $$
	CREATE PROCEDURE sp_set_gps_data(
		IN Itoken varchar(64),
		IN Ilat varchar(10),
        IN Ilon varchar(10)
    )
	BEGIN    
		
		SET @allow = (SELECT COUNT(*)
						FROM tb_em_transito 
						WHERE IF(COALESCE(close_time, 1)=1,1,0)
						AND token COLLATE utf8_general_ci = Itoken COLLATE utf8_general_ci);
		IF(@allow)THEN
			
            SET @id_frota = 0;
            SET @id_usuario = 0;
            
            SELECT id_frota, id_usuario INTO @id_frota,@id_usuario FROM tb_em_transito WHERE token COLLATE utf8_general_ci = Itoken COLLATE utf8_general_ci LIMIT 1;
                
			IF(@id_frota>0 AND @id_usuario>0)THEN
				INSERT INTO tb_gps_data (id_frota, id_usuario,lat,lon) 
				VALUES (@id_frota, @id_usuario,Ilat,Ilon);
			ELSE
				SET @allow = 2;
            END IF;            
        END IF;
        SELECT @allow AS markpoint;
	END $$
DELIMITER ;

/* GPS */

 DROP PROCEDURE IF EXISTS sp_view_open_track;
DELIMITER $$
	CREATE PROCEDURE sp_view_open_track(
        IN Iid_frota int
    )
	BEGIN
		SELECT * FROM vw_open_track WHERE id_frota=Iid_frota;
	END $$
DELIMITER ;

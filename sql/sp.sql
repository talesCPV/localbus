/* FUNCTIONS */

 DROP PROCEDURE IF EXISTS sp_getHash;
DELIMITER $$
	CREATE PROCEDURE sp_getHash(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SELECT SHA2(CONCAT(Iemail, Isenha), 256) AS HASH;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_allow;
DELIMITER $$
	CREATE PROCEDURE sp_allow(
		IN Iallow varchar(80),
		IN Ihash varchar(64)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
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

 DROP PROCEDURE IF EXISTS sp_setUser;
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
				DELETE FROM tb_mail WHERE de=Iid OR para=Iid;
				DELETE FROM tb_user WHERE id=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_usuario (email,hash,access,nome)VALUES(Iemail,SHA2(CONCAT(Iemail, Isenha), 256),Iaccess,Inome);
                ELSE
					IF(Isenha="")THEN
						UPDATE tb_usuario SET email=Iemail, access=Iaccess, nome=Inome WHERE id=Iid;
                    ELSE
						UPDATE tb_usuario SET email=Iemail, hash=SHA2(CONCAT(Iemail, Isenha), 256), access=Iaccess, nome=Inome WHERE id=Iid;
                    END IF;
                END IF;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_viewUser;
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
			SET @quer =CONCAT('SELECT id,email,access, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil FROM tb_usuario AS USR WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_updatePass;
DELIMITER $$
	CREATE PROCEDURE sp_updatePass(	
		IN Ihash varchar(64),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @call_id = (SELECT IFNULL(id,0) FROM tb_user WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@call_id > 0)THEN
			UPDATE tb_user SET hash = SHA2(CONCAT(email, Isenha), 256) WHERE id=@call_id;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

/* PERMISSÂO */

 DROP PROCEDURE IF EXISTS sp_set_usr_perm_perf;
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

 DROP PROCEDURE IF EXISTS sp_view_usr_perm_perf;
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

/* CALENDAR */

 DROP PROCEDURE IF EXISTS sp_view_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_view_calendar(	
		IN Ihash varchar(64),
		IN IdataIni date,
		IN IdataFin date
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM tb_calendario WHERE id_user=@id_call AND data_agd>=IdataIni AND data_agd<=IdataFin;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_set_calendar(	
		IN Ihash varchar(64),
		IN Idata date,
		IN Iobs varchar(255)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			SET @exist = (SELECT COUNT(*) FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata);
			IF(@exist AND Iobs = "")THEN
				DELETE FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata; 
			ELSE
				INSERT INTO tb_calendario (id_user, data_agd, obs) VALUES(@id_call, Idata, Iobs)
                ON DUPLICATE KEY UPDATE obs=Iobs;
			END IF;
        END IF;
	END $$
DELIMITER ;

/* MAIL */

 DROP PROCEDURE IF EXISTS sp_check_usr_mail;
DELIMITER $$
	CREATE PROCEDURE sp_check_usr_mail(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call>0)THEN        
			SELECT COUNT(*) AS new_mail FROM tb_mail WHERE id_to = @id_call AND looked=0;
		ELSE
			SELECT 0 AS new_mail ;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_mail;
DELIMITER $$
	CREATE PROCEDURE sp_set_mail(	
		IN Ihash varchar(64),
        IN Iid_to int(11),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			INSERT INTO tb_mail (id_from,id_to,message) VALUES (@id_call,Iid_to,Imessage);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_mail;
DELIMITER $$
	CREATE PROCEDURE sp_view_mail(	
		IN Ihash varchar(64),
        IN Isend boolean
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Isend)THEN
				SELECT MAIL.*, USR.email AS mail_from
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_from = USR.id AND MAIL.id_to = @id_call;            
            ELSE
				SELECT MAIL.*, USR.email AS mail_to
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_to = USR.id AND MAIL.id_from = @id_call;            
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_del_mail;
DELIMITER $$
	CREATE PROCEDURE sp_del_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			DELETE FROM tb_mail WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_mark_mail;
DELIMITER $$
	CREATE PROCEDURE sp_mark_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			UPDATE tb_mail SET looked=1 WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_all_mail_adress;
DELIMITER $$
	CREATE PROCEDURE sp_all_mail_adress(	
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT id,email FROM tb_usuario WHERE id != @id_call ORDER BY email ASC;
	END $$
DELIMITER ;

/* FIM PADRÂO */

/* BUSCAS E CADASTROS */

 DROP PROCEDURE IF EXISTS sp_view_clube;
DELIMITER $$
	CREATE PROCEDURE sp_view_clube(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @root = (SELECT IF(access=0,1,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
            IF(@root)THEN
				SET @quer =CONCAT('SELECT * FROM vw_clube WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
            ELSE
				SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
				SET @quer =CONCAT('SELECT * FROM vw_clube WHERE ',Ifield,' ',Isignal,' ',Ivalue,'AND id_usuario = "',@id_call,'" ORDER BY ',Ifield,';');
            END IF;
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_clube;
DELIMITER $$
	CREATE PROCEDURE sp_set_clube(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),        
		IN Inome varchar(70),
		IN Irua varchar(60),
		IN Inum varchar(6),
		IN Icidade varchar(30),
		IN Ibairro varchar(40),
		IN Iuf varchar(2),
		IN Icep varchar(10)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(@id_call >0)THEN
				IF(Iid=0)THEN
					INSERT INTO tb_clube (id_usuario,nome,rua,num,cidade,bairro,uf,cep) 
                    VALUES (@id_call,Inome,Irua,Inum,Icidade,Ibairro,Iuf,Icep);
				ELSE
					IF(Inome = "")THEN
						DELETE AGD.* 
							FROM tb_agenda AS AGD
							INNER JOIN tb_aula AS AUL
							ON AGD.id_aula = AUL.id
							WHERE AUL.id_clube = Iid;
                    
						DELETE AUD.* 
							FROM tb_aula_dada AS AUD
							INNER JOIN tb_aula AS AUL
							ON AUD.id_aula = AUL.id
							WHERE AUL.id_clube = Iid;
                    
						DELETE FROM tb_aluno WHERE id_clube=Iid;
                        DELETE FROM tb_aula  WHERE id_clube=Iid;
						DELETE FROM tb_clube WHERE id=Iid;
                    ELSE
						UPDATE tb_clube SET nome=Inome, rua=Irua,num=Inum,cidade=Icidade,bairro=Ibairro,uf=Iuf,cep=Icep
                        WHERE id=Iid; 
                    END IF;
                END IF;
			END IF;
		END IF;
	END $$
DELIMITER ;

/* ALUNO */

 DROP PROCEDURE IF EXISTS sp_view_aluno;
DELIMITER $$
	CREATE PROCEDURE sp_view_aluno(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @root = (SELECT IF(access=0,1,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
            IF(@root)THEN
				SET @quer =CONCAT('SELECT * FROM vw_aluno WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
            ELSE
				SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
				SET @quer =CONCAT('SELECT * FROM vw_aluno WHERE ',Ifield,' ',Isignal,' ',Ivalue,'AND id_usuario = "',@id_call,'" ORDER BY ',Ifield,';');
            END IF;
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_aluno;
DELIMITER $$
	CREATE PROCEDURE sp_set_aluno(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_clube int(11),
		IN Inome varchar(70),
		IN Irua varchar(60),
		IN Inum varchar(6),
		IN Icidade varchar(50),
		IN Ibairro varchar(50),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Idata_adm datetime,
		IN Icel varchar(15),
		IN Iemail varchar(90),
		IN Iativo boolean,
		IN Iobs varchar(255)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(@id_call >0)THEN
				IF(Iid=0)THEN
					INSERT INTO tb_aluno (id_usuario,id_clube,nome,rua,num,cidade,bairro,uf,cep,data_adm,cel,email,obs) 
                    VALUES (@id_call,Iid_clube,Inome,Irua,Inum,Icidade,Ibairro,Iuf,Icep,Idata_adm,Icel,Iemail,Iobs);
				ELSE
					IF(Inome = "")THEN
						DELETE FROM tb_agenda WHERE id_aluno=Iid;
                        DELETE FROM tb_aula_dada WHERE id_aluno=Iid;
						DELETE FROM tb_aluno WHERE id=Iid;
                    ELSE
						UPDATE tb_aluno SET nome=Inome,email=Iemail,rua=Irua,num=Inum,cidade=Icidade,bairro=Ibairro,uf=Iuf,
                        cep=Icep,data_adm=Idata_adm,cel=Icel,obs=Iobs,ativo=Iativo
                        WHERE id=Iid; 
                    END IF;
                END IF;
			END IF;
		END IF;
	END $$
DELIMITER ;

/* TIPOS DE AULAS */

 DROP PROCEDURE IF EXISTS sp_view_aula;
DELIMITER $$
	CREATE PROCEDURE sp_view_aula(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @root = (SELECT IF(access=0,1,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@root)THEN
			SELECT * FROM vw_aula;
		ELSE
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			SELECT * FROM vw_aula WHERE id_usuario = @id_call;
		END IF;
	END $$
	DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_aula;
DELIMITER $$
	CREATE PROCEDURE sp_set_aula(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
        IN Iid_clube int(11),
		IN Idesc varchar(70),
		IN Ivalor double,
		IN Iobs varchar(255)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(@id_call >0)THEN
				IF(Iid=0)THEN
					INSERT INTO tb_aula (id_usuario,id_clube,descricao,valor,obs) 
                    VALUES (@id_call,Iid_clube,Idesc,Ivalor,Iobs);
				ELSE
					IF(Idesc = "")THEN
						DELETE FROM tb_aula 
                        WHERE id=Iid;
                    ELSE
						UPDATE tb_aula SET descricao=Idesc,valor=Ivalor,obs=Iobs,id_clube=Iid_clube
                        WHERE id=Iid; 
                    END IF;
                END IF;
			END IF;
		END IF;
	END $$
DELIMITER ;

/* AGENDA */

 DROP PROCEDURE IF EXISTS sp_view_agenda;
DELIMITER $$
	CREATE PROCEDURE sp_view_agenda(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM vw_agenda WHERE id_usuario = @id_call;
	END $$
	DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_set_agenda;
DELIMITER $$
	CREATE PROCEDURE sp_set_agenda(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_aluno int(11),
		IN Iid_aula int(11),
		IN Idia int,
		IN Ihora int,
        IN del boolean
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(@id_call >0)THEN
				IF(del)THEN
					DELETE FROM tb_agenda 
					WHERE id_usuario=@id_call AND id_aluno=Iid_aluno AND dia=Idia AND hora=Ihora;
				ELSE
					INSERT INTO tb_agenda (id_usuario,id_aluno,id_aula,dia,hora) 
                    VALUES (@id_call,Iid_aluno,Iid_aula,Idia,Ihora)
                    ON DUPLICATE KEY UPDATE id_aula = Iid_aula;
                END IF;
			END IF;
		END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS sp_view_agenda_dia;
DELIMITER $$
	CREATE PROCEDURE sp_view_agenda_dia(
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM vw_agenda_dia WHERE id_usuario = @id_call;
	END $$
	DELIMITER ;
    
 DROP PROCEDURE IF EXISTS sp_set_aula_dada;
DELIMITER $$
	CREATE PROCEDURE sp_set_aula_dada(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_aluno int(11),
		IN Iid_aula int(11),
		IN Idata_hora datetime,
		IN Ivalor double,
        IN Ipg boolean,
        IN del boolean
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(@id_call >0)THEN
				IF(del)THEN
					DELETE FROM tb_aula_dada 
					WHERE id_usuario=@id_call AND id_aluno=Iid_aluno AND data_hora=Idata_hora;
				ELSE
					INSERT INTO tb_aula_dada (id_usuario,id_aluno,id_aula,data_hora,valor) 
                    VALUES (@id_call,Iid_aluno,Iid_aula,Idata_hora,Ivalor)
                    ON DUPLICATE KEY UPDATE id_aula = Iid_aula, valor=Ivalor, pg=Ipg;
                END IF;
			END IF;
		END IF;
	END $$
DELIMITER ;

	DROP PROCEDURE IF EXISTS sp_view_aula_dada;
DELIMITER $$
    CREATE PROCEDURE sp_view_aula_dada(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN IdtIn datetime,
        IN Idtout datetime
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			SELECT * FROM vw_aula_dada 
            WHERE data_hora >= IdtIn AND data_hora <= Idtout AND id_usuario=@id_call;
        END IF;
	END $$
	DELIMITER ;
    
/* FINANCEIRO */

	DROP PROCEDURE IF EXISTS sp_view_fecha_aula;
DELIMITER $$
    CREATE PROCEDURE sp_view_fecha_aula(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ialuno varchar(70),
		IN IdtIn datetime,
        IN Idtout datetime,
        IN Iaberto boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			IF(Iaberto)THEN
				SET @quer =CONCAT('
                	SELECT ALD.*,ALN.cel,ALN.email,
					CONCAT(LPAD(DAY(ALD.data_hora),2,0),"/",LPAD(MONTH(ALD.data_hora),2,0),"/",YEAR(ALD.data_hora)) AS DATA,
					CONCAT(LPAD(HOUR(ALD.data_hora),2,0),":00") AS HORARIO 
					FROM vw_aula_dada AS ALD
					INNER JOIN tb_aluno AS ALN
					ON ALD.id_aluno = ALN.id    
					WHERE ALD.aluno LIKE "%',Ialuno,'%"
					AND ALD.pg=0 
					AND ALD.id_usuario = ', @id_call,'
					AND ALD.data_hora >= "', IdtIn,'"
					AND ALD.data_hora <= "', Idtout,'"
					ORDER BY ALD.data_hora;');
            ELSE
				SET @quer =CONCAT('
					SELECT ALD.*,ALN.cel,ALN.email,
					CONCAT(LPAD(DAY(ALD.data_hora),2,0),"/",LPAD(MONTH(ALD.data_hora),2,0),"/",YEAR(ALD.data_hora)) AS DATA,
					CONCAT(LPAD(HOUR(ALD.data_hora),2,0),":00") AS HORARIO 
					FROM vw_aula_dada AS ALD
					INNER JOIN tb_aluno AS ALN
					ON ALD.id_aluno = ALN.id    
					WHERE ALD.aluno LIKE "%',Ialuno,'%"
					AND ALD.id_usuario = ', @id_call,'
					AND ALD.data_hora >= "', IdtIn,'"
					AND ALD.data_hora <= "', Idtout,'"
					ORDER BY ALD.data_hora;');
            END IF;
           
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
      
        END IF;
	END $$
	DELIMITER ;    
    
	DROP PROCEDURE IF EXISTS sp_view_saldo_devedor;
DELIMITER $$
    CREATE PROCEDURE sp_view_saldo_devedor(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ialuno varchar(70),   
		IN IdtIn datetime,
        IN Idtout datetime
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			SET @quer =CONCAT('
                SELECT ALD.id_usuario,ALD.id_aluno, ALD.aluno,ALN.cel,ALN.email, ROUND(SUM(ALD.valor),2) AS valor,
				GROUP_CONCAT(DISTINCT CONCAT(ALD.data_hora,"|",ALD.valor) SEPARATOR ",") AS aulas
				FROM vw_aula_dada AS ALD
				INNER JOIN tb_aluno AS ALN
				ON ALD.id_aluno = ALN.id
				WHERE ALD.pg=0
				AND ALD.aluno LIKE "%',Ialuno,'%"
				AND ALD.id_usuario = ', @id_call,'
				AND ALD.data_hora >= "', IdtIn,'"
				AND ALD.data_hora <= "', Idtout,'"
				GROUP BY ALD.id_aluno
				ORDER BY ALD.aluno, ALD.data_hora;
			');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ; 
    
	DROP PROCEDURE IF EXISTS sp_set_baixa_aula;
DELIMITER $$
	CREATE PROCEDURE sp_set_baixa_aula(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_aluno int(11),
		IN Idata_hora datetime,
        IN Ipg boolean
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
			UPDATE tb_aula_dada SET pg=Ipg WHERE id_usuario=@id_call AND id_aluno=Iid_aluno AND data_hora=Idata_hora;
		END IF;
	END $$
DELIMITER ;

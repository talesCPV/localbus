DROP VIEW IF EXISTS vw_em_transito;
 CREATE VIEW vw_em_transito AS
    SELECT TRS.*,FRT.nome AS veiculo,FRT.placa,FRT.modelo,FRT.grupo,USR.nome as motorista
    FROM tb_em_transito AS TRS
    INNER JOIN tb_frota AS FRT
    INNER JOIN tb_usuario AS USR
    ON TRS.id_frota=FRT.id
    AND TRS.id_usuario=USR.id
	ORDER BY TRS.open_time DESC ;
    
    SELECT * FROM vw_em_transito;
    
DROP VIEW IF EXISTS vw_free_car;
 CREATE VIEW vw_free_car AS
    SELECT FRT.* 
    FROM tb_frota AS FRT
    WHERE id NOT IN (SELECT id_frota FROM vw_em_transito WHERE IF(COALESCE(close_time, 1)=1,1,0));
    
	SELECT * FROM vw_free_car;
    
DROP VIEW IF EXISTS vw_free_driver;
 CREATE VIEW vw_free_driver AS
	SELECT USR.id,USR.nome,USR.email, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil 
    FROM tb_usuario AS USR
    LEFT JOIN tb_usr_perm_perfil AS PRM
    ON USR.access=PRM.id
    WHERE USR.id NOT IN (SELECT id_usuario FROM vw_em_transito WHERE IF(COALESCE(close_time, 1)=1,1,0))
    GROUP BY USR.id;
    
	SELECT * FROM vw_free_driver;

/*    
DROP VIEW IF EXISTS vw_em_transito_open;
CREATE VIEW vw_em_transito AS
	SELECT TRN.id_frota,TRN.id_usuario AS id_motorista, USR.nome AS motorista, TRN.open_time AS iniciado, FRT.nome AS veículo, FRT.placa, FRT.modelo, FRT.grupo
    FROM tb_em_transito AS TRN
    INNER JOIN tb_frota AS FRT
    INNER JOIN tb_usuario AS USR
    ON TRN.id_frota = FRT.id
    AND TRN.id_usuario = USR.id
    WHERE IF(COALESCE(close_time, 1)=1,1,0)
    ORDER BY TRN.id_frota;
        
    SELECT * FROM vw_em_transito;
*/
    
DROP VIEW IF EXISTS vw_open_track;
 CREATE VIEW vw_open_track AS
	SELECT GPS.id_frota, GPS.id_usuario AS id_motorista, TRN.motorista, GPS.dt_hr, GPS.lat, GPS.lon, TRN.open_time AS inicio, TRN.veiculo, TRN.placa, TRN.grupo
		FROM vw_em_transito AS TRN
        INNER JOIN tb_gps_data AS GPS
        ON TRN.id_frota = GPS.id_frota
        AND TRN.id_usuario = GPS.id_usuario
		WHERE IF(COALESCE(TRN.close_time, 1)=1,1,0)
		ORDER BY TRN.id_frota,GPS.dt_hr;
        
SELECT * FROM vw_open_track        
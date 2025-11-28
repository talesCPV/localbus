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
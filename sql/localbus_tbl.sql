 DROP TABLE IF EXISTS tb_usuario;
CREATE TABLE tb_usuario (
    id int(11) NOT NULL AUTO_INCREMENT,
    email varchar(70) NOT NULL,
    hash varchar(64) NOT NULL,
    nome varchar(30) NOT NULL DEFAULT "",
    access int(11) DEFAULT 1,
    cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	UNIQUE KEY (hash),
	UNIQUE KEY (email),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

INSERT INTO tb_usuario (email,hash,access,nome)VALUES("tales@planet3.com.br","b494f6a8b457c58f8feaac439d771a15045337826d72be5b14bb2f224dc7eb39",0,"Developer");

 DROP TABLE IF EXISTS tb_access;
CREATE TABLE tb_access (
    id int(11) NOT NULL AUTO_INCREMENT,
    stored_proc varchar(25) NOT NULL,
    access varchar(200) DEFAULT "0",
    UNIQUE KEY (stored_proc),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

INSERT INTO tb_access (stored_proc,access)VALUES("sp_setUser","0");
UPDATE tb_access SET access = "5" WHERE id=2;

 DROP TABLE  IF EXISTS tb_usr_perm_perfil;
CREATE TABLE tb_usr_perm_perfil (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    perm varchar(50) NOT NULL DEFAULT "0",
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

/* FROTA */

 DROP TABLE  IF EXISTS tb_frota;
CREATE TABLE tb_frota (
    id int(11) NOT NULL AUTO_INCREMENT,
    nome varchar(30) NOT NULL,
    placa varchar(7) NOT NULL,
    modelo varchar(30) DEFAULT NULL,
    grupo varchar(15) DEFAULT NULL,
    UNIQUE KEY (placa),
    PRIMARY KEY (id)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE  IF EXISTS tb_em_transito;
CREATE TABLE tb_em_transito (
    id_frota int(11) NOT NULL,
    id_usuario int(11) NOT NULL,
	open_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	close_time datetime DEFAULT NULL,
    token varchar(64) NOT NULL,
    FOREIGN KEY (id_frota) REFERENCES tb_frota(id) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id) ON DELETE CASCADE,    
    PRIMARY KEY (id_frota,open_time)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

 DROP TABLE  IF EXISTS tb_gps_data;
CREATE TABLE tb_gps_data (
    id_frota int(11) NOT NULL,
    id_usuario int(11) NOT NULL,
	dt_hr TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    lat varchar(10) NOT NULL,
    lon varchar(10) NOT NULL,
    FOREIGN KEY (id_frota) REFERENCES tb_frota(id) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id) ON DELETE CASCADE,    
    PRIMARY KEY (id_frota,dt_hr)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
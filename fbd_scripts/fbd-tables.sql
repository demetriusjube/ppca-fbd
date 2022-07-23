-- Carga despesa
CREATE TABLE fbd.CARGA_DESPESA(
	ANO INT(4) NOT NULL,
	MES INT(2) NOT NULL,
	SENADOR varchar(255) NOT NULL,
	TIPO_DESPESA varchar(255) NULL,
	CNPJ_CPF varchar(20) NULL,
	FORNECEDOR varchar(255) NULL,
	DOCUMENTO varchar(255) NULL,
	DATA_REEMBOLSO DATE NULL,
	DETALHAMENTO varchar(2000) NULL,
	VALOR_REEMBOLSADO BIGINT NULL,
	COD_DOCUMENTO varchar(100) NULL
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

--Carga Senador
CREATE TABLE fbd.CARGA_SENADOR (
	NOME varchar(255) NULL,
	PARTIDO varchar(100) NULL,
	UF varchar(2) NULL,
	PERIODO varchar(100) NULL,
	SEXO varchar(1) NULL,
	LEGISLATURA smallint NULL
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

--Tipo Despesa
CREATE TABLE fbd.TIPO_DESPESA (
	ID_TIPO_DESPESA BIGINT auto_increment NOT NULL,
	DESCRICAO varchar(255) NOT NULL,
	CONSTRAINT TIPO_DESPESA_PK PRIMARY KEY (ID_TIPO_DESPESA),
	CONSTRAINT TIPO_DESPESA_UN UNIQUE KEY (DESCRICAO)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci
AUTO_INCREMENT=1;

--Legislatura
CREATE TABLE fbd.LEGISLATURA (
  NR_LEGISLATURA smallint NOT NULL,
  ANO_INICIO smallint NOT NULL,
  ANO_FIM smallint NOT NULL,
  CONSTRAINT LEGISLATURA_PK PRIMARY KEY (NR_LEGISLATURA)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Fornecedor
CREATE TABLE fbd.FORNECEDOR (
	ID_FORNECEDOR BIGINT auto_increment NOT NULL,
	NOME varchar(255) NOT NULL,
	CPF_CNPJ varchar(20) NULL,
	CONSTRAINT FORNECEDOR_PK PRIMARY KEY (ID_FORNECEDOR),
	CONSTRAINT FORNECEDOR_UN UNIQUE KEY (CPF_CNPJ)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci
AUTO_INCREMENT=1;

-- Senador

CREATE TABLE fbd.SENADOR (
  ID_SENADOR bigint NOT NULL AUTO_INCREMENT,
  NOME varchar(255) NOT NULL,
  SEXO varchar(1) DEFAULT NULL,
  CONSTRAINT SENADOR_PK PRIMARY KEY (ID_SENADOR),
  CONSTRAINT SENADOR_NOME_UN UNIQUE KEY (NOME)
) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci 
AUTO_INCREMENT=1;

-- Mandato

CREATE TABLE fbd.MANDATO (
	ID_MANDATO BIGINT auto_increment NOT NULL,
	ID_SENADOR BIGINT NOT NULL,
	ESTADO varchar(2) NULL,
	PERIODO varchar(100) NULL,
	LEGISLATURA SMALLINT NULL,
	PARTIDO varchar(100) NULL,
	CONSTRAINT MANDATO_PK PRIMARY KEY (ID_MANDATO),
	CONSTRAINT MANDATO_FK FOREIGN KEY (ID_SENADOR) REFERENCES fbd.SENADOR(ID_SENADOR)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci
AUTO_INCREMENT=1;

-- Mandato Legislatura

CREATE TABLE fbd.MANDATO_LEGISLATURA (
	ID_MANDATO BIGINT NOT NULL,
	NR_LEGISLATURA SMALLINT NOT NULL,
	CONSTRAINT MANDATO_LEGISLATURA_PK PRIMARY KEY (ID_MANDATO,NR_LEGISLATURA),
	CONSTRAINT MANDATO_LEGISLATURA_MANDATO_FK FOREIGN KEY (ID_MANDATO) REFERENCES fbd.MANDATO(ID_MANDATO),
	CONSTRAINT MANDATO_LEGISLATURA_LEGISLATURA_FK FOREIGN KEY (NR_LEGISLATURA) REFERENCES fbd.LEGISLATURA(NR_LEGISLATURA)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- Despesa

CREATE TABLE fbd.DESPESA (
	ID_DESPESA BIGINT auto_increment NOT NULL,
	ANO SMALLINT NOT NULL,
	MES TINYINT NOT NULL,
	ID_SENADOR BIGINT NOT NULL,
	ID_FORNECEDOR BIGINT NULL,
	ID_TIPO_DESPESA BIGINT NOT NULL,
	DATA_REEMBOLSO DATE NULL,
	DETALHAMENTO varchar(2000) NULL,
	DOCUMENTO varchar(100) NULL,
	COD_DOCUMENTO varchar(100) NOT NULL,
	VALOR_REEMBOLSADO decimal(15,2) NOT NULL,
	CONSTRAINT DESPESA_PK PRIMARY KEY (ID_DESPESA),
	CONSTRAINT DESPESA_SENADOR_FK FOREIGN KEY (ID_SENADOR) REFERENCES fbd.SENADOR(ID_SENADOR),
	CONSTRAINT DESPESA_FORNECEDOR_FK FOREIGN KEY (ID_FORNECEDOR) REFERENCES fbd.FORNECEDOR(ID_FORNECEDOR),
	CONSTRAINT DESPESA_TIPO_DESPESA_FK FOREIGN KEY (ID_TIPO_DESPESA) REFERENCES fbd.TIPO_DESPESA(ID_TIPO_DESPESA),
	CONSTRAINT DESPESA_CODIGO_UN UNIQUE KEY (COD_DOCUMENTO)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci
AUTO_INCREMENT=1;

-- Carga da tabela Legislatura

INSERT INTO fbd.LEGISLATURA (NR_LEGISLATURA,ANO_INICIO,ANO_FIM) VALUES (53,2007,2011);
INSERT INTO fbd.LEGISLATURA (NR_LEGISLATURA,ANO_INICIO,ANO_FIM) VALUES (54,2011,2015);
INSERT INTO fbd.LEGISLATURA (NR_LEGISLATURA,ANO_INICIO,ANO_FIM) VALUES (55,2015,2019);
INSERT INTO fbd.LEGISLATURA (NR_LEGISLATURA,ANO_INICIO,ANO_FIM) VALUES (56,2019,2023);

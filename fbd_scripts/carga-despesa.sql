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
COLLATE=utf8mb4_0900_as_ci;
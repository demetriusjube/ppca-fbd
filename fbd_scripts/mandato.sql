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

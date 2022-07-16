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
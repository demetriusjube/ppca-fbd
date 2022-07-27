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
	VALOR_REEMBOLSADO decimal(15,2) NULL,
	COD_DOCUMENTO varchar(100) NULL
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- Carga Senador
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

-- Tipo Despesa
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

-- Legislatura
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

-- Trigger de carga de senadores

delimiter $$
CREATE DEFINER=`root`@`%` TRIGGER TRG_CARGA_SENADOR
AFTER INSERT
ON CARGA_SENADOR FOR EACH row
begin
    DECLARE v_id_senador int default 0;
    DECLARE v_id_mandato int default 0;
   
	SELECT s.id_senador INTO v_id_senador FROM fbd.senador s WHERE TRIM(UPPER(s.nome)) = TRIM(UPPER(new.NOME)) COLLATE utf8mb4_0900_ai_ci;    
	
	IF (v_id_senador = 0) then
	    INSERT INTO SENADOR (NOME, SEXO) VALUES (UPPER(new.NOME), new.SEXO);
	    SELECT s.id_senador INTO v_id_senador FROM fbd.senador s WHERE TRIM(UPPER(s.nome)) = TRIM(UPPER(new.NOME)) COLLATE utf8mb4_0900_ai_ci;
	end if; 
   
	SELECT m.id_mandato INTO v_id_mandato FROM fbd.mandato m WHERE m.ID_SENADOR = v_id_senador AND m.LEGISLATURA = new.legislatura;
 	
   IF (v_id_mandato = 0) then
    	INSERT INTO MANDATO (ID_SENADOR, ESTADO, PERIODO, LEGISLATURA, PARTIDO) VALUES (V_ID_SENADOR, new.uf, new.PERIODO, new.LEGISLATURA, new.PARTIDO);
    	SELECT m.id_mandato INTO v_id_mandato FROM fbd.mandato m WHERE m.ID_SENADOR = v_id_senador AND m.LEGISLATURA = new.legislatura;
        INSERT INTO MANDATO_LEGISLATURA (ID_MANDATO, NR_LEGISLATURA) VALUES (v_id_mandato, new.LEGISLATURA);
    end if;
    
 END 
$$
 
 -- Procedure de carga de despesa
CREATE DEFINER=`root`@`%` PROCEDURE `fbd`.`PRC_ETL_DESPESA`()
BEGIN

	DECLARE v_ano smallint DEFAULT 0;
    DECLARE v_mes tinyint DEFAULT 0;
    DECLARE v_senador varchar(255) DEFAULT '';
    DECLARE v_tipoDespesa varchar(255) DEFAULT '';
    DECLARE v_cnpjCpf VARCHAR(20) DEFAULT '';
	DECLARE v_fornecedor varchar(255) DEFAULT '';
	DECLARE v_documento varchar(255) DEFAULT '';
	DECLARE v_dataReembolso DATE ;
	DECLARE v_detalhamento varchar(255) DEFAULT '';
	DECLARE v_valorReembolsado decimal(15,2) ;
	DECLARE v_codDocumento varchar(100) ;
	DECLARE idSenador bigint DEFAULT 0;
	DECLARE idFornecedor bigint DEFAULT NULL;
	DECLARE idTipoDespesa bigint DEFAULT NULL;
	DECLARE cpfCnpjLimpo varchar(20) DEFAULT '';
    DECLARE total INT DEFAULT 0;
    DECLARE done BOOLEAN DEFAULT false;
    DECLARE curs CURSOR FOR 
    	SELECT ANO, MES, SENADOR, TIPO_DESPESA, CNPJ_CPF, FORNECEDOR, DOCUMENTO, DATA_REEMBOLSO, DETALHAMENTO, VALOR_REEMBOLSADO, COD_DOCUMENTO 
    	FROM CARGA_DESPESA 
    	WHERE COD_DOCUMENTO NOT IN (
    		SELECT COD_DOCUMENTO COLLATE utf8mb4_0900_as_ci AS COD FROM DESPESA
    	) AND SENADOR IN (
    		SELECT DISTINCT s.NOME COLLATE utf8mb4_0900_as_ci AS NOME_SENADOR FROM SENADOR s);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
   	
    SELECT CONCAT('TOTAL DE REGISTROS: ',FOUND_ROWS()); 
	SELECT 'Iniciando cadastro...';
    OPEN curs;
   
	read_loop: LOOP
    -- WHILE (done != true)DO
    	SET done = false;
        FETCH curs INTO v_ano, v_mes, v_senador, v_tipoDespesa, v_cnpjCpf, v_fornecedor, v_documento, v_dataReembolso, v_detalhamento, v_valorReembolsado, v_codDocumento;
        IF done THEN
        	LEAVE read_loop;
        END IF;
       -- Verifica se o Senador já está na base, para recuperar o ID dele
       	-- SELECT CONCAT('Pesquisando o Senador ', v_senador); 
		SELECT ID_SENADOR INTO idSenador FROM SENADOR WHERE UPPER(NOME) = UPPER(v_senador) COLLATE utf8mb4_0900_as_ci;
		-- SELECT concat('Recuperou o senador com id ', idSenador);
		IF (idSenador IS NOT NULL AND idSenador > 0) THEN
			START TRANSACTION;
		
			-- Verifica se foi informado um fornecedor
			IF (v_cnpjCpf IS NOT NULL AND TRIM(v_cnpjCpf) <> '') THEN
			-- Verifica se o fornecedor já está na base. Se não estiver, insere
				SET cpfCnpjLimpo = TRIM(REPLACE(REPLACE(REPLACE(v_cnpjCPf, '.', ''),'-',''),'/',''));
				-- SELECT CONCAT('Verificando fornecedor com cpfCnpj ', cpfCnpjLimpo);
				SELECT ID_FORNECEDOR INTO idFornecedor FROM FORNECEDOR WHERE TRIM(CPF_CNPJ) = cpfCnpjLimpo COLLATE utf8mb4_0900_as_ci;
				-- SELECT CONCAT('Fornecedor: ', idFornecedor);
				IF (idFornecedor IS NULL) THEN
					INSERT INTO FORNECEDOR (NOME, CPF_CNPJ) VALUES (v_fornecedor, cpfCnpjLimpo);
					SET idFornecedor = LAST_INSERT_ID();
					-- SELECT CONCAT('Fornecedor ', v_fornecedor, ' inserido com id ', idFornecedor);
				END IF;
			END IF;
		
			-- Verifica se o tipo de despesa já está na base
			-- SELECT CONCAT('Verificando tipo de despesa', v_tipoDespesa);
			SELECT ID_TIPO_DESPESA INTO idTipoDespesa FROM TIPO_DESPESA WHERE TRIM(UPPER(DESCRICAO)) = TRIM(UPPER(v_tipoDespesa)) COLLATE utf8mb4_0900_as_ci;
			-- SELECT CONCAT('Tipo de despesa: ', idFornecedor);
			IF (idTipoDespesa IS NULL) THEN
				INSERT INTO TIPO_DESPESA (DESCRICAO) VALUES (v_tipoDespesa);
				SET idTipoDespesa = LAST_INSERT_ID(); 
				-- SELECT CONCAT('Tipo de despesa ', v_tipoDespesa, ' inserido com id ', idTipoDespesa);
			END IF;
			
			-- SELECT CONCAT ('Ano: ', v_ano);
			-- Insere os dados na tabela DESPESA
			INSERT INTO DESPESA (ANO, MES, ID_SENADOR, ID_FORNECEDOR, ID_TIPO_DESPESA, DATA_REEMBOLSO, DETALHAMENTO , DOCUMENTO, COD_DOCUMENTO, VALOR_REEMBOLSADO)
			VALUES (v_ano, v_mes, idSenador, idFornecedor, idTipoDespesa, v_dataReembolso, v_detalhamento ,v_documento, v_codDocumento, v_valorReembolsado);
			-- Limpa as variáveis para garantir que a verificação será feita corretamente
			SET idFornecedor = NULL;
			SET idTipoDespesa = NULL;
			SET total = total +1;
			
			
			COMMIT;
        END IF;
       	-- Limpa o senador para garantir outro loop
       	SET idSenador = NULL;

	END LOOP;
    CLOSE curs;
    SELECT CONCAT('Importação terminada! ', total, ' registros importados!'); 
   

END $$

delimiter ;

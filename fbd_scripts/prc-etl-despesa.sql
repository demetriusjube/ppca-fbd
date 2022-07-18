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
	DECLARE idFornecedor bigint DEFAULT 0;
	DECLARE idTipoDespesa bigint DEFAULT 0;
	DECLARE cpfCnpjLimpo varchar(20) DEFAULT '';
    DECLARE total INT;
    DECLARE done BOOLEAN DEFAULT false;
    DECLARE curs CURSOR FOR 
    	SELECT ANO, MES, SENADOR, TIPO_DESPESA, CNPJ_CPF, FORNECEDOR, DOCUMENTO, DATA_REEMBOLSO, DETALHAMENTO, VALOR_REEMBOLSADO, COD_DOCUMENTO 
    	FROM CARGA_DESPESA 
    	WHERE COD_DOCUMENTO NOT IN (
    		SELECT COD_DOCUMENTO COLLATE utf8mb4_0900_as_ci AS COD FROM DESPESA
    	) ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
   SELECT 'Iniciando pesquisa';
    OPEN curs;    
    WHILE (done != true)DO
    	SELECT 'Iniciando loop';
    	-- SET done = true;
        FETCH curs INTO v_ano, v_mes, v_senador, v_tipoDespesa, v_cnpjCpf, v_fornecedor, v_documento, v_dataReembolso, v_detalhamento, v_valorReembolsado, v_codDocumento;
       -- Verifica se o Senador já está na base, para recuperar o ID dele
       	SELECT CONCAT('Pesquisando o Senador ', v_senador); 
		SELECT ID_SENADOR INTO idSenador FROM SENADOR WHERE UPPER(NOME) = UPPER(v_senador) COLLATE utf8mb4_0900_as_ci;
		SELECT concat('Recuperou o senador com id ', idSenador);
		IF (idSenador IS NOT NULL AND idSenador > 0) THEN
			START TRANSACTION;
		
			-- Verifica se foi informado um fornecedor
			IF (v_cnpjCpf IS NOT NULL AND TRIM(v_cnpjCpf) <> '') THEN
			-- Verifica se o fornecedor já está na base. Se não estiver, insere
				SET cpfCnpjLimpo = REPLACE(REPLACE(v_cnpjCPf, '.', ''),'-','');
				SELECT CONCAT('Verificando fornecedor com cpfCnpj ', cpfCnpjLimpo);
				SELECT ID_FORNECEDOR INTO idFornecedor FROM FORNECEDOR WHERE CPF_CNPJ = cpfCnpjLimpo COLLATE utf8mb4_0900_as_ci;
				IF (idFornecedor IS NULL) THEN
					INSERT INTO FORNECEDOR (NOME, CPF_CNPJ) VALUES (v_fornecedor, cpfCnpjLimpo);
					SET idFornecedor = LAST_INSERT_ID();
					SELECT CONCAT('Fornecedor ', v_fornecedor, ' inserido com id ', idFornecedor);
				END IF;
			END IF;
		
			-- Verifica se o tipo de despesa já está na base
			SELECT ID_TIPO_DESPESA INTO idTipoDespesa FROM TIPO_DESPESA WHERE UPPER(DESCRICAO) = TRIM(UPPER(v_tipoDespesa)) COLLATE utf8mb4_0900_as_ci;
			IF (idTipoDespesa IS NOT NULL) THEN
				INSERT INTO TIPO_DESPESA (DESCRICAO) VALUES (v_tipoDespesa);
				SET idTipoDespesa = LAST_INSERT_ID(); 
			END IF;
			
			-- Insere os dados na tabela DESPESA
			INSERT INTO DESPESA (ANO, MES, ID_SENADOR, ID_FORNECEDOR, ID_TIPO_DESPESA, DATA_REEMBOLSO, DETALHAMENTO , DOCUMENTO, COD_DOCUMENTO)
			VALUES (v_ano, v_mes, idSenador, idFornecedor, idTipoDespesa, v_dataReembolso, v_detalhamento ,v_documento, v_codDocumento);
			
			COMMIT;
        END IF;

	END WHILE;
    CLOSE curs;

END
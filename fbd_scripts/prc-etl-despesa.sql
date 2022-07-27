Delimiter $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `fbd`.`PRC_ETL_DESPESA`()
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
    #  WHILE (done != true)DO
    	SET done = false;
        FETCH curs INTO v_ano, v_mes, v_senador, v_tipoDespesa, v_cnpjCpf, v_fornecedor, v_documento, v_dataReembolso, v_detalhamento, v_valorReembolsado, v_codDocumento;
        IF done THEN
        	LEAVE read_loop;
        END IF;
       #  Verifica se o Senador já está na base, para recuperar o ID dele
       	#  SELECT CONCAT('Pesquisando o Senador ', v_senador); 
		SELECT ID_SENADOR INTO idSenador FROM SENADOR WHERE UPPER(NOME) = UPPER(v_senador) COLLATE utf8mb4_0900_as_ci;
		#  SELECT concat('Recuperou o senador com id ', idSenador);
		IF (idSenador IS NOT NULL AND idSenador > 0) THEN
			START TRANSACTION;
		
			#  Verifica se foi informado um fornecedor
			IF (v_cnpjCpf IS NOT NULL AND TRIM(v_cnpjCpf) <> '') THEN
			#  Verifica se o fornecedor já está na base. Se não estiver, insere
				SET cpfCnpjLimpo = TRIM(REPLACE(REPLACE(REPLACE(v_cnpjCPf, '.', ''),'-',''),'/',''));
				#  SELECT CONCAT('Verificando fornecedor com cpfCnpj ', cpfCnpjLimpo);
				SELECT ID_FORNECEDOR INTO idFornecedor FROM FORNECEDOR WHERE TRIM(CPF_CNPJ) = cpfCnpjLimpo COLLATE utf8mb4_0900_as_ci;
				#  SELECT CONCAT('Fornecedor: ', idFornecedor);
				IF (idFornecedor IS NULL) THEN
					INSERT INTO FORNECEDOR (NOME, CPF_CNPJ) VALUES (v_fornecedor, cpfCnpjLimpo);
					SET idFornecedor = LAST_INSERT_ID();
					#  SELECT CONCAT('Fornecedor ', v_fornecedor, ' inserido com id ', idFornecedor);
				END IF;
			END IF;
		
			#  Verifica se o tipo de despesa já está na base
			#  SELECT CONCAT('Verificando tipo de despesa', v_tipoDespesa);
			SELECT ID_TIPO_DESPESA INTO idTipoDespesa FROM TIPO_DESPESA WHERE TRIM(UPPER(DESCRICAO)) = TRIM(UPPER(v_tipoDespesa)) COLLATE utf8mb4_0900_as_ci;
			#  SELECT CONCAT('Tipo de despesa: ', idFornecedor);
			IF (idTipoDespesa IS NULL) THEN
				INSERT INTO TIPO_DESPESA (DESCRICAO) VALUES (v_tipoDespesa);
				SET idTipoDespesa = LAST_INSERT_ID(); 
				#  SELECT CONCAT('Tipo de despesa ', v_tipoDespesa, ' inserido com id ', idTipoDespesa);
			END IF;
			
			#  SELECT CONCAT ('Ano: ', v_ano);
			#  Insere os dados na tabela DESPESA
			INSERT INTO DESPESA (ANO, MES, ID_SENADOR, ID_FORNECEDOR, ID_TIPO_DESPESA, DATA_REEMBOLSO, DETALHAMENTO , DOCUMENTO, COD_DOCUMENTO, VALOR_REEMBOLSADO)
			VALUES (v_ano, v_mes, idSenador, idFornecedor, idTipoDespesa, v_dataReembolso, v_detalhamento ,v_documento, v_codDocumento, v_valorReembolsado);
			#  Limpa as variáveis para garantir que a verificação será feita corretamente
			SET idFornecedor = NULL;
			SET idTipoDespesa = NULL;
			SET total = total +1;
			
			COMMIT;
        END IF;
       	#  Limpa o senador para garantir outro loop
       	SET idSenador = NULL;

	END LOOP;
    CLOSE curs;
    SELECT CONCAT('Importação terminada! ', total, ' registros importados!'); 
   
end

$$

Delimiter ;

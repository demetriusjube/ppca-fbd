CREATE PROCEDURE fbd.PRC_ETL_DESPESA()
BEGIN

	DECLARE ano smallint DEFAULT 0;
    DECLARE mes tinyint DEFAULT 0;
    DECLARE senador varchar(255) DEFAULT '';
    DECLARE tipoDespesa varchar(255) DEFAULT '';
    DECLARE cnpjCpf VARCHAR(20) DEFAULT '';
	DECLARE fornecedor varchar(255) DEFAULT '';
	DECLARE documento varchar(255) DEFAULT '';
	DECLARE dataReembolso DATE ;
	DECLARE detalhamento varchar(255) DEFAULT '';
	DECLARE valorReembolsado decimal(15,2) ;
	DECLARE codDocumento varchar(100) ;
    DECLARE total INT;
    DECLARE done BOOLEAN;
    DECLARE curs CURSOR FOR SELECT ANO, MES, SENADOR, TIPO_DESPESA, CNPJ_CPF, FORNECEDOR, DOCUMENTO, DATA_REEMBOLSO, DETALHAMENTO, VALOR_REEMBOLSADO, COD_DOCUMENTO FROM CARGA_DESPESA;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  
    OPEN curs;    
    WHILE (done != true)DO
    	-- SET done = true;
        FETCH curs INTO ano, mes, senador, tipoDespesa, cnpjCpf, fornecedor, documento, dataReembolso, detalhamento, valorReembolsado, codDocumento;
       -- Verifica se o Senador já está na base, para recuperar o ID DELETE 
		SELECT ID_SENADOR INTO @idSenador FROM SENADOR WHERE NOME = UPPER(senador);
		IF (@idSenador > 0) THEN
			SELECT ID_FORNECEDOR INTO @idFornecedor FROM FORNECEDOR WHERE CNPJ_CPF =  REPLACE(REPLACE(cnpjCPf, '.', ''),'-','');
			IF (@idFornecedor IS NULL) THEN
				SET done=true; 
			ELSE 
				SET done=true;			
			END IF;
        END IF;

	END WHILE;
    CLOSE curs;

END
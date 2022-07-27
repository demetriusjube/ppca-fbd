delimiter $$
CREATE DEFINER=`root`@`localhost` TRIGGER TRG_CARGA_SENADOR
AFTER INSERT
ON carga_senador FOR EACH row
begin
	DECLARE v_nome_senador varchar(255) default '';
    DECLARE v_id_senador int default 0;
    DECLARE v_id_mandato int default 0;
   
	SELECT s.id_senador INTO v_id_senador FROM fbd.senador s WHERE TRIM(UPPER(s.nome)) = TRIM(UPPER(new.NOME)) COLLATE utf8mb4_0900_ai_ci;    
	
	IF (v_id_senador = 0) then
		INSERT INTO SENADOR (NOME, SEXO) VALUES (new.NOME, new.SEXO);
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
 
 delimiter ;

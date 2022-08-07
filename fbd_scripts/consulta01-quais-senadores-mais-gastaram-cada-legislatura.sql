/* consulta 01 - quais senadores mais gastaram em cada legislatura*/
select NR_LEGISLATURA, ANO_INICIO, ANO_FIM, 
	(select s.NOME from fbd.SENADOR s where s.ID_SENADOR = (
		select d1.ID_SENADOR 
		from fbd.DESPESA d1
		where ANO >= l.ANO_INICIO and ANO < l.ANO_FIM 
		group by d1.ID_SENADOR
		order by sum(d1.VALOR_REEMBOLSADO) desc limit 1)
	) as SENADOR,
	
	(select sum(d2.VALOR_REEMBOLSADO)
	 from fbd.DESPESA d2
	 where ANO >= l.ANO_INICIO and ANO < l.ANO_FIM 
	 group by d2.ID_SENADOR
	 order by sum(d2.VALOR_REEMBOLSADO) desc limit 1)
	 as VALOR
from fbd.LEGISLATURA l;

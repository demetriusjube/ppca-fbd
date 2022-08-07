/* Consulta 05 - Evolução de percentual de parlamentares */ 
/*               de cada gênero por legislatura.         */
select 
	ml.NR_LEGISLATURA , concat(l.ANO_INICIO, " - ", l.ANO_FIM) as LEGISLATURA , s.SEXO, count(ml.NR_LEGISLATURA) as TOTAL_POR_SEXO, 
	(count(ml.NR_LEGISLATURA) / (
		select  count(s_s.SEXO)
		from fbd.MANDATO_LEGISLATURA s_ml 
			inner join fbd.MANDATO s_m on s_m.ID_MANDATO = s_ml.ID_MANDATO
			inner join fbd.SENADOR s_s on s_s.ID_SENADOR  = s_m.ID_SENADOR 
		where s_m.LEGISLATURA = ml.NR_LEGISLATURA
	)) * 100  as PORCENTAGEM
# CONSULTA 5 - CONTINUACAO	
from fbd.MANDATO_LEGISLATURA ml
	inner join fbd.LEGISLATURA l on l.NR_LEGISLATURA = ml.NR_LEGISLATURA 
	inner join fbd.MANDATO m on m.ID_MANDATO = ml.ID_MANDATO
	inner join fbd.SENADOR s on s.ID_SENADOR  = m.ID_SENADOR 
group by s.SEXO, l.NR_LEGISLATURA 	
order by l.NR_LEGISLATURA;
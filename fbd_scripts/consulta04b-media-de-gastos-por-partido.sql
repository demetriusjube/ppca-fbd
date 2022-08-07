/* Consulta 04b - Quantidade média de gastos por partido */
select m.PARTIDO , avg(d.VALOR_REEMBOLSADO) 
from fbd.MANDATO m
	inner join SENADOR s on s.ID_SENADOR  = m.ID_MANDATO 
	inner join DESPESA d on d.ID_SENADOR = m.ID_SENADOR 
group by m.PARTIDO 	
order by m.PARTIDO;


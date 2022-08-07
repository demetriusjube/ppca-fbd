/* Consulta 04a - Quantidade média de gastos por senador */
select
	s.NOME , avg(d.VALOR_REEMBOLSADO) as MEDIA_GASTO
from fbd.DESPESA d
	inner join SENADOR s on s.ID_SENADOR = d.ID_SENADOR 
group by s.NOME
order by MEDIA_GASTO desc;


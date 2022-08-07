/* consulta 02-b - senadores que mais contrataram um dado fornecedor*/
select s.NOME , f.NOME , count(d.ID_FORNECEDOR ) QTD_CONTRATADO 
from fbd.DESPESA d 
	inner join fbd.SENADOR s ON s.ID_SENADOR = d.ID_SENADOR
	inner join fbd.FORNECEDOR f ON f.ID_FORNECEDOR = d.ID_FORNECEDOR 
where d.ID_FORNECEDOR is not null  
group by d.ID_SENADOR , d.ID_FORNECEDOR
order by QTD_CONTRATADO desc;
/* consulta 02-a - fornecedores que mais receberam recursos */
select f.ID_FORNECEDOR , f.NOME, f.CPF_CNPJ, sum(d.VALOR_REEMBOLSADO) as VALOR
from fbd.DESPESA d
	inner join fbd.FORNECEDOR f on f.ID_FORNECEDOR = d.ID_FORNECEDOR 
group by f.ID_FORNECEDOR , f.NOME, f.CPF_CNPJ
order by VALOR desc;

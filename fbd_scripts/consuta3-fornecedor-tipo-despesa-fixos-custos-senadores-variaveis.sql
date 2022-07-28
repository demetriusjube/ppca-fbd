/* CONSULTA 3 - Para um mesmo tipo de despesa e um mesmo fornedor, verificar se há divergências nos preços cobrados de cada senador. 
 */

select u1.fornecedor as fornecedor, u1.despesa, 
       s1.nome as senador1, u1.valor_medio as valor_medio_senador1, u1.valor_total as valor_total_senador1, u1.nr_parcelas as nr_parcelas_senador1,
       s2.nome as senador2, u2.valor_medio as valor_medio_senador2, u2.valor_total as valor_total_senador2, u2.nr_parcelas as nr_parcelas_senador2,
       concat(s1.nome, " - ", s2.nome) as relacao_senadores, concat(s2.nome, " - ", s1.nome) as relacao_senadores_inversa
from (
    select f.id_fornecedor, f.NOME as fornecedor, td.ID_TIPO_DESPESA, td.DESCRICAO as despesa, s.ID_SENADOR , s.NOME as senador,
    round((sum(d.VALOR_REEMBOLSADO) / count(d.MES)),2) as valor_medio, sum(d.VALOR_REEMBOLSADO) as valor_total, count(d.mes) as nr_parcelas 
	from fbd.tipo_despesa td, fbd.despesa d, fbd.fornecedor f, fbd.senador s 
	where td.ID_TIPO_DESPESA = d.ID_TIPO_DESPESA and d.ID_FORNECEDOR = f.ID_FORNECEDOR and d.ID_SENADOR = s.ID_SENADOR 
	group by td.ID_TIPO_DESPESA, f.ID_FORNECEDOR, s.ID_SENADOR
#	having valor_medio > 100 #and count(mes) = 1
	) u1, (
	select f.id_fornecedor, f.NOME as fornecedor, td.ID_TIPO_DESPESA, td.DESCRICAO as despesa, s.ID_SENADOR , s.NOME as senador, 
	round((sum(d.VALOR_REEMBOLSADO) / count(d.MES)),2) as valor_medio, sum(d.VALOR_REEMBOLSADO) as valor_total, count(d.mes) as nr_parcelas
	from fbd.tipo_despesa td, fbd.despesa d, fbd.fornecedor f, fbd.senador s
	where td.ID_TIPO_DESPESA = d.ID_TIPO_DESPESA and d.ID_FORNECEDOR = f.ID_FORNECEDOR and d.ID_SENADOR = s.ID_SENADOR
	group by td.ID_TIPO_DESPESA, f.ID_FORNECEDOR, s.ID_SENADOR
#	having valor_medio < 100 #and count(mes) = 1
	) u2, fbd.senador s1, fbd.senador s2
where u1.id_fornecedor = u2.id_fornecedor and u1.id_tipo_despesa = u2.id_tipo_despesa and u1.id_senador != u2.id_senador and
      u1.id_senador = s1.ID_SENADOR and u2.id_senador = s2.id_senador and 
      u1.nr_parcelas = u2.nr_parcelas



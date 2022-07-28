DELIMITER $$

create or replace
algorithm = UNDEFINED view `fbd`.`vw_despesa_por_legislatura` as
select
    `tp`.`DESCRICAO` as `DESCRICAO_DESPESA`,
    sum(`d`.`VALOR_REEMBOLSADO`) as `VALOR_TOTAL`,
    concat(`l`.`ANO_INICIO`, ' - ', `l`.`ANO_FIM`) as `LEGISLATURA`
from
    ((((((`fbd`.`tipo_despesa` `tp`
join `fbd`.`despesa` `d`)
join `fbd`.`senador` `s`)
join `fbd`.`fornecedor` `f`)
join `fbd`.`mandato` `m`)
join `fbd`.`legislatura` `l`)
join `fbd`.`mandato_legislatura` `ml`)
where
    ((`tp`.`ID_TIPO_DESPESA` = `d`.`ID_TIPO_DESPESA`)
        and (`d`.`ID_SENADOR` = `s`.`ID_SENADOR`)
            and (`d`.`ID_FORNECEDOR` = `f`.`ID_FORNECEDOR`)
                and (`s`.`ID_SENADOR` = `m`.`ID_SENADOR`)
                    and (`m`.`ID_MANDATO` = `ml`.`ID_MANDATO`)
                        and (`m`.`LEGISLATURA` = `ml`.`NR_LEGISLATURA`)
                            and (`ml`.`NR_LEGISLATURA` = `l`.`NR_LEGISLATURA`)
                                and (`d`.`ANO` between `l`.`ANO_INICIO` and `l`.`ANO_FIM`))
group by
    `tp`.`ID_TIPO_DESPESA`,
    `l`.`NR_LEGISLATURA`
order by
    `m`.`PERIODO` desc,
    `VALOR_TOTAL` desc;

$$

DELIMITER ;

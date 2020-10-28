
select
 pes_nome as Nome,
 smu_plpid as Plano
from
 tb_sugestao_matricula
 inner join tb_ingresso on (ing_id = smu_ingid)
 inner join tb_pessoa on (ing_pesid = pes_id)
where
 pes_codtel = '2008100058'


--VISUALIZA OS PLANO DE CADA ALUNO NA TURMA
select distinct
 pes_nome as Nome,
 smu_plpid as Plano,
 PLP_DESCRI as Descricao
from
 tb_sugestao_matricula
 inner join tb_ingresso on (ing_id = smu_ingid)
 inner join TB_PLANO_PAGAMENTO on(smu_plpid = plp_id)
 inner join TB_PESSOA on (ing_pesid = pes_id)
 inner join tb_mestre_aluno on (mal_ingid = ing_id)
 inner join tb_turma on (tur_id = mal_turid)
-- inner join tb_periodo_letivo on (tur_perid = pel_perid)
where
	tur_datfin > getdate()
--	and SUBSTRING(PLP_DESCRI,CHARINDEX('12',PLP_DESCRI), 2) = '12'
	and SUBSTRING(PLP_DESCRI,CHARINDEX('24',PLP_DESCRI), 2) not like '24'

-- pel_descri = '2009/2'
group by
 PLP_DESCRI,
 pes_nome,
 smu_plpid
 

--VISUALIZA OS PLANO UTILIDADOS NA TURMA
select smu_plpid as Plano, PLP_DESCRI as descricao from tb_sugestao_matricula
inner join tb_ingresso on (ing_id = smu_ingid)
inner join TB_PLANO_PAGAMENTO on(smu_plpid = plp_id)
inner join tb_pessoa on (ing_pesid = pes_id)
inner join tb_mestre_aluno on (mal_ingid = ing_id)
inner join tb_turma on (tur_id = mal_turid)
inner join tb_periodo_letivo on (tur_perid = pel_perid)
where tur_codtur = 'CEAI T 01' and pel_descri = '2009/2'
group by smu_plpid, PLP_DESCRI



TB_PLANO_PAGAMENTO where plp_descri like 'CEAI%'
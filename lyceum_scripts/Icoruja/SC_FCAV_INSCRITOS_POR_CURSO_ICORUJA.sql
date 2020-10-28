
SELECT DISTINCT  
 CASE WHEN CUR_ARCID = '29' THEN 'ATUALIZACAO'  
  WHEN CUR_ARCID = '31' THEN 'CAPACITACAO'  
  WHEN CUR_ARCID = '33' THEN 'ESPECIALIZACAO'  
  WHEN CUR_ARCID = '35' THEN 'PALESTRA'  
 END AS TIPO,  
 tur_codtur collate Latin1_General_CI_AI AS TURMA,  

 convert(datetime,convert(varchar, inr_dathor,112)) as DT_INSCRICAO,

 COUNT(pes_id) INSCRITOS
from  
 LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_INSC_INSCRICOES_REALIZADAS
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_INSC_INSREAL_OPC on (inr_id = iro_inrid)
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_insc_inscricao_opcao on (ict_id = iro_ictid)
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_pessoa on (pes_id = inr_pesid)
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_turma on (ict_turid = tur_id)
 --LEFT OUTER join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_pessoa as coord on (coord.pes_id = TUR_RESACAID)  
 --inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_PLANO_PAGAMENTO p on (IRO_PLPID = PLP_ID)  
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_curso on (tur_curid = cur_id)  
group by
	convert(datetime,convert(varchar, inr_dathor,112)),
	CUR_ARCID,   
	tur_codtur
 
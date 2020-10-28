SET DATEFORMAT DMY
SELECT
 pes_id,
 pes_nome,
 pes_email,
 --pes_fone as residencial,
 --pes_foncel as celular,
 --pes_foncom as comercial,
 tur_descri,
 inr_status,
 CONVERT(varCHAR(20),inr_dathor,103)+ ' ' + CONVERT(varCHAR(20),inr_dathor,114)
 inr_dathor,
 iro_id,
 iro_ictid,
 ict_turid
FROM
 LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_INSC_INSCRICOES_REALIZADAS
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_INSC_INSREAL_OPC on (inr_id = iro_inrid)
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_insc_inscricao_opcao on (ict_id = iro_ictid)
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_pessoa on (pes_id = inr_pesid)
 inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_turma on (ict_turid = tur_id)
where
 INR_DATHOR > '16/10/12'
order by 
 inr_dathor
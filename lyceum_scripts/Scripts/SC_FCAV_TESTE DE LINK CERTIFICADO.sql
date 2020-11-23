select * from  LYCEUM_MEDIA.dbo.certificados  
where ALUNO = 'C201800300'


update LYCEUM_MEDIA.dbo.certificados 
set
	URL_APROVACAO = 'http://10.0.10.14/tstvalidade/teste_pdf.asp?B0657EFBDFC8329D96A77D8CBE192CF4'

where ALUNO = 'C201800300'

	--'http://10.0.10.14/tstvalidade/teste_pdf.asp?B0657EFBDFC8329D96A77D8CBE192CF4'

select 
	aluno, sit_aluno, Lyceum.dbo.Decrypt(p.SENHA_TAC) senha
from 
	LYCEUM.dbo.LY_PESSOA p
	inner join lyceum.dbo.ly_aluno a
		on a.pessoa = p.pessoa
where aluno = 'C201800300'

delete LYCEUM.DBO.LY_AVISO where aluno = 'C201800300'



INSERT INTO LYCEUM.DBO.LY_AVISO
		(ALUNO,DTINI,DTFIM,MENSAGEM,CURSO,SERIE,TIPO_AVISO,UNID_RESPONSAVEL,UNID_FISICA,
			TURNO,CURRICULO,CONCURSO,DATA_INCLUSAO,USUARIO,DESTINO,ORDEM,LOTE,ANEXO_ID)
		VALUES
		('A201400091',CONVERT(DATE,GETDATE(),102),CONVERT(DATE,GETDATE()+500,102),'<p><a href="http://10.0.10.14/tstvalidade/teste_pdf.asp?B0657EFBDFC8329D96A77D8CBE192CF4">Link para o Certificado do Curso</a></p>',
			NULL,NULL,'I',NULL,NULL,NULL,NULL,NULL,CONVERT(DATE,GETDATE(),102),'zeus',NULL,NULL,NULL,NULL)	
/*

*/


/************************************************************	
	1 - CRIAR FILTRO DOS AVALIADORES
*************************************************************/
SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = 'A-ALGPON T 03' AND DISCIPLINA = 'A-ALGPON'  AND SIT_MATRICULA = 'Matriculado'
SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = 'A-YBON T 06' AND DISCIPLINA = 'A-YBON'  AND SIT_MATRICULA = 'Matriculado'

INSERT INTO LY_FILTRO_PUB_ALVO (TIPO_OBJETO,FILTRO_PUB_ALVO,CHAVE1,CHAVE2,CHAVE3,CHAVE4,DESCRICAO,QUERY)VALUES('ALUNO','ALUAYBONT06YBON',NULL,NULL,NULL,NULL,'Alunos Matriculados - YBON - A-YBON T 06','SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = ''A-YBON T 06'' AND DISCIPLINA = ''A-YBON''  AND SIT_MATRICULA = ''Matriculado''')

/************************************************************
	2 - FILTRO DAS DISCIPLINAS AVALIADAS
*************************************************************/
SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = 'A-ALGPON'
SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = 'A-YBON'


INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DISCIPLINA','DISAYBONT06YBONRBR','Disciplina - YBON - Renato Belandrino Rodrigues - A-YBON T 06','SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = ''A-YBON''')



/************************************************************	
	3 - FILTRO DOS DOCENTES AVALIADOS 
*************************************************************/
SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 94873
SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 86429

INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DOCENTE','DOAYBONT06YBONRBR','Docente - Renato Belandrino Rodrigues - YBON - A-YBON T 06','SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 86429')


/************************************************************	
	FILTRO INFRA-ESTRUTURA DOS CURSOS AVALIADOS 
*************************************************************/


select * from LY_FILTRO_APLIC_QUEST where FILTRO_APLIC_QUEST = 'INFAYBONT06YBONRBR'
INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DISCIPLINA','INFAYBONT06YBONRBR','Avalia��o da Infra - YBON - Renato Belandrino Rodrigues - A-YBON T 06','SELECT A.DISCIPLINA FROM LY_DISCIPLINA A  WHERE A.DISCIPLINA = ''A-YBON'' GROUP BY A.DISCIPLINA')

/*************************************************************/
/*

*/


/************************************************************	
	1 - CRIAR FILTRO DOS AVALIADORES
*************************************************************/
SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = 'CELOG T 29' AND DISCIPLINA = 'CELOG-SSL'  AND SIT_MATRICULA = 'Matriculado'
SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = 'CELOG T 29' AND DISCIPLINA = 'CELOG-MAM'  AND SIT_MATRICULA = 'Matriculado'

INSERT INTO LY_FILTRO_PUB_ALVO (TIPO_OBJETO,FILTRO_PUB_ALVO,CHAVE1,CHAVE2,CHAVE3,CHAVE4,DESCRICAO,QUERY)VALUES('ALUNO','ALUCELOGT29SSL',NULL,NULL,NULL,NULL,'Alunos Matriculados - SSL - CELOG T 29','SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = ''CELOG T 29'' AND DISCIPLINA = ''CELOG-SSL''  AND SIT_MATRICULA = ''Matriculado''')
INSERT INTO LY_FILTRO_PUB_ALVO (TIPO_OBJETO,FILTRO_PUB_ALVO,CHAVE1,CHAVE2,CHAVE3,CHAVE4,DESCRICAO,QUERY)VALUES('ALUNO','ALUCELOGT29MAM',NULL,NULL,NULL,NULL,'Alunos Matriculados - MAM - CELOG T 29','SELECT ALUNO FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA  WHERE  TURMA = ''CELOG T 29'' AND DISCIPLINA = ''CELOG-MAM''  AND SIT_MATRICULA = ''Matriculado''')


/************************************************************
	2 - FILTRO DAS DISCIPLINAS AVALIADAS
*************************************************************/
SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = 'CELOG-SSL'
SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = 'CELOG-MAM'


INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DISCIPLINA','DISCELOGT29SSLDdO','Disciplina - SSL - Daniel de Oliveira Mota - CELOG T 29','SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = ''CELOG-SSL''')
INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DISCIPLINA','DISCELOGT29MAMJLd','Disciplina - MAM - Jorge Luiz de Biazzi - CELOG T 29','SELECT DISCIPLINA FROM LY_DISCIPLINA WHERE DISCIPLINA = ''CELOG-MAM''')

/************************************************************	
	3 - FILTRO DOS DOCENTES AVALIADOS 
*************************************************************/
SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 9111134
SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 900215

INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DOCENTE','DOCELOGT29SSLDdO','Docente - Daniel de Oliveira Mota - SSL - CELOG T 29','SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 9111134')
INSERT INTO LY_FILTRO_APLIC_QUEST (TIPO_OBJETO_AVAL,TIPO_OBJETO,FILTRO_APLIC_QUEST,DESCRICAO,QUERY)VALUES('ALUNO','DOCENTE','DOCELOGT29MAMJLd','Docente - Jorge Luiz de Biazzi - MAM - CELOG T 29','SELECT NUM_FUNC FROM LY_DOCENTE WHERE NUM_FUNC = 900215')

/************************************************************	
	FILTRO INFRA-ESTRUTURA DOS CURSOS AVALIADOS 
*************************************************************/



/*************************************************************/
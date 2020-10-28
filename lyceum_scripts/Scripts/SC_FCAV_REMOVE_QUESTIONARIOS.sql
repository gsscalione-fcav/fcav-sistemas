remover formulários criados.

Apl_Doc_CAPAC
Avaliação de Docente
FORM_AVAL_DOC_2018
Apl_Infra_CAPAC
AvaliaçãoInfra
FORM_AVAL_INFRA_2018


DECLARE @tipo_questionario  VARCHAR (20)
DECLARE @questionario  VARCHAR (20)
DECLARE @aplicacao	VARCHAR (20)

SET @tipo_questionario	= 'FORM_AVAL_INFRA_2018'
SET @questionario		= 'AvaliaçãoInfra'
SET @aplicacao			= 'Apl_Infra_CAPAC'


SELECT * FROM LY_FAPLIC_QUEST_APLIC WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao


DELETE LY_QUESTAO_APLICADA WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao

DELETE LY_RESPOSTA WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao

DELETE LY_FAPLIC_QUEST_APLIC WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao


DELETE LY_QUESTAO_APLICADA WHERE
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
		AND APLICACAO = @aplicacao

DELETE LY_PUB_ALVO_APLIC WHERE
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao

DELETE LY_PARTICIPACAO_QUEST WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao

DELETE LY_APLIC_QUESTIONARIO WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao
	
/*DELETE LY_QUESTAO WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	AND APLICACAO = @aplicacao

DELETE LY_QUESTIONARIO WHERE 
TIPO_QUESTIONARIO  = @tipo_questionario
	AND QUESTIONARIO = @questionario
	*/

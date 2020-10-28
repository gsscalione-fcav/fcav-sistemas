--* ***************************************************************  
--*  
--*     *** TRIGGER TR_FCAV_EMAIL_TURMACANC  ***  
--*   
--* DESCRICAO:  
--* - Trigger que envia um email para o financeiro   
--* a cada vez que uma turma for cancelada  
--*  
--* PARAMETROS:  
--* -   
--*  
--* USO:  
--* - O email será disparada sempre que o campo Classificação  
--* for alterado para 'Cancelada'. @SITUACAO = 'Cancelada'  
--*  
--* ALTERAÇÕES:  
--*  03/03/2017: Alterado para pesquisar a turma pela View VW_FCAV_INI_FIM_CURSO_TURMA. Gabriel  
--*  
--* Autor: João Paulo  
--* Data de criação: 10/04/2015  
--*   
--* ***************************************************************  
  
  
ALTER TRIGGER TR_FCAV_EMAIL_TURMACANC  
ON LY_TURMA  
AFTER UPDATE  
  
AS  
  
    DECLARE @TURMA varchar(20)  
    DECLARE @CURSO varchar(20)  
    DECLARE @SITUACAO varchar(20)  
    DECLARE @DISCIPLINA varchar(20)  
    DECLARE @assunto varchar(100)  
    DECLARE @texto varchar(8000)  
    DECLARE @endereco varchar(100)  
    DECLARE @destinatario varchar(200)  
    DECLARE @inicio_curso varchar(30)  
    DECLARE @centro_custo varchar(20)  
  
  
    SET @TURMA = NULL  
    SET @CURSO = NULL  
    SET @SITUACAO = NULL  
    SET @DISCIPLINA = NULL  
    SET @assunto = NULL  
    SET @texto = NULL  
    SET @endereco = NULL  
    SET @destinatario = NULL  
    SET @inicio_curso = NULL  
    SET @centro_custo = NULL  
  
  
  
    BEGIN  
  
        SELECT  
            @TURMA = TURMA,  
            @SITUACAO = CLASSIFICACAO,  
            @DISCIPLINA = DISCIPLINA,  
            @CURSO = CURSO  
        FROM INSERTED  
        WHERE CLASSIFICACAO = 'Cancelada'  
  
        -- *** CONDIÇÃO PARA ALTERAÇÕES QUE NÃO POSSUAM O CAMPO CENTRO DE CUSTO PREECHIDO NO INSERTED    
  
  
        IF @SITUACAO = 'Cancelada'  
  
        BEGIN  
  
            SET @ASSUNTO = 'Cancelamento de turma: ' + @TURMA  
  
            -------------------------------------------------------------      
  
            SET @DESTINATARIO = 'claudia.liberal@vanzolini.org.br; danitiela.kermessi@vanzolini.org.br; victor.passadore@vanzolini.org.br'  
  
            -------------------------------------------------------------      
  
            SELECT  
                @centro_custo = ISNULL(CENTRO_DE_CUSTO,'NÃO CADASTRADO')
            FROM VW_FCAV_INI_FIM_CURSO_TURMA  
            WHERE TURMA = @turma  
            ORDER BY DT_INICIO  
            -------------------------------------------------------------      
  
  
            SELECT  
                @inicio_curso = CONVERT(varchar(30), DT_INICIO, 103)  
            FROM VW_FCAV_INI_FIM_CURSO_TURMA  
            WHERE TURMA = @turma  
            ORDER BY DT_INICIO  
  
            -------------------------------------------------------------     
  
            SELECT  
                @TEXTO =  
                'Aviso de cancelamento de turma no Lyceum, seguem dados:    
				<BR>    
				<BR>    
				<ul>     
				<li> Curso:  <b>' + @CURSO + '</b>    
				<li> Turma:  <b>' + @TURMA + '</b>    
				<li> CC:  <b>' + @centro_custo + '</b>      
				<li> Data de Início da Turma:  <b>' + @inicio_curso + '</b>      
				</ul>    
				'  
            FROM VW_FCAV_INI_FIM_CURSO_TURMA  
            WHERE TURMA = @turma  
            -------------------------------------------------------------      
            EXEC
					MSDB.dbo.SP_SEND_DBMAIL
						@PROFILE_NAME =
							-- Desenvolvimento/homologação
							--FCAV_HOMOLOGACAO,
							-- Produção
							VANZOLINI_BD,    
                         @RECIPIENTS = @destinatario,  
                         @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',  
                         @SUBJECT = @assunto,  
                         @BODY = @texto,  
                         @BODY_FORMAT = HTML;  
  
  
        END  
  
    END
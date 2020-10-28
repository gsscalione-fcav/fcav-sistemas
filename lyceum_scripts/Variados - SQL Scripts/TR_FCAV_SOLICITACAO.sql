--* ***************************************************************      
--*      
--*     *** TRIGGER TR_FCAV_CONVOC_MANUAL  ***      
--*      
--* DESCRICAO:      
--* - Aviso por email para Secretaria ou Financeiro quando houver alguma solicitação 
--*   do aluno   
--*   
/*********************************************************************************  
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO   
  
Para o ambiente de PRODUÇÃO, não esquecer de alterar as variáveis:   
 @encaminha_email comentar a parte de homologação,  
 @PROFILE_NAME alterar para VANZOLINI_BD  
  
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO   
**********************************************************************************/
--*      
--* ALTERAÇÕES:      
--*      
--* Autor: Gabriel Serrano Scalione
--* Data de criação: 08/06/2017     
--*      
--* *****************************************************************************      
ALTER TRIGGER TR_FCAV_SOLICITACAO
ON LY_ITENS_SOLICIT_SERV
AFTER INSERT

AS
    DECLARE @solicitacao T_NUMERO
    DECLARE @item_solicitacao T_NUMERO
    DECLARE @desc_solicitacao varchar(100)
    DECLARE @nome varchar(100)
    DECLARE @aluno T_CODIGO
    DECLARE @curso T_CODIGO
    DECLARE @turma T_CODIGO
    DECLARE @unidade_fisica T_CODIGO
    DECLARE @qtde T_NUMERO
    DECLARE @obs_aluno varchar(8000)
    DECLARE @data_solicitacao datetime
    DECLARE @setor varchar(15)
    DECLARE @assunto varchar(100)
    DECLARE @texto varchar(8000)
    DECLARE @destinatario varchar(100)
    DECLARE @encaminha_email varchar(100)
    DECLARE @responder_para varchar(100)

    BEGIN

        SELECT
            @solicitacao = SOLICITACAO,
            @item_solicitacao = ITEM_SOLICITACAO
        FROM INSERTED

        -------------------------------------------------------------      
        SELECT
            @desc_solicitacao = ISNULL(ts.DESCRICAO, ''),
            @qtde = ISNULL(sv.QTD, ''),
            @obs_aluno = ISNULL(sv.OBS, ''),
            @aluno = ISNULL(a.ALUNO, ''),
            @nome = a.NOME_COMPL,
            @turma = a.TURMA,
            @curso = a.CURSO,
            @unidade_fisica = OC.UNIDADE_FISICA,
            @data_solicitacao = so.DATA,
            @setor = ISNULL((SELECT
                SETOR
            FROM LY_FLUXO_DE_ANDAMENTO fa
            WHERE fa.SERVICO = sv.SERVICO
            GROUP BY SETOR), 'SECR-ATEND')
        FROM LY_ANDAMENTO an
        RIGHT JOIN LY_ITENS_SOLICIT_SERV sv
        LEFT JOIN LY_SOLICITACAO_SERV so
            ON sv.SOLICITACAO = so.SOLICITACAO
        INNER JOIN LY_TABELA_SERVICOS ts
            ON sv.SERVICO = ts.SERVICO
        INNER JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA a
            ON so.ALUNO = a.ALUNO
            ON an.SOLICITACAO = sv.SOLICITACAO
            AND AN.ANDAMENTO = (SELECT
                MAX(ANDAMENTO)
            FROM ly_andamento AN2
            WHERE AN.SOLICITACAO = AN2.SOLICITACAO)
        INNER JOIN LY_OFERTA_CURSO OC
            ON OC.OFERTA_DE_CURSO = A.OFERTA_DE_CURSO
        WHERE so.SOLICITACAO = @solicitacao
        AND SV.ITEM_SOLICITACAO = @item_solicitacao
        -------------------------------------------------------------      
        SELECT
            @destinatario =
            --Producao  
            (CASE
                WHEN @unidade_fisica = 'USP' AND
                    (@setor = 'SECR-ATEND' OR
                    @setor = 'APOIO-ATEND') THEN 'suporte_techne@vanzolini.org.br;' -- 'secretariausp@vanzolini.org.br'  
                WHEN @unidade_fisica = 'Paulista' AND
                    (@setor = 'SECR-ATEND' OR
                    @setor = 'APOIO-ATEND') THEN 'suporte_techne@vanzolini.org.br;' -- 'secretariapta@vanzolini.org.br'  
                WHEN @setor = 'FINAN-ATEND' THEN 'suporte_techne@vanzolini.org.br;' -- 'claudia.liberal@vanzolini.org.br; danitiela.kermessi@vanzolini.org.br'  
            END)
        --Homologacao  
        --'suporte_techne@vanzolini.org.br;'

        -------------------------------------------------------------      
        SET @assunto = 'Nova Solicitaçao de Aluno'
        -------------------------------------------------------------      
        SET @texto = +'Data da Solicitação: ' + CONVERT(varchar, @data_solicitacao, 103) + '<br><br>'
        + 'Curso: ' + @curso + '<br><br>'
        + 'Turma: ' + @turma + '<br><br>'
        + 'Aluno: ' + @aluno + ' - ' + @nome + '<br><br>'
        + 'Solicitou: ' + CAST(@solicitacao AS varchar) + ' - ' + @desc_solicitacao + '<br><br>'
        + 'Observação do Aluno: ' + @obs_aluno


        -------------------------------------------------------------      

        EXEC MSDB.dbo.SP_SEND_DBMAIL @profile_name =
                                     -- Desenvolvimento/homologação    
                                     FCAV_HOMOLOGACAO,
                                     -- Produção    
                                     --VANZOLINI_BD,  
                                     @recipients = @destinatario,
                                     @blind_copy_recipients = 'suporte_techne@vanzolini.org.br', --@encaminha_email,
                                     @subject = @assunto,
                                     @body = @texto,
                                     @body_format = HTML;


    END
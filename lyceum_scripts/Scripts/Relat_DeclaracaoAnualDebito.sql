IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = OBJECT_ID('dbo.[Relat_DeclaracaoAnualDebito]') AND
                   OBJECTPROPERTY(id, 'IsProcedure') = 1)
  DROP PROCEDURE dbo.[Relat_DeclaracaoAnualDebito]
GO

/****** Object:  StoredProcedure [dbo].[[Relat_DeclaracaoAnualDebito]]    Script Date: 22/02/2008 16:07:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Relat_DeclaracaoAnualDebito]
(
    @p_uniresp AS T_CODIGO,
    @p_nivelcurso AS T_CODIGO,
    @p_curso AS T_NUMERO,
    @p_ano AS T_ANO,
    @p_aluno AS T_CODIGO
)

AS
BEGIN
  -- ATUALIZA O NÚMERO DE VIAS EM TODOS OS REGISTROS DO ALUNO E ANO
  UPDATE LY_COBRANCA_QUITADA 
  SET
    LY_COBRANCA_QUITADA.NUM_VIAS = NUM_VIAS + 1
  FROM
    LY_COBRANCA_QUITADA
  INNER JOIN
    LY_ALUNO
  ON
    LY_COBRANCA_QUITADA.ALUNO = LY_ALUNO.ALUNO
  WHERE 
    YEAR(DATA_DE_VENCIMENTO) = @p_ano
  AND 
    ((@p_aluno IS NOT NULL AND LY_ALUNO.ALUNO = @p_aluno) OR @p_aluno IS NULL)
    
  -- OBTEM ALUNOS COM QUIATAÇÃO
  SELECT DISTINCT 
    LY_CURSO.NOME, 
    LY_ALUNO.NOME_COMPL, 
    LY_ALUNO.ALUNO, 
    LY_CURSO.CURSO, 
    MUNICIPIO.NOME AS MUNICIPIO
 
  FROM 
    LY_COBRANCA_QUITADA
  INNER JOIN
    LY_ALUNO
  ON 
    LY_COBRANCA_QUITADA.ALUNO = LY_ALUNO.ALUNO
  INNER JOIN 
    LY_CURSO
  ON
    LY_ALUNO.CURSO = LY_CURSO.CURSO
  INNER JOIN
    LY_FACULDADE
  ON
    LY_CURSO.FACULDADE = LY_FACULDADE.FACULDADE 
  INNER JOIN
    MUNICIPIO
  ON
    LY_FACULDADE.MUNICIPIO = MUNICIPIO.CODIGO

  WHERE 
    YEAR(DATA_DE_VENCIMENTO) = @p_ano
  AND 
    ((@p_uniresp IS NOT NULL AND LY_CURSO.FACULDADE = @p_uniresp) OR @p_uniresp IS NULL)        
  AND 
    ((@p_nivelcurso IS NOT NULL AND LY_CURSO.TIPO = @p_nivelcurso) OR @p_nivelcurso IS NULL)        
  AND 
    ((@p_curso IS NOT NULL AND LY_CURSO.CURSO = @p_curso) OR @p_curso IS NULL)        
  AND 
    ((@p_aluno IS NOT NULL AND LY_ALUNO.ALUNO = @p_aluno) OR @p_aluno IS NULL)        

  ORDER BY 
    LY_CURSO.NOME, LY_ALUNO.NOME_COMPL
  
END;

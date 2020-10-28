USE [LYCEUM_MEDIA]
GO

/****** Object:  Table [dbo].[certificados]    Script Date: 06/08/2020 16:04:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[certificados](
	[ALUNO] [nvarchar](10) NOT NULL,
	[CURSO] [nvarchar](10) NOT NULL,
	[TURMA] [nvarchar](40) NOT NULL,
	[CERTIFICADO] [varbinary](max) NULL,
	[DATA_INCLUSAO] [datetime] NULL,
	[NOME] [varchar](255) NULL,
	[MD5] [varchar](32) NULL,
	[DISCIPLINA] [nvarchar](40) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
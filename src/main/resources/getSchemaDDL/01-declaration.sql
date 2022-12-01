<% if ( asProcedure ) { %>
CREATE OR ALTER PROCEDURE [dbo].[sp_GetDDL]
  @TBL                VARCHAR(255)
AS
<% } %>

BEGIN
    SET NOCOUNT ON;
    DECLARE
        @SCHEMA_NAME            VARCHAR(200) ='<% print schemaName %>',
        @SCHEMA_ID              INT,
        @TABLE_NAME             VARCHAR(200) ='<% print tableName %>',
        @TABLE_ID               INT = 0;
    DECLARE @DDLScript TABLE (
        [OBJECT_ID]             INT,
        [TYPE]                  INT,
        [LINE_NO]               INT IDENTITY,
        [LINE_TEXT]             VARCHAR(MAX) NOT NULL,
        [LINE_PREFIX]           VARCHAR(100) NOT NULL DEFAULT '',
        [LINE_SUFFIX]           VARCHAR(100) NOT NULL DEFAULT ''
);
<% if ( asProcedure ) { %>
  SELECT @SCHEMA_NAME = ISNULL(PARSENAME(@TBL,2),'dbo') ,
         @TABLE_NAME    = PARSENAME(@TBL,1);
<% } %>
SET @SCHEMA_ID = SCHEMA_ID( @SCHEMA_NAME )
IF ( @TABLE_NAME != '' AND LEFT(@TABLE_NAME,1) = '#'  COLLATE SQL_Latin1_General_CP1_CI_AS )
    BEGIN
        PRINT '--GO TO TEMP PROCESS';
        GOTO TEMPPROCESS;
    END;
IF ( @TABLE_NAME != '' )
    SELECT
        @TABLE_ID = [objz].[object_id]
      FROM [sys].[objects]     AS [objz]
      WHERE [objz].[type]      IN ('S','U')
        AND [objz].[name]      <>  'dtproperties'
        AND [objz].[name]      =  @TABLE_NAME
        AND [objz].[schema_id] =  SCHEMA_ID(@SCHEMA_NAME) ;

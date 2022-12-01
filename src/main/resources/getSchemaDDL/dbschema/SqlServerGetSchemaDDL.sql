--#################################################################################################
-- Real World DBA Toolkit Version 2019-08-01 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE OR ALTER PROCEDURE [dbo].[sp_GetSchemaDDL]
  @SCHNAME              VARCHAR(255)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @SavedSchema TABLE ( [Id] INT IDENTITY (1, 1) NOT NULL, [ScriptDefinition] VARCHAR(max) NULL);
DECLARE @QualifiedObjectName  VARCHAR(260),
        @SchemaName           VARCHAR(128),
        @ObjectName           VARCHAR(128),
        @ObjectType           VARCHAR(128);
DECLARE [c1] CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
--###############################################################################################
--cursor definition
--###############################################################################################
  SELECT
    QUOTENAME(SCHEMA_NAME([objz].[schema_id])) + '.' + QUOTENAME([objz].[name]) AS [QualifiedObjectName],
    SCHEMA_NAME([objz].[schema_id]) AS [SchemaName],
    [objz].[name] AS [ObjectName],
    [objz].[type_desc]
  FROM [sys].[objects] AS [objz]
  LEFT OUTER JOIN sys.tables AS t ON objz.object_id = t.history_table_id
  WHERE [objz].[type] IN ('S','U')
  AND [objz].[type_desc] IN ('USER_TABLE' )
  AND [objz].[name] <> 'dtproperties'
  AND SCHEMA_NAME([objz].[schema_id]) = @SCHNAME
  --'SYNONYM','SQL_STORED_PROCEDURE','VIEW','SQL_INLINE_TABLE_VALUED_FUNCTION','SQL_SCALAR_FUNCTION', 'SQL_TABLE_VALUED_FUNCTION'
  ORDER BY [QualifiedObjectName];
--###############################################################################################
--DELETE FROM @SavedSchema;
OPEN [c1];
FETCH NEXT FROM [c1] INTO @QualifiedObjectName,@SchemaName,@ObjectName,@ObjectType;
WHILE @@fetch_status <> -1
  BEGIN
      INSERT INTO @SavedSchema([ScriptDefinition])
        EXECUTE [dbo].[sp_GetDDL] @QualifiedObjectName;
    FETCH NEXT FROM [c1] INTO @QualifiedObjectName,@SchemaName,@ObjectName,@ObjectType;
  END;
CLOSE [c1];
DEALLOCATE [c1];
SELECT sv.[ScriptDefinition] FROM @SavedSchema sv ORDER BY [Id]
END;
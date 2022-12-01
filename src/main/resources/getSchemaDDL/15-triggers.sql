--##############################################################################
--TRIGGERS
--##############################################################################
INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_SUFFIX, LINE_TEXT )
  SELECT
    15, [objz].[parent_object_id], CHAR(10) + 'GO' + CHAR(10) + CHAR(10),
    [MODS].[definition]
  FROM ${isTempTable?'[tempdb].':''}[sys].[sql_modules] AS [MODS]
  JOIN ${isTempTable?'[tempdb].':''}[sys].[objects] AS [objz] ON [MODS].[object_id]=[objz].[parent_object_id]
  WHERE [objz].[type] = 'TR'
        AND [objz].[schema_id] = @SCHEMA_ID
        AND ( @TABLE_ID = 0 OR [objz].[parent_object_id] = @TABLE_ID )
  ;

DELETE FROM @DDLScript WHERE LINE_TEXT = '' OR LINE_TEXT IS NULL;
INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT, LINE_SUFFIX )
SELECT 12, [tabz].[object_id], 'GO' + CHAR(10) + CHAR(10), ''
FROM ${isTempTable?'[tempdb].':''}[sys].[tables] [tabz]
WHERE
  [tabz].[schema_id] = @SCHEMA_ID AND ( @TABLE_ID = 0 OR [tabz].[object_id] = @TABLE_ID )
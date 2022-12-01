INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 02, [tabz].[object_id],
    CASE
        WHEN [tabz].[history_table_id] IS NULL
        THEN ''
        ELSE 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME([tabz].[object_id]) ) + '.' + QUOTENAME(OBJECT_NAME([tabz].[object_id])) + ' SET (SYSTEM_VERSIONING = OFF);' + CHAR(10)
             +  'IF OBJECT_ID(''' + QUOTENAME(OBJECT_SCHEMA_NAME([tabz].[history_table_id]) ) + '.' + QUOTENAME(OBJECT_NAME([tabz].[history_table_id])) + ''') IS NOT NULL ' + CHAR(10)
             + 'DROP TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME([tabz].[history_table_id])) + '.' + QUOTENAME(OBJECT_NAME([tabz].[history_table_id])) + ' ' + CHAR(10) + 'GO' + CHAR(10)
        END
    + 'IF OBJECT_ID(''' + QUOTENAME(OBJECT_SCHEMA_NAME([tabz].[object_id]) ) + '.' + QUOTENAME(OBJECT_NAME([tabz].[object_id])) + ''') IS NOT NULL ' + CHAR(10)
    + 'DROP TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME([tabz].[object_id])) + '.' + QUOTENAME(OBJECT_NAME([tabz].[object_id])) + ' ' + CHAR(10) + 'GO' + CHAR(10)
    + 'CREATE ' + ( CASE WHEN tabz.is_external = 1 THEN 'EXTERNAL ' ELSE '' END ) + 'TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME([tabz].[object_id])) + '.' + QUOTENAME(OBJECT_NAME([tabz].[object_id])) + ' ( '
FROM ${isTempTable?'[tempdb].':''}[sys].[tables] [tabz]
WHERE
  [tabz].[schema_id] = @SCHEMA_ID AND ( @TABLE_ID = 0 OR [tabz].[object_id] = @TABLE_ID )

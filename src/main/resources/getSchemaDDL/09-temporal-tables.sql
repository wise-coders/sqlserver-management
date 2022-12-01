--##############################################################################
-- Temporal tables
--##############################################################################
INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 3, [colz].[object_id],
   'PERIOD FOR SYSTEM_TIME ('
    + MAX(CASE WHEN [colz].[generated_always_type] = 1 THEN [colz].[name] ELSE '' END)
    +','
    + MAX(CASE WHEN [colz].[generated_always_type] = 2 THEN [colz].[name] ELSE '' END)
    +')'
FROM [sys].[tables] [objz]
INNER JOIN [sys].[columns] [colz] ON [objz].[object_id] = [colz].[object_id]
WHERE
    [objz].[schema_id] = @SCHEMA_ID
    AND ( @TABLE_ID = 0  OR [colz].[object_id] = @TABLE_ID )
    AND [colz].[generated_always_type] > 0
GROUP BY [colz].[object_id],[objz].[history_table_id];

INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 9, [colz].[object_id],
    ' SYSTEM_VERSIONING = ON (HISTORY_TABLE=' + QUOTENAME(OBJECT_SCHEMA_NAME([objz].[history_table_id])) + '.' + QUOTENAME(OBJECT_NAME([objz].[history_table_id])) + '),'
FROM [sys].[tables] [objz]
INNER JOIN [sys].[columns] [colz] ON [objz].[object_id] = [colz].[object_id]
WHERE
    [objz].[schema_id] = @SCHEMA_ID
    AND ( @TABLE_ID = 0  OR [colz].[object_id] = @TABLE_ID )
    AND [colz].[generated_always_type] > 0
GROUP BY [colz].[object_id],[objz].[history_table_id];

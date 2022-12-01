--##############################################################################
--CHECK CONSTRAINTS
--##############################################################################
INSERT INTO @DDLScript ( TYPE, OBJECT_ID,  LINE_TEXT )
SELECT 3, [objz].[parent_object_id],
    'CONSTRAINT   ' + QUOTENAME([objz].[name]) + ' '
    + SPACE(5*5 - LEN([objz].[name]))
    + ' CHECK ' + ISNULL([CHECKS].[definition],'')
FROM ${isTempTable?'[tempdb].':''}[sys].[objects] AS [objz]
    INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[check_constraints] AS [CHECKS] ON [objz].[object_id] = [CHECKS].[object_id]
WHERE [objz].[type] = 'C'
   AND [objz].[schema_id] = @SCHEMA_ID
   AND ( @TABLE_ID = 0 OR [objz].[parent_object_id] = @TABLE_ID );
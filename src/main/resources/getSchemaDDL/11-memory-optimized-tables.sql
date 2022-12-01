--##############################################################################
-- MEMORY OPTIMIZED
--##############################################################################
INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 9, [objz].[object_id],
    'MEMORY_OPTIMIZED=ON, DURABILITY=' + [objz].[durability_desc] + ','
FROM [sys].[tables] [objz]
WHERE
    [objz].[is_memory_optimized] =1
    AND [objz].[schema_id] = @SCHEMA_ID
    AND ( @TABLE_ID = 0 OR [objz].[object_id] = @TABLE_ID )

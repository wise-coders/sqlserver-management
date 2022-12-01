--##############################################################################
--CONSTRAINTS
--COLUMN STORE INDEXES ARE DIFFERENT: THE "INCLUDE" COLUMNS FOR NORMAL INDEXES AS SCRIPTED ABOVE ARE THE COLUMNSTORES INDEXED COLUMNS
--ADD A CASE FOR THAT SITUATION.
--##############################################################################
INSERT INTO
    @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 3, rs.[OBJECT_ID],
    CASE
       WHEN rs.[is_primary_key] = 1 OR rs.[is_unique] = 1
       THEN
            'CONSTRAINT   '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME(rs.[index_name]) + ' '
            + CASE
                 WHEN rs.[is_primary_key] = 1
                 THEN ' PRIMARY KEY '
                 ELSE CASE WHEN rs.[is_unique] = 1 THEN ' UNIQUE      ' ELSE '' END
                 END
            + rs.[type_desc]
            + CASE WHEN rs.[type_desc]='NONCLUSTERED' THEN '' ELSE '   ' END
            + ' (' + rs.[index_columns_key] + ')'
            + CASE WHEN rs.[index_columns_include] <> '---' THEN ' INCLUDE (' + rs.[index_columns_include] + ')' ELSE '' END
            + CASE WHEN rs.[has_filter] = 1 THEN ' ' + rs.[filter_definition] ELSE ' ' END
            + CASE WHEN rs.[fill_factor] <> 0 OR rs.[CurrentCompression] <> 'NONE'
            THEN ' WITH ('
                 + CASE WHEN rs.[fill_factor] <> 0 THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),rs.[fill_factor]) ELSE '' END
                 + CASE
                     WHEN rs.[fill_factor] <> 0  AND rs.[CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + rs.[CurrentCompression] + ' '
                     WHEN rs.[fill_factor] <> 0  AND rs.[CurrentCompression]  = 'NONE' THEN ''
                     WHEN rs.[fill_factor]  = 0  AND rs.[CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + rs.[CurrentCompression] + ' '
                     ELSE ''
                 END
                + ')'
             ELSE ''
             END
        ELSE ''
    END
    + ISNULL(fn.[PartitionStatement],'')
FROM @PrimaryUniqueKeys${isTempTable?'Tmp':''} rs
    LEFT JOIN @Partitioning fn ON rs.[OBJECT_ID] = fn.[object_id] AND rs.[index_id] = fn.[index_id]
WHERE rs.[type_desc] != 'HEAP'
   AND rs.[is_primary_key] = 1
   OR  rs.[is_unique] = 1
ORDER BY
    [is_primary_key] DESC,
    [is_unique] DESC;

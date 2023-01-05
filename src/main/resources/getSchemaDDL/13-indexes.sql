--##############################################################################
--INDEXES
--##############################################################################
INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 13, [OBJECT_ID],
     CASE
         WHEN [is_primary_key] = 0 OR [is_unique] = 0
         THEN CHAR(10)
              + 'CREATE '  COLLATE SQL_Latin1_General_CP1_CI_AS + [type_desc] + ' INDEX '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([index_name]) + ' '
              + CHAR(10)
              + '   ON '   COLLATE SQL_Latin1_General_CP1_CI_AS
              + QUOTENAME([SCHEMA_NAME]) + '.' + QUOTENAME([OBJECT_NAME])
              + CASE
                    WHEN [CurrentCompression] = 'COLUMNSTORE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                    THEN ' (' + [index_columns_include] + ')'
                    ELSE ' (' + [index_columns_key] + ')'
                END
              + CASE
                  WHEN [CurrentCompression] = 'COLUMNSTORE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                  THEN ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                  ELSE
                    CASE
                 WHEN [index_columns_include] <> '---'
                 THEN CHAR(10) + '   INCLUDE ('  COLLATE SQL_Latin1_General_CP1_CI_AS + [index_columns_include] + ')'   COLLATE SQL_Latin1_General_CP1_CI_AS
                 ELSE ''   COLLATE SQL_Latin1_General_CP1_CI_AS
               END
                END
              --2008 filtered indexes syntax
              + CASE
                  WHEN [has_filter] = 1
                  THEN CHAR(10) + '   WHERE '  COLLATE SQL_Latin1_General_CP1_CI_AS + [filter_definition]
                  ELSE ''
                END
              + CASE WHEN [fill_factor] <> 0 OR [CurrentCompression] <> 'NONE'  COLLATE SQL_Latin1_General_CP1_CI_AS
              THEN ' WITH ('  COLLATE SQL_Latin1_General_CP1_CI_AS + CASE
                        WHEN [fill_factor] <> 0
                        THEN 'FILLFACTOR = '  COLLATE SQL_Latin1_General_CP1_CI_AS + CONVERT(VARCHAR(30),[fill_factor])
                        ELSE ''
                      END
                    + CASE
                        WHEN [fill_factor] <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression]+' '
                        WHEN [fill_factor] <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                        WHEN [fill_factor]  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression]+' '
                        ELSE ''
                      END
                      + ')'
              ELSE ''
              END
               + CHAR(10) + 'GO' + CHAR(10)
       END
FROM @PrimaryUniqueKeys${isTempTable?'Tmp':''}
WHERE [type_desc] != 'HEAP'
    AND [is_primary_key] = 0
    AND [is_unique] = 0
ORDER BY
    [is_primary_key] DESC,
    [is_unique] DESC;

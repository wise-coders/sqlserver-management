--##############################################################################
--constraints
--##############################################################################
  SELECT @CONSTRAINTSQLS = @CONSTRAINTSQLS
         + CASE
             WHEN [is_primary_key] = 1 OR [is_unique] = 1
             THEN @vbCrLf
                  + 'CONSTRAINT   '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([index_name]) + ' '
                  + SPACE(@STRINGLEN - LEN([index_name]))
                  + CASE
                      WHEN [is_primary_key] = 1
                      THEN ' PRIMARY KEY '  COLLATE SQL_Latin1_General_CP1_CI_AS
                      ELSE CASE
                             WHEN [is_unique] = 1
                             THEN ' UNIQUE      '     COLLATE SQL_Latin1_General_CP1_CI_AS
                             ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                           END
                    END
                  + [type_desc]
                  + CASE
                      WHEN [type_desc]='NONCLUSTERED'
                      THEN ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                      ELSE '   '
                    END
                  + ' (' + [index_columns_key] + ')'
                  + CASE
                      WHEN [index_columns_include] <> '---'
                      THEN ' INCLUDE (' + [index_columns_include] + ')'
                      ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                    END
                  + CASE
                      WHEN [has_filter] = 1
                      THEN ' ' + [filter_definition]
                      ELSE ' '
                    END
                  + CASE WHEN [fill_factor] <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN [fill_factor] <> 0
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),[fill_factor])
                                    ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  END
                                + CASE
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN [fill_factor]  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  END
                                  + ')'
                  ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                  END
             ELSE '' COLLATE SQL_Latin1_General_CP1_CI_AS
           END + ','
  FROM @Results2
  WHERE [type_desc] != 'HEAP'
    AND [is_primary_key] = 1
    OR  [is_unique] = 1
  ORDER BY
    [is_primary_key] DESC,
    [is_unique] DESC;
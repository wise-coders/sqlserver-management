INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
SELECT 3, [objz].[object_id],
   CASE
       WHEN [colz].[is_computed] = 1
       THEN QUOTENAME([colz].[name])
           + ' '
           + SPACE(5*5 - LEN([colz].[name]))
           + 'AS ' + ISNULL([CALC].[definition],'')
           + CASE WHEN [CALC].[is_persisted] = 1 THEN ' PERSISTED' ELSE '' END
       ELSE QUOTENAME([colz].[name])
           + ' '
           + SPACE(5*5 - LEN([colz].[name]))
           + UPPER(TYPE_NAME([colz].[user_type_id]))
           + CASE
            -- DATA TYPES WITH PRECISION AND SCALE
           WHEN TYPE_NAME([colz].[user_type_id]) IN ('decimal','numeric')
           THEN '('
                + CONVERT(VARCHAR,[colz].[precision])
                + ','
                + CONVERT(VARCHAR,[colz].[scale])
                + ') '
                + SPACE(6 - LEN(CONVERT(VARCHAR,[colz].[precision])
                + ','
                + CONVERT(VARCHAR,[colz].[scale])))
                + SPACE(7)
                + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                + CASE
                    <% if ( isTempTable ){ %>
                    WHEN [colz].[is_identity] = 1 THEN ' IDENTITY(1,1)' ELSE '              '
                    <% } else { %>
                    WHEN COLUMNPROPERTY ( [colz].[object_id], [colz].[name] , 'IsIdentity' ) = 0
                    THEN ''
                    ELSE ' IDENTITY('
                        + CONVERT(VARCHAR,ISNULL(IDENT_SEED([objz].[name]),1) )
                        + ','
                        + CONVERT(VARCHAR,ISNULL(IDENT_INCR([objz].[name]),1) )
                        + ')'
                    <% } %>
                   END
                + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
              -- DATA TYPES WITH SCALE
              WHEN TYPE_NAME([colz].[user_type_id]) IN ('datetime2','datetimeoffset','time')
              THEN CASE WHEN [colz].[scale] < 7 THEN '(' + CONVERT(VARCHAR,[colz].[scale]) + ') ' ELSE '    ' END
                 + SPACE(4)
                 + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                 + '        '
                 + CASE  WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                 + CASE [colz].[generated_always_type]
                     WHEN 0 THEN ''
                     WHEN 1 THEN ' GENERATED ALWAYS AS ROW START'
                     WHEN 2 THEN ' GENERATED ALWAYS AS ROW END'
                     ELSE ''
                   END
                 + CASE WHEN [colz].[is_hidden] = 1 THEN ' HIDDEN' ELSE '' END
                 + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
              -- DATA TYPES WITH NO/PRECISION/SCALE
              WHEN  TYPE_NAME([colz].[user_type_id]) IN ('float') --,'real')
              THEN
                   CASE
                   -- 53 IS DEFAULT PRECISION
                   WHEN [colz].[precision] = 53
                   THEN SPACE(11 - LEN(CONVERT(VARCHAR,[colz].[precision])))
                       + SPACE(7)
                       + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                       + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                       + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
                   ELSE '('
                       + CONVERT(VARCHAR,[colz].[precision])
                       + ') '
                       + SPACE(6 - LEN(CONVERT(VARCHAR,[colz].[precision])))
                       + SPACE(7) + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                       + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                       + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
                   END
              -- DATA TYPE WITH MAX_LENGTH
              WHEN  TYPE_NAME([colz].[user_type_id]) IN ('char','varchar','binary','varbinary')
              THEN CASE
                   WHEN  [colz].[max_length] = -1
                   THEN  '(max)'
                        + SPACE(6 - LEN(CONVERT(VARCHAR,[colz].[max_length])))
                        + SPACE(7) + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                        + CASE WHEN [colz].collation_name IS NULL OR [colz].collation_name = 'SQL_Latin1_General_CP1_CI_AS' THEN '' ELSE ' COLLATE ' + [colz].collation_name END
                        + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                        + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
                   ELSE '('
                        + CONVERT(VARCHAR,[colz].[max_length])
                        + ') '
                        + SPACE(6 - LEN(CONVERT(VARCHAR,[colz].[max_length])))
                        + SPACE(7) + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                        -- COLLATE
                        + CASE WHEN [colz].collation_name IS NULL OR [colz].collation_name = 'SQL_Latin1_General_CP1_CI_AS' THEN '' ELSE ' COLLATE ' + [colz].collation_name END
                        + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                        + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
                   END
              -- DATA TYPE WITH MAX_LENGTH
              WHEN TYPE_NAME([colz].[user_type_id]) IN ('nchar','nvarchar')
              THEN CASE
                   WHEN  [colz].[max_length] = -1
                   THEN '(max)'
                        + SPACE(5 - LEN(CONVERT(VARCHAR,([colz].[max_length] / 2))))
                        + SPACE(7)
                        + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                        + CASE WHEN [colz].collation_name IS NULL OR [colz].collation_name = 'SQL_Latin1_General_CP1_CI_AS' THEN '' ELSE ' COLLATE ' + [colz].collation_name END
                        + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                        + CASE WHEN [colz].[is_nullable] = 0 THEN  ' NOT NULL' ELSE '     NULL' END
                   ELSE '('
                        + CONVERT(VARCHAR,([colz].[max_length] / 2))
                        + ') '
                        + SPACE(6 - LEN(CONVERT(VARCHAR,([colz].[max_length] / 2))))
                        + SPACE(7)
                        + SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                        + CASE WHEN [colz].collation_name IS NULL OR [colz].collation_name = 'SQL_Latin1_General_CP1_CI_AS' THEN '' ELSE ' COLLATE ' + [colz].collation_name END
                        + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                        + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
                   END
              WHEN TYPE_NAME([colz].[user_type_id]) IN ('datetime','money','text','image','real')
              THEN SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                 + '              '
                 + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                 + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
              --  OTHER DATA TYPE: INT, DATETIME, MONEY, CUSTOM DATA TYPE
              ELSE SPACE(4*4 - LEN(TYPE_NAME([colz].[user_type_id])))
                   + CASE
                        <% if ( isTempTable ){ %>
                        WHEN [colz].[is_identity] = 1 THEN ' IDENTITY(1,1)' ELSE '              '
                        <% } else { %>
                        WHEN COLUMNPROPERTY ( [colz].[object_id] , [colz].[name] , 'IsIdentity' ) = 0
                        THEN '              '
                        ELSE ' IDENTITY('
                            + CONVERT(VARCHAR,ISNULL(IDENT_SEED([objz].[name]),1) )
                            + ','
                            + CONVERT(VARCHAR,ISNULL(IDENT_INCR([objz].[name]),1) )
                            + ')'
                        <% }%>
                        END
                   + SPACE(2)
                   + CASE WHEN [colz].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                   + CASE WHEN [colz].[is_nullable] = 0 THEN ' NOT NULL' ELSE '     NULL' END
           END
           + CASE
                WHEN [colz].[default_object_id] = 0
                THEN ''
                --ELSE ' DEFAULT '  + ISNULL(def.[definition] ,'')
                --optional section in case NAMED default constraints are needed:
                ELSE '  CONSTRAINT ' + QUOTENAME([DEF].[name]) + ' DEFAULT ' + ISNULL([DEF].[definition] ,'')
                       --i thought it needed to be handled differently! NOT!
           END  --CASE cdefault
       END --iscomputed
   FROM
       [sys].[objects] AS [objz]
       JOIN ${isTempTable?'[tempdb].':''}[sys].[columns] AS [colz] ON [objz].[object_id] = [colz].[object_id]
       LEFT OUTER JOIN ${isTempTable?'[tempdb].':''}[sys].[default_constraints]  AS [DEF] ON [colz].[default_object_id] = [DEF].[object_id]
       LEFT OUTER JOIN ${isTempTable?'[tempdb].':''}[sys].[computed_columns] AS [CALC] ON  [colz].[object_id] = [CALC].[object_id] AND [colz].[column_id] = [CALC].[column_id]
   WHERE
       [objz].[type]  IN ('S','U')
       AND [objz].[name] <>  'dtproperties'
       AND [objz].[schema_id] = @SCHEMA_ID
       AND ( @TABLE_ID = 0 OR [objz].[object_id] = @TABLE_ID )
   ORDER BY [objz].[object_id], [colz].[column_id];

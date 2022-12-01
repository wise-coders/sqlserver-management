--##############################################################################
--PK/UNIQUE CONSTRAINTS AND INDEXES, USING THE 2005/08 INCLUDE SYNTAX
--##############################################################################
DECLARE @PrimaryUniqueKeys${isTempTable?"Tmp":""}  TABLE (
        [SCHEMA_ID]             INT,
        [SCHEMA_NAME]           VARCHAR(255),
        [OBJECT_ID]             INT,
        [OBJECT_NAME]           VARCHAR(255),
        [index_id]              INT,
        [index_name]            VARCHAR(255),
        [ROWS]                  BIGINT,
        [SizeMB]                DECIMAL(19,3),
        [IndexDepth]            INT,
        [TYPE]                  INT,
        [type_desc]             VARCHAR(30),
        [fill_factor]           INT,
        [is_unique]             INT,
        [is_primary_key]        INT ,
        [is_unique_constraint]  INT,
        [index_columns_key]     VARCHAR(MAX),
        [index_columns_include] VARCHAR(MAX),
        [has_filter]            BIT ,
        [filter_definition]     VARCHAR(MAX),
        [currentFilegroupName]  VARCHAR(128),
        [CurrentCompression]    VARCHAR(128));
INSERT INTO @PrimaryUniqueKeys${isTempTable?'Tmp':''}
    SELECT
        [SCH].[schema_id], [SCH].[name] AS [SCHEMA_NAME],
        [objz].[object_id], [objz].[name] AS [OBJECT_NAME],
        [IDX].[index_id], ISNULL([IDX].[name], '---') AS [index_name],
        [partitions].[ROWS], [partitions].[SizeMB], INDEXPROPERTY([objz].[object_id], [IDX].[name], 'IndexDepth') AS [IndexDepth],
        [IDX].[type], [IDX].[type_desc], [IDX].[fill_factor],
        [IDX].[is_unique], [IDX].[is_primary_key], [IDX].[is_unique_constraint],
        ISNULL([Index_Columns].[index_columns_key], '---') AS [index_columns_key],
        ISNULL([Index_Columns].[index_columns_include], '---') AS [index_columns_include],
        [IDX].[has_filter],
        [IDX].[filter_definition],
        [filz].[name],
        ISNULL([p].[data_compression_desc],'')
    FROM [sys].[objects] AS [objz]
        INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[schemas] AS [SCH] ON [objz].[schema_id]=[SCH].[schema_id]
        INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[indexes] AS [IDX] ON [objz].[object_id]=[IDX].[object_id]
        INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[filegroups] AS [filz] ON [IDX].[data_space_id] = [filz].[data_space_id]
        INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[partitions] AS [p]     ON  [IDX].[object_id] =  [p].[object_id]  AND [IDX].[index_id] = [p].[index_id]
        INNER JOIN (
             SELECT
                 [statz].[object_id], [statz].[index_id], SUM([statz].[row_count]) AS [ROWS],
                 CONVERT(NUMERIC(19,3), CONVERT(NUMERIC(19,3), SUM([statz].[in_row_reserved_page_count]+[statz].[lob_reserved_page_count]+[statz].[row_overflow_reserved_page_count]))/CONVERT(NUMERIC(19,3), 128)) AS [SizeMB]
             FROM ${isTempTable?'[tempdb].':''}[sys].[dm_db_partition_stats] AS [statz]
             GROUP BY [statz].[object_id], [statz].[index_id]
             ) AS [partitions]
        ON  [IDX].[object_id]=[partitions].[object_id]
        AND [IDX].[index_id]=[partitions].[index_id]
    CROSS APPLY (
        SELECT
            LEFT([Index_Columns].[index_columns_key], LEN([Index_Columns].[index_columns_key])-1) AS [index_columns_key],
            LEFT([Index_Columns].[index_columns_include], LEN([Index_Columns].[index_columns_include])-1) AS [index_columns_include]
                 FROM (
                       SELECT (
                              SELECT QUOTENAME([colz].[name]) + CASE WHEN [IXCOLS].[is_descending_key] = 0 THEN ' asc' ELSE ' desc' END + ',' + ' '
                              FROM ${isTempTable?'[tempdb].':''}[sys].[index_columns] AS [IXCOLS]
                              INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[columns] AS [colz]
                                   ON  [IXCOLS].[column_id]   = [colz].[column_id]
                                   AND [IXCOLS].[object_id] = [colz].[object_id]
                              WHERE [IXCOLS].[is_included_column] = 0
                                   AND [IDX].[object_id] = [IXCOLS].[object_id]
                                   AND [IDX].[index_id] = [IXCOLS].[index_id]
                              ORDER BY [IXCOLS].[key_ordinal]
                              FOR XML PATH('')
                              ) AS [index_columns_key],
                             (
                              SELECT QUOTENAME([colz].[name]) + ',' + ' '
                              FROM ${isTempTable?'[tempdb].':''}[sys].[index_columns] AS [IXCOLS]
                              INNER JOIN ${isTempTable?'[tempdb].':''}[sys].[columns] AS [colz]
                                  ON  [IXCOLS].[column_id]   = [colz].[column_id]
                                  AND [IXCOLS].[object_id] = [colz].[object_id]
                              WHERE [IXCOLS].[is_included_column] = 1
                                  AND [IDX].[object_id] = [IXCOLS].[object_id]
                                  AND [IDX].[index_id] = [IXCOLS].[index_id]
                              ORDER BY [IXCOLS].[index_column_id]
                              FOR XML PATH('')
                             ) AS [index_columns_include]
                      ) AS [Index_Columns]
                ) AS [Index_Columns]
        WHERE [SCH].[name]  LIKE CASE WHEN @SCHEMA_NAME = ''   COLLATE SQL_Latin1_General_CP1_CI_AS THEN [SCH].[name] ELSE @SCHEMA_NAME  END
        AND [objz].[name] LIKE CASE WHEN @TABLE_NAME = ''   COLLATE SQL_Latin1_General_CP1_CI_AS THEN [objz].[name] ELSE @TABLE_NAME END
        AND [objz].[schema_id]= @SCHEMA_ID AND ( @TABLE_ID = 0 OR [objz].[object_id] = @TABLE_ID )
    ORDER BY
      [SCH].[name],
      [objz].[name],
      [IDX].[name];

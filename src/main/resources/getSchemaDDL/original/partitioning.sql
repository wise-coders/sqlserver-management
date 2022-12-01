--##############################################################################
--Partitioning Info, if Any
--##############################################################################
DECLARE @Partitioning TABLE (
 [SchemaName]           NVARCHAR(128)                                                                 NULL,
 [ObjectNameName]       NVARCHAR(128)                                                                 NULL,
 [object_id]            INT                                                                       NOT NULL,
 [ColumnName]           SYSNAME                                                                       NULL,
 [column_id]            INT                                                                       NOT NULL,
 [IndexName]            SYSNAME                                                                       NULL,
 [PartitionSchemeName]  SYSNAME                                                                   NOT NULL,
 [index_id]             INT                                                                       NOT NULL,
 [type_desc]            NVARCHAR(60)                                                                  NULL,
 [PartitionStatement]   NVARCHAR(max)                                                                 NULL)
 ;WITH t
AS
(
SELECT
  object_schema_name([i].[object_id]) AS [SchemaName],
  object_name([i].[object_id]) AS [ObjectNameName],
  [i].[object_id],
  [c].[name] As ColumnName,
  [c].[column_id],
  [i].[name] AS IndexName,
  [ps].[name] AS PartitionSchemeName,
  [i].[index_id],
  [i].[type_desc]
  FROM [sys].[dm_db_partition_stats] AS [pstats]
    INNER JOIN [sys].[partitions] AS [p] ON [pstats].[partition_id] = [p].[partition_id]
    INNER JOIN [sys].[destination_data_spaces] AS [dds] ON [pstats].[partition_number] = [dds].[destination_id]
    INNER JOIN [sys].[data_spaces] AS [ds] ON [dds].[data_space_id] = [ds].[data_space_id]
    INNER JOIN [sys].[partition_schemes] AS [ps] ON [dds].[partition_scheme_id] = [ps].[data_space_id]
    INNER JOIN [sys].[partition_functions] AS [pf] ON [ps].[function_id] = [pf].[function_id]
    INNER JOIN [sys].[indexes] AS [i] ON [pstats].[object_id] = [i].[object_id] AND [pstats].[index_id] = [i].[index_id] AND [dds].[partition_scheme_id] = [i].[data_space_id] AND [i].[type] <= 1 /* Heap or Clustered Index */
    INNER JOIN [sys].[index_columns] AS [ic] ON [i].[index_id] = [ic].[index_id] AND [i].[object_id] = [ic].[object_id] AND [ic].[partition_ordinal] > 0
    INNER JOIN [sys].[columns] AS [c] ON [pstats].[object_id] = [c].[object_id] AND [ic].[column_id] = [c].[column_id]
WHERE [i].[object_id] = @TABLE_ID
GROUP BY [i].[object_id],[c].[name],[c].[column_id],[i].[name], [ps].[name],[i].[index_id],[i].[type_desc]
)
INSERT INTO @Partitioning
SELECT DISTINCT t.* , ' ON ' + t.PartitionSchemeName + '(' + sq.Colzs + ')'  AS PartitionStatement
FROM t
CROSS APPLY (   SELECT s.Colzs
        FROM(SELECT
               Colzs = STUFF((SELECT ',' +ColumnName
                              FROM [t]
                              ORDER BY column_id
                              FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
            ) s ) sq
SELECT @PartitioningStatement = fn.[PartitionStatement] FROM @Partitioning fn WHERE fn.[object_id] = @TABLE_ID AND fn.[index_id] <=0
SET @PartitioningStatement = ISNULL(@PartitioningStatement,'')
  --##############################################################################
  -- EXTERNAL TABLES
  --##############################################################################
  INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
  SELECT
      9, [etabz].[object_id],
      CASE WHEN [etabz].[location] IS NOT NULL THEN ' LOCATION = ' + [etabz].[location] + ',' END
      + CASE WHEN [etabz].[data_source_id] IS NOT NULL THEN ' DATA_SOURCE = ' + [eds].[name] + ',' END
      + CASE WHEN [etabz].[file_format_id] IS NOT NULL THEN ' FILE_FORMAT = ' + [efs].[name] + ',' END
      + CASE WHEN [etabz].[reject_type] IS NOT NULL THEN ' REJECT_TYPE = ' + [etabz].[reject_type] + ',' END
      + CASE WHEN [etabz].[reject_value] IS NOT NULL THEN ' REJECT_VALUE = ' + [etabz].[reject_value] + ',' END
      + CASE WHEN [etabz].[reject_sample_value] IS NOT NULL THEN ' REJECT_SAMPLE_VALUE = ' + [etabz].[reject_sample_value] + ',' END
      + ' '
  FROM [sys].[external_tables] [etabz]
  LEFT JOIN [sys].[external_data_sources] [eds] ON [eds].[data_source_id] = [etabz].[data_source_id]
  LEFT JOIN [sys].[external_file_formats] [efs] ON [efs].[file_format_id] = [etabz].[file_format_id]
  WHERE
      [etabz].[schema_id] = @SCHEMA_ID
      AND ( @TABLE_ID = 0 OR [etabz].[object_id] = @TABLE_ID );

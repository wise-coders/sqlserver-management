--##############################################################################
--NEW SECTION QUERY ALL EXTENDED PROPERTIES
--##############################################################################
INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
  SELECT  16, [tabz].[object_id],
         'EXEC sys.sp_addextendedproperty
          @name = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS + [fn].[name] + ''', @value = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS + REPLACE(CONVERT(VARCHAR(MAX),[value]),'''','''''') + ''',
          @level0type = N''SCHEMA'', @level0name = '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME(@SCHEMA_NAME) + ',
          @level1type = N''TABLE'', @level1name = '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME(OBJECT_NAME([tabz].[object_id])) + ';' + CHAR(10) + 'GO' + CHAR(10) + CHAR(10)
 --SELECT objtype, objname, name, value
  FROM [sys].[tables] [tabz]
    OUTER APPLY ${isTempTable?'[tempdb].':''}[sys].[fn_listextendedproperty] (NULL, 'schema', @SCHEMA_NAME, 'table', OBJECT_NAME([tabz].[object_id]), NULL, NULL) AS [fn]
  WHERE
    [fn].[name] IS NOT NULL AND
    [tabz].[schema_id] = @SCHEMA_ID AND ( @TABLE_ID = 0 OR [tabz].[object_id] = @TABLE_ID );
    --OMacoder suggestion for column extended properties http://www.sqlservercentral.com/Forums/FindPost1651606.aspx
   WITH [obj] AS (
	SELECT [split].[a].[value]('.', 'VARCHAR(20)') AS [name]
	FROM (
		SELECT CAST ('<M>' + REPLACE('column,constraint,index,trigger,parameter', ',', '</M><M>') + '</M>' AS XML) AS [data]
		) AS [A]
		CROSS APPLY [data].[nodes] ('/M') AS [split]([a])
	)
	INSERT INTO @DDLScript ( TYPE, OBJECT_ID, LINE_TEXT )
	SELECT  16, [tabz].[object_id],
         'EXEC sys.sp_addextendedproperty
         @name = N''' COLLATE SQL_Latin1_General_CP1_CI_AS
         + [lep].[name]
         + ''', @value = N''' COLLATE SQL_Latin1_General_CP1_CI_AS
         + REPLACE(CONVERT(VARCHAR(MAX),[lep].[value]),'''','''''') + ''',
         @level0type = N''SCHEMA'', @level0name = ' COLLATE SQL_Latin1_General_CP1_CI_AS
         + QUOTENAME(@SCHEMA_NAME)
         + ',
         @level1type = N''TABLE'', @level1name = ' COLLATE SQL_Latin1_General_CP1_CI_AS
         + QUOTENAME(OBJECT_NAME([tabz].[object_id]))
         + ',
         @level2type = N''' COLLATE SQL_Latin1_General_CP1_CI_AS
         + UPPER([obj].[name])
         + ''', @level2name = ' COLLATE SQL_Latin1_General_CP1_CI_AS
         + QUOTENAME([lep].[objname]) + ';' + CHAR(10) + 'GO' + CHAR(10) + CHAR(10)  COLLATE SQL_Latin1_General_CP1_CI_AS
  --SELECT objtype, objname, name, value
  FROM [obj]
    CROSS APPLY [sys].[tables] [tabz]
	CROSS APPLY ${isTempTable?'[tempdb].':''}[sys].[fn_listextendedproperty] (NULL, 'schema', @SCHEMA_NAME, 'table', OBJECT_NAME([tabz].[object_id]), [obj].[name], NULL) AS [lep]
    WHERE
       [lep].[name] IS NOT NULL AND
       [tabz].[schema_id] = @SCHEMA_ID AND ( @TABLE_ID = 0 OR [tabz].[object_id] = @TABLE_ID );
--#########################
-- TEMP TABLES
--#########################
TEMPPROCESS:
  SELECT @TABLE_ID = OBJECT_ID('tempdb..' COLLATE SQL_Latin1_General_CP1_CI_AS + @TABLE_NAME);
 PRINT 'TEMP @TABLE_ID' + CONVERT(VARCHAR,@TABLE_ID)
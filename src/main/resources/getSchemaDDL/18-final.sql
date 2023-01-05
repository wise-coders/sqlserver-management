--###################
-- FINAL
--###################
--TYPE 3 - COLUMNS GETS A COMMA OR )
UPDATE S SET LINE_SUFFIX=','
FROM @DDLScript S
WHERE TYPE=3 AND EXISTS ( SELECT 1 FROM @DDLScript V WHERE S.OBJECT_ID=V.OBJECT_ID AND S.LINE_NO < V.LINE_NO AND V.TYPE = S.TYPE );
UPDATE S SET LINE_SUFFIX=' )'
FROM @DDLScript S
WHERE TYPE=3 AND NOT EXISTS ( SELECT 1 FROM @DDLScript V WHERE S.OBJECT_ID=V.OBJECT_ID AND S.LINE_NO < V.LINE_NO AND V.TYPE = S.TYPE );
-- TYPE 9 - TEMPORAL, EXTERNAL OR MEMORY OPTIMIZED GETS A WITH (, COMMA OR )
UPDATE S SET LINE_SUFFIX=','
FROM @DDLScript S
WHERE TYPE=9 AND EXISTS ( SELECT 1 FROM @DDLScript V WHERE S.OBJECT_ID=V.OBJECT_ID AND S.LINE_NO < V.LINE_NO AND V.TYPE = S.TYPE );
UPDATE S SET LINE_SUFFIX=' )'
FROM @DDLScript S
WHERE TYPE=9 AND NOT EXISTS ( SELECT 1 FROM @DDLScript V WHERE S.OBJECT_ID=V.OBJECT_ID AND S.LINE_NO < V.LINE_NO AND V.TYPE = S.TYPE );
UPDATE S SET LINE_PREFIX='WITH ( '
FROM @DDLScript S
WHERE TYPE=9 AND NOT EXISTS ( SELECT 1 FROM @DDLScript V WHERE S.OBJECT_ID=V.OBJECT_ID AND S.LINE_NO > V.LINE_NO AND V.TYPE = S.TYPE );

--###################
-- END
--###################
SELECT [LINE_PREFIX] + [LINE_TEXT] + [LINE_SUFFIX] as TEXT FROM @DDLScript ORDER BY [OBJECT_ID], [TYPE], [LINE_NO];
<% if ( asProcedure) { %>
  RETURN 0;
<% } %>
END
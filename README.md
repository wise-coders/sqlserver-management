# SqlServer Get Schema DDL

This project creates a procedure for generating the schema or table DDL.
This is based on Real World DBA Toolkit Version 2019-08-01 [Lowell Izaguirre lowell@stormrage.com](http://www.stormrage.com/SQLStuff/sp_GetDDL_Latest.txt).

The gradle project has two targets: 
- generate will create a procedure or a begin...end block.
- executeInDb will test one of them in a database


## License

[GPL-3 dual license](https://opensource.org/licenses/GPL-3.0).
The driver is free to use by everyone.
Code modifications allowed only to the current repository as pull requests
https://github.com/wise-coders/sqlserver-management
 
## How it works

The project consists of small queries. They insert line of text in a declared table:

```
@DDLScript TABLE (
[OBJECT_ID]             INT,
[TYPE]                  INT,
[LINE_NO]               INT IDENTITY,
[LINE_TEXT]             VARCHAR(MAX) NOT NULL,
[LINE_PREFIX]           VARCHAR(100) NOT NULL DEFAULT '',
[LINE_SUFFIX]           VARCHAR(100) NOT NULL DEFAULT ''
```

The type is 3 for columns, constraints, PK and FK keys, and other values for indexes, rules, etc.
The DDLScript will receive commas for all type 3 records.
The output will be LINE_PREFIX + LINE_TEXT + LINE_SUFFIX, ordered by OBJECT_ID, TYPE, LINE_NO.

Mandatory parameter is the schema name.
The table name is optional. If specified, the script will generate the DDL only for that table.

Please help us to keep this code up-to-date.
Thank you to Lowell Izaguirre for writing the sp_GetDDL_Latest procedure!





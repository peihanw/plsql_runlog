#### 'L' : Oracle PL/SQL logging utility package
1. Installation
```
$ git clone ...
$ cd plsql_runlog/
$ sh ./pls_chg_tbs.sh $REAL_TABLESPACE_NAME
$ sqlplus user/passwd@sid
> @run_log.sql
> @run_log_cfg.sql
> @l.sql
```

1. Usage examples
```
$ sqlplus user/passwd@sid
> @pkg_unit_test.sql
> exec pkg_unit_test.case_01;
```
```
select to_char(log_ts, 'hh24:mi:ss.ff') ts, \
log_sid sid, log_audsid audsid, log_level level, \
log_src src, log_line line, log_text text \
from run_log where log_mmdd = to_char(sysdate,'mmdd') \
order by log_ts desc; 
```

|TS|SID|AUDSID|LEVEL|SRC|LINE|TEXT|
|--------------:|-:|------:|--:|------------:|-:|:-----------|
|11:21:47.710763|88|5385410|TRC|PKG_UNIT_TEST|10|some trc log|
|11:21:47.710621|88|5385410|DBG|PKG_UNIT_TEST| 9|some dbg log|
|11:21:47.710512|88|5385410|INF|PKG_UNIT_TEST| 8|some inf log|
|11:21:47.710402|88|5385410|WRN|PKG_UNIT_TEST| 7|some wrn log|
|11:21:47.710135|88|5385410|ERO|PKG_UNIT_TEST| 6|some ero log|

while RUN_LOG_CFG is configed below, result of the above test case would be:

|LOG_SRC|LOG_LINE|LOG_LEVEL|ENABLED|
|------------:|-:|--:|-:|
|*|-1|INF|1|
|PKG_UNIT_TEST| 6|OFF|1|
|PKG_UNIT_TEST|10|TRC|1|

|TS|SID|AUDSID|LEVEL|SRC|LINE|TEXT|
|--------------:|-:|------:|--:|------------:|-:|:-----------|
|11:21:47.710763|88|5385410|TRC|PKG_UNIT_TEST|10|some trc log|
|11:21:47.710512|88|5385410|INF|PKG_UNIT_TEST| 8|some inf log|
|11:21:47.710402|88|5385410|WRN|PKG_UNIT_TEST| 7|some wrn log|

#### 'CSV' : Oracle PL/SQL csv utility package

- For now, only 'extract' is provided in the CSV utility.

```
$ sqlplus user/passwd@sid
> @csv.sql
> select csv.extract('a,bb,ccc,dddd',3) from dual;
```

#### Memo

- Test environment is Oracle 11g (11.2.0.3.0).
- SQL is formatted with Toad Extension for Eclipse.


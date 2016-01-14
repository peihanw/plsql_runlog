#### 'L' : Oracle PL/SQL logging utility package

- Installation

```
$ git clone https://github.com/peihanw/plsql_runlog.git
$ cd plsql_runlog/
$ sh ./pls_chg_tbs.sh $REAL_TABLESPACE_NAME
$ sqlplus user/passwd@sid
> @run_log.sql
> @run_log_cfg.sql
> @l.sql
```

- Usage examples

```
$ sqlplus user/passwd@sid
> @pkg_unit_test.sql
> exec pkg_unit_test.case_01;
```

![alt tag](https://cloud.githubusercontent.com/assets/8326226/12315419/a2d773d8-bab5-11e5-913b-62c837e09606.png)

While RUN_LOG_CFG is configed below:

![alt tag](https://cloud.githubusercontent.com/assets/8326226/12317638/104502e2-bace-11e5-82cc-28acf2ec94b4.png)

Only log text from line 10,8 and 7 will be logged.

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


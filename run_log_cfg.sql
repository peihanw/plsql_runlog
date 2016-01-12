CREATE TABLE RUN_LOG_CFG
(
   LOG_SRC     VARCHAR2 (200) NOT NULL,
   LOG_LINE    NUMBER (10) NOT NULL,
   LOG_LEVEL   VARCHAR2 (3) NOT NULL,
   ENABLED     NUMBER (1) DEFAULT 1 NOT NULL,
   MEMO        VARCHAR2 (255)
)
TABLESPACE PLS_CHG_TBS;

ALTER TABLE RUN_LOG_CFG
   ADD CONSTRAINT PK_RUN_LOG_CFG PRIMARY KEY (LOG_SRC, LOG_LINE)
       USING INDEX TABLESPACE PLS_CHG_TBS;

ALTER TABLE RUN_LOG_CFG
   ADD CONSTRAINT CK_RUN_LOG_CFG_LEVEL CHECK
          (LOG_LEVEL IN ('TRC',
                         'DBG',
                         'INF',
                         'WRN',
                         'ERO',
                         'OFF'));

ALTER TABLE RUN_LOG_CFG
   ADD CONSTRAINT CK_RUN_LOG_CFG_ENABLED CHECK (ENABLED IN (0, 1));

COMMENT ON TABLE RUN_LOG_CFG IS 'runtime logging config';
COMMENT ON COLUMN RUN_LOG_CFG.LOG_SRC IS
   'source name of caller procedure/package, * for wildcard';
COMMENT ON COLUMN RUN_LOG_CFG.LOG_LINE IS
   'source line number of caller procedure/package, -1 for wildcard';
COMMENT ON COLUMN RUN_LOG_CFG.LOG_LEVEL IS
   'TRC/DBG/INF/WRN/ERO, OFF for disable';
COMMENT ON COLUMN RUN_LOG_CFG.enabled IS '1:enabled, 0:disabled';
COMMENT ON COLUMN RUN_LOG_CFG.memo IS 'memo/comment/remark';

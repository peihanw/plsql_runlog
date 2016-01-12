CREATE OR REPLACE PACKAGE L
AS
   PROCEDURE ero (p_log_text IN VARCHAR2);

   PROCEDURE wrn (p_log_text IN VARCHAR2);

   PROCEDURE inf (p_log_text IN VARCHAR2);

   PROCEDURE dbg (p_log_text IN VARCHAR2);

   PROCEDURE trc (p_log_text IN VARCHAR2);

   PROCEDURE tag (p_log_tag IN VARCHAR2);

   g_log_tag   VARCHAR2 (30) := NULL;
-- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
-- unit test example:
-- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
-- begin
-- l.tag('unit test');
-- l.ero('some ero log');
-- l.wrn('some wrn log');
-- l.inf('some inf log');
-- l.dbg('some dbg log');
-- l.trc('some trc log');
-- end;
-- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
END;
/

CREATE OR REPLACE PACKAGE BODY L
AS
   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- private procedure extracts caller's src and line by parsing call_stack
   PROCEDURE parse_call_stack (p_call_stack   IN     VARCHAR2,
                               p_src             OUT VARCHAR2,
                               p_line            OUT NUMBER)
   IS
      v_cnt          PLS_INTEGER := 0;
      v_pos          PLS_INTEGER := 0;
      v_start        PLS_INTEGER := 1;
      v_stack_line   VARCHAR2 (2000);
   BEGIN
      p_src := 'ukn';
      p_line := 0;

      IF p_call_stack IS NULL
      THEN
         RETURN;
      END IF;

      WHILE TRUE
      LOOP
         v_pos :=
            INSTR (p_call_stack,
                   CHR (10),
                   v_start,
                   1);

         IF v_pos <= 0
         THEN
            p_src := 'Ukn';
            RETURN;
         END IF;

         v_stack_line := SUBSTR (p_call_stack, v_start, v_pos - v_start);

         IF REGEXP_LIKE (v_stack_line, '^[0-9a-fA-FxX]+ +[0-9]+ ')
         THEN
            v_cnt := v_cnt + 1;

            IF v_cnt = 3
            THEN
               p_src := REGEXP_SUBSTR (v_stack_line, '[ \.][^ \.]+$');

               IF p_src IS NULL
               THEN
                  p_src := 'UKn';
               ELSE
                  p_src := SUBSTR (p_src, 2);
               END IF;

               p_line := REGEXP_SUBSTR (v_stack_line, ' [0-9]+ ');

               IF p_line IS NULL
               THEN
                  p_line := 0;
               ELSE
                  p_line := TRIM (p_line);
               END IF;

               RETURN;
            END IF;
         END IF;

         v_start := v_pos + 1;
      END LOOP;

      p_src := 'UKN';
      p_line := 0;
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_src := 'ukN';
         p_line := 0;
         RETURN;
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- private function convert 'OFF|ERO|WRN|INF|DBG|TRC' to '0|1|2|3|4|5'
   FUNCTION cvt_log_level (p_log_level IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      IF p_log_level = 'OFF'
      THEN
         RETURN 0;
      ELSIF p_log_level = 'ERO'
      THEN
         RETURN 1;
      ELSIF p_log_level = 'WRN'
      THEN
         RETURN 2;
      ELSIF p_log_level = 'INF'
      THEN
         RETURN 3;
      ELSIF p_log_level = 'DBG'
      THEN
         RETURN 4;
      ELSE
         RETURN 5;
      END IF;
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- private procedure called by (ero|wrn|inf|dbg|trc), do NOT call it directly
   PROCEDURE log_add (p_log_level IN VARCHAR2, p_log_text IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_now           TIMESTAMP;
      v_log_src       VARCHAR2 (200);
      v_log_line      NUMBER;
      v_log_src_int   NUMBER;
      v_log_cfg_int   NUMBER;
   BEGIN
      v_now := SYSTIMESTAMP;
      parse_call_stack (DBMS_UTILITY.format_call_stack (),
                        v_log_src,
                        v_log_line);
      v_log_src_int := cvt_log_level (p_log_level);

      FOR i
         IN (SELECT log_level
               FROM run_log_cfg t
              WHERE     t.log_src = v_log_src
                    AND t.log_line = v_log_line
                    AND enabled = 1
             UNION ALL
             SELECT log_level
               FROM run_log_cfg t
              WHERE t.log_src = v_log_src AND t.log_line = -1 AND enabled = 1
             UNION ALL
             SELECT log_level
               FROM run_log_cfg t
              WHERE t.log_src = '*' AND t.log_line = -1 AND enabled = 1
             UNION ALL
             SELECT 'TRC' FROM DUAL)
      LOOP
         v_log_cfg_int := cvt_log_level (i.log_level);

         IF v_log_cfg_int < v_log_src_int
         THEN
            RETURN;
         END IF;

         INSERT INTO run_log (log_mmdd,
                                  log_ts,
                                  log_sid,
                                  log_audsid,
                                  log_level,
                                  log_src,
                                  log_line,
                                  log_tag,
                                  log_text)
              VALUES (TO_CHAR (v_now, 'MMDD'),
                      v_now,
                      SYS_CONTEXT ('USERENV', 'SID'),
                      SYS_CONTEXT ('USERENV', 'SESSIONID'),
                      p_log_level,
                      v_log_src,
                      v_log_line,
                      g_log_tag,
                      p_log_text);

         COMMIT;
         RETURN;
      END LOOP;
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- public procedure wrapping ERO level log
   PROCEDURE ero (p_log_text IN VARCHAR2)
   IS
   BEGIN
      log_add ('ERO', p_log_text);
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- public procedure wrapping WRN level log
   PROCEDURE wrn (p_log_text IN VARCHAR2)
   IS
   BEGIN
      log_add ('WRN', p_log_text);
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- public procedure wrapping INF level log
   PROCEDURE inf (p_log_text IN VARCHAR2)
   IS
   BEGIN
      log_add ('INF', p_log_text);
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- public procedure wrapping DBG level log
   PROCEDURE dbg (p_log_text IN VARCHAR2)
   IS
   BEGIN
      log_add ('DBG', p_log_text);
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- public procedure wrapping TRC level log
   PROCEDURE trc (p_log_text IN VARCHAR2)
   IS
   BEGIN
      log_add ('TRC', p_log_text);
   END;

   -- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
   -- public procedure set LOG_TAG
   PROCEDURE tag (p_log_tag IN VARCHAR2)
   IS
   BEGIN
      g_log_tag := p_log_tag;
   END;
END;
/

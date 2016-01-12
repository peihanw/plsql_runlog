CREATE OR REPLACE PACKAGE CSV
AS
   FUNCTION EXTRACT (p_str         IN VARCHAR2,
                     p_idx         IN PLS_INTEGER,
                     p_delimiter   IN VARCHAR2 := ',')
      RETURN VARCHAR2;
-- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
-- unit test example:
-- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
-- select csv.extract('a,bb,ccc,dddd', 3) from dual; -- returns 'ccc'
-- = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =     
END csv;
/

CREATE OR REPLACE PACKAGE BODY csv
IS
   FUNCTION EXTRACT (p_str         IN VARCHAR2,
                     p_idx         IN PLS_INTEGER,
                     p_delimiter   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_delimiter_len   PLS_INTEGER;
      v_cnt             PLS_INTEGER := 1;
      v_pos             PLS_INTEGER;
      v_start           PLS_INTEGER := 1;
   BEGIN
      IF p_str IS NULL
      THEN
         RETURN NULL;
      END IF;

      IF p_delimiter IS NULL
      THEN
         RETURN NULL;
      END IF;

      v_delimiter_len := LENGTH (p_delimiter);

      WHILE TRUE
      LOOP
         v_pos :=
            INSTR (p_str,
                   p_delimiter,
                   v_start,
                   1);

         IF v_cnt = p_idx
         THEN
            IF v_pos > 0
            THEN
               RETURN SUBSTR (p_str, v_start, v_pos - v_start);
            ELSE
               RETURN SUBSTR (p_str, v_start);
            END IF;
         END IF;

         IF v_pos <= 0
         THEN
            RETURN NULL;
         END IF;

         v_cnt := v_cnt + 1;
         v_start := v_pos + v_delimiter_len;
      END LOOP;

      RETURN NULL;
   END;
END;
/

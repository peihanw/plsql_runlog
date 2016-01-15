CREATE OR REPLACE PACKAGE pkg_unit_test
AS
   PROCEDURE case_01;

   PROCEDURE case_02;
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_unit_test
AS
   PROCEDURE case_01
   IS
   BEGIN
      l.ero ('some ero log');
      l.wrn ('some wrn log');
      l.inf ('some inf log');
      l.dbg ('some dbg log');
      l.trc ('some trc log');
   END;

   PROCEDURE fake_lowest
   IS
   BEGIN
      l.trc ('from lowest');
      RAISE VALUE_ERROR;
   EXCEPTION
      WHEN OTHERS
      THEN
         l.ero ('exception' || CHR (10) || DBMS_UTILITY.format_call_stack ());
   END;

   PROCEDURE fake_lower
   IS
   BEGIN
      l.trc ('from lower');
      fake_lowest;
   END;

   PROCEDURE fake_low
   IS
   BEGIN
      l.trc ('from low');
      fake_lower;
   END;

   PROCEDURE fake_middle
   IS
   BEGIN
      l.trc ('from middle');
      fake_low;
   END;

   PROCEDURE fake_high
   IS
   BEGIN
      l.trc ('from high');
      fake_middle;
   END;

   PROCEDURE fake_higher
   IS
   BEGIN
      l.trc ('from higher');
      fake_high;
   END;

   PROCEDURE fake_highest
   IS
   BEGIN
      l.trc ('from highest');
      fake_higher;
   END;

   PROCEDURE case_02
   IS
   BEGIN
      l.inf ('case 02 begin');
      fake_highest;
   END;
END;
/

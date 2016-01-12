CREATE OR REPLACE PACKAGE pkg_unit_test
AS
   PROCEDURE case_01;
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
END;
/

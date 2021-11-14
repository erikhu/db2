CREATE OR REPLACE PROCEDURE fechas_escenario_libre(byYear IN NUMBER, scenario in NUMBER) IS
CURSOR lapses IS
SELECT fechainicio, fechafin
FROM contrato
WHERE EXTRACT(YEAR FROM fechainicio) = byYear
OR EXTRACT(YEAR FROM fechafin) = byYear
GROUP BY fechainicio, fechafin
ORDER BY fechainicio;
busydate lapses%ROWTYPE;
freedate lapses%ROWTYPE;
TYPE interval_t IS TABLE OF lapses%ROWTYPE INDEX BY BINARY_INTEGER;
fechainicioaux contrato.fechainicio%TYPE;
fechafinaux contrato.fechafin%TYPE;
intervals interval_t;
pindex NUMBER(8);
BEGIN
fechainicioaux := TO_DATE('01/01/'||byYear, 'dd/mm/yyyy');
fechafinaux := TO_DATE('31/12/'||byYear, 'dd/mm/yyyy');
pindex := 0;
OPEN lapses;
LOOP
FETCH lapses INTO busydate;
EXIT WHEN lapses%NOTFOUND;
freedate.fechainicio := busydate.fechainicio - 1;
freedate.fechafin := busydate.fechafin + 1;
IF pindex = 0 THEN
    intervals(pindex) := freedate;
    pindex := 1;
ELSIF intervals(pindex-1).fechafin + 1 < freedate.fechainicio THEN
    intervals(pindex) := freedate;
    pindex := pindex + 1;
ELSE
    freedate.fechainicio := intervals(pindex-1).fechainicio;
    IF freedate.fechafin < intervals(pindex-1).fechafin THEN
        freedate.fechafin := intervals(pindex-1).fechafin;
    END IF;
    intervals(pindex-1) := freedate;
END IF;
END LOOP;
CLOSE lapses;
IF pindex > 0 THEN
   IF intervals(0).fechainicio < fechainicioaux THEN
      intervals(0).fechainicio := fechainicioaux;
   END IF;
   IF fechafinaux < intervals(pindex-1).fechafin THEN
      intervals(pindex-1).fechafin := fechafinaux;
   END IF;
END IF;
FOR i IN 0..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;

BEGIN
fechas_escenario_libre(2020, 1);
END;


-- 05-JAN-20	20-JAN-20
-- 10-JAN-20	25-JAN-20
-- 04-MAR-20	05-MAR-20
-- 06-MAR-20	07-MAR-20

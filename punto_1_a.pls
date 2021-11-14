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
IF pindex = 0 THEN
   freedate := busydate;
   IF busydate.fechainicio > fechainicioaux THEN
      freedate.fechainicio := fechainicioaux;
      freedate.fechafin := busydate.fechainicio - 1;
   ELSE
      freedate.fechainicio := busydate.fechafin + 1;
      freedate.fechafin := fechafinaux;
   END IF;
   intervals(pindex) := freedate;
   pindex := pindex+1;
ELSE
   IF busydate.fechainicio <= intervals(pindex-1).fechafin THEN
      intervals(pindex-1).fechafin := busydate.fechainicio - 1;
      freedate := busydate;
   ELSE
      freedate.fechainicio := freedate.fechafin + 1;
      freedate.fechafin := fechafinaux;
      intervals(pindex) := freedate;
      pindex := pindex + 1;
   END IF;
END IF;
END LOOP;
CLOSE lapses;
IF pindex > 0 THEN
   IF fechafinaux == intervals(pindex-1).fechainicio THEN
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

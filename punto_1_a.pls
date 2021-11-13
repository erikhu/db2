/* punto 1 a */
CREATE OR REPLACE PROCEDURE print_available_lapse_scenario(byYear IN NUMBER, scenario in NUMBER) IS
CURSOR lapses IS
SELECT fechainicio, fechafin
FROM contrato
WHERE EXTRACT(YEAR FROM fechainicio) = byYear
OR EXTRACT(YEAR FROM fechafin) = byYear
GROUP BY fechainicio, fechafin
ORDER BY fechainicio;
busydate lapses%ROWTYPE;
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
intervals(pindex) := busydate;
pindex := 1;
ELSIF intervals(pindex-1).fechafin < busydate.fechainicio THEN
intervals(pindex) := busydate;
pindex := pindex + 1;
ELSE
busydate.fechainicio := intervals(pindex-1).fechainicio;
IF busydate.fechafin < intervals(pindex-1).fechafin THEN
busydate.fechafin := intervals(pindex-1).fechafin;
END IF;
intervals(pindex-1) := busydate;
END IF;
END LOOP;
CLOSE lapses;
IF pindex > 0 THEN
IF intervals(0).fechainicio < fechainicioaux THEN
intervals(0).fechainicio := fechainicioaux;
END IF;
IF fechainicioaux < intervals(pindex-1).fechafin THEN
intervals(0).fechafin := fechafinaux;
END IF;
END IF;
FOR i IN 0..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;

BEGIN
print_available_lapse_scenario(2020, 1);
END;

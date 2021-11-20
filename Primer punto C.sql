/* Tramos ocupados */
CREATE OR REPLACE PROCEDURE fechas_escenario_ocupado_gen(byYear IN NUMBER) IS
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
ELSIF intervals(pindex-1).fechafin + 1< busydate.fechainicio THEN
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
IF fechafinaux < intervals(pindex-1).fechafin THEN
intervals(pindex-1).fechafin := fechafinaux;
END IF;
END IF;
DBMS_OUTPUT.PUT_LINE('Tramos continuos ocupados durante todo el año:');
FOR i IN 0..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;

/* Tramos desocupados */
CREATE OR REPLACE PROCEDURE fechas_escenario_libre_gen(byYear IN NUMBER) IS
CURSOR lapses IS
SELECT fechainicio, fechafin
FROM contrato
WHERE (EXTRACT(YEAR FROM fechainicio) = byYear 
OR EXTRACT(YEAR FROM fechafin) = byYear)
GROUP BY fechainicio, fechafin
ORDER BY fechainicio;
busydate lapses%ROWTYPE;
freedate lapses%ROWTYPE;
TYPE interval_t IS TABLE OF lapses%ROWTYPE INDEX BY BINARY_INTEGER;
fechainicioaux contrato.fechainicio%TYPE;
fechafinaux contrato.fechafin%TYPE;
intervals interval_t;
pindex NUMBER(8);
it NUMBER(8);
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
ELSIF intervals(pindex-1).fechafin < freedate.fechainicio THEN
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
it := 0;
IF pindex > 0 THEN
	IF intervals(0).fechainicio > fechainicioaux THEN
		freedate.fechainicio := fechainicioaux;
	ELSE
		freedate.fechainicio := intervals(0).fechafin;
		it := 1;
	END IF;	
	
	FOR i IN it..pindex-1 LOOP
		busydate.fechafin := intervals(i).fechafin;
		freedate.fechafin := intervals(i).fechainicio;
		intervals(i) := freedate;
		freedate.fechainicio := busydate.fechafin;
	END LOOP;
	
	IF busydate.fechafin < fechafinaux THEN
		freedate.fechainicio := busydate.fechafin;
		freedate.fechafin := fechafinaux;
		intervals(pindex) := freedate; 
		pindex := pindex + 1;
	END IF;
END IF;
DBMS_OUTPUT.PUT_LINE('Tramos continuos desocupados durante todo el año:');
FOR i IN it..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;

CREATE OR REPLACE PROCEDURE caso_combinado(byYear IN NUMBER) IS
BEGIN
    fechas_escenario_libre_gen(byYear);
    fechas_escenario_ocupado_gen(byYear);
END;


BEGIN
    caso_combinado(2015);
END;

INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (1, TO_DATE('01/05/2020', 'mm/dd/yyyy'), TO_DATE('01/20/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (5, TO_DATE('01/10/2020', 'mm/dd/yyyy'), TO_DATE('01/25/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (8, TO_DATE('03/04/2020', 'mm/dd/yyyy'), TO_DATE('03/05/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (21, TO_DATE('03/04/2020', 'mm/dd/yyyy'), TO_DATE('03/05/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (23, TO_DATE('03/06/2020', 'mm/dd/yyyy'), TO_DATE('03/07/2020', 'mm/dd/yyyy'), 8);

INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (28, TO_DATE('01/18/2020', 'mm/dd/yyyy'), TO_DATE('01/28/2020', 'mm/dd/yyyy'), 99);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (9, TO_DATE('11/05/2020', 'mm/dd/yyyy'), TO_DATE('04/07/2021', 'mm/dd/yyyy'), 99);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (15, TO_DATE('03/06/2019', 'mm/dd/yyyy'), TO_DATE('03/10/2019', 'mm/dd/yyyy'), 99);

INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (100, TO_DATE('03/01/2017', 'mm/dd/yyyy'), TO_DATE('03/20/2017', 'mm/dd/yyyy'), 3);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (200, TO_DATE('03/01/2017', 'mm/dd/yyyy'), TO_DATE('04/25/2017', 'mm/dd/yyyy'), 3);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (300, TO_DATE('05/05/2017', 'mm/dd/yyyy'), TO_DATE('05/19/2017', 'mm/dd/yyyy'), 3);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (400, TO_DATE('04/28/2017', 'mm/dd/yyyy'), TO_DATE('06/01/2017', 'mm/dd/yyyy'), 1);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (10, TO_DATE('05/06/2021', 'mm/dd/yyyy'), TO_DATE('05/10/2021', 'mm/dd/yyyy'), 99);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (11, TO_DATE('04/25/2021', 'mm/dd/yyyy'), TO_DATE('06/10/2021', 'mm/dd/yyyy'), 2);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (19, TO_DATE('04/25/2016', 'mm/dd/yyyy'), TO_DATE('04/29/2016', 'mm/dd/yyyy'), 2);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (2, TO_DATE('01/01/2015', 'mm/dd/yyyy'), TO_DATE('04/25/2015', 'mm/dd/yyyy'), 2);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (3, TO_DATE('04/29/2015', 'mm/dd/yyyy'), TO_DATE('05/25/2015', 'mm/dd/yyyy'), 2);



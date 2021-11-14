DROP TABLE contrato;

CREATE TABLE contrato(
codigo NUMBER(8),
fechainicio DATE NOT NULL,
fechafin DATE NOT NULL,
CHECK (fechafin - fechainicio >= 1),
escenario NUMBER(8) NOT NULL
);


CREATE OR REPLACE PROCEDURE auto_popular(start_from IN NUMBER, finished IN NUMBER, fechaI IN VARCHAR, fechaF IN VARCHAR) IS
BEGIN
FOR i IN start_from..finished LOOP
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (i, TO_DATE(fechaI, 'dd-mm-yyyy'), TO_DATE(fechaF, 'dd-mm-yyyy'), DBMS_RANDOM.VALUE(1, 10));
END LOOP;
END;

BEGIN
auto_popular(12,20, '11-12-2020', '21-12-2020');
auto_popular(21,30, '01-10-2020', '30-12-2020');
auto_popular(31,60, '01-09-2020', '30-12-2020');
auto_popular(61,80, '17-05-2020', '16-06-2020');
auto_popular(81,100, '05-03-2020', '03-07-2020');
auto_popular(101,120, '05-03-2019', '02-01-2020');
auto_popular(121,130, '01-02-2021', '03-02-2021');
END;

SELECT * FROM contrato;


INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (1, TO_DATE('01/05/2020', 'mm/dd/yyyy'), TO_DATE('01/20/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (5, TO_DATE('01/10/2020', 'mm/dd/yyyy'), TO_DATE('01/25/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (8, TO_DATE('03/04/2020', 'mm/dd/yyyy'), TO_DATE('03/05/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (21, TO_DATE('03/04/2020', 'mm/dd/yyyy'), TO_DATE('03/05/2020', 'mm/dd/yyyy'), 8);
INSERT INTO contrato (codigo, fechainicio, fechafin, escenario) VALUES (23, TO_DATE('03/06/2020', 'mm/dd/yyyy'), TO_DATE('03/07/2020', 'mm/dd/yyyy'), 8);

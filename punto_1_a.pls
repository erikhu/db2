/* punto 1 a */
CREATE OR REPLACE PROCEDURE print_available_lapse_scenario(byYear IN NUMBER, scenario in NUMBER) IS
CURSOR lapses IS SELECT * FROM contrato WHERE EXTRACT(YEAR FROM fechainicio) = byYear OR EXTRACT(YEAR FROM fechafin) = byYear;
mi contrato%ROWTYPE;
BEGIN
OPEN lapses;
LOOP
FETCH lapses INTO mi;
EXIT WHEN lapses%NOTFOUND;
DBMS_OUTPUT.PUT_LINE(mi.fechainicio);
END LOOP;
CLOSE lapses;
END;

BEGIN
print_available_lapse_scenario(2020, 1);
END;

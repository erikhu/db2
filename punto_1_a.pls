/* punto 1 b */
/*
Se soluciona este punto utilizando un cursor para iterar sobre un conjunto agrupado por fechas de inicio y fechas fin, tambien
se ordena por fecha de inicio (esto ultimo es clave para solucionar el problema).
Una variable busydate para ir actualizando el elemento traido con el cursor.
se define un arreglo con los elemento del tipo de las filas del cursor.
se usa la variable pindex para como puntero del arreglo.
Y se utilizar las variable fechainicioaux y fechafinaux para ajustar al final los tramos que esten fuera del ano.

El proceso de solucion al problema es el siguiente:
Cuando se itera sobre el cursor validamos unas condiciones para actualizar el arreglo.

La validacion es la siguiente:
* La primera condicion, es una especie de condicional base, donde si existe al menos un elemento en el cursor, este se asigne a un arreglo por defecto.
* La siguiente validacion ocurre cuando al menos existe un elemento en el arreglo y esta consiste en verificar si su fecha de fin es menor a la fecha de inicio
del nuevo elemento, si es correcto se infiere que esta fila es un nuevo registro para agregar
(esta inferencia es gracias a que la consulta del cursor esta ordenada por fecha de inicio).
* Si no se cumplio la condicion anterior se puede deducir que entonces la fecha de inicio del elemento del arreglo es menor o igual,
por lo que puede se un caso de tramos iguales o que el nuevo elemento contenga al guardado en el arreglo. Por lo que asumimos
que se puede remplazar el elemento del arreglo con el nuevo elemento sacado del cursor. No sin antes verificar que la fecha fin del elemento del arreglo
sea mayor a la fecha fin del nuevo elemento , si esta condicion se cumple entonces sabremos que el elemento del arreglo contiene al nuevo elemento pero
como siempre vamos a remplazar en este punto procedemos a actualizar la fecha fin del elemento nuevo y actualizamos el viejo elemento del arreglo con el nuevo.

Finalmente antes de mostrar los tramos en los que el escenario sera ocupado en el ano,
verificamos que el primer tramo en su fecha inicial no sea de otro ano pues si es asi lo actualizamos al valor por defecto de
la variable fechainicioaux.
Del mismo modo con el ultimo tramo del arreglo, verificamos que su fecha fin no sea del proximo ano pues si es asi,
la fecha fin del ultimo tramo sera actualizado por el valor por defecto de la variable fechafinaux.
*/
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

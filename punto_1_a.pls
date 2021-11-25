/*
Para encontrar las fechas de los escenarios libre se realiza la siguiente iteracion:
Se consultan las fechas del escenario segun el ano y escenario, sea que la fechainicio o la fechafin incluyan el ano.
Luego ordenamos la consulta (esto es muy importante).
Por medio de un cursor se recorren los registros y se almacena en una lista las fecha en las cuales
el escenario esta libre. estas serian fechainicio - un dia y fechafin + un dia.
En ese recorrido se registran esas fechas en un arreglo y se verifica antes de registrarse si
en lo nuevo que se va registrar la fechainicio es mayor a la fecha fin del registrado previo.
Si esta condicion se cumple entonces se guarda ese nuevo registro sin ningun problema.
De lo contrario estariamos ante un caso de fechas cruzadas o que una contenga la otra.
En este ultima caso como la fechafin del registro previo es mayor a la fechainicio del que se piensa
ingresar, asumimos entonces que la fechainicio del nuevo registro no puede ser ya que estaria dentro del
rango de los dias ocupados o por fuera de los dias libres. Por lo que sabemos que posiblemente tendremos que actualizar la fechafin del
el registro anterior en vez de guardar un nuevo elemento en la lista. Para saber si vamos a mantener la fechafin
del registro anterior y saber que no va ser necesario actualizarlo, verificamos que la fechafin del nuevo registro sea menor al elemento de la lista.
Si este se cumple entonces sabemos que no es necesario actualizar la nueva fecha. Luego de todos modos se actualiza el mismo valor en el mismo registro
pero esto es para no anadir mas condicionales.

Luego organizamos las fechas de los intervalos, ya que en el primer paso se iteraron las fechas pero no quedaron los intervalos
correctamente formados, sino que quedaron los intervalos como inversos. osea por ejemplo en vez de tener en una
elemento ene 5 - ene 10 , se tiene ene 4 - ene 11. es al como inverso por que realmente los valores deberian ser ene 1 - ene 4 y ene 11 - dic 31.
Por lo que este paso es importante para organizar esa informacion correctamente.

En el ciclo para organizar la data despues de traida y procesado, lo primero que se verifica
que si existe algo que organizar.
En el codigo con anterioridad definimos en dos variables cual va ser nuestro rango a encontra en este caso
es desde enero 1 hasta diciembre 31 del ano en cuestion.
con base a esto, podemos quitar fechas que incluyan anos que posiblemente hayan quedado de las operaciones anteriores.
Esto ocurre por lo general en el primer registro o en el ultimo, o en ambos.
Luego verificamos si el primer registro su fecha de inicio es menos a la fiche inicial del ano osea ene 1, si esto es asi. entonces
asumimos que nuestra fecha libre inicial va ser ene 1 sino nuestra fecha inicio sera la fecha fin del primer registro y
vamos a empezar el siguiente for desde 1 en vez de 0.
Dentro del for siguiente, organizamos entonces los intervalos reutilizando la variable freedate para actualizar los intervalos y la variable busydate
como apoyo que guarda fechas que se usan en la proximo iteracion.
En este for antes de actualizar nuevamente el registro se cache en la variable busydate la fechafin y se actualiza en freedate la fechafin con la fechainicial
el elemento del elemento actual en el for. luego se guarda y despues de eso se actualiza la fechainicio de freedate para continuar con el ciclo.
por supuesto al final del ciclo es posible que la fechafin que estamos almacenando temporalmente en busydate sea menor a la fecha final del ano que es diciembre 31,
si esto ocurre anadimos un nuevo registro donde consideramos este nuevo intervalo para asi cerrar el ano.
Al final recorremos de nuevo el arreglo mostrando los elementos.
*/
CREATE OR REPLACE PROCEDURE fechas_escenario_libre(byYear IN NUMBER, scenario in NUMBER) IS
CURSOR lapses IS
SELECT fechainicio, fechafin
FROM contrato
WHERE (EXTRACT(YEAR FROM fechainicio) = byYear 
OR EXTRACT(YEAR FROM fechafin) = byYear) AND escenario = scenario
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
FOR i IN it..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;
BEGIN
fechas_escenario_libre(2020, 8);
END;


-- 05-JAN-20	20-JAN-20
-- 10-JAN-20	25-JAN-20
-- 04-MAR-20	05-MAR-20
-- 06-MAR-20	07-MAR-20

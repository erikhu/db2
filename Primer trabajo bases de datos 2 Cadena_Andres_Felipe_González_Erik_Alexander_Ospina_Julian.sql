/* Punto 1A */
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

/* Punto 1B */
CREATE OR REPLACE PROCEDURE fechas_escenario_ocupado(byYear IN NUMBER, scenario in NUMBER) IS
CURSOR lapses IS
SELECT fechainicio, fechafin
FROM contrato
WHERE (EXTRACT(YEAR FROM fechainicio) = byYear 
OR EXTRACT(YEAR FROM fechafin) = byYear) AND escenario = scenario
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
ELSIF intervals(pindex-1).fechafin + 1 < busydate.fechainicio THEN
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
FOR i IN 0..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;


/* Punto 1C
Tramos ocupados */
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
DBMS_OUTPUT.PUT_LINE('Tramos continuos ocupados durante todo el a??o:');
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
DBMS_OUTPUT.PUT_LINE('Tramos continuos desocupados durante todo el a??o:');
FOR i IN it..pindex-1 LOOP
DBMS_OUTPUT.PUT_LINE(intervals(i).fechainicio || ' ' || intervals(i).fechafin);
END LOOP;
END;

CREATE OR REPLACE PROCEDURE caso_combinado(byYear IN NUMBER) IS
BEGIN
    fechas_escenario_libre_gen(byYear);
    fechas_escenario_ocupado_gen(byYear);
END;





/* Punto 2A */
CREATE OR REPLACE TRIGGER controlSalarioEmpleadosUpdate
FOR UPDATE ON empleado
COMPOUND TRIGGER
    salarioEmpleado empleado.salario%TYPE;
    salarioJefe empleado.salario%TYPE;
    jefeViejo empleado.jefe%TYPE;
    codigoViejo empleado.codigo%TYPE;
    salarioNuevo empleado.salario%TYPE;
    salarioViejo empleado.salario%TYPE;

    BEFORE EACH ROW IS
    BEGIN
        jefeViejo := :OLD.jefe;
        codigoViejo := :OLD.codigo;
        salarioNuevo := :NEW.salario;
        salarioViejo := :OLD.salario;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        IF jefeViejo IS NULL THEN
            FOR emp IN (SELECT salario FROM empleado WHERE jefe = codigoViejo)
            LOOP    
                IF emp.salario > salarioNuevo THEN
                    UPDATE empleado SET salario = salarioViejo WHERE codigo = codigoViejo;
                    RAISE_APPLICATION_ERROR(-20506,'El salario del jefe no puede ser menor al de sus empleados');
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            SELECT salario INTO salarioJefe
            FROM empleado WHERE codigo = jefeViejo;
            IF salarioJefe < salarioNuevo THEN
                UPDATE empleado SET salario = salarioViejo WHERE codigo = codigoViejo;
                RAISE_APPLICATION_ERROR(-20505,'Salario de empleado mayor al del jefe');
            END IF;
            FOR emp IN (SELECT salario FROM empleado WHERE jefe = codigoViejo)
            LOOP    
                    IF emp.salario > salarioNuevo THEN
                        UPDATE empleado SET salario = salarioViejo WHERE codigo = codigoViejo;
                        RAISE_APPLICATION_ERROR(-20506,'El salario del jefe no puede ser menor al de sus empleados');
                        EXIT;
                    END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('');
    END AFTER STATEMENT;
END controlSalarioEmpleadosUpdate;

CREATE OR REPLACE TRIGGER controlSalarioEmpleadosInsert
FOR INSERT ON empleado
COMPOUND TRIGGER
    salarioJefe empleado.salario%TYPE;
    salarioNuevo empleado.salario%TYPE;
    jefeNuevo empleado.jefe%TYPE;
    codigoNuevo empleado.codigo%TYPE;

    BEFORE EACH ROW IS
    BEGIN
        salarioNuevo := :NEW.salario;
        jefeNuevo := :NEW.jefe;
        codigoNuevo := :NEW.codigo;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        SELECT salario INTO salarioJefe
        FROM empleado WHERE codigo = jefeNuevo;
        IF salarioJefe < salarioNuevo THEN
            DELETE FROM empleado WHERE codigo = codigoNuevo;
            RAISE_APPLICATION_ERROR(-20505,'Salario de empleado mayor al del jefe');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('');
    END AFTER STATEMENT;
END controlSalarioEmpleadosInsert;


/* Punto 2B */
CREATE OR REPLACE TRIGGER actualizacion_depto
FOR UPDATE ON empleado
COMPOUND TRIGGER
    
    codigoEmpleado empleado.codigo%TYPE;
    codigoJefe empleado.jefe%TYPE;
    deptoNuevo empleado.depto%TYPE;
    deptoAntiguo empleado.depto%TYPE;
    deptoJefe empleado.depto%TYPE;
    
    BEFORE EACH ROW IS
    
    BEGIN
    
        codigoEmpleado := :OLD.codigo;
        codigoJefe := :OLD.jefe;
        deptoNuevo := :NEW.depto;
        deptoAntiguo := :OLD.depto;
        
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    
    BEGIN
    
        IF codigoJefe IS NULL THEN
            FOR employee IN (SELECT depto FROM empleado WHERE jefe = codigoEmpleado)
            LOOP    
                IF employee.depto = deptoNuevo THEN
                    UPDATE empleado SET depto = deptoAntiguo WHERE codigo = codigoEmpleado;
                    RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual entre el jefe y el empleado.');
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            SELECT depto INTO deptoJefe
            FROM empleado WHERE codigo = codigoJefe;
            IF deptoJefe = deptoNuevo THEN
                UPDATE empleado SET depto = deptoAntiguo WHERE codigo = codigoEmpleado;
                RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual entre el jefe y el empleado.');
            END IF;
            FOR employee IN (SELECT depto FROM empleado WHERE jefe = codigoEmpleado)
            LOOP
                IF employee.depto = deptoNuevo THEN
                    UPDATE empleado SET depto = deptoAntiguo WHERE codigo = codigoEmpleado;
                    RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual entre el jefe y el empleado.');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    END AFTER STATEMENT;
    
END actualizacion_depto;

CREATE OR REPLACE TRIGGER control_depto_nuevo_emp
FOR INSERT ON empleado
COMPOUND TRIGGER
    
    codigoEmpleadoNuevo empleado.codigo%TYPE;
    codigoJefe empleado.jefe%TYPE;
    deptoNuevo empleado.depto%TYPE;
    deptoJefe empleado.depto%TYPE;
    
    BEFORE EACH ROW IS
    
    BEGIN
    
        codigoEmpleadoNuevo := :NEW.codigo;
        codigoJefe := :NEW.jefe;
        deptoNuevo := :NEW.depto;
        deptoJefe := :OLD.depto;
        
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    
    BEGIN
        SELECT depto INTO deptoJefe
        FROM empleado WHERE codigo = codigoJefe;
        IF deptoJefe = deptoNuevo THEN
            DELETE FROM empleado WHERE codigo = codigoEmpleadoNuevo;
            RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual entre el jefe y el empleado.');
        END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('');
    END AFTER STATEMENT;
    
END control_depto_nuevo_emp;

/* Punto 2C */
CREATE OR REPLACE TRIGGER controlSalComEmpsUpdate
FOR UPDATE ON empleado
COMPOUND TRIGGER
    salarioEmpleado empleado.salario%TYPE;
    salarioJefe empleado.salario%TYPE;
    jefeViejo empleado.jefe%TYPE;
    codigoViejo empleado.codigo%TYPE;
    salarioNuevo empleado.salario%TYPE;
    salarioViejo empleado.salario%TYPE;
    comis comision.valor%TYPE;
    sumajef NUMBER(8);
    sumaemp NUMBER(8);
    sumaux NUMBER(8);

    BEFORE EACH ROW IS
    BEGIN
        jefeViejo := :OLD.jefe;
        codigoViejo := :OLD.codigo;
        salarioNuevo := :NEW.salario;
        salarioViejo := :OLD.salario;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        IF jefeViejo IS NULL THEN
            FOR emp IN (SELECT salario, codigo FROM empleado WHERE jefe = codigoViejo)
            LOOP
                sumaux := 0;
                FOR com IN (SELECT valor FROM comision WHERE codemp = emp.codigo)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumaemp := sumaux + emp.salario;
              
                sumaux := 0;
                FOR com IN (SELECT valor FROM comision WHERE codemp = codigoViejo)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumajef := sumaux + salarioNuevo;
                IF sumaemp > sumajef THEN
                    UPDATE empleado SET salario = salarioViejo WHERE codigo = codigoViejo;
                    RAISE_APPLICATION_ERROR(-20506,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            sumaux := 0;
            FOR com IN (SELECT valor FROM comision WHERE codemp = codigoViejo)
            
            LOOP
                sumaux := sumaux + com.valor;
            END LOOP;
            sumaemp := sumaux + salarioNuevo;
            
            sumaux := 0;
            SELECT salario into sumaux
            FROM empleado WHERE codigo = jefeViejo;
            FOR com IN (SELECT valor FROM comision WHERE codemp = jefeViejo)
            
            LOOP
                sumaux := sumaux + com.valor;
            END LOOP;
            sumajef := sumaux;
            IF sumajef < sumaemp THEN
                UPDATE empleado SET salario = salarioViejo WHERE codigo = codigoViejo;
                RAISE_APPLICATION_ERROR(-20505,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
            END IF;
            FOR emp IN (SELECT salario, codigo FROM empleado WHERE jefe = codigoViejo)
            LOOP    
                sumaux := 0;
                FOR com IN (SELECT valor FROM comision WHERE codemp = emp.codigo)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumaemp := sumaux + emp.salario;
                sumaux := 0;
                FOR com IN (SELECT valor FROM comision WHERE codemp = codigoViejo)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumajef := sumaux + salarioNuevo;
                IF sumaemp > sumajef THEN
                    UPDATE empleado SET salario = salarioViejo WHERE codigo = codigoViejo;
                    RAISE_APPLICATION_ERROR(-20506,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('');
    END AFTER STATEMENT;
END controlSalComEmpsUpdate;


CREATE OR REPLACE TRIGGER controlComisionUpdate
FOR UPDATE ON comision
COMPOUND TRIGGER
    valorNuevo comision.valor%TYPE;
    valorViejo comision.valor%TYPE;
    codigoEmpleado comision.codemp%TYPE;
    codigoComision comision.codcomi%TYPE;
    sumajef NUMBER(8);
    sumaemp NUMBER(8);
    sumaux NUMBER(8);
    codaux NUMBER(8);

    BEFORE EACH ROW IS
    BEGIN
        valorNuevo := :NEW.valor;
        valorViejo := :OLD.valor;
        codigoEmpleado := :OLD.codemp;
        codigoComision := :OLD.codcomi;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
            
        SELECT jefe INTO codaux
        FROM empleado WHERE codigo = codigoEmpleado;
        IF codaux IS NULL THEN
            FOR emp IN (SELECT salario, codigo FROM empleado WHERE jefe = codigoEmpleado)
            LOOP
                SELECT salario INTO sumaux
                FROM empleado WHERE codigo = emp.codigo;
                FOR com IN (SELECT valor FROM comision WHERE codemp = emp.codigo)
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumaemp := sumaux;
                sumaux := 0;
                SELECT salario INTO sumaux
                FROM empleado WHERE codigo = codigoEmpleado;
                FOR com IN (SELECT valor FROM comision WHERE codemp = codigoEmpleado)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumajef := sumaux;
                IF sumaemp > sumajef THEN
                    UPDATE comision SET valor = valorViejo WHERE codcomi = codigoComision;
                    RAISE_APPLICATION_ERROR(-20506,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            sumaux := 0;
            SELECT salario into sumaux
            FROM empleado WHERE codigo = codigoEmpleado;
            FOR com IN (SELECT valor FROM comision WHERE codemp = codigoEmpleado)
            
            LOOP
                sumaux := sumaux + com.valor;
            END LOOP;
            sumaemp := sumaux;
            
            sumaux := 0;
            SELECT salario into sumaux
            FROM empleado WHERE codigo = codaux;
            FOR com IN (SELECT valor FROM comision WHERE codemp = codaux)
            
            LOOP
                sumaux := sumaux + com.valor;
            END LOOP;
            sumajef := sumaux;
            IF sumajef < sumaemp THEN
               UPDATE comision SET valor = valorViejo WHERE codcomi = codigoComision;
                RAISE_APPLICATION_ERROR(-20505,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
            END IF;
            FOR emp IN (SELECT salario, codigo FROM empleado WHERE jefe = codigoEmpleado)
            LOOP    
                sumaux := 0;
                SELECT salario INTO sumaux
                FROM empleado WHERE codigo = emp.codigo;
                FOR com IN (SELECT valor FROM comision WHERE codemp = emp.codigo)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumaemp := sumaux + emp.salario;
                sumaux := 0;
                SELECT salario INTO sumaux
                FROM empleado WHERE codigo = codigoEmpleado;
                FOR com IN (SELECT valor FROM comision WHERE codemp = codigoEmpleado)
                
                LOOP
                    sumaux := sumaux + com.valor;
                END LOOP;
                sumajef := sumaux;
                IF sumaemp > sumajef THEN
                    UPDATE comision SET valor = valorViejo WHERE codcomi = codigoComision;
                    RAISE_APPLICATION_ERROR(-20506,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('');
    END AFTER STATEMENT;
END controlComisionUpdate;



CREATE OR REPLACE TRIGGER controlComisionInsert
FOR INSERT ON comision
COMPOUND TRIGGER
    codigoEmpleado comision.codemp%TYPE;
    comisionNueva comision.valor%TYPE;
    codigoComision comision.codcomi%TYPE;
    sumajef NUMBER(8);
    sumaemp NUMBER(8);
    sumaux NUMBER(8);
    codaux NUMBER(8);

    BEFORE EACH ROW IS
    BEGIN
        codigoComision := :NEW.codcomi;
        codigoEmpleado := :NEW.codemp;
        comisionNueva := :NEW.valor;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
            
        SELECT jefe INTO codaux
        FROM empleado WHERE codigo = codigoEmpleado;
        IF codaux IS NOT NULL THEN
            sumaux := 0;
            SELECT salario INTO sumajef
            FROM empleado WHERE codigo = codaux;
            FOR comjef IN (SELECT valor FROM comision WHERE codemp = codaux)
                
            LOOP
                sumaux := sumaux + comjef.valor;
            END LOOP;
            sumajef := sumajef + sumaux;
            
            SELECT salario into sumaemp
            FROM empleado WHERE codigo = codigoEmpleado;
            sumaux := 0;
            FOR comemp IN (SELECT valor FROM comision WHERE codemp = codigoEmpleado)
            LOOP
                sumaux := sumaux + comemp.valor;
            END LOOP;    
            sumaemp := sumaemp + sumaux;
            IF sumajef < sumaemp THEN
                DELETE FROM comision WHERE codcomi = codigoComision;
                RAISE_APPLICATION_ERROR(-20505,'La suma del salario y la comision del empleado es mayor a la de su jefe.');
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('');
    END AFTER STATEMENT;
END controlComisionInsert;



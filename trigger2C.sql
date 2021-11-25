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
            DBMS_OUTPUT.PUT_LINE('Suma del jefe');
            DBMS_OUTPUT.PUT_LINE(sumajef);
            DBMS_OUTPUT.PUT_LINE('Suma del empleado');
            DBMS_OUTPUT.PUT_LINE(sumaemp);
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

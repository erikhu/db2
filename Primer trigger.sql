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




INSERT INTO empleado VALUES(1,'Julian',NULL,200000,2);
INSERT INTO empleado VALUES(2,'Erik',1,100000,3);
INSERT INTO empleado VALUES(3,'Andres',1,100000,3);
INSERT INTO empleado VALUES(4,'Juan',1,3000,5);
INSERT INTO empleado VALUES(5,'Daniela',2,100,3);
INSERT INTO empleado VALUES(6,'Juliana',2,100,3);
INSERT INTO empleado VALUES(7,'Sebastian',2,300,5);
INSERT INTO empleado VALUES(8,'Alberto',3,100,1);
INSERT INTO empleado VALUES(9,'Luisa',3,300,2);

UPDATE empleado SET salario = 1 WHERE codigo = 3;

SELECT * FROM empleado;
DROP TABLE comision;
DROP TABLE empleado;

CREATE TABLE empleado(
codigo NUMBER(8) PRIMARY KEY,
nombre VARCHAR2(25) NOT NULL,
jefe NUMBER(8) REFERENCES empleado,
CHECK(jefe <> codigo),
salario NUMBER(8) NOT NULL CHECK(salario > 0),
depto NUMBER(8) NOT NULL CHECK(depto > 0)
);

CREATE TABLE comision(
codcomi NUMBER(8) PRIMARY KEY,
codemp NUMBER(8) REFERENCES empleado NOT NULL,
valor NUMBER(8) NOT NULL CHECK(valor > 0)
);

SHOW ERROR

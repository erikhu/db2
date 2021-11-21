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
        deptoJefe := :OLD.depto;
        
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    
    BEGIN
    
        IF codigoJefe IS NULL THEN
            FOR employee IN (SELECT depto FROM empleado WHERE jefe = codigoEmpleado)
            LOOP    
                IF employee.depto = deptoNuevo THEN
                    UPDATE empleado SET depto = deptoAntiguo WHERE codigo = codigoEmpleado;
                    RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual al del jefe.');
                    EXIT;
                END IF;
            END LOOP;
        ELSE
        
        SELECT depto INTO deptoJefe
        FROM empleado WHERE codigo = codigoJefe;
        FOR employee IN (SELECT depto FROM empleado WHERE jefe = codigoJefe)
        LOOP
            IF deptoJefe = employee.depto THEN
                UPDATE empleado SET depto = deptoAntiguo WHERE codigo = codigoEmpleado;
                RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual al del jefe.');
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
            RAISE_APPLICATION_ERROR(-20505,'El departamento ingresado no puede ser igual al del jefe.');
        END IF;
    END AFTER STATEMENT;
    
END control_depto_nuevo_emp;

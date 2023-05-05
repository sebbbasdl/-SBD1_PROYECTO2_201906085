CREATE TABLE Restaurante (
  Id_restaurante NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  Direccion VARCHAR2(255),
  Municipio VARCHAR2(50),
  Zona NUMBER CONSTRAINT zona_positiva CHECK (Zona >= 0),
  Telefono NUMBER(10),
  Personal NUMBER(10),
  Tiene_parqueo NUMBER(1)
);



CREATE TABLE Puesto (
  id_puesto NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  Nombre VARCHAR2(50),
  Descripcion VARCHAR2(255),
  Salario NUMBER(10,2) CHECK (Salario >= 0)
);

CREATE TABLE Empleados (
  id_empleado VARCHAR2(8),
  Nombres VARCHAR2(50),
  Apellidos VARCHAR2(50),
  Fecha_nacimiento DATE,
  Correo VARCHAR2(100) CHECK (REGEXP_LIKE(Correo, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
  Telefono NUMBER(10),
  Direccion VARCHAR2(255),
  Numero_DPI NUMBER(20),
  id_Puesto NUMBER,
  Fecha_inicio DATE,
  Id_Restaurante NUMBER,
  CONSTRAINT empleado_id_formato CHECK (LENGTH(id_empleado) = 8 AND id_empleado LIKE '0%'),
  CONSTRAINT pk_empleados PRIMARY KEY (id_empleado),
  CONSTRAINT fk_puesto FOREIGN KEY (id_Puesto) REFERENCES Puesto(id_puesto),
  CONSTRAINT fk_restaurante FOREIGN KEY (Id_Restaurante) REFERENCES Restaurante(Id_restaurante)
);


INSERT INTO Empleados (Nombres, Apellidos, Fecha_Nacimiento, Correo, Telefono, Direccion, Numero_DPI, id_Puesto, Fecha_Inicio, Id_Restaurante) 
VALUES ('Juan', 'Perez', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'juan.perez@example.com', 1234567, '4ta Calle 10-10 Zona 1', 12345678901234, 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1);


CREATE TABLE Cliente (
  numero_DPI NUMBER PRIMARY KEY,
  nombre VARCHAR2(100),
  apellidos VARCHAR2(100),
  fecha_nacimiento DATE,
  correo VARCHAR2(255) CONSTRAINT chk_correo CHECK (regexp_like(correo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
  telefono NUMBER(10,0),
  NIT NUMBER(10,0) NULL
);



CREATE TABLE Direccion (
  id_direccion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero_DPI NUMBER,
  Direccion VARCHAR2(255),
  Municipio VARCHAR2(100),
  Zona NUMBER CONSTRAINT zona_positiva2 CHECK (Zona >= 0),
  CONSTRAINT fk_cliente_direccion_id FOREIGN KEY (numero_DPI) REFERENCES Cliente(numero_DPI)
);




CREATE TABLE Orden (
  id_orden NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero_dpi NUMBER,
  id_direccion NUMBER,
  id_restaurante NUMBER,
  canal CHAR(1) CONSTRAINT chk_canal CHECK (canal IN ('L', 'A')),
  estado VARCHAR2(50) DEFAULT 'iniciada',
  forma_pago CHAR(1) CONSTRAINT chk_forma_pago CHECK (forma_pago IN ('E', 'T')),
  fecha_inicio DATE DEFAULT SYSDATE,
  fecha_final DATE,
  CONSTRAINT fk_orden_cliente FOREIGN KEY (numero_dpi) REFERENCES Cliente(numero_DPI),
  CONSTRAINT fk_orden_direccion FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion),
  CONSTRAINT fk_orden_restaurante FOREIGN KEY (id_restaurante) REFERENCES Restaurante(id_restaurante)
);


ALTER TABLE Orden ADD CONSTRAINT uk_orden_direccion UNIQUE (id_direccion);

CREATE TABLE Items (
  id_item NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  Id_Orden NUMBER NOT NULL,
  Tipo_producto CHAR(1) CHECK (Tipo_producto IN ('C','E','B','P')),
  Producto NUMBER,
  Cantidad NUMBER CHECK (Cantidad > 0),
  Observacion VARCHAR2(100),
  FOREIGN KEY (Id_Orden) REFERENCES Orden(Id_Orden),
  CONSTRAINT validacion_producto CHECK (
    (Tipo_producto = 'C' AND Producto BETWEEN 1 AND 6) OR
    (Tipo_producto = 'E' AND Producto BETWEEN 1 AND 3) OR
    (Tipo_producto = 'B' AND Producto BETWEEN 1 AND 5) OR
    (Tipo_producto = 'P' AND Producto BETWEEN 1 AND 4)
  )
);


--eliminar tablas
drop table items;
drop table orden;
drop table direccion;
drop table cliente;
drop table empleados;
drop table puesto;
drop table restaurante;







--Registrar restaurante
CREATE OR REPLACE PROCEDURE insertar_restaurante(
    p_direccion IN VARCHAR2,
    p_municipio IN VARCHAR2,
    p_zona IN NUMBER,
    p_telefono IN NUMBER,
    p_personal IN NUMBER,
    p_tiene_parqueo IN NUMBER
)
IS
BEGIN
  INSERT INTO Restaurante(Direccion, Municipio, Zona, Telefono, Personal, Tiene_parqueo)
  VALUES(p_direccion, p_municipio, p_zona, p_telefono, p_personal, p_tiene_parqueo);
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Restaurante insertado correctamente.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error al insertar restaurante: ' || SQLERRM);
END;



BEGIN
  insertar_restaurante('5ta. Calle 10-20 Zona 1', 'Guatemala', 1, 22334455, 20, 1);
END;

--registrar puesto
CREATE OR REPLACE PROCEDURE insertar_puesto (
    nombre_puesto IN VARCHAR2,
    descripcion_puesto IN VARCHAR2,
    salario_puesto IN NUMBER
) AS
BEGIN
    INSERT INTO Puesto (Nombre, Descripcion, Salario)
    VALUES (nombre_puesto, descripcion_puesto, salario_puesto);
    COMMIT;
END;
/

BEGIN
    insertar_puesto('Gerente', 'Encargado de administrar el área de ventas', 5000);
END;

--registrar empleada
CREATE SEQUENCE secuencia_empleados
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 99999999;



CREATE OR REPLACE PROCEDURE insertar_empleado (
    nombres IN VARCHAR2,
    apellidos IN VARCHAR2,
    fecha_nacimiento IN DATE,
    correo IN VARCHAR2,
    telefono IN NUMBER,
    direccion IN VARCHAR2,
    numero_dpi IN NUMBER,
    id_puesto IN NUMBER,
    fecha_inicio IN DATE,
    id_restaurante IN NUMBER
) AS
  v_id_empleado VARCHAR2(8);
BEGIN
  SELECT LPAD(secuencia_empleados.NEXTVAL, 8, '0') INTO v_id_empleado FROM dual;
  INSERT INTO Empleados (id_empleado, Nombres, Apellidos, Fecha_nacimiento, Correo, Telefono, Direccion, Numero_DPI, id_Puesto, Fecha_inicio, Id_Restaurante)
  VALUES (v_id_empleado, nombres, apellidos, fecha_nacimiento, correo, telefono, direccion, numero_dpi, id_puesto, fecha_inicio, id_restaurante);
  COMMIT;
END;
/



BEGIN
  insertar_empleado('Juan', 'Perez', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'juan.perez@example.com', 1234567, '4ta Calle 10-10 Zona 1', 12345678901234, 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1);
END;



--registrar cliente
CREATE OR REPLACE PROCEDURE insertar_cliente (
    numero_dpi IN NUMBER,
    nombre IN VARCHAR2,
    apellidos IN VARCHAR2,
    fecha_nacimiento IN DATE,
    correo IN VARCHAR2,
    telefono IN NUMBER,
    nit IN NUMBER DEFAULT NULL
) AS
BEGIN
    INSERT INTO Cliente (numero_DPI, nombre, apellidos, fecha_nacimiento, correo, telefono, nit)
    VALUES (numero_dpi, nombre, apellidos, fecha_nacimiento, correo, telefono, nit);
    COMMIT;
END;
/

BEGIN
    insertar_cliente(1234567890123, 'María', 'González', TO_DATE('1995-01-01', 'YYYY-MM-DD'), 'maria.gonzalez@example.com', 1234567, NULL);
END;


-- registrar direccion
CREATE OR REPLACE PROCEDURE insertar_direccion (
    numero_dpi IN NUMBER,
    direccion IN VARCHAR2,
    municipio IN VARCHAR2,
    zona IN NUMBER
) AS
BEGIN
    INSERT INTO Direccion (numero_DPI, Direccion, Municipio, Zona)
    VALUES (numero_dpi, direccion, municipio, zona);
    COMMIT;
END;
/

BEGIN
    insertar_direccion(1234567890123, '2a Avenida 10-35 Zona 15', 'Ciudad de Guatemala', 5);
END;

-- registrar orden con validaciones

CREATE OR REPLACE PROCEDURE insertar_orden(
    p_numero_dpi IN NUMBER,
    p_id_direccion IN NUMBER,
    p_canal IN CHAR,
    p_forma_pago IN CHAR,
    p_fecha_final IN DATE
) AS
    v_id_restaurante NUMBER;
    v_municipio VARCHAR2(50);
    v_zona VARCHAR2(50);
BEGIN
    -- Obtener el municipio y la zona de la dirección del cliente
    SELECT municipio, zona INTO v_municipio, v_zona FROM Direccion WHERE id_direccion = p_id_direccion;

    -- Buscar un restaurante en la misma zona y municipio
    SELECT id_restaurante INTO v_id_restaurante FROM Restaurante WHERE municipio = v_municipio AND zona = v_zona;

    -- Si no se encontró un restaurante, establecer el estado a "SIN COBERTURA"
    IF v_id_restaurante IS NULL THEN
        INSERT INTO Orden(numero_dpi, id_direccion, id_restaurante, canal, estado, forma_pago, fecha_inicio, fecha_final)
        VALUES(p_numero_dpi, p_id_direccion, NULL, p_canal, 'SIN COBERTURA', p_forma_pago, SYSDATE, SYSDATE);
    ELSE
        INSERT INTO Orden(numero_dpi, id_direccion, id_restaurante, canal, forma_pago, fecha_inicio, fecha_final)
        VALUES(p_numero_dpi, p_id_direccion, v_id_restaurante, p_canal, p_forma_pago, SYSDATE, p_fecha_final);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO Orden(numero_dpi, id_direccion, id_restaurante, canal, estado, forma_pago, fecha_inicio, fecha_final)
        VALUES(p_numero_dpi, p_id_direccion, NULL, p_canal, 'SIN COBERTURA', p_forma_pago, SYSDATE, SYSDATE);
END;




BEGIN
  insertar_orden(1234567890123, 1, 'A', 'T', NULL);
END;



--VALIDAR COBERTURA 
CREATE OR REPLACE PROCEDURE ValidarCoberturaOrden (
    p_idorden IN NUMBER,
    p_municipio IN VARCHAR2,
    p_zona IN VARCHAR2,
    o_error OUT VARCHAR2
) IS
    v_idrestaurante NUMBER;
BEGIN
    -- Validar si existe un restaurante en la misma zona y municipio que la dirección del cliente
    SELECT idrestaurante INTO v_idrestaurante
    FROM Restaurantes
    WHERE municipio = p_municipio AND zona = p_zona;
    
    -- Si se encontró un restaurante, actualizar el estado de la orden a "PENDIENTE"
    UPDATE Ordenes
    SET estado = 'PENDIENTE', idrestaurante = v_idrestaurante
    WHERE idorden = p_idorden;
    
    -- Si no se encontró un restaurante, actualizar el estado de la orden a "SIN COBERTURA"
    IF v_idrestaurante IS NULL THEN
        UPDATE Ordenes
        SET estado = 'SIN COBERTURA'
        WHERE idorden = p_idorden;
        o_error := 'No hay cobertura en el área de entrega.';
    ELSE
        o_error := NULL;
    END IF;
END;


--FACTURA
CREATE OR REPLACE FUNCTION generar_encabezado_factura(
  p_id_orden IN NUMBER,
  p_monto_total IN NUMBER,
  p_lugar IN VARCHAR2,
  p_nit_cliente IN VARCHAR2,
  p_forma_pago IN CHAR
) RETURN VARCHAR2
AS
  v_numero_serie VARCHAR2(20);
  v_fecha_actual DATE;
BEGIN
  -- Generar número de serie concatenando año en curso e id de la orden
  SELECT TO_CHAR(SYSDATE, 'YYYY') || p_id_orden INTO v_numero_serie FROM DUAL;

  -- Obtener fecha y hora actual
  v_fecha_actual := SYSDATE;

  -- Construir encabezado de factura
  RETURN 'Número de serie: ' || v_numero_serie || CHR(10) ||
         'Monto total: Q' || TO_CHAR(p_monto_total, '999,999,990.00') || CHR(10) ||
         'Lugar: ' || p_lugar || CHR(10) ||
         'Fecha y hora: ' || TO_CHAR(v_fecha_actual, 'DD/MM/YYYY HH24:MI:SS') || CHR(10) ||
         'Id de la orden: ' || p_id_orden || CHR(10) ||
         'NIT del cliente: ' || COALESCE(p_nit_cliente, 'C/F') || CHR(10) ||
         'Forma de pago: ' || CASE p_forma_pago WHEN 'E' THEN 'Efectivo' ELSE 'Tarjeta de débito o crédito' END;
END;
/





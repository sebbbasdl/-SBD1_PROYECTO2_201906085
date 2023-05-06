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
  id_empleado VARCHAR2(8),
  canal CHAR(1) CONSTRAINT chk_canal CHECK (canal IN ('L', 'A')),
  estado VARCHAR2(50) DEFAULT 'iniciada',
  forma_pago CHAR(1) CONSTRAINT chk_forma_pago CHECK (forma_pago IN ('E', 'T')),
  fecha_inicio DATE DEFAULT SYSDATE,
  fecha_final DATE,
  CONSTRAINT fk_orden_cliente FOREIGN KEY (numero_dpi) REFERENCES Cliente(numero_DPI),
  CONSTRAINT fk_orden_direccion FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion),
  CONSTRAINT fk_orden_restaurante FOREIGN KEY (id_restaurante) REFERENCES Restaurante(id_restaurante),
  CONSTRAINT fk_orden_empleado FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado)
);


--ALTER TABLE Orden ADD CONSTRAINT uk_orden_direccion UNIQUE (id_direccion);

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

CREATE TABLE Factura (
  id_factura NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero_serie VARCHAR2(20),
  monto_total NUMBER(10,2),
  lugar VARCHAR2(100),
  fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  Municipio VARCHAR2(100),
  id_orden NUMBER NOT NULL,
  nit_cliente VARCHAR2(20) CONSTRAINT chk_nit__cliente CHECK (nit_cliente IN ('C/F') OR REGEXP_LIKE(nit_cliente, '^[0-9]{8}-[0-9]$')),
  forma_pago CHAR(1) CONSTRAINT chk_forma__pago CHECK (forma_pago IN ('E', 'T')),
  FOREIGN KEY (id_orden) REFERENCES Orden(id_orden)
);


--crear menu
CREATE GLOBAL TEMPORARY TABLE menu (
  id_producto VARCHAR2(2),
  producto VARCHAR2(50),
  precio NUMBER(6,2)
)
ON COMMIT PRESERVE ROWS; -- la opcion ON COMMIT PRESERVE ROWS indica que los datos no se borran al hacer commit

INSERT INTO menu (id_producto, producto, precio) VALUES ('C1', 'Cheeseburger', 41.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('C2', 'Chicken Sandwinch', 32.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('C3', 'BBQ Ribs', 54.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('C4', 'Pasta Alfredo', 47.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('C5', 'Pizza Espinator', 85.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('C6', 'Buffalo Wings', 36.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('E1', 'Papas fritas', 15.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('E2', 'Aros de cebolla', 17.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('E3', 'Coleslaw', 12.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('B1', 'Coca-Cola', 12.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('B2', 'Fanta', 12.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('B3', 'Sprite', 12.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('B4', 'Té frío', 12.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('B5', 'Cerveza de barril', 18.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('P1', 'Copa de helado', 13.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('P2', 'Cheesecake', 15.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('P3', 'Cupcake de chocolate', 8.00);
INSERT INTO menu (id_producto, producto, precio) VALUES ('P4', 'Flan', 10.00);

--eliminar tablas
drop table factura;
drop table items;
drop table orden;
drop table direccion;
drop table cliente;
drop table empleados;
drop table puesto;
drop table restaurante;




delete from orden;





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
    insertar_direccion(1234567890123, '5ta. Calle 10-20 Zona 1', 'Guatemala', 1);
END;

-- registrar orden con validaciones

CREATE OR REPLACE PROCEDURE insertar_orden(
    p_numero_dpi IN NUMBER,
    p_id_direccion IN NUMBER,
    p_canal IN CHAR
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
        INSERT INTO Orden(numero_dpi, id_direccion, id_restaurante, canal, estado)
        VALUES(p_numero_dpi, p_id_direccion, NULL, p_canal, 'SIN COBERTURA');
    ELSE
        INSERT INTO Orden(numero_dpi, id_direccion, id_restaurante, canal)
        VALUES(p_numero_dpi, p_id_direccion, v_id_restaurante, p_canal);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO Orden(numero_dpi, id_direccion, id_restaurante, canal, estado)
        VALUES(p_numero_dpi, p_id_direccion, NULL, p_canal, 'SIN COBERTURA');
END;




BEGIN
  insertar_orden(1234567890123, 1, 'A');
END;


--agregar item

CREATE OR REPLACE PROCEDURE insertar_item (
    p_Id_Orden IN Items.Id_Orden%TYPE,
    p_Tipo_producto IN Items.Tipo_producto%TYPE,
    p_Producto IN Items.Producto%TYPE,
    p_Cantidad IN Items.Cantidad%TYPE,
    p_Observacion IN Items.Observacion%TYPE
) AS
  v_Estado Orden.Estado%TYPE;
BEGIN
  -- Obtener el estado actual de la orden
  SELECT Estado INTO v_Estado
  FROM Orden
  WHERE Id_Orden = p_Id_Orden;

  -- Verificar que el estado de la orden sea "iniciada"
  IF v_Estado != 'iniciada' THEN
    DBMS_OUTPUT.PUT_LINE('No se pueden agregar items a una orden que no está en estado "iniciada".');
  ELSE
    -- Insertar el nuevo item
    INSERT INTO Items (Id_Orden, Tipo_producto, Producto, Cantidad, Observacion)
    VALUES (p_Id_Orden, p_Tipo_producto, p_Producto, p_Cantidad, p_Observacion);
    
    -- Actualizar el estado de la orden a "agregando"
    UPDATE Orden SET Estado = 'agregando' WHERE Id_Orden = p_Id_Orden;
    
    DBMS_OUTPUT.PUT_LINE('Item agregado correctamente.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error al agregar el item: ' || SQLERRM);
END;

BEGIN
  insertar_item(1, 'C', 6, 3, NULL);
END;

--confirmar_orden

CREATE OR REPLACE PROCEDURE confirmar_orden (
  id_orden2 IN NUMBER, 
  forma_pago2 IN CHAR,
  id_empleado IN NUMBER
  
) IS
  -- Variables para la factura
  v_anno NUMBER;
  v_numero_serie VARCHAR2(50);
  v_monto_total NUMBER(10,2);
  v_municipio VARCHAR2(100);
  v_fecha_actual DATE;
  v_id_cliente NUMBER;
  v_nit_cliente VARCHAR2(20);
  v_forma_pago CHAR(1);
  -- Variables para la orden
  v_estado_anterior VARCHAR2(50);
BEGIN
  -- Obtener la información de la orden
  SELECT estado, numero_dpi, id_direccion, forma_pago
  INTO v_estado_anterior, v_id_cliente, v_municipio, v_forma_pago
  FROM orden
  WHERE id_orden = id_orden2;

  -- Verificar que la orden esté en estado "iniciada"
  IF v_estado_anterior <> 'agregando' THEN
    RAISE_APPLICATION_ERROR(-20001, 'La orden no está en estado agregando');
  END IF;

  -- Actualizar el estado y forma de pago de la orden
  UPDATE orden
  SET estado = 'EN CAMINO', id_empleado = id_empleado
  WHERE id_orden = id_orden2;
  
  UPDATE orden SET forma_pago = forma_pago2 WHERE id_orden = id_orden2;

  -- Generar el número de serie de la factura
  SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_anno FROM DUAL;
  v_numero_serie := v_anno || '-' || id_orden2;

  -- Calcular el monto total de la factura
  SELECT SUM(m.precio * i.cantidad) INTO v_monto_total
  FROM items i
  JOIN menu m ON CONCAT(i.tipo_producto, i.producto) = m.id_producto
  WHERE i.id_orden = id_orden2;
  v_monto_total := v_monto_total * 1.12; -- Sumar el IVA 12%

  -- Obtener el NIT del cliente (si tiene)
  SELECT nit INTO v_nit_cliente FROM cliente WHERE numero_dpi = v_id_cliente;
  IF v_nit_cliente IS NULL THEN
    v_nit_cliente := 'C/F';
  END IF;

  -- Obtener la fecha y hora actual
  v_fecha_actual := SYSDATE;
    
  -- Insertar el encabezado de la factura
  INSERT INTO factura (numero_serie, monto_total, municipio, fecha_hora, id_orden, nit_cliente, forma_pago)
  VALUES (v_numero_serie, v_monto_total, v_municipio, v_fecha_actual, id_orden2, v_nit_cliente, forma_pago2);
    
 SELECT numero_serie INTO v_numero_serie FROM factura WHERE id_orden = id_orden2;
 DBMS_OUTPUT.PUT_LINE('Número de serie: ' || v_numero_serie);   
    
  COMMIT;

   
  

END confirmar_orden;


BEGIN
  confirmar_orden(1,'E',00000022);
END;

SET SERVEROUTPUT ON;









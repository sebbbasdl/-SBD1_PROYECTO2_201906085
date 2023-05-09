CREATE TABLE Restaurante (
  id_restaurante VARCHAR2(50) PRIMARY KEY,
  Direccion VARCHAR2(255),
  Municipio VARCHAR2(50),
  Zona NUMBER CONSTRAINT zona_positiva CHECK (Zona >= 0),
  Telefono NUMBER(10),
  Personal NUMBER(10) CONSTRAINT chk_personal CHECK (Personal = TRUNC(Personal)),
  Tiene_parqueo NUMBER(1)
);



CREATE TABLE Puesto (
  id_puesto NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  Nombre VARCHAR2(50) UNIQUE,
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
  Id_Restaurante VARCHAR2(50),
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
  NIT VARCHAR(20) NULL
);



CREATE TABLE Direccion (
  id_direccion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero_DPI NUMBER,
  Direccion VARCHAR2(255),
  Municipio VARCHAR2(100) NOT NULL,
  Zona NUMBER CONSTRAINT zona_positiva2 CHECK (Zona >= 0),
  CONSTRAINT fk_cliente_direccion_id FOREIGN KEY (numero_DPI) REFERENCES Cliente(numero_DPI)
);




CREATE TABLE Orden (
  id_orden NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero_dpi NUMBER,
  id_direccion NUMBER,
  id_restaurante VARCHAR2(50),
  id_empleado VARCHAR2(8),
  canal CHAR(1) CONSTRAINT chk_canal CHECK (canal IN ('L', 'A')),
  estado VARCHAR2(50) DEFAULT 'INICIADA',
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
  nit_cliente VARCHAR2(20) ,
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

DROP SEQUENCE secuencia_empleados;

CREATE SEQUENCE secuencia_empleados
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 99999999;



--Registrar restaurante
CREATE OR REPLACE PROCEDURE RegistrarRestaurante(
    p_id_restaurante IN VARCHAR2,
    p_direccion IN VARCHAR2,
    p_municipio IN VARCHAR2,
    p_zona IN NUMBER,
    p_telefono IN NUMBER,
    p_personal IN NUMBER,
    p_tiene_parqueo IN NUMBER
)
IS
BEGIN
  INSERT INTO Restaurante(id_Restaurante, Direccion, Municipio, Zona, Telefono, Personal, Tiene_parqueo)
  VALUES(p_id_restaurante, p_direccion, p_municipio, p_zona, p_telefono, p_personal, p_tiene_parqueo);
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Restaurante insertado correctamente.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error al insertar restaurante: ' || SQLERRM);
END;



BEGIN
  RegistrarRestaurante('R001', '1a EXECe zona 4      ', 'Guatemala', 4, 1770, 18, 1);
                        
                    
END;

--registrar puesto
CREATE OR REPLACE PROCEDURE RegistrarPuesto (
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
    RegistrarPuesto('Gerente', 'Encargado de administrar el área de ventas', 5000);
END;

--registrar empleada




CREATE OR REPLACE PROCEDURE CrearEmpleado (
    nombres IN VARCHAR2,
    apellidos IN VARCHAR2,
    fecha_nacimiento_str IN VARCHAR2,
    correo IN VARCHAR2,
    telefono IN NUMBER,
    direccion IN VARCHAR2,
    numero_dpi IN NUMBER,
    id_puesto IN NUMBER,
    fecha_inicio_str IN VARCHAR2,
    id_restaurante IN VARCHAR2
) AS
  v_id_empleado VARCHAR2(8);
  fecha_nacimiento DATE := TO_DATE(fecha_nacimiento_str, 'YYYY-MM-DD');
  fecha_inicio DATE := TO_DATE(fecha_inicio_str, 'YYYY-MM-DD');
BEGIN
  SELECT LPAD(secuencia_empleados.NEXTVAL, 8, '0') INTO v_id_empleado FROM dual;
  INSERT INTO Empleados (id_empleado, Nombres, Apellidos, Fecha_nacimiento, Correo, Telefono, Direccion, Numero_DPI, id_Puesto, Fecha_inicio, Id_Restaurante)
  VALUES (v_id_empleado, nombres, apellidos, fecha_nacimiento, correo, telefono, direccion, numero_dpi, id_puesto, fecha_inicio, id_restaurante);
  COMMIT;
END;
/



BEGIN
  CrearEmpleado('Juan', 'Perez', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'juan.perez@example.com', 1234567, '4ta Calle 10-10 Zona 1', 12345678901234, 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1);
END;



--registrar cliente
CREATE OR REPLACE PROCEDURE RegistrarCliente (
    numero_dpi IN NUMBER,
    nombre IN VARCHAR2,
    apellidos IN VARCHAR2,
    fecha_nacimiento_str IN VARCHAR2,
    correo IN VARCHAR2,
    telefono IN NUMBER,
    nit IN NUMBER DEFAULT NULL
) AS
    fecha_nacimiento DATE := TO_DATE(fecha_nacimiento_str, 'YYYY-MM-DD');
    nit_str VARCHAR2(20);
BEGIN
    -- Convertir nit a cadena de caracteres
    nit_str := TO_CHAR(nit);
    
    -- Verificar que nombre y apellidos no contengan símbolos extraños
    IF REGEXP_LIKE(nombre, '[^[:alnum:][:space:]]') THEN
        RAISE_APPLICATION_ERROR(-20001, 'El nombre contiene símbolos extraños');
    END IF;
    IF REGEXP_LIKE(apellidos, '[^[:alnum:][:space:]]') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Los apellidos contienen símbolos extraños');
    END IF;
    
    INSERT INTO Cliente (numero_DPI, nombre, apellidos, fecha_nacimiento, correo, telefono, nit)
    VALUES (numero_dpi, nombre, apellidos, fecha_nacimiento, correo, telefono, nit_str);
    COMMIT;
END;
/




BEGIN
    RegistrarCliente(1234567890123, 'María', 'González', TO_DATE('1995-01-01', 'YYYY-MM-DD'), 'maria.gonzalez@example.com', 1234567, NULL);
END;


-- registrar direccion
CREATE OR REPLACE PROCEDURE RegistrarDireccion (
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
    RegistrarDireccion(1234567890123, '5ta. Calle 10-20 Zona 2', 'Guatemala', 2);
END;

-- registrar orden con validaciones

CREATE OR REPLACE PROCEDURE CrearOrden(
    p_numero_dpi IN NUMBER,
    p_id_direccion IN NUMBER,
    p_canal IN CHAR
) AS
    v_id_restaurante VARCHAR2(50);
    v_municipio VARCHAR2(50);
    v_zona VARCHAR2(50);
    v_dir_exists NUMBER;
BEGIN
    -- Validar que el cliente tenga registrada la dirección
    SELECT COUNT(*) INTO v_dir_exists FROM Direccion WHERE id_direccion = p_id_direccion AND numero_dpi = p_numero_dpi;
    IF v_dir_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La dirección no está registrada para el cliente');
    END IF;

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
/






BEGIN
  CrearOrden(1234567890123, 1, 'A');
END;


--agregar item

CREATE OR REPLACE PROCEDURE AgregarItem (
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
  IF v_Estado = 'INICIADA' OR v_Estado='AGREGANDO' THEN
  -- Insertar el nuevo item
    INSERT INTO Items (Id_Orden, Tipo_producto, Producto, Cantidad, Observacion)
    VALUES (p_Id_Orden, p_Tipo_producto, p_Producto, p_Cantidad, p_Observacion);
    
    -- Actualizar el estado de la orden a "AGREGANDO"
    UPDATE Orden SET Estado = 'AGREGANDO' WHERE Id_Orden = p_Id_Orden;
    
    DBMS_OUTPUT.PUT_LINE('Item agregado correctamente.');  
  ELSE
    DBMS_OUTPUT.PUT_LINE('No se pueden agregar items a una orden que no está en estado "iniciada".');
  END IF;
  
  
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error al agregar el item: ' || SQLERRM);
END;

BEGIN
  AgregarItem(2, 'C', 6, 3, 'SIN CEBOLLA');
END;

--ConfirmarOrden

CREATE OR REPLACE PROCEDURE ConfirmarOrden (
  id_orden2 IN NUMBER, 
  forma_pago2 IN CHAR,
  id_empleado2 IN VARCHAR
  
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
  v_empleado number;
  v_id_direccion number;
  -- Variables para la orden
  v_estado_anterior VARCHAR2(50);
BEGIN

    
  -- Obtener la información de la orden
  SELECT estado, numero_dpi, forma_pago,id_direccion
  INTO v_estado_anterior, v_id_cliente, v_forma_pago, v_id_direccion
  FROM orden
  WHERE id_orden = id_orden2;
  
  SELECT municipio
  INTO v_municipio
  FROM direccion
  where id_direccion = v_id_direccion;

  -- Verificar que la orden esté en estado "iniciada"
  IF v_estado_anterior <> 'AGREGANDO' THEN
    RAISE_APPLICATION_ERROR(-20001, 'La orden no está en estado AGREGANDO');
  END IF;
  
  --verifica si existe empleado
  BEGIN
  
    SELECT COUNT(*) INTO v_empleado
    FROM empleados
    WHERE id_empleado = id_empleado2;
    
    IF v_empleado = 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'El empleado no existe1');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20002, 'El empleado no existe2');
  END;

  -- Actualizar el estado y forma de pago de la orden
  UPDATE orden
  SET estado = 'EN CAMINO', id_empleado = id_empleado2
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
SELECT monto_total INTO v_monto_total FROM factura WHERE id_orden = id_orden2;
SELECT municipio INTO v_municipio FROM factura WHERE id_orden = id_orden2;
SELECT fecha_hora INTO v_fecha_actual FROM factura WHERE id_orden = id_orden2;
SELECT nit_cliente INTO v_nit_cliente FROM factura WHERE id_orden = id_orden2;
SELECT forma_pago INTO v_forma_pago FROM factura WHERE id_orden = id_orden2;

DBMS_OUTPUT.PUT_LINE('Número de serie: ' || v_numero_serie);
DBMS_OUTPUT.PUT_LINE('Monto total: ' || v_monto_total);
DBMS_OUTPUT.PUT_LINE('Id de la orden: ' || id_orden2);
DBMS_OUTPUT.PUT_LINE('Municipio: ' || v_municipio);
DBMS_OUTPUT.PUT_LINE('Fecha y hora: ' || v_fecha_actual);
DBMS_OUTPUT.PUT_LINE('NIT cliente: ' || v_nit_cliente);
DBMS_OUTPUT.PUT_LINE('Forma de pago: ' || v_forma_pago); 
    
  COMMIT;

END ConfirmarOrden;



BEGIN
  ConfirmarOrden(2,'E','00000025');
END;


-----------------------------------------
CREATE OR REPLACE NONEDITIONABLE PROCEDURE FinalizarOrden(
    v_id_orden IN NUMBER
) AS
    v_estado VARCHAR2(20);
BEGIN
    -- Obtener el estado actual de la orden
    SELECT Estado INTO v_estado
    FROM Orden
    WHERE Id_Orden = v_id_orden
    AND ROWNUM = 1; -- Agregar esta condición para devolver solo una fila

    -- Validar que la orden exista y que su estado sea "EN CAMINO"
    IF v_estado IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'La orden no existe.');
    ELSIF v_estado != 'EN CAMINO' THEN
        RAISE_APPLICATION_ERROR(-20002, 'La orden no está en camino.');
    END IF;

    -- Actualizar el estado y la fecha de entrega de la orden
    UPDATE Orden SET Estado = 'ENTREGADA', Fecha_final = SYSDATE
    WHERE Id_Orden = v_id_orden;

    COMMIT;
END FinalizarOrden;



begin
    finalizarorden(2);
end;


CREATE OR REPLACE PROCEDURE ListarRestaurantes
IS
  aux_parqueo VARCHAR2(200);
BEGIN
  FOR c IN (SELECT Id_restaurante, Direccion, Municipio, Zona, Telefono, Personal, Tiene_parqueo
            FROM Restaurante)
  LOOP
    IF c.Tiene_parqueo = 1 THEN
      aux_parqueo := 'Sí';
    ELSE
      aux_parqueo := 'No';
    END IF;
    DBMS_OUTPUT.PUT_LINE('Id_restaurante: ' || c.Id_restaurante || ' | ' || 
                     'Direccion: ' || c.Direccion || ' | ' || 
                     'Municipio: ' || c.Municipio || ' | ' || 
                     'Zona: ' || c.Zona || ' | ' || 
                     'Telefono: ' || c.Telefono || ' | ' || 
                     'Personal: ' || c.Personal || ' | ' || 
                     'Tiene_parqueo: ' || aux_parqueo);

  END LOOP;
END;
/


BEGIN ListarRestaurantes; END;


---------------------------------------------
CREATE OR REPLACE PROCEDURE ConsultarEmpleado (p_IdEmpleado IN Empleados.id_empleado%TYPE) AS
  v_NombreCompleto Empleados.Nombres%TYPE;
  v_FechaNacimiento Empleados.Fecha_nacimiento%TYPE;
  v_Correo Empleados.Correo%TYPE;
  v_Telefono Empleados.Telefono%TYPE;
  v_Direccion Empleados.Direccion%TYPE;
  v_NumeroDPI Empleados.Numero_DPI%TYPE;
  v_NombrePuesto Puesto.Nombre%TYPE;
  v_FechaInicio Empleados.Fecha_inicio%TYPE;
  v_Salario Puesto.Salario%TYPE;
BEGIN
  SELECT e.Nombres || ' ' || e.Apellidos INTO v_NombreCompleto
  FROM Empleados e
  WHERE e.id_empleado = p_IdEmpleado;

  SELECT e.Fecha_nacimiento, e.Correo, e.Telefono, e.Direccion, e.Numero_DPI, p.Nombre, e.Fecha_inicio, p.Salario
  INTO v_FechaNacimiento, v_Correo, v_Telefono, v_Direccion, v_NumeroDPI, v_NombrePuesto, v_FechaInicio, v_Salario
  FROM Empleados e
  JOIN Puesto p ON e.id_Puesto = p.id_puesto
  WHERE e.id_empleado = p_IdEmpleado;

  DBMS_OUTPUT.PUT_LINE('IdEmpleado: ' || p_IdEmpleado);
  DBMS_OUTPUT.PUT_LINE('Nombre completo: ' || v_NombreCompleto);
  DBMS_OUTPUT.PUT_LINE('Fecha de nacimiento: ' || v_FechaNacimiento);
  DBMS_OUTPUT.PUT_LINE('Correo: ' || v_Correo);
  DBMS_OUTPUT.PUT_LINE('Teléfono: ' || v_Telefono);
  DBMS_OUTPUT.PUT_LINE('Dirección: ' || v_Direccion);
  DBMS_OUTPUT.PUT_LINE('Número de DPI: ' || v_NumeroDPI);
  DBMS_OUTPUT.PUT_LINE('Nombre del puesto: ' || v_NombrePuesto);
  DBMS_OUTPUT.PUT_LINE('Fecha de inicio: ' || v_FechaInicio);
  DBMS_OUTPUT.PUT_LINE('Salario: ' || v_Salario);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: el empleado con Id ' || p_IdEmpleado || ' no existe.');
END;

begin
    ConsultarEmpleado('00000025');
end;


---------------------------------------------
CREATE OR REPLACE PROCEDURE ConsultarPedidosCliente (pIdOrden IN NUMBER) IS
  vRowCount NUMBER;
BEGIN
    
  -- Verificar que la orden existe
  SELECT COUNT(*) INTO vRowCount FROM Orden WHERE id_orden = pIdOrden;
  IF vRowCount = 0 THEN
    RAISE_APPLICATION_ERROR(-20000, 'La orden especificada no existe');
  END IF;
  
  -- Obtener el detalle del pedido
  FOR c IN (SELECT i.Producto, m.producto AS TipoProducto, m.precio AS Precio, i.Cantidad, i.Observacion
            FROM Items i
            JOIN menu m ON i.Tipo_producto || i.Producto = m.id_producto
            WHERE i.id_orden = pIdOrden)
    
  LOOP
    -- Imprimir los detalles de cada ítem
    DBMS_OUTPUT.PUT_LINE('Producto: ' || c.Producto);
    DBMS_OUTPUT.PUT_LINE('Tipo de producto: ' || c.TipoProducto);
    DBMS_OUTPUT.PUT_LINE('Precio: ' || c.Precio);
    DBMS_OUTPUT.PUT_LINE('Cantidad: ' || c.Cantidad);
    IF c.Observacion IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('Observación: ' || c.Observacion);
    END IF;
    DBMS_OUTPUT.NEW_LINE;
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END;

begin ConsultarPedidosCliente(2) ;end;

------------------------------NO SIRVE
CREATE OR REPLACE PROCEDURE ConsultarHistorialOrdenes (
    NUMERO_DPI IN NUMBER
) AS 
    v_count NUMBER;
    v_id_orden Orden.id_orden%TYPE;
    v_fecha_inicio Orden.fecha_inicio%TYPE;
    v_monto_total Factura.monto_total%TYPE;
    v_restaurante Restaurante.nombre%TYPE;
    v_repartidor Empleados.nombres%TYPE;
    v_direccion_envio Direccion.direccion%TYPE;
    v_canal VARCHAR2(20);
BEGIN
    -- Verificar si el DPI del cliente existe
    SELECT COUNT(*) INTO v_count FROM Cliente WHERE numero_DPI = NUMERO_DPI;
    IF v_count = 0 THEN
        raise_application_error(-20001, 'El DPI del cliente no existe.');
    END IF;

    -- Consultar historial de órdenes del cliente
    SELECT o.id_orden, o.fecha_inicio, f.monto_total, 
           r.nombre AS restaurante, 
           CONCAT(e.nombres, ' ', e.apellidos) AS repartidor, 
           d.direccion AS envio,
           CASE o.canal WHEN 'L' THEN 'Llamada' ELSE 'Aplicación' END AS canal
    INTO v_id_orden, v_fecha_inicio, v_monto_total, 
         v_restaurante, v_repartidor, v_direccion_envio, v_canal
    FROM Orden o
    JOIN Factura f ON f.id_orden = o.id_orden
    JOIN Restaurante r ON r.id_restaurante = o.id_restaurante
    JOIN Empleados e ON e.id_empleado = o.id_empleado
    JOIN Direccion d ON d.id_direccion = o.id_direccion
    WHERE o.numero_DPI = NUMERO_DPI;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        raise_application_error(-20002, 'No se encontraron órdenes para el DPI del cliente.');
END;
/

---------------------------------------------------
CREATE OR REPLACE PROCEDURE ConsultarDirecciones(
  DPI_Cliente IN NUMBER
) AS
BEGIN
  -- Verificar si el cliente existe
  DECLARE
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Cliente
    WHERE numero_DPI = DPI_Cliente;

    IF v_count = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'El cliente con DPI ' || DPI_Cliente || ' no existe.');
    END IF;
  END;

  -- Obtener las direcciones correspondientes al cliente
  FOR direccion IN (SELECT Direccion, Municipio, Zona
                    FROM Direccion
                    WHERE numero_DPI = DPI_Cliente) LOOP
    DBMS_OUTPUT.PUT_LINE('Dirección completa: ' || direccion.Direccion);
    DBMS_OUTPUT.PUT_LINE('Municipio: ' || direccion.Municipio);
    DBMS_OUTPUT.PUT_LINE('Zona: ' || direccion.Zona);
    DBMS_OUTPUT.NEW_LINE;
  END LOOP;
END;
/

begin ConsultarDirecciones(1234567890123); end;


-----------------------------------
CREATE OR REPLACE PROCEDURE MostrarOrdenes (p_estado IN NUMBER) IS
  v_estado VARCHAR2(50);
  TYPE OrdenesCursor IS REF CURSOR;
  v_ordenes_cursor OrdenesCursor;
  v_id_orden Orden.id_orden%TYPE;
  v_estado_orden Orden.estado%TYPE;
  v_fecha_inicio Orden.fecha_inicio%TYPE;
  v_numero_dpi Orden.numero_dpi%TYPE;
  v_direccion Direccion.direccion%TYPE;
  v_canal VARCHAR2(50);
BEGIN
  IF p_estado = 1 THEN
    v_estado := 'INICIADA';
  ELSIF p_estado = 2 THEN
    v_estado := 'AGREGANDO';
  ELSIF p_estado = 3 THEN
    v_estado := 'EN CAMINO';
  ELSIF p_estado = 4 THEN
    v_estado := 'ENTREGADA';
  ELSIF p_estado = -1 THEN
    v_estado := 'SIN COBERTURA';
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'El estado ingresado no es válido.');
  END IF;
  
  OPEN v_ordenes_cursor FOR
    SELECT o.id_orden, o.estado, o.fecha_inicio, o.numero_dpi, d.direccion,
           CASE WHEN o.canal = 'L' THEN 'Llamada' ELSE 'Aplicación' END AS canal
    FROM Orden o
    JOIN Direccion d ON o.id_direccion = d.id_direccion
    JOIN Restaurante r ON o.id_restaurante = r.id_restaurante
    WHERE o.estado = v_estado;
    
  LOOP
    FETCH v_ordenes_cursor INTO v_id_orden, v_estado_orden, v_fecha_inicio, v_numero_dpi, v_direccion, v_canal;
    EXIT WHEN v_ordenes_cursor%NOTFOUND;
    -- Imprimir los datos de la orden
    DBMS_OUTPUT.PUT_LINE('ID de Orden: ' || v_id_orden);
    DBMS_OUTPUT.PUT_LINE('Estado de Orden: ' || v_estado_orden);
    DBMS_OUTPUT.PUT_LINE('Fecha de Inicio: ' || v_fecha_inicio);
    DBMS_OUTPUT.PUT_LINE('Número de DPI: ' || v_numero_dpi);
    DBMS_OUTPUT.PUT_LINE('Dirección de Entrega: ' || v_direccion);
    DBMS_OUTPUT.PUT_LINE('Canal de Pedido: ' || v_canal);
  END LOOP;
  
  CLOSE v_ordenes_cursor;
END;
/

EXEC  MostrarOrdenes(1);


CREATE OR REPLACE PROCEDURE ConsultarFacturas(
  p_dia IN NUMBER,
  p_mes IN NUMBER,
  p_anio IN NUMBER
) IS
  v_numero_serie VARCHAR2(20);
  v_monto_total NUMBER(10,2);
  v_lugar VARCHAR2(100);
  v_fecha_hora TIMESTAMP;
  v_id_orden NUMBER;
  v_nit_cliente VARCHAR2(20);
  v_forma_pago VARCHAR2(10);
BEGIN
  FOR factura IN (SELECT numero_serie, monto_total, lugar, fecha_hora, id_orden, nit_cliente,
    CASE forma_pago
      WHEN 'E' THEN 'Efectivo'
      WHEN 'T' THEN 'Tarjeta'
    END AS forma_pago
  FROM Factura
  WHERE TRUNC(fecha_hora) = TO_DATE(p_dia || '-' || p_mes || '-' || p_anio, 'DD-MM-YYYY')) LOOP
  
    v_numero_serie := factura.numero_serie;
    v_monto_total := factura.monto_total;
    v_lugar := factura.lugar;
    v_fecha_hora := factura.fecha_hora;
    v_id_orden := factura.id_orden;
    v_nit_cliente := factura.nit_cliente;
    v_forma_pago := factura.forma_pago;
    
    DBMS_OUTPUT.PUT_LINE('Número de serie: ' || v_numero_serie);
    DBMS_OUTPUT.PUT_LINE('Monto total de la factura: ' || v_monto_total);
    DBMS_OUTPUT.PUT_LINE('Lugar: ' || v_lugar);
    DBMS_OUTPUT.PUT_LINE('Fecha y hora: ' || v_fecha_hora);
    DBMS_OUTPUT.PUT_LINE('IdOrden: ' || v_id_orden);
    DBMS_OUTPUT.PUT_LINE('NIT del cliente: ' || v_nit_cliente);
    DBMS_OUTPUT.PUT_LINE('Forma de pago: ' || v_forma_pago);
  END LOOP;
END;
/


EXEC  ConsultarFacturas(6,5,2023);



SET SERVEROUTPUT ON;



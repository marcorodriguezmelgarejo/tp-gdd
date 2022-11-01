use GD2C2022
go
create schema nibble
go


-- CREACIÓN DE TABLAS


use GD2C2022

create table nibble.Provincia (
    id_provincia decimal(3) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255) not null,
    );

create table nibble.Codigo_postal (
    codigo_postal decimal(18,0) PRIMARY KEY,
    id_provincia decimal(3) not null,              
    FOREIGN KEY (id_provincia) REFERENCES nibble.Provincia(id_provincia)
    ); 

create table nibble.Medio_envio (
    id_medio decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
);

create table nibble.Envio_X_codigo_postal (
    id_medio decimal(18,0) not null,
    codigo_postal decimal(18,0) not null,
	costo_envio decimal(18,2) not null,
    FOREIGN KEY (id_medio) REFERENCES nibble.Medio_envio(id_medio),
    FOREIGN KEY (codigo_postal) REFERENCES nibble.Codigo_postal(codigo_postal),
    CONSTRAINT PK_Envio_X_codigo_postal PRIMARY KEY (id_medio, codigo_postal)
    );


create table nibble.Canal (
    id_canal decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
    costo decimal(18,2),
);

create table nibble.Cliente (
    id_cliente decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    direccion varchar(255),
    DNI decimal(18,0),
    nombre nvarchar(255),
    apellido nvarchar(255),
    telefono decimal(18,0),
    mail nvarchar(255),
    fecha_nac date,
    localidad nvarchar(255),
    codigo_postal decimal(18,0),
    FOREIGN KEY (codigo_postal) REFERENCES nibble.Codigo_postal(codigo_postal)
);

create table nibble.Medio_de_pago_venta(
    id_medio_pago decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
    descuento decimal(18,2),
    costo decimal(18,2),
    CONSTRAINT porcentaje_de_descuento_menor_a_1 CHECK (descuento >= 0 and descuento <= 1)
);

create table nibble.Medio_de_pago_compra(
    id_medio_pago_compra decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
);

/* VENTA */

create table nibble.Venta (
    codigo_venta decimal(19,0) PRIMARY KEY,
    fecha date,
    id_cliente decimal(18,0),
    canal_de_venta decimal(18,0),
    medio_de_envio decimal(18,0),
    costo_envio decimal(18,2),
    medio_de_pago decimal(18,0),
    total decimal(18,2) DEFAULT 0,
    desc_medio_de_pago decimal(18,2),
    costo_medio_de_pago decimal(18,2),
    FOREIGN KEY (medio_de_pago) REFERENCES nibble.Medio_de_pago_venta(id_medio_pago),
    FOREIGN KEY (medio_de_envio) REFERENCES nibble.Medio_envio(id_medio),
    FOREIGN KEY (canal_de_venta) REFERENCES nibble.Canal(id_canal),
    FOREIGN KEY (id_cliente) REFERENCES nibble.Cliente(id_cliente),
    CONSTRAINT Importe_total_venta_mayor_a_cero CHECK (total >= 0)
);



/* DESCUENTOS VENTA */

create table nibble.Cupon_descuento (
    codigo nvarchar(255) PRIMARY KEY,
    fecha_desde date,
    fecha_hasta date,
    valor decimal(18,2),
    tipo nvarchar(50),
    CONSTRAINT fecha_de_expiracion_antes_de_la_fecha_de_inicio CHECK (fecha_hasta >= fecha_desde),
    CONSTRAINT porcentaje_menor_a_1 CHECK (tipo = 'Tipo Descuento Monto Fijo' or valor <= 1)
);

create table nibble.Descuento_venta (
    id_descuento_venta decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    codigo_venta decimal(19,0),
    importe decimal(18,2)
    FOREIGN KEY (codigo_venta) REFERENCES nibble.Venta(codigo_venta)        
);

create table nibble.Cupon_descuento_X_venta (
    codigo nvarchar(255),
    codigo_venta decimal(19,0),
    importe decimal(18,2)
    FOREIGN KEY (codigo) REFERENCES nibble.Cupon_descuento(codigo),
    FOREIGN KEY (codigo_venta) REFERENCES nibble.Venta(codigo_venta),
    CONSTRAINT Pk_Cupon_descuento_X_venta PRIMARY KEY (codigo, codigo_venta)
);




/* PRODUCTOS */

create table nibble.Variante(
    descripcion_variante nvarchar(50),
    tipo_variante nvarchar(50),
    CONSTRAINT PK_Variante PRIMARY KEY (descripcion_variante, tipo_variante)
);

create table nibble.Producto(
    cod_producto nvarchar(50) PRIMARY KEY,
    descripcion nvarchar(50),
    nombre NVARCHAR(50),
    material NVARCHAR(50),
    marca nvarchar(255),
    categoria nvarchar(255),
);

create table nibble.Producto_X_Variante(
    cod_producto_X_variante nvarchar(50) PRIMARY KEY,
    cod_producto nvarchar(50) not null,
    descripcion_variante nvarchar(50), -- son nulleables estos dos campos porque puede haber productos sin variante
    tipo_variante nvarchar(50),
    precio_venta decimal(18,2),
    precio_compra decimal(18,2),
    stock decimal(20,0),
    FOREIGN KEY (cod_producto) REFERENCES nibble.Producto(cod_producto),
    FOREIGN KEY (descripcion_variante, tipo_variante) REFERENCES nibble.Variante(descripcion_variante, tipo_variante),
    CONSTRAINT Combinacion_unica_producto_y_variante UNIQUE (cod_producto, descripcion_variante, tipo_variante)
)

create table nibble.Venta_X_Producto (
    codigo_venta decimal(19,0),
    producto_variante nvarchar(50),
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
    total_por_producto decimal(18,2),
    FOREIGN KEY (codigo_venta) REFERENCES nibble.Venta(codigo_venta),
    FOREIGN KEY (producto_variante) REFERENCES nibble.Producto_X_Variante(cod_producto_X_variante),
    CONSTRAINT PK_Venta_X_Producto PRIMARY KEY (codigo_venta, producto_variante)
);

/* COMPRAS */

create table nibble.proveedor(
    cuit nvarchar(50) PRIMARY KEY,
    razon_social nvarchar(50),
    domicilio nvarchar(50),
    localidad nvarchar(255),
    mail nvarchar(50),
    codigo_postal decimal(18),
    foreign key(codigo_postal) REFERENCES nibble.Codigo_postal(codigo_postal)
);

create table nibble.Compra(
    numero_compra decimal(19,0) PRIMARY KEY,
    fecha date,
    proveedor nvarchar(50),
    total decimal(18,2) DEFAULT 0,
    medio_de_pago decimal(18,0)
    foreign key(proveedor) REFERENCES nibble.proveedor(cuit),
    foreign key(medio_de_pago) REFERENCES nibble.Medio_de_pago_compra(id_medio_pago_compra),
    CONSTRAINT Importe_total_compra_mayor_a_cero CHECK (total >= 0)
)

create table nibble.Descuento_compra(
    codigo_descuento_compra decimal(19,0) PRIMARY KEY,
    compra decimal(19,0) not null,
    valor decimal(18,2)
    foreign key(compra) REFERENCES nibble.Compra(numero_compra),
    CONSTRAINT porcentaje_descuento_menor_a_1 CHECK (valor <= 1)
)

create table nibble.Compra_X_Producto(
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
	compra decimal(19,0) not null,
	producto nvarchar(50),
	total_por_producto decimal(18,2),
    foreign key(compra) REFERENCES nibble.Compra(numero_compra),
    foreign key(producto) REFERENCES nibble.Producto_X_Variante(cod_producto_X_variante),
    CONSTRAINT PK_Compra_X_Producto PRIMARY KEY (compra, producto)
);
GO



-- FUNCIONES AUXILIARES


create function nibble.maximo_decimal_18_2 (@a decimal(18,2), @b decimal(18,2))
returns decimal(18,2)
as 
begin
    if @a > @b
        return @a
    return @b
end
go

create function nibble.stockDeProducto (@producto nvarchar(50))
returns decimal(20,0)
as 
begin
    return (select top 1 stock from nibble.Producto_X_Variante where cod_producto_X_variante = @producto)
end
go

create function nibble.codigoPostalDeCliente(@cliente decimal(18,0))
returns decimal(18,0)
as
begin
    return (select top 1 codigo_postal from nibble.Cliente where id_cliente = @cliente)
end
go

create function nibble.medioDeEnvioEnCodigoPostal(@medio_de_envio decimal(18,0), @codigo_postal decimal(18,0))
returns bit
as
begin
    if (@medio_de_envio in (select id_medio from nibble.Envio_X_codigo_postal where @codigo_postal = codigo_postal))
    begin 
        return 1
    end
    return 0
end
go


-- OTROS CONSTRAINTS

alter table nibble.Venta add
CONSTRAINT medio_de_envio_en_ese_codigo_postal CHECK 
(nibble.medioDeEnvioEnCodigoPostal(medio_de_envio, nibble.codigoPostalDeCliente(id_cliente)) = 1)
GO


-- PROCEDURES MIGRACION

CREATE PROC nibble.migracion_provincia
as
    insert into nibble.Provincia (nombre)
    select distinct PROVEEDOR_PROVINCIA from gd_esquema.Maestra
    where PROVEEDOR_PROVINCIA is not null
go

CREATE PROC nibble.migracion_codigo_postal
as
    insert into nibble.Codigo_postal (codigo_postal, id_provincia)
    select distinct PROVEEDOR_CODIGO_POSTAL, (select id_provincia from nibble.Provincia where Provincia.nombre = PROVEEDOR_PROVINCIA) as provincia from gd_esquema.Maestra
        where PROVEEDOR_CODIGO_POSTAL is not null
    union 
    select distinct CLIENTE_CODIGO_POSTAL, (select id_provincia from nibble.Provincia where Provincia.nombre = CLIENTE_PROVINCIA) as provincia from gd_esquema.Maestra
        where CLIENTE_CODIGO_POSTAL is not null
go



CREATE PROC nibble.migracion_variante
as
    insert into nibble.Variante (descripcion_variante, tipo_variante)
    select distinct PRODUCTO_VARIANTE, PRODUCTO_TIPO_VARIANTE from gd_esquema.Maestra
    where PRODUCTO_VARIANTE is not null
go

CREATE PROC nibble.migracion_medio_envio
as
    insert into nibble.Medio_envio (nombre)
    select distinct VENTA_MEDIO_ENVIO from gd_esquema.Maestra
    where VENTA_MEDIO_ENVIO is not null
go

CREATE PROC nibble.migracion_medio_de_pago_venta
as
    insert into nibble.Medio_de_pago_venta (nombre, descuento, costo)
    select VENTA_MEDIO_PAGO,
        (select top 1-- De la ultima venta con ese medio de pago...
        isnull((select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where VENTA_CODIGO = m1.VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO),0) /
        sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0)) as descuento
        -- El descuento dividido el total de los productos
        from gd_esquema.Maestra m1
        where m.VENTA_MEDIO_PAGO = VENTA_MEDIO_PAGO 
        group by VENTA_CODIGO, VENTA_FECHA
        order by VENTA_FECHA desc) as descuento,
        (select top 1-- De la ultima venta con ese medio de pago...
        min(VENTA_MEDIO_PAGO_COSTO) -- no importa que funcion de agrupacion use porque son todos el mismo valor
        from gd_esquema.Maestra m1
        where m.VENTA_MEDIO_PAGO = VENTA_MEDIO_PAGO 
        group by VENTA_CODIGO, VENTA_FECHA
        order by VENTA_FECHA desc) as costo
    from gd_esquema.Maestra m
    where VENTA_MEDIO_PAGO is not null
    group by VENTA_MEDIO_PAGO
go

CREATE PROC nibble.migracion_cliente
AS
    insert into nibble.Cliente (direccion, DNI, nombre, apellido, telefono, mail, fecha_nac, localidad, codigo_postal)
    select distinct CLIENTE_DIRECCION,
     CLIENTE_DNI,
     CLIENTE_NOMBRE,
     CLIENTE_APELLIDO,
     CLIENTE_TELEFONO,
     CLIENTE_MAIL,
     CLIENTE_FECHA_NAC,
     CLIENTE_LOCALIDAD,
     CLIENTE_CODIGO_POSTAL from gd_esquema.Maestra
    where CLIENTE_DNI is not null

GO

CREATE PROC nibble.migracion_canal
AS
    insert into nibble.Canal(nombre, costo)
    select distinct VENTA_CANAL, VENTA_CANAL_COSTO from gd_esquema.Maestra
    where VENTA_CANAL is not null
GO

CREATE PROC nibble.migracion_producto
AS

    insert into nibble.Producto(cod_producto, nombre, descripcion, material, marca, categoria)
    select distinct PRODUCTO_CODIGO, PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION, PRODUCTO_MATERIAL, PRODUCTO_MARCA, PRODUCTO_CATEGORIA
    from gd_esquema.Maestra
    where PRODUCTO_CODIGO is not null

GO

create proc nibble.migracion_proveedor
AS
    
    insert into nibble.Proveedor(cuit, razon_social, domicilio, mail, localidad, codigo_postal)
    select distinct PROVEEDOR_CUIT, PROVEEDOR_RAZON_SOCIAL, PROVEEDOR_DOMICILIO, PROVEEDOR_MAIL, PROVEEDOR_LOCALIDAD, PROVEEDOR_CODIGO_POSTAL
    from gd_esquema.Maestra
    where PROVEEDOR_CUIT is not null

go

create proc nibble.migracion_cupon_descuento
AS

    insert into nibble.Cupon_descuento(codigo, fecha_desde, fecha_hasta, valor, tipo)
    select distinct VENTA_CUPON_CODIGO, VENTA_CUPON_FECHA_DESDE, VENTA_CUPON_FECHA_HASTA, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO
    from gd_esquema.Maestra
    where VENTA_CUPON_CODIGO is not null
    order by VENTA_CUPON_CODIGO

Go

CREATE PROC nibble.migracion_envio_X_codigo_postal
AS
    insert into nibble.Envio_X_codigo_postal (id_medio, codigo_postal, costo_envio)
    select distinct (select id_medio from nibble.Medio_envio where Medio_envio.nombre = VENTA_MEDIO_ENVIO) as id_medio,
     CLIENTE_CODIGO_POSTAL,
     (select top 1 VENTA_ENVIO_PRECIO 
     from gd_esquema.Maestra 
     where CLIENTE_CODIGO_POSTAL = m.CLIENTE_CODIGO_POSTAL and VENTA_MEDIO_ENVIO = m.VENTA_MEDIO_ENVIO
     order by VENTA_FECHA desc) 
    from gd_esquema.Maestra m
    where VENTA_MEDIO_ENVIO is not null
GO

CREATE PROC nibble.migracion_producto_X_variante 
AS
    insert into nibble.Producto_X_variante(cod_producto_X_variante, cod_producto, descripcion_variante, tipo_variante, stock, precio_venta, precio_compra)
    select PRODUCTO_VARIANTE_CODIGO, PRODUCTO_CODIGO, PRODUCTO_VARIANTE, PRODUCTO_TIPO_VARIANTE,
        (select sum(COMPRA_PRODUCTO_CANTIDAD)
        from gd_esquema.Maestra
        where PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO and COMPRA_PRODUCTO_CANTIDAD is not null)
        -
        (select sum(VENTA_PRODUCTO_CANTIDAD)
        from gd_esquema.Maestra
        where PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO and VENTA_PRODUCTO_CANTIDAD is not null) as stock,
        (select top 1 VENTA_PRODUCTO_PRECIO
        from gd_esquema.Maestra
        where PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO
        order by VENTA_FECHA DESC, VENTA_PRODUCTO_PRECIO DESC) as precio_actual_venta, -- Ordena tambien por VENTA_PRODUCTO_PRECIO para tomar el precio mas caro de esa venta en el caso que figuren varias compras de ese prod en la misma fecha
        (select top 1 COMPRA_PRODUCTO_PRECIO
        from gd_esquema.Maestra
        where PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO
        order by COMPRA_FECHA DESC, COMPRA_PRODUCTO_PRECIO DESC) as precio_actual_compra -- Idem anterior
    from gd_esquema.Maestra m
    where PRODUCTO_VARIANTE_CODIGO is not null
    group by PRODUCTO_VARIANTE_CODIGO, PRODUCTO_CODIGO, PRODUCTO_VARIANTE, PRODUCTO_TIPO_VARIANTE
GO

CREATE PROC nibble.migracion_medio_de_pago_compra
as
    insert into nibble.Medio_de_pago_compra(nombre)
    select distinct COMPRA_MEDIO_PAGO from gd_esquema.Maestra
    where COMPRA_MEDIO_PAGO is not null
GO

CREATE PROC nibble.migracion_compra
AS
    insert into nibble.Compra (numero_compra, fecha, proveedor, total, medio_de_pago)
    select distinct COMPRA_NUMERO,
    COMPRA_FECHA,
    PROVEEDOR_CUIT,
    COMPRA_TOTAL,
    (select id_medio_pago_compra from nibble.medio_de_pago_compra where nombre = COMPRA_MEDIO_PAGO)
    from gd_esquema.Maestra
    where COMPRA_NUMERO is not null 
GO



create proc nibble.migracion_descuento_compra
as
    insert into nibble.Descuento_compra(compra, codigo_descuento_compra, valor)
    select COMPRA_NUMERO, DESCUENTO_COMPRA_CODIGO, DESCUENTO_COMPRA_VALOR
    from gd_esquema.Maestra
    where DESCUENTO_COMPRA_CODIGO is not null
    
    
go

create proc nibble.migracion_descuento_venta
as

    insert into nibble.Descuento_venta(codigo_venta, importe)
    select VENTA_CODIGO, VENTA_DESCUENTO_IMPORTE
    from gd_esquema.Maestra
    where VENTA_CODIGO is not null and VENTA_DESCUENTO_CONCEPTO = 'Otros'
    ORDER by VENTA_CODIGO

go

create proc nibble.migracion_compra_X_producto
as
    insert into nibble.Compra_X_Producto(producto, compra, precio_unitario, cantidad, total_por_producto)
    select PRODUCTO_VARIANTE_CODIGO, COMPRA_NUMERO, COMPRA_PRODUCTO_PRECIO, sum(COMPRA_PRODUCTO_CANTIDAD) as cant, COMPRA_PRODUCTO_PRECIO * sum(COMPRA_PRODUCTO_CANTIDAD) as total
    from gd_esquema.Maestra
    where COMPRA_NUMERO is not null and PRODUCTO_VARIANTE_CODIGO is not null
    group by PRODUCTO_VARIANTE_CODIGO, COMPRA_NUMERO, COMPRA_PRODUCTO_PRECIO
go


CREATE proc nibble.migracion_venta
as
    insert into nibble.Venta(codigo_venta, fecha, id_cliente, canal_de_venta, medio_de_envio, costo_envio, medio_de_pago, total, desc_medio_de_pago, costo_medio_de_pago)
    select 
        VENTA_CODIGO,
        VENTA_FECHA,
        (select id_cliente from nibble.Cliente where DNI = CLIENTE_DNI and nombre = CLIENTE_NOMBRE and apellido = CLIENTE_APELLIDO),
        (select id_canal from nibble.Canal where nombre = VENTA_CANAL),
        (select id_medio from nibble.Medio_envio where nombre = VENTA_MEDIO_ENVIO),
        VENTA_ENVIO_PRECIO,
        (select id_medio_pago from nibble.Medio_de_pago_venta where nombre = VENTA_MEDIO_PAGO),
        VENTA_TOTAL,
        isnull((select isnull((select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where VENTA_CODIGO = m1.VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO),0) /
        sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0))
        from gd_esquema.Maestra m1
        where VENTA_CODIGO = m.VENTA_CODIGO
        group by VENTA_CODIGO),0) as porc_descuento_medio_pago,
        VENTA_MEDIO_PAGO_COSTO
    from gd_esquema.Maestra as m
    where VENTA_CODIGO is not null
    group by VENTA_CODIGO, VENTA_FECHA, VENTA_CANAL, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_MEDIO_PAGO, VENTA_TOTAL, CLIENTE_DNI, CLIENTE_APELLIDO, CLIENTE_NOMBRE, VENTA_MEDIO_PAGO_COSTO
GO

-- chequear que no se use el mismo cupon en la misma venta. Poner distinct?
create proc nibble.migracion_cupon_decuento_X_venta
as
    insert into nibble.Cupon_descuento_X_venta(codigo, codigo_venta, importe)
    select distinct
        VENTA_CUPON_CODIGO,
        VENTA_CODIGO,
        VENTA_CUPON_IMPORTE
    from gd_esquema.Maestra
    where VENTA_CUPON_CODIGO is not null and VENTA_CODIGO is not null
go

create proc nibble.migracion_venta_X_producto
as
    insert into nibble.Venta_X_Producto(producto_variante, codigo_venta, precio_unitario, cantidad, total_por_producto)
    select PRODUCTO_VARIANTE_CODIGO,
        VENTA_CODIGO,
        VENTA_PRODUCTO_PRECIO,
        sum(VENTA_PRODUCTO_CANTIDAD) as cant, 
        VENTA_PRODUCTO_PRECIO * sum(VENTA_PRODUCTO_CANTIDAD) as total
    from gd_esquema.Maestra
    where VENTA_CODIGO is not null and PRODUCTO_VARIANTE_CODIGO is not null
    group by PRODUCTO_VARIANTE_CODIGO, VENTA_CODIGO, VENTA_PRODUCTO_PRECIO
go



-- EJECUTAR MIGRACION

CREATE PROC nibble.migracion
as
    exec nibble.migracion_provincia
    exec nibble.migracion_codigo_postal
    exec nibble.migracion_variante
    exec nibble.migracion_medio_envio
    exec nibble.migracion_cliente
    exec nibble.migracion_canal
    exec nibble.migracion_medio_de_pago_venta
    exec nibble.migracion_producto
    exec nibble.migracion_proveedor
    exec nibble.migracion_cupon_descuento
    exec nibble.migracion_envio_X_codigo_postal
    exec nibble.migracion_medio_de_pago_compra
    exec nibble.migracion_compra
    exec nibble.migracion_producto_X_variante
    exec nibble.migracion_descuento_compra
    exec nibble.migracion_compra_X_producto
    exec nibble.migracion_venta
    exec nibble.migracion_descuento_venta
    exec nibble.migracion_venta_X_producto
    exec nibble.migracion_cupon_decuento_X_venta
go

exec nibble.migracion
go

-- CREACION DE INDICES

/*create index index_name
on table_name(column1, column2, .., columnN);*/


-- creamos estos dos porque las personas que usen el sistema van a querer buscar por nombre (el id es generado)
-- y no impacta tanto el rendimiento porque casi nunca se van a crear filas en estas tablas
create index indice_por_nombre
on nibble.Canal(nombre);

create index indice_por_nombre
on nibble.Medio_de_pago_compra(nombre);

create index indice_por_nombre
on nibble.Medio_de_pago_venta(nombre);

create index indice_por_nombre
on nibble.Provincia(nombre);   

create index indice_por_nombre
on nibble.medio_envio(nombre);   

-- medio dudoso xq capaz crean muchos productos al ser un negocio de ropa
-- pero la gente probablemente quiera buscar por nombre al comprar asi que lo ponemos
create index indice_por_nombre
on nibble.Producto(nombre);

-- creamos este porque los clientes van a saber su DNI y probablemente no sepan su codigo de cliente
create index indice_por_DNI
on nibble.Cliente(DNI);

GO



-- TRIGGERS


create trigger calcular_total_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select cantidad, precio_unitario, compra, producto, total_por_producto from inserted

    declare @cantidad decimal(18,0)
    declare @precio_unitario decimal(18,2)
	declare @compra decimal(19,0)
	declare @producto nvarchar(50)
	declare @total_por_producto decimal(18,2)

    open insertados
    fetch from insertados into @cantidad, @precio_unitario,	@compra, @producto, @total_por_producto 
    while @@fetch_status = 0
    BEGIN
        -- El total por producto se calcula
        update nibble.Compra_X_Producto
        set total_por_producto = @cantidad * @precio_unitario
        where compra = @compra and producto = @producto
        -- Se actualiza el total de la compra sumandole el total del producto calculado
        update nibble.Compra
        set total = total + @cantidad * @precio_unitario
        where numero_compra = @compra

        fetch from insertados into @cantidad, @precio_unitario,	@compra, @producto, @total_por_producto 
    END

    close insertados
    deallocate insertados
END
go


create trigger aplicar_descuento_compra on nibble.Descuento_compra
after insert
as
BEGIN       

    declare insertados cursor for select compra, valor from inserted

    declare @compra decimal(19,0)
    declare @valor decimal(18,2)

    open insertados
    fetch from insertados into @compra, @valor
    while @@fetch_status = 0
    BEGIN
        -- Se actualiza el total de la compra restandole el valor del descuento. Si el valor del descuento supera el monto de la compra, dejo el total en 0.
        update nibble.Compra
        set total = total - @valor
        where numero_compra = @compra

        fetch from insertados into @compra, @valor
    END

    close insertados
    deallocate insertados
END
go

create trigger actualizar_stock_en_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       
    declare insertados cursor for select cantidad, producto from inserted

    declare @cantidad decimal(18,0)
	declare @producto nvarchar(50)

    open insertados
    fetch from insertados into @cantidad, @producto
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set stock = stock + @cantidad
        where cod_producto_X_variante = @producto
        fetch from insertados into @cantidad, @producto
    END

    close insertados
    deallocate insertados
END
go

create trigger actualizar_precio_producto_en_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select precio_unitario, producto from inserted

	declare @producto nvarchar(50)
    declare @precio_unitario decimal(18,2)

    open insertados
    fetch from insertados into @precio_unitario, @producto
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set precio_compra = @precio_unitario
        where cod_producto_X_variante = @producto
        fetch from insertados into @precio_unitario, @producto
    END

    close insertados
    deallocate insertados
END
go

-- TRIGGERS PARA LA VENTA

create trigger actualizar_stock_en_venta on nibble.Venta_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select producto_variante, cantidad from inserted

    declare @producto_variante nvarchar(50)
    declare @cantidad decimal(18,0)

    open insertados
    fetch from insertados into @producto_variante, @cantidad
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set stock = stock - @cantidad
        where cod_producto_X_variante = @producto_variante
        fetch from insertados into @producto_variante, @cantidad
    END

    close insertados
    deallocate insertados
END
go


create trigger actualizar_precio_producto_en_venta on nibble.Venta_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select precio_unitario, producto_variante from inserted

	declare @producto_variante nvarchar(50)
    declare @precio_unitario decimal(18,2)

    open insertados
    fetch from insertados into @precio_unitario, @producto_variante
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set precio_venta = @precio_unitario
        where cod_producto_X_variante = @producto_variante
        fetch from insertados into @precio_unitario, @producto_variante
    END

    close insertados
    deallocate insertados
END
go

-- TERMINAR
create trigger calcular_total_venta on nibble.Venta_X_Producto
after insert
as
BEGIN       
    declare insertados cursor for select codigo_venta, producto_variante, cantidad, precio_unitario, total_por_producto from inserted

    declare @cantidad decimal(18,0)
    declare @precio_unitario decimal(18,2)
    declare @codigo_venta decimal(19,0)
    declare @producto_variante nvarchar(50)
    declare @total_por_producto decimal(18,2)

    declare @desc_medio_de_pago decimal(18,2)

    open insertados
    fetch from insertados into @codigo_venta, @producto_variante, @cantidad, @precio_unitario, @total_por_producto
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN
            set @desc_medio_de_pago = (select desc_medio_de_pago from nibble.Venta where codigo_venta = @codigo_venta)

            update nibble.Venta_X_Producto
            set total_por_producto = @cantidad * @precio_unitario
            where codigo_venta = @codigo_venta and producto_variante = @producto_variante
            
            update nibble.Venta
            set total = total + (@cantidad * @precio_unitario) * (1 - @desc_medio_de_pago) -- * (1 - @desc_medio_de_pago - descuentoCuponesPorcentuales(@codigo_venta)) (no lo hacemos porque consideramos que los descuentos porcentuales se aplican después de cargar los productos)
            where codigo_venta = @codigo_venta

            -- Envio gratis. Definimos 1000 como valor arbitrario.
            if (select sum(total_por_producto) from nibble.Venta_X_Producto where codigo_venta = @codigo_venta) > 1000
            BEGIN
                update nibble.Venta
                set costo_envio = 0
                where codigo_venta = @codigo_venta
            END
        END

        fetch from insertados into @codigo_venta, @producto_variante, @cantidad, @precio_unitario, @total_por_producto
    END

    close insertados
    deallocate insertados
END
go

-- TERMINAR
create trigger aplicar_descuento_cupon_venta on nibble.Cupon_descuento_X_venta
after insert
as
BEGIN       

    declare insertados cursor for select codigo_venta, codigo from inserted

    declare @codigo_venta decimal(19,0)
    declare @codigo_cupon nvarchar(255)
    declare @importe decimal(18,2)

    open insertados
    fetch from insertados into @codigo_venta, @codigo_cupon
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN
            if (select tipo from nibble.Cupon_descuento where codigo = @codigo_cupon) = 'Tipo Descuento Porcentaje'
            BEGIN
                set @importe = (select valor from nibble.Cupon_descuento where codigo = @codigo_cupon) * (select total from nibble.Venta where codigo_venta = @codigo_venta)
                -- si insertaramos mas productos en la venta despues de aplicarle el cupon, deberiamos volver a calcular este valor 
            END
            else -- monto fijo
            BEGIN
                set @importe = (select valor from nibble.Cupon_descuento where codigo = @codigo_cupon)
            END

            update nibble.Cupon_descuento_X_venta
            set importe = @importe
            where codigo_venta = @codigo_venta and codigo = @codigo_cupon

            update nibble.Venta
            set total = total - @importe
            where codigo_venta = @codigo_venta

        END
        fetch from insertados into @codigo_venta, @codigo_cupon
    END

    close insertados
    deallocate insertados
END
go

create trigger aplicar_descuento_especial_venta on nibble.Descuento_venta
after insert
as
BEGIN       

    declare insertados cursor for select codigo_venta, importe from inserted

    declare @codigo_venta decimal(19,0)
    declare @importe decimal(18,2)

    open insertados
    fetch from insertados into @codigo_venta, @importe
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN
        update nibble.Venta
        set total = nibble.maximo_decimal_18_2(total - @importe, 0)
        where codigo_venta = @codigo_venta
        END
        fetch from insertados into @codigo_venta, @importe
    END

    close insertados
    deallocate insertados
END
go

create trigger desnormalizar_venta on nibble.Venta 
after insert
as
BEGIN       

    declare insertados cursor for select codigo_venta, medio_de_envio, medio_de_pago, id_cliente from inserted

    declare @codigo_venta decimal(19,0)
    declare @medio_de_envio decimal(18,0)
    declare @medio_de_pago decimal(18,0)
    declare @id_cliente decimal(18,0)

    open insertados
    fetch from insertados into @codigo_venta, @medio_de_envio, @medio_de_pago, @id_cliente
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN

            update nibble.Venta set
            costo_envio = (select costo_envio from Envio_X_codigo_postal where id_medio = @medio_de_envio and codigo_postal = nibble.codigoPostalDeCliente(@id_cliente)),
            costo_medio_de_pago = (select costo from Medio_de_pago_venta where id_medio_pago = @medio_de_pago),
            desc_medio_de_pago = (select descuento from Medio_de_pago_venta where id_medio_pago = @medio_de_pago)
            where codigo_venta = @codigo_venta

        END

        fetch from insertados into  @codigo_venta, @medio_de_envio, @medio_de_pago, @id_cliente
    END

    close insertados
    deallocate insertados
END
go






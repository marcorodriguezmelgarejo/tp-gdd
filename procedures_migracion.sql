CREATE PROC migracion_provincia
as
    insert into Provincia (nombre)
    select distinct PROVEEDOR_PROVINCIA from gd_esquema.Maestra
    where PROVEEDOR_PROVINCIA is not null
go

CREATE PROC migracion_codigo_postal
as
    insert into Codigo_postal (codigo_postal, id_provincia)
    select distinct PROVEEDOR_CODIGO_POSTAL, (select id_provincia from Provincia where Provincia.nombre = PROVEEDOR_PROVINCIA) as provincia from gd_esquema.Maestra
        where PROVEEDOR_CODIGO_POSTAL is not null
    union 
    select distinct CLIENTE_CODIGO_POSTAL, (select id_provincia from Provincia where Provincia.nombre = CLIENTE_PROVINCIA) as provincia from gd_esquema.Maestra
        where CLIENTE_CODIGO_POSTAL is not null
go



CREATE PROC migracion_variante
as
    insert into Variante (descripcion_variante, tipo_variante)
    select distinct PRODUCTO_VARIANTE, PRODUCTO_TIPO_VARIANTE from gd_esquema.Maestra
    where PRODUCTO_VARIANTE is not null
go

CREATE PROC migracion_medio_envio
as
    insert into Medio_envio (nombre)
    select distinct VENTA_MEDIO_ENVIO from gd_esquema.Maestra
    where VENTA_MEDIO_ENVIO is not null
go

CREATE PROC migracion_medio_de_pago_venta
as
    insert into Medio_de_pago_venta (nombre, descuento, costo)
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

CREATE PROC migracion_cliente
AS
    insert into Cliente (direccion, DNI, nombre, apellido, telefono, mail, fecha_nac, localidad, codigo_postal)
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

CREATE PROC migracion_canal
AS
    insert into Canal(nombre, costo)
    select distinct VENTA_CANAL, VENTA_CANAL_COSTO from gd_esquema.Maestra
    where VENTA_CANAL is not null
GO

CREATE PROC migracion_producto
AS

    insert into dbo.Producto(cod_producto, nombre, descripcion, material, marca, categoria)
    select distinct PRODUCTO_CODIGO, PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION, PRODUCTO_MATERIAL, PRODUCTO_MARCA, PRODUCTO_CATEGORIA
    from gd_esquema.Maestra
    where PRODUCTO_CODIGO is not null

GO

create proc migracion_proveedor
AS
    
    insert into dbo.Proveedor(cuit, razon_social, domicilio, mail, localidad, codigo_postal)
    select distinct PROVEEDOR_CUIT, PROVEEDOR_RAZON_SOCIAL, PROVEEDOR_DOMICILIO, PROVEEDOR_MAIL, PROVEEDOR_LOCALIDAD, PROVEEDOR_CODIGO_POSTAL
    from gd_esquema.Maestra
    where PROVEEDOR_CUIT is not null

go

create proc migracion_cupon_descuento
AS

    insert into dbo.Cupon_descuento(codigo, fecha_desde, fecha_hasta, valor, tipo)
    select distinct VENTA_CUPON_CODIGO, VENTA_CUPON_FECHA_DESDE, VENTA_CUPON_FECHA_HASTA, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO
    from gd_esquema.Maestra
    where VENTA_CUPON_CODIGO is not null
    order by VENTA_CUPON_CODIGO

Go

CREATE PROC migracion_envio_X_codigo_postal
AS
    insert into Envio_X_codigo_postal (id_medio, codigo_postal, costo_envio)
    select distinct (select id_medio from Medio_envio where Medio_envio.nombre = VENTA_MEDIO_ENVIO) as id_medio,
     CLIENTE_CODIGO_POSTAL,
     (select top 1 VENTA_ENVIO_PRECIO 
     from gd_esquema.Maestra 
     where CLIENTE_CODIGO_POSTAL = m.CLIENTE_CODIGO_POSTAL and VENTA_MEDIO_ENVIO = m.VENTA_MEDIO_ENVIO
     order by VENTA_FECHA desc) 
    from gd_esquema.Maestra m
    where VENTA_MEDIO_ENVIO is not null
GO

CREATE PROC migracion_producto_X_variante 
AS
    insert into Producto_X_variante(cod_producto_X_variante, cod_producto, descripcion_variante, tipo_variante, stock, precio_venta, precio_compra)
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

CREATE PROC migracion_medio_de_pago_compra
as
    insert into Medio_de_pago_compra(nombre)
    select distinct COMPRA_MEDIO_PAGO from gd_esquema.Maestra
    where COMPRA_MEDIO_PAGO is not null
GO

CREATE PROC migracion_compra
AS
    insert into Compra (numero_compra, fecha, proveedor, total, medio_de_pago)
    select distinct COMPRA_NUMERO,
    COMPRA_FECHA,
    PROVEEDOR_CUIT,
    COMPRA_TOTAL,
    (select id_medio_pago_compra from medio_de_pago_compra where nombre = COMPRA_MEDIO_PAGO)
    from gd_esquema.Maestra
    where COMPRA_NUMERO is not null 
GO



create proc migracion_descuento_compra
as
    insert into Descuento_compra(compra, codigo_descuento_compra, valor)
    select COMPRA_NUMERO, DESCUENTO_COMPRA_CODIGO, DESCUENTO_COMPRA_VALOR
    from gd_esquema.Maestra
    where DESCUENTO_COMPRA_CODIGO is not null
    
    
go

create proc migracion_descuento_venta
as

    insert into Descuento_venta(codigo_venta, importe)
    select VENTA_CODIGO, VENTA_DESCUENTO_IMPORTE
    from gd_esquema.Maestra
    where VENTA_CODIGO is not null and VENTA_DESCUENTO_CONCEPTO = 'Otros'
    ORDER by VENTA_CODIGO

go

create proc migracion_compra_X_producto
as
    insert into Compra_X_Producto(producto, compra, precio_unitario, cantidad, total_por_producto)
    select PRODUCTO_VARIANTE_CODIGO, COMPRA_NUMERO, COMPRA_PRODUCTO_PRECIO, sum(COMPRA_PRODUCTO_CANTIDAD) as cant, COMPRA_PRODUCTO_PRECIO * sum(COMPRA_PRODUCTO_CANTIDAD) as total
    from gd_esquema.Maestra
    where COMPRA_NUMERO is not null and PRODUCTO_VARIANTE_CODIGO is not null
    group by PRODUCTO_VARIANTE_CODIGO, COMPRA_NUMERO, COMPRA_PRODUCTO_PRECIO
go


CREATE proc migracion_venta
as
    insert into Venta(codigo_venta, fecha, id_cliente, canal_de_venta, medio_de_envio, costo_envio, medio_de_pago, total, desc_medio_de_pago)
    select 
        VENTA_CODIGO,
        VENTA_FECHA,
        (select id_cliente from Cliente where DNI = CLIENTE_DNI and nombre = CLIENTE_NOMBRE and apellido = CLIENTE_APELLIDO),
        (select id_canal from Canal where nombre = VENTA_CANAL),
        (select id_medio from Medio_envio where nombre = VENTA_MEDIO_ENVIO),
        VENTA_ENVIO_PRECIO,
        (select id_medio_pago from Medio_de_pago_venta where nombre = VENTA_MEDIO_PAGO),
        VENTA_TOTAL,
        isnull((select isnull((select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where VENTA_CODIGO = m1.VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO),0) /
        sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0))
        from gd_esquema.Maestra m1
        where VENTA_CODIGO = m.VENTA_CODIGO
        group by VENTA_CODIGO),0) as porc_descuento_medio_pago
    from gd_esquema.Maestra as m
    where VENTA_CODIGO is not null
    group by VENTA_CODIGO, VENTA_FECHA, VENTA_CANAL, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_MEDIO_PAGO, VENTA_TOTAL, CLIENTE_DNI, CLIENTE_APELLIDO, CLIENTE_NOMBRE
GO

-- chequear que no se use el mismo cupon en la misma venta.
create proc migracion_cupon_decuento_X_venta
as
    insert into Cupon_descuento_X_venta(codigo, codigo_venta, importe)
    select
        VENTA_CUPON_CODIGO,
        VENTA_CODIGO,
        VENTA_CUPON_IMPORTE
    from gd_esquema.Maestra
    where VENTA_CUPON_CODIGO is not null and VENTA_CODIGO is not null
go

create proc migracion_venta_X_producto
as
    insert into Venta_X_Producto(producto_variante, codigo_venta, precio_unitario, cantidad, total_por_producto)
    select PRODUCTO_VARIANTE_CODIGO,
        VENTA_CODIGO,
        VENTA_PRODUCTO_PRECIO,
        sum(VENTA_PRODUCTO_CANTIDAD) as cant, 
        VENTA_PRODUCTO_PRECIO * sum(VENTA_PRODUCTO_CANTIDAD) as total
    from gd_esquema.Maestra
    where VENTA_CODIGO is not null and PRODUCTO_VARIANTE_CODIGO is not null
    group by PRODUCTO_VARIANTE_CODIGO, VENTA_CODIGO, VENTA_PRODUCTO_PRECIO
go



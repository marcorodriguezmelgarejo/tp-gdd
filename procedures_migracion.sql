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

CREATE PROC migracion_medio_de_pago
as
    
    -- Costo del medio de pago: (LISTO)
    select VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO from gd_esquema.Maestra
    -- where VENTA_MEDIO_PAGO is not null
    -- GROUP by venta_medio_pago, venta_medio_pago_costo
    
    -- Descuento del medio de pago: (LISTO)
    select VENTA_MEDIO_PAGO,
        (select top 1-- De la ultima venta con ese medio de pago...
            (select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where VENTA_CODIGO = m1.VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) /
        sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0))
        from gd_esquema.Maestra m1
        where m.VENTA_MEDIO_PAGO = VENTA_MEDIO_PAGO 
        group by VENTA_CODIGO, VENTA_FECHA
        order by VENTA_FECHA desc)
    as descuento_porcentual_por_medio_de_pago
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

CREATE PROC migracion_envio_X_codigo_postal
AS
    insert into Envio_X_codigo_postal (id_medio, codigo_postal, costo_envio)
    select distinct (select id_medio from Medio_envio where Medio_envio.nombre = VENTA_MEDIO_ENVIO) as id_medio,
     CLIENTE_CODIGO_POSTAL,
     VENTA_COSTO_ENVIO from gd_esquema.Maestra
    where VENTA_MEDIO_ENVIO is not null





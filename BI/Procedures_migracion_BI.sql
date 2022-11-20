create proc nibble.migracion_dim_provincia
as
    insert into nibble.Dim_provincia(id_provincia, nombre)
    select distinct id_provincia, nombre from nibble.provincia
go

create proc nibble.migracion_dim_medio_de_pago_venta
as
    insert into nibble.Dim_medio_de_pago_venta(id_medio_de_pago_venta, nombre)
    select distinct id_medio_pago, nombre from nibble.medio_de_pago_venta
go

create proc nibble.migracion_dim_rango_etario
as
    insert into nibble.dim_rango_etario(rango)
    values ('<25'),
         ('25-35'), 
         ('35-55'), 
         ('>55');
go

create proc nibble.migracion_dim_tiempo
AS
    insert into nibble.dim_tiempo(fecha, anio, mes)
    select distinct fecha, (year(fecha)), (month(fecha)) from nibble.Venta
    insert into nibble.dim_tiempo(fecha, anio, mes)

    select distinct fecha, YEAR(fecha), month(fecha) 
    from nibble.Compra
    where fecha not in (select fecha from nibble.dim_tiempo) -- para no insertar la misma fecha dos veces
go

create proc nibble.migracion_dim_tipo_descuento
as
    insert into nibble.dim_tipo_descuento(nombre)
    values ('cupon'), 
        ('medio_de_pago'), 
        ('descuento_por_medio'), 
        ('envio_gratis'),
        ('especial');
go

create proc nibble.migracion_dim_canal
as
    insert into nibble.dim_canal(id_canal,nombre)
    select distinct id_canal, nombre from nibble.Canal
GO

create proc nibble.migracion_dim_producto
as
    insert into nibble.dim_producto(cod_producto, nombre, id_categoria, nombre_categoria)
    select distinct cod_producto, nombre, id_categoria, Categoria.descripcion from nibble.Producto join nibble.Categoria on Producto.categoria = Categoria.id_categoria
GO

create proc nibble.migracion_medio_envio
as
    insert into nibble.dim_medio_de_envio(id_medio_de_envio, nombre)
    select distinct id_medio, nombre from nibble.Medio_envio
GO

create proc nibble.migracion_dim_proveedor
as
    insert into nibble.dim_proveedor(cuit, razon_social)
    select distinct cuit, razon_social from nibble.Proveedor
GO

create proc nibble.migracion_hechos_compras
as
    insert into nibble.Hechos_Ventas_Compras(cod_producto, cuit_proveedor, id_provincia, id_tiempo, cantidad, precio_unitario)
    select producto, cuit, id_provincia, id_tiempo, cantidad, precio_unitario 
    from nibble.Compra 
    join nibble.Compra_X_Producto on Compra.numero_compra = Compra_X_Producto.compra
    join nibble.Proveedor on Compra.proveedor = Proveedor.cuit
    join nibble.Codigo_postal on Proveedor.codigo_postal = Codigo_postal.Codigo_postal
    join nibble.Dim_tiempo on Compra.fecha = dim_tiempo.fecha
go
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
    insert into nibble.dim_rango_etario(nombre_rango, limite_inferior_inclusive, limite_superior_no_inclusive)
    values  ('<25', 0, 24),
            ('25-35', 25, 35), 
            ('35-55', 35, 55), 
            ('>55', 55, 999);
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
    values  ('cupon'), 
            ('medio_de_pago'), 
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
    insert into nibble.dim_producto(id_producto, nombre, id_categoria, nombre_categoria)
    select distinct cod_producto, nombre, id_categoria, Categoria.descripcion from nibble.Producto join nibble.Categoria on Producto.categoria = Categoria.id_categoria
GO

create proc nibble.migracion_dim_medio_envio
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
    insert into nibble.Hechos_Compras(cod_producto, cuit_proveedor, id_provincia, id_tiempo, cantidad, precio_unitario)
    select p.cod_producto, cuit, id_provincia, id_tiempo, cantidad, precio_unitario 
    from nibble.Compra 
    join nibble.Compra_X_Producto on Compra.numero_compra = Compra_X_Producto.compra
	join nibble.Producto_X_Variante on Compra_X_Producto.producto = Producto_X_Variante.cod_producto_x_variante
    join nibble.Producto p on Producto_X_Variante.cod_producto = p.cod_producto
    join nibble.Proveedor on Compra.proveedor = Proveedor.cuit
    join nibble.Codigo_postal on Proveedor.codigo_postal = Codigo_postal.Codigo_postal
    join nibble.Dim_tiempo on Compra.fecha = dim_tiempo.fecha
go

create proc nibble.migracion_hechos_ventas
AS
    insert into nibble.Hechos_Ventas(id_provincia, id_tiempo, id_canal, cod_producto, id_medio_de_envio, id_rango_etario, id_medio_de_pago_venta, cantidad, precio_unitario)
    select id_provincia, 
        id_tiempo,
        canal_de_venta,
        p.cod_producto,
        medio_de_envio,
        (select top 1 id_rango_etario from nibble.dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive),
        medio_de_pago,
        cantidad,
        precio_unitario
        from nibble.Venta
        join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente
        join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
        join nibble.Dim_tiempo on Venta.fecha = dim_tiempo.fecha
        join nibble.Venta_X_Producto on Venta.codigo_venta = Venta_X_Producto.codigo_venta
        join nibble.Producto_X_Variante on Venta_X_Producto.producto_variante = Producto_X_Variante.cod_producto_x_variante
        join nibble.Producto p on Producto_X_Variante.cod_producto = p.cod_producto        
go 

create proc nibble.migracion_hechos_ventas_descuentos
AS
    -- migra los descuentos por medio de pago (hay uno por venta)
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_provincia, id_medio_de_envio, descuento)
    select canal_de_venta, 
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive), 
        medio_de_pago, 
        (select id_tipo_descuento from dim_tipo_descuento where nombre = 'medio_de_pago'),
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha), 
        id_provincia, 
        medio_de_envio, 
        desc_medio_de_pago * total
    from nibble.Venta 
      join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente 
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
      join nibble.medio_de_pago_venta on Venta.medio_de_pago = medio_de_pago_venta.id_medio_pago
    where desc_medio_de_pago is not null

    -- migra los descuentos especiales (hay mas de uno por venta)
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_provincia, id_medio_de_envio, descuento)
    select canal_de_venta, 
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive), 
        medio_de_pago, 
        (select id_tipo_descuento from dim_tipo_descuento where nombre = 'especial'), 
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha), 
        id_provincia, 
        medio_de_envio, 
        importe
    from nibble.Venta 
      join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente 
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
      join nibble.medio_de_pago_venta on Venta.medio_de_pago = medio_de_pago_venta.id_medio_pago
      join nibble.Descuento_Venta on Venta.codigo_venta = Descuento_Venta.codigo_venta

    -- migra los descuentos por cupon (hay mas de uno por venta)
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_provincia, id_medio_de_envio, descuento)
    select canal_de_venta, 
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive), 
        medio_de_pago, 
        (select id_tipo_descuento from dim_tipo_descuento where nombre = 'cupon'), 
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha), 
        id_provincia, 
        medio_de_envio, 
        importe
    from nibble.Venta 
      join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente 
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
      join nibble.medio_de_pago_venta on Venta.medio_de_pago = medio_de_pago_venta.id_medio_pago
      join nibble.Cupon_descuento_X_venta on Venta.codigo_venta = Cupon_descuento_X_venta.codigo_venta

-- migra los descuentos por envio gratis (no hay ninguno)
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_provincia, id_medio_de_envio, descuento)
    select canal_de_venta, 
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive), 
        medio_de_pago, 
        (select id_tipo_descuento from dim_tipo_descuento where nombre = 'cupon'), 
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha), 
        id_provincia, 
        medio_de_envio, 
        Envio_X_codigo_postal.costo_envio -- el descuento por envio gratis es el costo del envio a ese codigo postal
    from nibble.Venta 
      join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente 
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
      join nibble.medio_de_pago_venta on Venta.medio_de_pago = medio_de_pago_venta.id_medio_pago
      join nibble.Envio_X_codigo_postal on Codigo_postal.Codigo_postal = Envio_X_codigo_postal.codigo_postal
    where Venta.costo_envio = 0 and venta.medio_de_envio != 5 -- es 'Entrega en sucursal'     

GO

create proc nibble.migracion_hechos_ventas_costo_medio_de_pago
AS
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tiempo, id_provincia, id_medio_de_envio, costo_medio_de_pago)
    select canal_de_venta,
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive),
        medio_de_pago,
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha),
        id_provincia,
        medio_de_envio,
        costo_medio_de_pago
    from nibble.Venta
        join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente
        join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
GO

create proc nibble.migracion_hechos_ventas_costo_canal
AS
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tiempo, id_provincia, id_medio_de_envio, costo_canal)
    select canal_de_venta,
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive),
        medio_de_pago,
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha),
        id_provincia,
        medio_de_envio,
        costo
    from nibble.Venta
        join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente
        join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
        join nibble.Canal on Venta.canal_de_venta = Canal.id_canal
GO

create proc nibble.migracion_hechos_ventas_costo_envio
AS
    insert into nibble.Hechos_Ventas(id_canal, id_rango_etario, id_medio_de_pago_venta, id_tiempo, id_provincia, id_medio_de_envio, costo_envio)
    select canal_de_venta,
        (select top 1 id_rango_etario from dim_rango_etario where DATEDIFF(year, fecha_nac, GETDATE()) >= limite_inferior_inclusive and DATEDIFF(year, fecha_nac, GETDATE()) < limite_superior_no_inclusive),
        medio_de_pago,
        (select id_tiempo from nibble.Dim_tiempo where fecha = Venta.fecha),
        id_provincia,
        medio_de_envio,
        costo_envio
    from nibble.Venta
        join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente
        join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
GO
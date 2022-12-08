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
    insert into nibble.dim_tiempo(anio, mes)
    select distinct (year(fecha)), (month(fecha)) from nibble.Venta
    
    insert into nibble.dim_tiempo(anio, mes)
    select distinct YEAR(fecha), month(fecha) 
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
    insert into nibble.Hechos_Compras(cod_producto, cuit_proveedor, id_provincia, id_tiempo, cantidad_vendida, monto_vendido)
    select p.cod_producto, cuit, id_provincia, id_tiempo, sum(cantidad), sum(precio_unitario * cantidad)
    from nibble.Compra 
    join nibble.Compra_X_Producto on Compra.numero_compra = Compra_X_Producto.compra
	join nibble.Producto_X_Variante on Compra_X_Producto.producto = Producto_X_Variante.cod_producto_x_variante
    join nibble.Producto p on Producto_X_Variante.cod_producto = p.cod_producto
    join nibble.Proveedor on Compra.proveedor = Proveedor.cuit
    join nibble.Codigo_postal on Proveedor.codigo_postal = Codigo_postal.Codigo_postal
    join nibble.Dim_tiempo on month(Compra.fecha) = dim_tiempo.mes and year(compra.fecha) = dim_tiempo.anio
    group by p.cod_producto, cuit, id_provincia, id_tiempo
go


create proc nibble.migracion_hechos_items_ventas
AS
    insert into nibble.Hechos_Items_Ventas(id_provincia, id_tiempo, id_canal, cod_producto, id_medio_de_envio, id_rango_etario, id_medio_de_pago_venta, cantidad_vendida, monto_vendido)
    select id_provincia, 
        id_tiempo,
        canal_de_venta,
        p.cod_producto,
        medio_de_envio,
        (case when DATEDIFF(year, fecha_nac, GETDATE()) >= 0 and DATEDIFF(year, fecha_nac, GETDATE()) < 25
            then 1
            when
                DATEDIFF(year, fecha_nac, GETDATE()) >= 25 and DATEDIFF(year, fecha_nac, GETDATE()) < 35
            then 2
            when
                DATEDIFF(year, fecha_nac, GETDATE()) >= 35 and DATEDIFF(year, fecha_nac, GETDATE()) < 55
            then 3
            else 4
        end),
        medio_de_pago,
        sum(cantidad),
        sum(precio_unitario * cantidad)
    from nibble.Venta
        join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente
        join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
        join nibble.Dim_tiempo on month(Venta.fecha) = dim_tiempo.mes and year(Venta.fecha) = dim_tiempo.anio
        join nibble.Venta_X_Producto on Venta.codigo_venta = Venta_X_Producto.codigo_venta
        join nibble.Producto_X_Variante on Venta_X_Producto.producto_variante = Producto_X_Variante.cod_producto_x_variante
        join nibble.Producto p on Producto_X_Variante.cod_producto = p.cod_producto        
    group by id_provincia, id_tiempo, canal_de_venta, p.cod_producto, medio_de_envio, medio_de_pago,
        case when DATEDIFF(year, fecha_nac, GETDATE()) >= 0 and DATEDIFF(year, fecha_nac, GETDATE()) < 25
            then 1
            when
                DATEDIFF(year, fecha_nac, GETDATE()) >= 25 and DATEDIFF(year, fecha_nac, GETDATE()) < 35
            then 2
            when
                DATEDIFF(year, fecha_nac, GETDATE()) >= 35 and DATEDIFF(year, fecha_nac, GETDATE()) < 55
            then 3
            else 4
        end
go

create proc nibble.migracion_hechos_ventas
AS
    -- migramos por separado para cada las ventas que tienen cada tipo de descuento

    insert into nibble.Hechos_Ventas(id_provincia, id_canal, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_medio_de_envio, descuento, costo_medio_de_pago, costo_canal, costo_envio)
    select id_provincia, 
        canal_de_venta,  
        medio_de_pago, 
        (select id_tipo_descuento from nibble.dim_tipo_descuento where nombre = 'medio_de_pago'),
        (select id_tiempo from nibble.Dim_tiempo where anio = year(Venta.fecha) and mes = month(Venta.fecha)), 
        medio_de_envio, 
        sum(desc_medio_de_pago * total),
        sum(costo_medio_de_pago),
        sum(canal.costo),
        sum(costo_envio)
    from nibble.Venta  
        join nibble.Canal on Canal.id_canal = Venta.canal_de_venta
        join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente
        join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
    where desc_medio_de_pago is not null and desc_medio_de_pago > 0
    group by id_provincia, canal_de_venta, medio_de_pago, month(Venta.fecha), year(Venta.fecha), medio_de_envio

    insert into nibble.Hechos_Ventas(id_provincia, id_canal, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_medio_de_envio, descuento, costo_medio_de_pago, costo_canal, costo_envio)
    select id_provincia,
        canal_de_venta, 
        medio_de_pago, 
        (select id_tipo_descuento from nibble.dim_tipo_descuento where nombre = 'especial'), 
        (select id_tiempo from nibble.Dim_tiempo where anio = year(Venta.fecha) and mes = month(Venta.fecha)), 
        medio_de_envio,
        sum(importe),
        sum(costo_medio_de_pago),
        sum(canal.costo),
        sum(costo_envio)
    from nibble.Venta
      join nibble.Cliente on Cliente.id_cliente = Venta.id_cliente
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.codigo_postal
      join nibble.Descuento_Venta on Venta.codigo_venta = Descuento_Venta.codigo_venta
      join nibble.Canal on Canal.id_canal = Venta.canal_de_venta
    group by id_provincia, canal_de_venta, medio_de_pago, month(Venta.fecha), year(Venta.fecha), medio_de_envio

    insert into nibble.Hechos_Ventas(id_provincia, id_canal, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_medio_de_envio, descuento, costo_medio_de_pago, costo_canal, costo_envio)
    select id_provincia,
        canal_de_venta, 
        medio_de_pago, 
        (select id_tipo_descuento from nibble.dim_tipo_descuento where nombre = 'cupon'), 
        (select id_tiempo from nibble.Dim_tiempo where anio = year(Venta.fecha) and mes = month(Venta.fecha)),
        medio_de_envio, 
        sum(importe),
        sum(costo_medio_de_pago),
        sum(canal.costo),
        sum(costo_envio)
    from nibble.Venta 
      join nibble.Cliente on Cliente.id_cliente = Venta.id_cliente
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.codigo_postal
      join nibble.Cupon_descuento_X_venta on Venta.codigo_venta = Cupon_descuento_X_venta.codigo_venta
      join nibble.Canal on Canal.id_canal = Venta.canal_de_venta
    group by id_provincia, canal_de_venta, medio_de_pago, month(Venta.fecha), year(Venta.fecha), medio_de_envio

    insert into nibble.Hechos_Ventas(id_provincia, id_canal, id_medio_de_pago_venta, id_tipo_descuento, id_tiempo, id_medio_de_envio, descuento, costo_medio_de_pago, costo_canal, costo_envio)
    select id_provincia,
        canal_de_venta, 
        medio_de_pago, 
        (select id_tipo_descuento from nibble.dim_tipo_descuento where nombre = 'envio gratis'),
        (select id_tiempo from nibble.Dim_tiempo where anio = year(Venta.fecha) and mes = month(Venta.fecha)),
        medio_de_envio, 
        Envio_X_codigo_postal.costo_envio, -- el descuento por envio gratis es el costo del envio a ese codigo postal
        sum(costo_medio_de_pago),
        sum(canal.costo),
        sum(Venta.costo_envio)
    from nibble.Venta 
      join nibble.Cliente on Cliente.id_cliente = Venta.id_cliente
      join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.codigo_postal
      join nibble.Envio_X_codigo_postal on Cliente.Codigo_postal = Envio_X_codigo_postal.codigo_postal
      join nibble.medio_de_pago_venta on Venta.medio_de_pago = medio_de_pago_venta.id_medio_pago
      join nibble.Canal on Canal.id_canal = Venta.canal_de_venta
    where Venta.costo_envio = 0 and venta.medio_de_envio != 5 -- es 'Entrega en sucursal'
    group by id_provincia, canal_de_venta, medio_de_pago, month(Venta.fecha), year(Venta.fecha), medio_de_envio, Envio_X_codigo_postal.costo_envio
GO

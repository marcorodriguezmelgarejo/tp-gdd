-- creacion de dimensiones
use gd2c2022

create table nibble.Dim_tiempo (
    id_tiempo decimal(10) identity(1,1) primary key,
    fecha date,
    anio decimal(4),
    mes decimal(2)
);

create table nibble.Dim_provincia (
    id_provincia decimal(3) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_rango_etario (
    id_rango_etario decimal(3) identity(1,1) primary key,
    nombre_rango nvarchar(255),
    limite_inferior_inclusive decimal(3),
    limite_superior_no_inclusive decimal(3)
);

create table nibble.Dim_canal (
    id_canal decimal(18,0) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_producto (
    id_producto nvarchar(50) primary key,
    nombre nvarchar(255),
    id_categoria decimal(18,0),
    nombre_categoria nvarchar(255)
);

create table nibble.Dim_proveedor (
    CUIT nvarchar(50) primary key,
    razon_social nvarchar(50)
);

create table nibble.Dim_Medio_de_envio (
    id_medio_de_envio decimal(18,0) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_tipo_descuento (
    id_tipo_descuento decimal(18) identity(1,1) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_medio_de_pago_venta (
    id_medio_de_pago_venta decimal(18) primary key,
    nombre nvarchar(255)
);


create table nibble.Hechos_Ventas (
    id_provincia decimal(3),
    id_tiempo decimal(10),
    id_canal decimal(18,0),
    cod_producto nvarchar(50),
    id_medio_de_envio decimal(18,0),
    id_rango_etario decimal(3),
    id_medio_de_pago_venta decimal(18),
    id_tipo_descuento decimal(18),
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
    costo_medio_de_pago decimal(18,2),
    costo_canal decimal(18,2),
    descuento decimal(18,2),
    costo_envio decimal(18,2),
    constraint FK_Hechos_Ventas_Dim_provincia foreign key (id_provincia) references nibble.Dim_provincia(id_provincia),
    constraint FK_Hechos_Ventas_Dim_tiempo foreign key (id_tiempo) references nibble.Dim_tiempo(id_tiempo),
    constraint FK_Hechos_Ventas_Dim_canal foreign key (id_canal) references nibble.Dim_canal(id_canal),
    constraint FK_Hechos_Ventas_Dim_medio_de_envio foreign key (id_medio_de_envio) references nibble.Dim_Medio_de_envio(id_medio_de_envio),
    constraint FK_Hechos_Ventas_Dim_rango_etario foreign key (id_rango_etario) references nibble.Dim_rango_etario(id_rango_etario),
    constraint FK_Hechos_Ventas_Dim_medio_de_pago_venta foreign key (id_medio_de_pago_venta) references nibble.Dim_medio_de_pago_venta(id_medio_de_pago_venta),
    constraint FK_Hechos_Ventas_Dim_tipo_descuento foreign key (id_tipo_descuento) references nibble.Dim_tipo_descuento(id_tipo_descuento),
    constraint FK_Hechos_Ventas_Dim_producto foreign key (cod_producto) references nibble.Dim_producto(id_producto)
); 


create table nibble.Hechos_Compras (
    id_provincia decimal(3),
    id_tiempo decimal(10),
    cod_producto nvarchar(50),
    cuit_proveedor nvarchar(50),
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
    constraint FK_Hechos_Compras_Dim_provincia foreign key (id_provincia) references nibble.Dim_provincia(id_provincia),
    constraint FK_Hechos_Compras_Dim_tiempo foreign key (id_tiempo) references nibble.Dim_tiempo(id_tiempo),
    constraint FK_Hechos_Compras_Dim_producto foreign key (cod_producto) references nibble.Dim_producto(id_producto),
    constraint FK_Hechos_Compras_Dim_proveedor foreign key (cuit_proveedor) references nibble.Dim_proveedor(CUIT)
); 
go

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

create proc nibble.migracion_BI
as 
    exec nibble.migracion_dim_rango_etario
    exec nibble.migracion_dim_producto
    exec nibble.migracion_dim_provincia
    exec nibble.migracion_dim_medio_de_pago_venta
    exec nibble.migracion_dim_tiempo
    exec nibble.migracion_dim_tipo_descuento
    exec nibble.migracion_dim_canal
    exec nibble.migracion_dim_medio_envio
    exec nibble.migracion_dim_proveedor
    exec nibble.migracion_hechos_compras
    exec nibble.migracion_hechos_ventas
    exec nibble.migracion_hechos_ventas_descuentos
    exec nibble.migracion_hechos_ventas_costo_medio_de_pago
    exec nibble.migracion_hechos_ventas_costo_canal
    exec nibble.migracion_hechos_ventas_costo_envio
go

exec nibble.migracion_BI
go

-- Las ganancias mensuales de cada canal de venta.
--Se entiende por ganancias al total de las ventas, menos el total de las
--compras, menos los costos de transacción totales aplicados asociados los
--medios de pagos utilizados en las mismas


go
create view nibble.Ganancias_Mensuales_Por_Canal
as
    select canal.nombre canal, tiempoVentas.anio, tiempoVentas.mes,  (sum(v.cantidad * v.precio_unitario) - sum(v.cantidad) *
                                                (select avg(c.precio_unitario ) 
                                                from nibble.Hechos_Compras c
                                                join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio and tiempoCompras.mes = tiempoVentas.mes
												group by tiempoCompras.anio, tiempoCompras.mes
												  )
                                                - sum(isnull(v.costo_medio_de_pago,0) + isnull(v.costo_canal,0))) GananciasTotales
        from nibble.Hechos_Ventas v 
		join nibble.Dim_canal canal on canal.id_canal = v.id_canal 
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
        group by canal.nombre, tiempoVentas.anio, tiempoVentas.mes

go
-- Test
--select * from Ganancias_Mensuales_Por_Canal order by anio, mes, canal asc


-- Los 5 productos con mayor rentabilidad anual, con sus respectivos %
--Se entiende por rentabilidad a los ingresos generados por el producto
--(ventas) durante el periodo menos la inversión realizada en el producto
--(compras) durante el periodo, todo esto sobre dichos ingresos.
--Valor expresado en porcentaje.
--Para simplificar, no es necesario tener en cuenta los descuentos aplicados.



--OPCION QUE CUMPLE LITERALMENTE CON EL ENUNCIADO
--alter view top5RentabilidadAnual
--as	
--	select * from 
--	(select RANK() OVER (PARTITION BY tiempoVentas.anio ORDER BY ((sum(v.cantidad * v.precio_unitario) - (sum(v.cantidad) *
--													(select avg(c.precio_unitario ) 
--													from nibble.Hechos_Compras c
--													join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio
--													group by tiempoCompras.anio
--													  )))/ sum(v.cantidad * v.precio_unitario)) DESC) puesto,
												  
--			v.cod_producto, p.nombre, ((rtrim(ltrim((sum(v.cantidad * v.precio_unitario) - (sum(v.cantidad) *
--											(select avg(c.precio_unitario ) 
--											from nibble.Hechos_Compras c
--											join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio
--											)))/ sum(v.cantidad * v.precio_unitario))))+' %') Rentabilidad_anual,tiempoVentas.anio
--												from nibble.Hechos_Ventas v 
--												join nibble.Dim_producto p on p.id_producto = cod_producto
--												join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
--												group by v.cod_producto,p.nombre, tiempoVentas.anio
--												) Ranking_Rentabilidad
--		where puesto <=5
--		order by anio, puesto
--go



------------------------------------------------------------------------------------------------------
--OPCION SENCILLA
create view nibble.top5RentabilidadAnual
as	


    select top 5  v.cod_producto,p.nombre, (rtrim(ltrim(((sum(v.cantidad * v.precio_unitario) - (sum(v.cantidad) *
                                                (select avg(c.precio_unitario ) 
                                                from nibble.Hechos_Compras c
                                                join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio
												group by tiempoCompras.anio
												  )))/ sum(v.cantidad * v.precio_unitario))*100))+' %') Rentabilidad_anual , tiempoVentas.anio
        from nibble.Hechos_Ventas v 
		join nibble.Dim_producto p on p.id_producto = v.cod_producto
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
        group by v.cod_producto,p.nombre, tiempoVentas.anio
		order by ((sum(v.cantidad * v.precio_unitario) - (sum(v.cantidad) *
                                                (select avg(c.precio_unitario ) 
                                                from nibble.Hechos_Compras c
                                                join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio
												group by tiempoCompras.anio
												  )))/ sum(v.cantidad * v.precio_unitario)) desc


go

-- select * from top5RentabilidadAnual 

-- Las 5 categorías de productos más vendidos por rango etario de clientes
--por mes.
create view nibble.top5categoriasPorRangoEtario
as
	select mes, anio, re.nombre_rango, p.nombre_categoria, sum(v.cantidad) cantidad
	from nibble.Hechos_Ventas v 
		join nibble.Dim_Tiempo t on v.id_tiempo = t.id_tiempo
		join nibble.Dim_Producto p on v.cod_producto = p.id_producto
		join nibble.Dim_rango_etario re on v.id_rango_etario = re.id_rango_etario
	group by mes, anio, re.id_rango_etario, re.nombre_rango, p.nombre_categoria
	having count(distinct p.id_categoria) <= 5 -- para que no me muestre mas de 5 categorias

go





-- Total de Ingresos por cada medio de pago por mes, descontando los costos
--por medio de pago (en caso que aplique) y descuentos por medio de pago
--(en caso que aplique)
create view nibble.Ingresos
as
	select mp.nombre Medio_De_Pago, tiempoVentas.anio, tiempoVentas.mes,  (sum(v.cantidad * v.precio_unitario) - sum(isnull(v.costo_medio_de_pago,0) + isnull(v.descuento,0))) GananciasTotales
        from nibble.Hechos_Ventas v 
		join nibble.Dim_medio_de_pago_venta mp on mp.id_medio_de_pago_venta = v.id_medio_de_pago_venta 
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
        group by mp.nombre, tiempoVentas.anio, tiempoVentas.mes
		

go

--select * from Ingresos order by anio, mes, GananciasTotales desc


-- Importe total en descuentos aplicados según su tipo de descuento, por
--canal de venta, por mes. Se entiende por tipo de descuento como los
--correspondientes a envío, medio de pago, cupones, etc)
create view nibble.total_descuentos_por_tipo_canal_y_mes
as
	select anio, mes, nibble.Dim_canal.nombre as canal, 
		nibble.Dim_tipo_descuento.nombre as tipo_descuento, 
		sum(descuento) as total_descuentos
	from nibble.Hechos_Ventas
		join nibble.Dim_Tiempo on Hechos_Ventas.id_tiempo = Dim_Tiempo.id_tiempo
		join nibble.Dim_tipo_descuento on Hechos_Ventas.id_tipo_descuento = Dim_tipo_descuento.id_tipo_descuento
		join nibble.Dim_canal on Hechos_Ventas.id_canal = Dim_canal.id_canal
	group by anio, mes, nibble.Dim_canal.id_canal, nibble.Dim_tipo_descuento.id_tipo_descuento,
		nibble.Dim_canal.nombre, nibble.Dim_tipo_descuento.nombre

go

-- PRUEBA
-- -- total descuentos especiales en el mes 2/2022 por ventas por Facebook 
-- select sum(importe)
-- from nibble.Venta join nibble.Descuento_venta
-- 	on Venta.codigo_venta = Descuento_venta.codigo_venta
-- where YEAR(fecha) = 2022 and MONTH(fecha) = 2 and Venta.canal_de_venta = 3

-- -- total descuentos por cupon en el mes 2/2022 por ventas por Facebook 
-- select sum(importe)
-- from nibble.Venta join nibble.Cupon_descuento_X_venta
-- 	on Venta.codigo_venta = Cupon_descuento_X_venta.codigo_venta
-- where YEAR(fecha) = 2022 and MONTH(fecha) = 2 and Venta.canal_de_venta = 3

-- -- total descuentos por medio de pago en el mes 2/2022 por ventas por Facebook 
-- select sum(desc_medio_de_pago * total)
-- from nibble.Venta
-- where YEAR(fecha) = 2022 and MONTH(fecha) = 2 and Venta.canal_de_venta = 3



-- Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
--debe representar la cantidad de envíos realizados a cada provincia sobre
--total de envío mensuales.
create view nibble.EnviosxProvincia
as

	select tiempoVentas.anio, tiempoVentas.mes, p.nombre Provincia, (rtrim(ltrim((count(v.id_provincia)*1.0   -- Multiplico por 1.0 para castearlo a decimal devido a que sino, SQL asumira que es una div de enteros y retornara 0 al ser mas grande el denominador
	/ (select count(v2.id_provincia) 
			from nibble.Hechos_Ventas v2
			join nibble.Dim_Tiempo t on t.id_tiempo = v2.id_tiempo and t.anio = tiempoVentas.anio and t.mes = tiempoVentas.mes
			where id_medio_de_envio <> 5
			group by t.anio, t.mes
													))))+' %') PorcentajeDelTotal
	from nibble.Hechos_Ventas v 
		join nibble.Dim_provincia p on v.id_provincia = p.id_provincia  
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
		where v.id_medio_de_envio <> 5
        group by p.nombre, tiempoVentas.anio, tiempoVentas.mes

		

go

--select * from nibble.dim_medio_de_envio

-- Valor promedio de envío por Provincia por Medio De Envío anual.
create view nibble.ValorEnvioXProvincia
as
    SELECT p.nombre, avg(v.costo_envio) as costo_envio, t.anio 
		from nibble.Hechos_Ventas v
        join nibble.Dim_provincia p on v.id_provincia = p.id_provincia 
        join nibble.Dim_Tiempo t on v.id_tiempo = t.id_tiempo 
        group by p.nombre, t.anio

go


-- Aumento promedio de precios de cada proveedor anual. Para calcular este
--indicador se debe tomar como referencia el máximo precio por año menos
--el mínimo todo esto divido el mínimo precio del año. Teniendo en cuenta
--que los precios siempre van en aumento.

create view nibble.aumentoDePrecios
as
    select c.cuit_proveedor, ((rtrim(ltrim(((max(c.precio_unitario) - min(c.precio_unitario))/min(c.precio_unitario))*100)))+' %') Promedio_De_Precios, t.anio 
	from nibble.Hechos_Compras c 
	join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
	GROUP by c.cuit_proveedor, t.anio

go


-- Los 3 productos con mayor cantidad de reposición por mes. 
create view nibble.top_Productos_reposicion
as
    select top 3 c.cod_producto, sum(c.cantidad) Cantidad_de_Reposicion 
		from nibble.Hechos_Compras c 
		join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
		GROUP by c.cod_producto, t.anio, t.mes

go
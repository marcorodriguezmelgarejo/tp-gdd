-- Las ganancias mensuales de cada canal de venta.
--Se entiende por ganancias al total de las ventas, menos el total de las
--compras, menos los costos de transacción totales aplicados asociados los
--medios de pagos utilizados en las mismas

go
create view nibble.Ganancias_Mensuales_Por_Canal
as

    select canal.nombre canal, tiempoVentas.anio, tiempoVentas.mes,  (sum(iv.monto_vendido) - sum(iv.cantidad_vendida) *
                                                (select avg(c.monto_comprado / c.cantidad_comprada)
                                                from nibble.Hechos_Compras c
                                                join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio and tiempoCompras.mes = tiempoVentas.mes
												where c.cod_producto = iv.cod_producto
												group by c.cod_producto
												)
                                                - 
												(select sum(isnull(v.costo_medio_de_pago,0) + isnull(v.costo_canal,0))
												from nibble.Hechos_Ventas v
        from nibble.Hechos_Ventas v 
												from nibble.Hechos_Ventas v
												where v.id_canal = iv.id_canal and v.id_tiempo = iv.id_tiempo)
												) GananciasTotales
        from nibble.Hechos_Items_Ventas iv
		join nibble.Dim_canal canal on canal.id_canal = iv.id_canal 
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = iv.id_tiempo
        group by canal.nombre, tiempoVentas.anio, tiempoVentas.mes, iv.cod_producto,  iv.id_canal, iv.id_tiempo
go


-- Los 5 productos con mayor rentabilidad anual, con sus respectivos %
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
--		
--go



------------------------------------------------------------------------------------------------------

-- MEJOR OPCION 
create view nibble.top5RentabilidadAnual
as	


    select top 5 v.cod_producto,p.nombre, concat((((sum(monto_vendido) -
                                                (select sum(c.monto_comprado) 
                                                from nibble.Hechos_Compras c
                                                join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio
												where c.cod_producto = v.cod_producto
												group by tiempoCompras.anio
												  )))/ sum(monto_vendido))*100, '%') Rentabilidad_anual , tiempoVentas.anio
        from nibble.Hechos_Items_Ventas v 
		join nibble.Dim_producto p on p.id_producto = v.cod_producto
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
        group by v.cod_producto, p.nombre, tiempoVentas.anio
		order by ((sum(monto_vendido) - (select sum(c.monto_comprado) 
                                                from nibble.Hechos_Compras c
                                                join nibble.Dim_Tiempo tiempoCompras on c.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio
												where c.cod_producto = v.cod_producto
												group by tiempoCompras.anio
												  ))/ sum(monto_vendido)) desc


go



-- Las 5 categorías de productos más vendidos por rango etario de clientes
--por mes.
create view nibble.top5categoriasPorRangoEtario
as
	select anio, mes, re.nombre_rango, p.nombre_categoria, sum(v.cantidad_vendida) cantidad
	from nibble.Hechos_Items_Ventas v 
		join nibble.Dim_Tiempo t on v.id_tiempo = t.id_tiempo
		join nibble.Dim_Producto p on v.cod_producto = p.id_producto
		join nibble.Dim_rango_etario re on v.id_rango_etario = re.id_rango_etario
	group by mes, anio, v.id_tiempo, p.id_categoria, v.id_rango_etario, re.nombre_rango, p.nombre_categoria
	having p.id_categoria in (
		select top 5 p2.id_categoria 
		from nibble.Hechos_Items_Ventas v2 join nibble.Dim_producto p2 on v2.cod_producto = p2.id_producto
		where v2.id_rango_etario = v.id_rango_etario and v2.id_tiempo = v.id_tiempo
		group by p2.id_categoria
		order by sum(cantidad_vendida) desc	
	)

go





-- Total de Ingresos por cada medio de pago por mes, descontando los costos
--por medio de pago (en caso que aplique) y descuentos por medio de pago
--(en caso que aplique)


create view nibble.Ingresos
as
	select mp.nombre Medio_De_Pago, tiempoVentas.anio, tiempoVentas.mes, (select sum(monto_vendido) from nibble.Hechos_Items_Ventas
																			where id_tiempo = v.id_tiempo and id_medio_de_pago_venta = v.id_medio_de_pago_venta)
			- sum(isnull(v.costo_medio_de_pago,0) + isnull(v.descuento,0)) GananciasTotales
        from nibble.Hechos_Ventas v 
		join nibble.Dim_medio_de_pago_venta mp on mp.id_medio_de_pago_venta = v.id_medio_de_pago_venta 
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
        group by mp.nombre, tiempoVentas.anio, tiempoVentas.mes, v.id_tiempo, v.id_medio_de_pago_venta
		
go

--select * from Ingresos order by anio, mes, GananciasTotales desc


-- Importe total en descuentos aplicados según su tipo de descuento, por
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

	select tiempoVentas.anio, tiempoVentas.mes, p.nombre Provincia, concat((count(v.id_provincia)*1.0   -- Multiplico por 1.0 para castearlo a decimal debido a que sino, SQL asumira que es una div de enteros y retornara 0 al ser mas grande el denominador
	/ (select count(v2.id_provincia) 
			from nibble.Hechos_Ventas v2
			join nibble.Dim_Tiempo t on t.id_tiempo = v2.id_tiempo and t.anio = tiempoVentas.anio and t.mes = tiempoVentas.mes
			where id_medio_de_envio <> 5
			group by t.anio, t.mes
													))*100, '%') PorcentajeDelTotal
	from nibble.Hechos_Ventas v 
		join nibble.Dim_provincia p on v.id_provincia = p.id_provincia  
		join nibble.Dim_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
		where v.id_medio_de_envio <> 5
        group by p.nombre, tiempoVentas.anio, tiempoVentas.mes

		

go


-- Valor promedio de envío por Provincia por Medio De Envío anual.
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
    select c.cuit_proveedor, concat(100*( -- para cada proveedor y anio...
		select avg( -- para todos los produtos distintos que se compraron a ese proveedor en ese anio...
		(( 
			select top 1 precio_unitario_max -- precio maximo de ese producto en el ultimo mes en el que se compro ese anio
			from nibble.Hechos_Compras c3 join nibble.Dim_Tiempo t3 on c3.id_tiempo = t3.id_tiempo
			where c3.cuit_proveedor = c.cuit_proveedor and t3.anio = t.anio and c3.cod_producto = c2.cod_producto
			order by t3.mes desc
		) - 
		(
			select top 1 precio_unitario_min -- precio minimo de ese producto en el primer mes en el que se compro ese anio
			from nibble.Hechos_Compras c3 join nibble.Dim_Tiempo t3 on c3.id_tiempo = t3.id_tiempo
			where c3.cuit_proveedor = c.cuit_proveedor and t3.anio = t.anio and c3.cod_producto = c2.cod_producto
			order by t3.mes asc
		))
		/ 
		(
			select top 1 precio_unitario_min -- precio minimo de ese producto en el primer mes en el que se compro ese anio
			from nibble.Hechos_Compras c3 join nibble.Dim_Tiempo t3 on c3.id_tiempo = t3.id_tiempo
			where c3.cuit_proveedor = c.cuit_proveedor and t3.anio = t.anio and c3.cod_producto = c2.cod_producto
			order by t3.mes asc
		))
		from nibble.Hechos_Compras c2 join nibble.Dim_Tiempo t2 on c2.id_tiempo = t2.id_tiempo
		where c2.cuit_proveedor = c.cuit_proveedor and t2.anio = t.anio
		group by c2.cod_producto)
		,'%') Aumento_Promedio_De_Precios, t.anio 
	from nibble.Hechos_Compras c 
	join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
	GROUP by c.cuit_proveedor, t.anio
go

-- Los 3 productos con mayor cantidad de reposición por mes. 
create view nibble.top_Productos_reposicion
as
    select c.cod_producto, anio, mes, sum(c.cantidad_comprada) Cantidad_de_Reposicion 
		from nibble.Hechos_Compras c 
	join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
	GROUP by c.cod_producto, t.anio, t.mes, t.id_tiempo
	having c.cod_producto in (
		select top 3 c2.cod_producto
		from nibble.Hechos_Compras c2
		where c2.id_tiempo = t.id_tiempo 
		GROUP by c2.cod_producto
		order by sum(c2.cantidad_comprada) desc
	)
go

-- opción mas performante pero con subselect en from 
-- create view nibble.top_Productos_reposicion
-- as
--    select * from (select (RANK() OVER (PARTITION BY t.anio, t.mes ORDER BY sum(c.cantidad_comprada) desc)) indice_ranking,c.cod_producto, anio, mes, sum(c.cantidad_comprada) Cantidad_de_Reposicion 
-- 		from nibble.Hechos_Compras c 
-- 	join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
-- 	GROUP by c.cod_producto, t.anio, t.mes, t.id_tiempo) as xd
-- 	where indice_ranking <= 3
-- go
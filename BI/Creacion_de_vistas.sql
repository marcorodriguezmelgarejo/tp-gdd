use GD2C2022

-- Las ganancias mensuales de cada canal de venta.
--Se entiende por ganancias al total de las ventas, menos el total de las
--compras, menos los costos de transacción totales aplicados asociados los
--medios de pagos utilizados en las mismas


go
alter view Ganancias_Mensuales_Por_Canal
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
alter view top5RentabilidadAnual
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
create view top5categoriasPorRangoEtario
as
	select mes, anio, re.nombre_rango, p.nombre_categoria, sum(v.cantidad) cantidad
	from nibble.Hechos_Ventas v 
		join nibble.Dim_Tiempo t on v.id_tiempo = t.id_tiempo
		join nibble.Dim_Producto p on v.cod_producto = p.id_producto
		join nibble.Dim_rango_etario re on v.id_rango_etario = re.id_rango_etario
	group by mes, anio, re.id_rango_etario, re.nombre_rango, p.nombre_categoria
	having count(distinct p.id_categoria) <= 5 -- para que no me muestre mas de 5 categorias
	order by mes, anio, re.id_rango_etario, sum(v.cantidad) desc

go





-- Total de Ingresos por cada medio de pago por mes, descontando los costos
--por medio de pago (en caso que aplique) y descuentos por medio de pago
--(en caso que aplique)
create view Ingresos
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
create view total_descuentos_por_tipo_canal_y_mes
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
	order by anio, mes, nibble.Dim_canal.nombre, nibble.Dim_tipo_descuento.nombre

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
create view EnviosxProvincia
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
		order by tiempoVentas.anio, tiempoVentas.mes, count(v.id_provincia) desc
		

go

--select * from nibble.dim_medio_de_envio

-- Valor promedio de envío por Provincia por Medio De Envío anual.
create view ValorEnvioXProvincia
as
    SELECT p.nombre, avg(v.costo_envio), t.anio 
		from nibble.Hechos_Ventas v
        join nibble.Dim_provincia p on v.id_provincia = p.id_provincia 
        join nibble.Dim_Tiempo t on v.id_tiempo = t.id_tiempo 
        group by p.nombre, t.anio

go


-- Aumento promedio de precios de cada proveedor anual. Para calcular este
--indicador se debe tomar como referencia el máximo precio por año menos
--el mínimo todo esto divido el mínimo precio del año. Teniendo en cuenta
--que los precios siempre van en aumento.

create view aumentoDePrecios
as
    select c.cuit_proveedor, ((rtrim(ltrim(((max(c.precio_unitario) - min(c.precio_unitario))/min(c.precio_unitario))*100)))+' %') Promedio_De_Precios, t.anio 
	from nibble.Hechos_Compras c 
	join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
	GROUP by c.cuit_proveedor, t.anio
	order by c.cuit_proveedor, t.anio desc

go


-- Los 3 productos con mayor cantidad de reposición por mes. 
create view top_Productos_reposicion
as
    select top 3 c.cod_producto, sum(c.cantidad) Cantidad_de_Reposicion 
		from nibble.Hechos_Compras c 
		join nibble.Dim_Tiempo t on c.id_tiempo = t.id_tiempo 
		GROUP by c.cod_producto, t.anio, t.mes
		order by 2 desc
	



go
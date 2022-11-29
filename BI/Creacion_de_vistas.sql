-- Las ganancias mensuales de cada canal de venta.
--Se entiende por ganancias al total de las ventas, menos el total de las
--compras, menos los costos de transacción totales aplicados asociados los
--medios de pagos utilizados en las mismas


create view Ganancias_Mensuales_Por_Canal
as
    select v.id_canal, tiempoVentas.anio, tiempoVentas.mes,  (sum(cantidad * precio) - 
                                                (select sum(Hechos_Compras.precio * Hechos_Ventas.cantidad ) 
                                                from Hechos_Compras 
                                                join Dimension_Tiempo tiempoCompras on Hechos_Compras.id_tiempo = tiempoCompras.id_tiempo and tiempoCompras.anio = tiempoVentas.anio and tiempoCompras.mes = tiempoVentas.mes ) 
                                                - sum(v.costo_medio_pago + v.costo_canal)) GananciasTotales
        from Hechos_Ventas v 
		join Dimension_Canal canal on canal.id_canal = id_canal 
		join Dimension_Tiempo tiempoVentas on tiempoVentas.id_tiempo = v.id_tiempo
        group by v.id_canal, tiempoVentas.anio, tiempoVentas.mes

go


-- Los 5 productos con mayor rentabilidad anual, con sus respectivos %
--Se entiende por rentabilidad a los ingresos generados por el producto
--(ventas) durante el periodo menos la inversión realizada en el producto
--(compras) durante el periodo, todo esto sobre dichos ingresos.
--Valor expresado en porcentaje.
--Para simplificar, no es necesario tener en cuenta los descuentos aplicados.
--12
create view top5RentabilidadAnual
as
    select top 5 


go




-- Las 5 categorías de productos más vendidos por rango etario de clientes
--por mes.
create view xxxxx
as



go





-- Total de Ingresos por cada medio de pago por mes, descontando los costos
--por medio de pago (en caso que aplique) y descuentos por medio de pago
--(en caso que aplique)
create view xxxxx
as


go




-- Importe total en descuentos aplicados según su tipo de descuento, por
--canal de venta, por mes. Se entiende por tipo de descuento como los
--correspondientes a envío, medio de pago, cupones, etc)
create view xxxxx
as



go



-- Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
--debe representar la cantidad de envíos realizados a cada provincia sobre
--total de envío mensuales.
create view xxxxx
as



go



-- Valor promedio de envío por Provincia por Medio De Envío anual.
create view ValorEnvioXProvincia
as
    SELECT p.nombre, avg(v.costo_envio), t.anio from Hechos_Ventas 
        join Dimension_Provincia p on v.id_provincia= p.id_provincia 
        join Dimension_Tiempo t on v.id_tiempo = t.id_tiempo 
        group by p.nombre, t.anio


go


-- Aumento promedio de precios de cada proveedor anual. Para calcular este
--indicador se debe tomar como referencia el máximo precio por año menos
--el mínimo todo esto divido el mínimo precio del año. Teniendo en cuenta
--que los precios siempre van en aumento.

create view aumentoDePrecios
as
    select c.cuit_proveedor, ((max(c.precio) - min(c.precio))/min(c.precio)) Promedio_De_Precios from Hechos_Compras c join Dimension_Tiempo t on c.id_tiempo = t.id_tiempo GROUP by c.cuit_proveedor, t.anio

go


-- Los 3 productos con mayor cantidad de reposición por mes. 
create view top_Productos_reposicion
as
    (select top 3 c.cod_producto, sum(c.cantidad) Cantidad_de_Reposicion from Hechos_Compras c join Dimension_Tiempo t on c.id_tiempo = t.id_tiempo GROUP by c.cod_producto, t.anio, t.mes )



go
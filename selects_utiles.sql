-- INFO DE LAS VENTAS
select VENTA_CODIGO, VENTA_FECHA, VENTA_TOTAL, VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_DESCUENTO_CONCEPTO, VENTA_DESCUENTO_IMPORTE, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO, VENTA_PRODUCTO_CANTIDAD, VENTA_PRODUCTO_PRECIO
from gd_esquema.Maestra venta where VENTA_CODIGO is not null 
group by VENTA_CODIGO, VENTA_FECHA, VENTA_TOTAL, VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_DESCUENTO_CONCEPTO, VENTA_DESCUENTO_IMPORTE, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO, VENTA_PRODUCTO_CANTIDAD, VENTA_PRODUCTO_PRECIO
order by VENTA_FECHA desc

select VENTA_CODIGO, VENTA_FECHA, VENTA_TOTAL, VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_DESCUENTO_CONCEPTO, VENTA_DESCUENTO_IMPORTE, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO, VENTA_PRODUCTO_CANTIDAD, VENTA_PRODUCTO_PRECIO
from gd_esquema.Maestra venta where VENTA_CODIGO = 127882
group by VENTA_CODIGO, VENTA_FECHA, VENTA_TOTAL, VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_DESCUENTO_CONCEPTO, VENTA_DESCUENTO_IMPORTE, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO, VENTA_PRODUCTO_CANTIDAD, VENTA_PRODUCTO_PRECIO
order by VENTA_FECHA desc

select VENTA_CODIGO, 
    sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0)) as VENTA_PRODUCTO_TOTAL
from gd_esquema.Maestra 
group by VENTA_CODIGO



select distinct VENTA_DESCUENTO_CONCEPTO from gd_esquema.Maestra 

-- Los descuentos por medio de pago en todas las ventas
select VENTA_CODIGO, 
sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0)) as total_productos,
VENTA_MEDIO_PAGO,
(select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where venta.VENTA_CODIGO = VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) as descuento_por_medio_pago,
100 * 
(select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where venta.VENTA_CODIGO = VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) 
/ sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0))  as porcentaje_descuento_por_medio_de_pago
from gd_esquema.Maestra venta 
where VENTA_CODIGO = 121416
group by VENTA_CODIGO, VENTA_MEDIO_PAGO
order by VENTA_MEDIO_PAGO, porcentaje_descuento_por_medio_de_pago


select VENTA_CODIGO, sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0)) as venta_productos,
(select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where VENTA_CODIGO = m1.VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) as venta_desc_medio_pago, -- De la ultima venta con ese medio de pago...
sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0)) -- El total de los productos dividido por...
/ (select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where VENTA_CODIGO = m1.VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) 
--La suma de los descuentos en esa venta que son por el medio de pago
from gd_esquema.Maestra m1
where 'Efectivo' = VENTA_MEDIO_PAGO and VENTA_CODIGO = 121416
group by VENTA_CODIGO


-- Los descuentos por medio de pago en efectivo orfenados de menor a mayor
select VENTA_CODIGO, 
sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0)) as total_productos,
VENTA_MEDIO_PAGO,
(select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where venta.VENTA_CODIGO = VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) as descuento_por_medio_pago,
100 * 
(select sum(VENTA_DESCUENTO_IMPORTE) from gd_esquema.Maestra where venta.VENTA_CODIGO = VENTA_CODIGO and VENTA_DESCUENTO_CONCEPTO = VENTA_MEDIO_PAGO) 
/ sum(isnull(VENTA_PRODUCTO_CANTIDAD,0) * isnull(VENTA_PRODUCTO_PRECIO,0))  as porcentaje_descuento_por_medio_de_pago
from gd_esquema.Maestra venta 
where VENTA_CODIGO is not null and VENTA_MEDIO_PAGO = 'Efectivo'
group by VENTA_CODIGO, VENTA_MEDIO_PAGO
order by porcentaje_descuento_por_medio_de_pago



-- INFO DE LAS VENTAS
select VENTA_CODIGO, VENTA_FECHA, VENTA_TOTAL, VENTA_MEDIO_PAGO, VENTA_MEDIO_PAGO_COSTO, VENTA_MEDIO_ENVIO, VENTA_ENVIO_PRECIO, VENTA_DESCUENTO_CONCEPTO, VENTA_DESCUENTO_IMPORTE, VENTA_CUPON_VALOR, VENTA_CUPON_TIPO, VENTA_PRODUCTO_CANTIDAD, VENTA_PRODUCTO_PRECIO
from gd_esquema.Maestra venta
order by VENTA_FECHA desc

select 
from nibble.Venta
join nibble.Medio_envio on nibble.Venta.medio_de_envio = nibble.Medio_envio.id_medio

select * from nibble.Medio_envio

select codigo_venta, 
    medio_de_pago, 
    desc_medio_de_pago,
    count(*)
from nibble.Venta 
where desc_medio_de_pago is not null
group by codigo_venta, desc_medio_de_pago, medio_de_pago
order by count(*) desc

select v.codigo_venta,
    count(*)
from nibble.Venta v
    join nibble.Descuento_Venta on v.codigo_venta = Descuento_Venta.codigo_venta
group by v.codigo_venta
order by count(*) desc

select canal_de_venta, 
    fecha_nac,
    medio_de_pago,  
    fecha,
    id_provincia, 
    medio_de_envio, 
    importe
from nibble.Venta 
    join nibble.Cliente on Venta.id_cliente = Cliente.id_cliente 
    join nibble.Codigo_postal on Cliente.codigo_postal = Codigo_postal.Codigo_postal
    join nibble.medio_de_pago_venta on Venta.medio_de_pago = medio_de_pago_venta.id_medio_pago
    join nibble.Descuento_Venta on Venta.codigo_venta = Descuento_Venta.codigo_venta

-- INFO DE LOS PRODUCTOS
select distinct PRODUCTO_CODIGO, PRODUCTO_NOMBRE, PRODUCTO_DESCRIPCION, PRODUCTO_MATERIAL, PRODUCTO_MARCA, PRODUCTO_CATEGORIA
from gd_esquema.Maestra
where PRODUCTO_CODIGO is not null
order by PRODUCTO_CODIGO

-- INFO DE LAS COMPRAS
select COMPRA_NUMERO, COMPRA_FECHA, PROVEEDOR_CUIT, COMPRA_TOTAL, COMPRA_MEDIO_PAGO, DESCUENTO_COMPRA_CODIGO, DESCUENTO_COMPRA_VALOR,
PRODUCTO_VARIANTE_CODIGO, COMPRA_PRODUCTO_CANTIDAD, COMPRA_PRODUCTO_PRECIO
from gd_esquema.Maestra
where COMPRA_NUMERO is not null
order by DESCUENTO_COMPRA_CODIGO desc

select * from gd_esquema.Maestra
order by COMPRA_NUMERO
where 

where COMPRA_NUMERO is not null
from gd_esquema.Maestra
where COMPRA_NUMERO is not null

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

-- cant de mails de cada cliente
select CLIENTE_DNI, CLIENTE_APELLIDO, count(distinct CLIENTE_MAIL) as cantidad_de_mails
from gd_esquema.Maestra
where (CLIENTE_DNI is not null) or (CLIENTE_APELLIDO is not null)
group by CLIENTE_DNI, CLIENTE_APELLIDO
order by cantidad_de_mails desc

-- cant de numeros de telefono de cada cliente
select CLIENTE_DNI, CLIENTE_APELLIDO, count(distinct CLIENTE_TELEFONO) as cantidad_telefonos
from gd_esquema.Maestra
where (CLIENTE_DNI is not null) or (CLIENTE_APELLIDO is not null)
group by CLIENTE_DNI, CLIENTE_APELLIDO
order by cantidad_telefonos desc

-- esquemas de la base de datos
use GD2C2022

select * from sys.schemas

select t.name, t.schema_id
from sys.tables t
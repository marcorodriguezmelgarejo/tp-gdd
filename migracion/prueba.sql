	drop table Provincia
    drop table Codigo_postal
    drop table Variante
    drop table Medio_envio
    drop table Cliente
    drop table Canal
    drop table Medio_de_pago_venta
    drop table Producto
    drop table proveedor
    drop table Cupon_descuento
    drop table Envio_X_codigo_postal
    drop table Medio_de_pago_compra
    drop table Compra
    drop table Producto_X_Variante
    drop table Descuento_compra
    drop table Compra_X_Producto
    drop table Venta
    drop table Descuento_venta
    drop table Cupon_descuento_X_venta
    drop table Venta_X_Product

use GD2015C1
drop database GD2C2022
CREATE database GD2C2022

resetear las tablas:
    drop table nibble.venta_X_producto
    drop table nibble.cupon_descuento_X_venta
    drop table nibble.descuento_venta
    drop table nibble.venta
    drop table nibble.compra_X_producto
    drop table nibble.descuento_compra
    drop table nibble.producto_X_variante
    drop table nibble.compra
    drop table nibble.medio_de_pago_compra
    drop table nibble.envio_X_codigo_postal
    drop table nibble.cupon_descuento
    drop table nibble.proveedor
    drop table nibble.producto
    drop table nibble.medio_de_pago_venta
    drop table nibble.canal
    drop table nibble.cliente
    drop table nibble.medio_envio
    drop table nibble.variante
    drop table nibble.codigo_postal
	drop table nibble.provincia

    
    exec nibble.migracion



drop PROC nibble.migracion_provincia
drop PROC nibble.migracion_codigo_postal
drop PROC nibble.migracion_variante
drop PROC nibble.migracion_medio_envio
drop PROC nibble.migracion_medio_de_pago_venta
drop PROC nibble.migracion_cliente
drop PROC nibble.migracion_canal
drop PROC nibble.migracion_producto
drop proc nibble.migracion_proveedor
drop proc nibble.migracion_cupon_descuento
drop PROC nibble.migracion_envio_X_codigo_postal
drop PROC nibble.migracion_producto_X_variante 
drop PROC nibble.migracion_medio_de_pago_compra
drop PROC nibble.migracion_compra
drop proc nibble.migracion_descuento_compra
drop proc nibble.migracion_descuento_venta
drop proc nibble.migracion_compra_X_producto
drop proc nibble.migracion_venta
drop proc nibble.migracion_cupon_decuento_X_venta
drop proc nibble.migracion_venta_X_producto


-- PROBAR DESPUES DEL SCRIPT

select * from nibble.provincia
select * from nibble.codigo_postal
select * from nibble.variante
select * from nibble.medio_envio
select * from nibble.cliente
select * from nibble.canal
select * from nibble.medio_de_pago_venta
select * from nibble.producto
select * from nibble.proveedor
select * from nibble.cupon_descuento
select * from nibble.envio_X_codigo_postal
select * from nibble.medio_de_pago_compra
select * from nibble.compra
select * from nibble.producto_X_variante
select * from nibble.descuento_compra
select * from nibble.compra_X_producto
select * from nibble.venta
select * from nibble.descuento_venta
select * from nibble.cupon_descuento_X_venta
select * from nibble.venta_X_producto

	Provincia
    Codigo_postal
    Variante
    Medio_envio
    Cliente
    Canal
    Medio_de_pago_venta
    Producto
    proveedor
    Cupon_descuento
    Envio_X_codigo_postal
    Medio_de_pago_compra
    Compra
    Producto_X_Variante
    Descuento_compra
    Compra_X_Producto
    Venta
    Descuento_venta
    Cupon_descuento_X_venta
    Venta_X_Product


use GD2015C1
drop database GD2C2022
CREATE database GD2C2022

resetear las tablas:
    delete from nibble.venta_X_producto
    delete from nibble.cupon_descuento_X_venta
    delete from nibble.descuento_venta
    delete from nibble.venta
    delete from nibble.compra_X_producto
    delete from nibble.descuento_compra
    delete from nibble.producto_X_variante
    delete from nibble.compra
    delete from nibble.medio_de_pago_compra
    delete from nibble.envio_X_codigo_postal
    delete from nibble.cupon_descuento
    delete from nibble.proveedor
    delete from nibble.producto
    delete from nibble.medio_de_pago_venta
    delete from nibble.canal
    delete from nibble.cliente
    delete from nibble.medio_envio
    delete from nibble.variante
    delete from nibble.codigo_postal
	delete from nibble.provincia
    exec nibble.migracion
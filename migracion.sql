CREATE PROC nibble.migracion
as
    exec nibble.migracion_provincia
    exec nibble.migracion_codigo_postal
    exec nibble.migracion_variante
    exec nibble.migracion_medio_envio
    exec nibble.migracion_cliente
    exec nibble.migracion_canal
    exec nibble.migracion_medio_de_pago_venta
    exec nibble.migracion_producto
    exec nibble.migracion_proveedor
    exec nibble.migracion_cupon_descuento
    exec nibble.migracion_envio_X_codigo_postal
    exec nibble.migracion_medio_de_pago_compra
    exec nibble.migracion_compra
    exec nibble.migracion_producto_X_variante
    exec nibble.migracion_descuento_compra
    exec nibble.migracion_compra_X_producto
    exec nibble.migracion_venta
    exec nibble.migracion_descuento_venta
    exec nibble.migracion_venta_X_producto
    -- exec nibble.migracion_cupon_decuento_X_venta
go

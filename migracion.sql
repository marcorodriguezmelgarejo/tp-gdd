CREATE PROC migracion
as
    -- PRIMERO CORRER FUNCIONES AUXILIARES.SQL
    exec migracion_provincia
    exec migracion_codigo_postal
    exec migracion_variante
    exec migracion_medio_envio
    exec migracion_cliente
    exec migracion_canal
    exec migracion_medio_de_pago_venta
    exec migracion_producto
    exec migracion_proveedor
    exec migracion_cupon_descuento
    exec migracion_envio_X_codigo_postal
    exec migracion_medio_de_pago_compra
    exec migracion_compra
    exec migracion_producto_X_variante
    exec migracion_descuento_compra
    exec migracion_compra_X_producto
    exec migracion_venta
    exec migracion_descuento_venta
    exec migracion_cupon_decuento_X_venta
    exec migracion_venta_X_producto
    -- exec migracion_cupon_decuento_X_venta
go

create proc nibble.
migracion_BI
as 
    exec nibble.migracion_dim_rango_etario
    exec nibble.migracion_dim_producto
    exec nibble.migracion_dim_provincia
    exec nibble.migracion_dim_medio_de_pago_venta
    exec nibble.migracion_dim_tiempo
    exec nibble.migracion_dim_tipo_descuento
    exec nibble.migracion_dim_canal
    exec nibble.migracion_medio_envio
    exec nibble.migracion_dim_proveedor
    -- tabla de hechos
go
-- Borrar todo lo de BI

drop table nibble.Hechos_Ventas_Compras
drop table nibble.Dim_tiempo 
drop table nibble.Dim_provincia
drop table nibble.Dim_rango_etario
drop table nibble.Dim_canal
drop table nibble.Dim_producto
drop table nibble.Dim_proveedor
drop table nibble.Dim_Medio_de_envio
drop table nibble.Dim_tipo_descuento 
drop table nibble.Dim_medio_de_pago_venta 
go

drop proc nibble.migracion_BI
drop proc nibble.migracion_dim_provincia
drop proc nibble.migracion_dim_medio_de_pago_venta
drop proc nibble.migracion_dim_rango_etario
drop proc nibble.migracion_dim_tiempo
drop proc nibble.migracion_dim_tipo_descuento
drop proc nibble.migracion_dim_canal
drop proc nibble.migracion_dim_producto
drop proc nibble.migracion_medio_envio
drop proc nibble.migracion_dim_proveedor
go
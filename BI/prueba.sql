-- Borrar todo lo de BI

delete from nibble.Hechos_Ventas
delete from nibble.Hechos_Compras
delete from nibble.Dim_tiempo 
delete from nibble.Dim_provincia
delete from nibble.Dim_rango_etario
delete from nibble.Dim_canal
delete from nibble.Dim_producto
delete from nibble.Dim_proveedor
delete from nibble.Dim_Medio_de_envio
delete from nibble.Dim_tipo_descuento 
delete from nibble.Dim_medio_de_pago_venta 
go

drop proc nibble.migracion_BI
drop proc nibble.migracion_dim_provincia
drop proc nibble.migracion_dim_medio_de_pago_venta
drop proc nibble.migracion_dim_rango_etario
drop proc nibble.migracion_dim_tiempo
drop proc nibble.migracion_dim_tipo_descuento
drop proc nibble.migracion_dim_canal
drop proc nibble.migracion_dim_producto
drop proc nibble.migracion_dim_medio_envio
drop proc nibble.migracion_dim_proveedor
drop proc nibble.migracion_hechos_compras
drop proc nibble.migracion_hechos_ventas
drop proc nibble.migracion_hechos_ventas_descuentos
drop proc nibble.migracion_hechos_ventas_costo_medio_de_pago
drop proc nibble.migracion_hechos_ventas_costo_canal
drop proc nibble.migracion_hechos_ventas_costo_envio
go
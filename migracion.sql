CREATE PROC migracion
as
    exec migracion_provincia
    exec migracion_codigo_postal
    exec migracion_variante
    exec migracion_medio_envio
go

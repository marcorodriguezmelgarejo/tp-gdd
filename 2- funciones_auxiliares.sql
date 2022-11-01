create function nibble.maximo_decimal_18_2 (@a decimal(18,2), @b decimal(18,2))
returns decimal(18,2)
as 
begin
    if @a > @b
        return @a
    return @b
end
go

create function nibble.stockDeProducto (@producto nvarchar(50))
returns decimal(20,0)
as 
begin
    return (select top 1 stock from nibble.Producto_X_Variante where cod_producto_X_variante = @producto)
end
go

create function nibble.codigoPostalDeCliente(@cliente decimal(18,0))
returns decimal(18,0)
as
begin
    return (select top 1 codigo_postal from nibble.Cliente where id_cliente = @cliente)
end
go

create function nibble.medioDeEnvioEnCodigoPostal(@medio_de_envio decimal(18,0), @codigo_postal decimal(18,0))
returns bit
as
begin
    if (@medio_de_envio in (select id_medio from nibble.Envio_X_codigo_postal where @codigo_postal = nibble.codigoPostalDeCliente(id_cliente)))
    begin 
        return 1
    end
    return 0
end
go
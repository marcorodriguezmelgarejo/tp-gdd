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
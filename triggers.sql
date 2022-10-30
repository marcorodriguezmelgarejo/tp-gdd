create trigger precio_por_producto_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select cantidad, precio_unitario, compra, producto, total_por_producto from inserted

    declare @cantidad decimal(18,0)
    declare @precio_unitario decimal(18,2)
	declare @compra decimal(19,0) not null
	declare @producto nvarchar(50)
	declare @total_por_producto decimal(18,2)

    open insertados
    fetch from insertados into @cantidad, @precio_unitario,	@compra, @producto, @total_por_producto 
    while @@fetch_status = 0
    BEGIN
        update nibble.Compra_X_Producto
        set total_por_producto = @cantidad * @precio_unitario
        where compra = @compra and producto = @producto
        fetch from insertados into @cantidad, @precio_unitario,	@compra, @producto, @total_por_producto 
    END

    close insertados
    deallocate insertados
END
go


create trigger actualizar_stock_en_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select cantidad, producto from inserted

    declare @cantidad decimal(18,0)
	declare @producto nvarchar(50)

    open insertados
    fetch from insertados into @cantidad, @producto
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set stock = stock + @cantidad
        where cod_producto_X_variante = @producto
        fetch from insertados into @cantidad, @producto
    END

    close insertados
    deallocate insertados
END
go

create trigger actualizar_stock_en_venta on nibble.Venta_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select producto_variante, cantidad from inserted

    declare @producto_variante nvarchar(50)
    declare @cantidad decimal(18,0)

    open insertados
    fetch from insertados into @producto_variante, @cantidad
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set stock = stock - @cantidad
        where cod_producto_X_variante = @producto_variante
        fetch from insertados into @producto_variante, @cantidad
    END

    close insertados
    deallocate insertados
END
go

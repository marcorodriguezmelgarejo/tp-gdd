-- TRIGGERS PARA LA COMPRA
create trigger calcular_total_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select cantidad, precio_unitario, compra, producto, total_por_producto from inserted

    declare @cantidad decimal(18,0)
    declare @precio_unitario decimal(18,2)
	declare @compra decimal(19,0)
	declare @producto nvarchar(50)
	declare @total_por_producto decimal(18,2)

    open insertados
    fetch from insertados into @cantidad, @precio_unitario,	@compra, @producto, @total_por_producto 
    while @@fetch_status = 0
    BEGIN
        -- El total por producto se calcula
        update nibble.Compra_X_Producto
        set total_por_producto = @cantidad * @precio_unitario
        where compra = @compra and producto = @producto
        -- Se actualiza el total de la compra sumandole el total del producto calculado
        update nibble.Compra
        set total = total + @cantidad * @precio_unitario
        where numero_compra = @compra

        fetch from insertados into @cantidad, @precio_unitario,	@compra, @producto, @total_por_producto 
    END

    close insertados
    deallocate insertados
END
go


create trigger aplicar_descuento_compra on nibble.Descuento_compra
after insert
as
BEGIN       

    declare insertados cursor for select compra, valor from inserted

    declare @compra decimal(19,0)
    declare @valor decimal(18,2)

    open insertados
    fetch from insertados into @compra, @valor
    while @@fetch_status = 0
    BEGIN
        -- Se actualiza el total de la compra restandole el valor del descuento. Si el valor del descuento supera el monto de la compra, dejo el total en 0.
        update nibble.Compra
        set total = total - @valor
        where numero_compra = @compra

        fetch from insertados into @compra, @valor
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

create trigger actualizar_precio_producto_en_compra on nibble.Compra_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select precio_unitario, producto from inserted

	declare @producto nvarchar(50)
    declare @precio_unitario decimal(18,2)

    open insertados
    fetch from insertados into @precio_unitario, @producto
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set precio_compra = @precio_unitario
        where cod_producto_X_variante = @producto
        fetch from insertados into @precio_unitario, @producto
    END

    close insertados
    deallocate insertados
END
go

-- TRIGGERS PARA LA VENTA

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


create trigger actualizar_precio_producto_en_venta on nibble.Venta_X_Producto
after insert
as
BEGIN       

    declare insertados cursor for select precio_unitario, producto_variante from inserted

	declare @producto_variante nvarchar(50)
    declare @precio_unitario decimal(18,2)

    open insertados
    fetch from insertados into @precio_unitario, @producto_variante
    while @@fetch_status = 0
    BEGIN
        update nibble.Producto_X_Variante
        set precio_venta = @precio_unitario
        where cod_producto_X_variante = @producto_variante
        fetch from insertados into @precio_unitario, @producto_variante
    END

    close insertados
    deallocate insertados
END
go

-- TERMINAR
create trigger calcular_total_venta on nibble.Venta_X_Producto
after insert
as
BEGIN       
    declare insertados cursor for select codigo_venta, producto_variante, cantidad, precio_unitario, total_por_producto from inserted

    declare @cantidad decimal(18,0)
    declare @precio_unitario decimal(18,2)
    declare @codigo_venta decimal(19,0)
    declare @producto_variante nvarchar(50)
    declare @total_por_producto decimal(18,2)

    declare @desc_medio_de_pago decimal(18,2)

    open insertados
    fetch from insertados into @codigo_venta, @producto_variante, @cantidad, @precio_unitario, @total_por_producto
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN
            set @desc_medio_de_pago = (select desc_medio_de_pago from nibble.Venta where codigo_venta = @codigo_venta)

            update nibble.Venta_X_Producto
            set total_por_producto = @cantidad * @precio_unitario
            where codigo_venta = @codigo_venta and producto_variante = @producto_variante
            
            update nibble.Venta
            set total = total + (@cantidad * @precio_unitario) * (1 - @desc_medio_de_pago) -- * (1 - @desc_medio_de_pago - descuentoCuponesPorcentuales(@codigo_venta)) (no lo hacemos porque consideramos que los descuentos porcentuales se aplican después de cargar los productos)
            where codigo_venta = @codigo_venta

            -- Envio gratis. Definimos 1000 como valor arbitrario.
            if (select sum(total_por_producto) from nibble.Venta_X_Producto where codigo_venta = @codigo_venta) > 1000
            BEGIN
                update nibble.Venta
                set costo_envio = 0
                where codigo_venta = @codigo_venta
            END
        END

        fetch from insertados into @codigo_venta, @producto_variante, @cantidad, @precio_unitario, @total_por_producto
    END

    close insertados
    deallocate insertados
END
go

-- TERMINAR
create trigger aplicar_descuento_cupon_venta on nibble.Cupon_descuento_X_venta
after insert
as
BEGIN       

    declare insertados cursor for select codigo_venta, codigo from inserted

    declare @codigo_venta decimal(19,0)
    declare @codigo_cupon nvarchar(255)
    declare @importe decimal(18,2)

    open insertados
    fetch from insertados into @codigo_venta, @codigo_cupon
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN
            if (select tipo from nibble.Cupon_descuento where codigo = @codigo_cupon) = 'Tipo Descuento Porcentaje'
            BEGIN
                set @importe = (select valor from nibble.Cupon_descuento where codigo = @codigo_cupon) * (select total from nibble.Venta where codigo_venta = @codigo_venta)
                -- si insertaramos mas productos en la venta despues de aplicarle el cupon, deberiamos volver a calcular este valor 
            END
            else -- monto fijo
            BEGIN
                set @importe = (select valor from nibble.Cupon_descuento where codigo = @codigo_cupon)
            END

            update nibble.Cupon_descuento_X_venta
            set importe = @importe
            where codigo_venta = @codigo_venta and codigo = @codigo_cupon

            update nibble.Venta
            set total = total - @importe
            where codigo_venta = @codigo_venta

        END
        fetch from insertados into @codigo_venta, @codigo_cupon
    END

    close insertados
    deallocate insertados
END
go

create trigger aplicar_descuento_especial_venta on nibble.Descuento_venta
after insert
as
BEGIN       

    declare insertados cursor for select codigo_venta, importe from inserted

    declare @codigo_venta decimal(19,0)
    declare @importe decimal(18,2)

    open insertados
    fetch from insertados into @codigo_venta, @importe
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN
        update nibble.Venta
        set total = nibble.maximo_decimal_18_2(total - @importe, 0)
        where codigo_venta = @codigo_venta
        END
        fetch from insertados into @codigo_venta, @importe
    END

    close insertados
    deallocate insertados
END
go

create trigger desnormalizar_venta on nibble.Venta 
after insert
as
BEGIN       

    declare insertados cursor for select codigo_venta, medio_de_envio, medio_de_pago, id_cliente from inserted

    declare @codigo_venta decimal(19,0)
    declare @medio_de_envio decimal(18,0)
    declare @medio_de_pago decimal(18,0)
    declare @id_cliente decimal(18,0)

    open insertados
    fetch from insertados into @codigo_venta, @medio_de_envio, @medio_de_pago, @id_cliente
    while @@fetch_status = 0
    BEGIN
        if (select canal_de_venta from nibble.Venta where codigo_venta = @codigo_venta) != (select id_canal from nibble.Canal where nombre = 'Web')
        BEGIN

            update nibble.Venta set
            costo_envio = (select costo_envio from Envio_X_codigo_postal where id_medio = @medio_de_envio and codigo_postal = nibble.codigoPostalDeCliente(@id_cliente)),
            costo_medio_de_pago = (select costo from Medio_de_pago_venta where id_medio_pago = @medio_de_pago),
            desc_medio_de_pago = (select descuento from Medio_de_pago_venta where id_medio_pago = @medio_de_pago)
            where codigo_venta = @codigo_venta

        END

        fetch from insertados into  @codigo_venta, @medio_de_envio, @medio_de_pago, @id_cliente
    END

    close insertados
    deallocate insertados
END

-- alter table nibble.Venta_X_Producto add
-- CONSTRAINT Stock_suficiente CHECK 
-- (cantidad <= nibble.stockDeProducto(producto_variante))

-- Prueba 

-- insert into nibble.Compra
-- select 1, GETDATE(), (select top 1 cuit from nibble.Proveedor order by cuit), 0, (select top 1 id_medio_pago from nibble.Medio_de_pago_venta)

-- select * from nibble.Compra
-- select * from nibble.Compra_X_Producto

-- delete from  nibble.Compra_X_Producto where compra = 1
-- delete from  nibble.Descuento_compra where compra = 1
-- delete from  nibble.Compra where numero_compra = 1


-- insert into nibble.Compra_X_Producto (cantidad, precio_unitario, compra, producto)
-- select 2, 10, 1, '015HPH1YB6HEBMWAG' -- primer prod por codigo

-- insert into nibble.Compra_X_Producto (cantidad, precio_unitario, compra, producto)
-- select 3, 11, 1, '0314LN3TPRKH3X6ER' -- segundo producto por codigo

-- select * from nibble.Compra
-- select * from nibble.Compra_X_Producto

-- -- total = 10 * 2 + 11 * 3 = 53

-- insert into nibble.Descuento_compra
-- select 1, 1, 10

-- -- total = 53 - 10 = 43

-- insert into nibble.Descuento_compra
-- select 2, 1, 100

-- -- total = 0

-- select * 
-- from nibble.Producto_X_Variante 
-- where cod_producto_X_variante = '015HPH1YB6HEBMWAG' or cod_producto_X_variante = '0314LN3TPRKH3X6ER'

Prueba
crear la Venta
ver que esten bien los campos
agregar productos
ver que esten bien los campos de ventaXprod
ver si se aplicaron el descuento por medio de pago
agregar mas y ver si se aplica el envio gratis
agregar el descuento especial 
ver si se aplico
agregar cupon monto fijo
ver si se aplicaron
agregar cupon porcentaje
ver si se aplicaron

Borrar:
delete from  nibble.Venta_X_Producto where codigo_venta = 1
delete from  nibble.Cupon_descuento_X_venta where codigo_venta = 1
delete from  nibble.Descuento_venta where codigo_venta = 1
delete from  nibble.Venta where codigo_venta = 1

Esta bien:
actualizar_stock_en_venta
actualizar precio venta en producto_X_variante
el trigger desnormalizar venta
el descuento por medio de pago
envio gratis
el descuento especial

Prueba:
insert into nibble.Venta 
(codigo_venta,  fecha,      id_cliente,                                                         canal_de_venta,     medio_de_envio,                                               medio_de_pago)
select 1,       GETDATE(),  (select top 1 id_cliente from nibble.Cliente order by id_cliente),  1,                  (select top 1 id_medio_pago from nibble.Medio_de_pago_venta), 2 -- (efectivo)

insert into nibble.Venta_X_Producto (cantidad, precio_unitario, codigo_venta, producto_variante)
select 106, 10, 1, '015HPH1YB6HEBMWAG' -- primer prod por codigo

insert into nibble.Venta_X_Producto (cantidad, precio_unitario, codigo_venta, producto_variante)
select 3, 11, 1, '0314LN3TPRKH3X6ER' -- segundo producto por codigo

insert into nibble.Descuento_venta
select 1, 100

-- 829 y pico

insert into nibble.Cupon_descuento_X_venta(codigo, codigo_venta)
select '01DUG6YG17WVQ1P2K', 1 -- cupon de 459 monto fijo

insert into nibble.Cupon_descuento_X_venta(codigo, codigo_venta)
select '0JCVWBMO0VIT1W9SN', 1 -- cupon por porcentaje

-- select * from nibble.Cupon_descuento

-- select * from nibble.Venta
-- select * from nibble.Venta_X_Producto



-- stock inicial: 124


-- delete from  nibble.Venta_X_Producto where codigo_venta = 2
-- delete from  nibble.Cupon_descuento_X_venta where codigo_venta = 2
-- delete from  nibble.Descuento_venta where codigo_venta = 2
-- delete from  nibble.Venta where codigo_venta = 2

-- insert into nibble.Venta 
-- (codigo_venta,  fecha,      id_cliente,                                                         canal_de_venta,     medio_de_envio,                                               medio_de_pago)
-- select 2,       GETDATE(),  (select top 1 id_cliente from nibble.Cliente order by id_cliente),  1,                  (select top 1 id_medio_pago from nibble.Medio_de_pago_venta), 2 -- (efectivo)


-- insert into nibble.Venta_X_Producto(codigo_venta, producto_variante, cantidad, precio_unitario)
-- select 2, '015HPH1YB6HEBMWAG', 4, 10

-- select * from nibble.Producto_X_variante where cod_producto_X_variante = '015HPH1YB6HEBMWAG'





-- -- total = 10 * 2 + 11 * 3 = 53

-- insert into nibble.Descuento_compra
-- select 1, 1, 10

-- -- total = 53 - 10 = 43

-- insert into nibble.Descuento_compra
-- select 2, 1, 100

-- -- total = 0

-- select * 
-- from nibble.Producto_X_Variante 
-- where cod_producto_X_variante = '015HPH1YB6HEBMWAG' or cod_producto_X_variante = '0314LN3TPRKH3X6ER'





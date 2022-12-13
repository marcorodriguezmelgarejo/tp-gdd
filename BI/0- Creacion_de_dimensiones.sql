-- creacion de dimensiones

create table nibble.Dim_tiempo (
    id_tiempo decimal(10) identity(1,1) primary key,
    anio decimal(4),
    mes decimal(2)
);

create table nibble.Dim_provincia (
    id_provincia decimal(3) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_rango_etario (
    id_rango_etario decimal(3) identity(1,1) primary key,
    nombre_rango nvarchar(255),
    limite_inferior_inclusive decimal(3),
    limite_superior_no_inclusive decimal(3)
);

create table nibble.Dim_canal (
    id_canal decimal(18,0) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_producto (
    id_producto nvarchar(50) primary key,
    nombre nvarchar(255),
    id_categoria decimal(18,0),
    nombre_categoria nvarchar(255)
);

create table nibble.Dim_proveedor (
    CUIT nvarchar(50) primary key,
    razon_social nvarchar(50)
);

create table nibble.Dim_Medio_de_envio (
    id_medio_de_envio decimal(18,0) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_tipo_descuento (
    id_tipo_descuento decimal(18) identity(1,1) primary key,
    nombre nvarchar(255)
);

create table nibble.Dim_medio_de_pago_venta (
    id_medio_de_pago_venta decimal(18) primary key,
    nombre nvarchar(255)
);


create table nibble.Hechos_Items_Ventas (
    id_provincia decimal(3),
    id_tiempo decimal(10),
    id_canal decimal(18,0),
    cod_producto nvarchar(50),
    id_medio_de_envio decimal(18,0),
    id_rango_etario decimal(3),
    id_medio_de_pago_venta decimal(18),
    cantidad_vendida decimal(18,0),
    monto_vendido decimal(18,2),
    constraint FK_Hechos_items_Ventas_Dim_provincia foreign key (id_provincia) references nibble.Dim_provincia(id_provincia),
    constraint FK_Hechos_items_Ventas_Dim_tiempo foreign key (id_tiempo) references nibble.Dim_tiempo(id_tiempo),
    constraint FK_Hechos_items_Ventas_Dim_canal foreign key (id_canal) references nibble.Dim_canal(id_canal),
    constraint FK_Hechos_items_Ventas_Dim_medio_de_envio foreign key (id_medio_de_envio) references nibble.Dim_Medio_de_envio(id_medio_de_envio),
    constraint FK_Hechos_items_Ventas_Dim_rango_etario foreign key (id_rango_etario) references nibble.Dim_rango_etario(id_rango_etario),
    constraint FK_Hechos_items_Ventas_Dim_medio_de_pago_venta foreign key (id_medio_de_pago_venta) references nibble.Dim_medio_de_pago_venta(id_medio_de_pago_venta),
    constraint FK_Hechos_items_Ventas_Dim_producto foreign key (cod_producto) references nibble.Dim_producto(id_producto),
    constraint PK_Hechos_items_Items_Ventas primary key (id_provincia, id_tiempo, id_canal, cod_producto, id_medio_de_envio, id_rango_etario, id_medio_de_pago_venta)
); 

create table nibble.Hechos_Ventas (
    id_provincia decimal(3),
    id_tiempo decimal(10),
    id_canal decimal(18,0),
    id_medio_de_envio decimal(18,0),
    id_medio_de_pago_venta decimal(18),
    id_tipo_descuento decimal(18),
    costo_medio_de_pago decimal(18,2),
    costo_canal decimal(18,2),
    descuento decimal(18,2),
    costo_envio decimal(18,2),
    constraint FK_Hechos_Ventas_Dim_provincia foreign key (id_provincia) references nibble.Dim_provincia(id_provincia),
    constraint FK_Hechos_Ventas_Dim_tiempo foreign key (id_tiempo) references nibble.Dim_tiempo(id_tiempo),
    constraint FK_Hechos_Ventas_Dim_canal foreign key (id_canal) references nibble.Dim_canal(id_canal),
    constraint FK_Hechos_Ventas_Dim_medio_de_envio foreign key (id_medio_de_envio) references nibble.Dim_Medio_de_envio(id_medio_de_envio),
    constraint FK_Hechos_Ventas_Dim_medio_de_pago_venta foreign key (id_medio_de_pago_venta) references nibble.Dim_medio_de_pago_venta(id_medio_de_pago_venta),
    constraint FK_Hechos_Ventas_Dim_tipo_descuento foreign key (id_tipo_descuento) references nibble.Dim_tipo_descuento(id_tipo_descuento),
    constraint PK_Hechos_Ventas primary key (id_provincia, id_tiempo, id_canal, id_medio_de_envio, id_medio_de_pago_venta, id_tipo_descuento)
); 

create table nibble.Hechos_Compras (
    id_provincia decimal(3),
    id_tiempo decimal(10),
    cod_producto nvarchar(50),
    cuit_proveedor nvarchar(50),
    cantidad_comprada decimal(18,0),
    monto_comprado decimal(18,2),
    precio_unitario_max decimal(18,2),
    precio_unitario_min decimal(18,2),
    constraint FK_Hechos_Compras_Dim_provincia foreign key (id_provincia) references nibble.Dim_provincia(id_provincia),
    constraint FK_Hechos_Compras_Dim_tiempo foreign key (id_tiempo) references nibble.Dim_tiempo(id_tiempo),
    constraint FK_Hechos_Compras_Dim_producto foreign key (cod_producto) references nibble.Dim_producto(id_producto),
    constraint FK_Hechos_Compras_Dim_proveedor foreign key (cuit_proveedor) references nibble.Dim_proveedor(CUIT),
    constraint PK_Hechos_Compras primary key (id_provincia, id_tiempo, cod_producto, cuit_proveedor)
); 


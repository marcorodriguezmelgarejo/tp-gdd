use GD2C2022




create table nibble.Material(
    id_material decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    descripcion nvarchar(50)
)


create table nibble.Categoria(
    id_categoria decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    descripcion nvarchar(255)
)

create table nibble.Marca(
    id_marca decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    descripcion nvarchar(255)
)

create table nibble.Provincia (
    id_provincia decimal(3) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255) not null,
    );

create table nibble.Codigo_postal (
    codigo_postal decimal(18,0) PRIMARY KEY,
    id_provincia decimal(3) not null,              
    FOREIGN KEY (id_provincia) REFERENCES nibble.Provincia(id_provincia)
    ); 

create table nibble.Medio_envio (
    id_medio decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
);

create table nibble.Envio_X_codigo_postal (
    id_medio decimal(18,0) not null,
    codigo_postal decimal(18,0) not null,
	costo_envio decimal(18,2) not null,
    FOREIGN KEY (id_medio) REFERENCES nibble.Medio_envio(id_medio),
    FOREIGN KEY (codigo_postal) REFERENCES nibble.Codigo_postal(codigo_postal),
    CONSTRAINT PK_Envio_X_codigo_postal PRIMARY KEY (id_medio, codigo_postal)
    );


create table nibble.Canal (
    id_canal decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
    costo decimal(18,2),
);

create table nibble.Cliente (
    id_cliente decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    direccion varchar(255),
    DNI decimal(18,0),
    nombre nvarchar(255),
    apellido nvarchar(255),
    telefono decimal(18,0),
    mail nvarchar(255),
    fecha_nac date,
    localidad nvarchar(255),
    codigo_postal decimal(18,0),
    FOREIGN KEY (codigo_postal) REFERENCES nibble.Codigo_postal(codigo_postal)
);

create table nibble.Medio_de_pago_venta(
    id_medio_pago decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
    descuento decimal(18,2),
    costo decimal(18,2),
    CONSTRAINT porcentaje_de_descuento_menor_a_1 CHECK (descuento >= 0 and descuento <= 1)
);

create table nibble.Medio_de_pago_compra(
    id_medio_pago_compra decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
);

/* VENTA */

create table nibble.Venta (
    codigo_venta decimal(19,0) PRIMARY KEY,
    fecha date,
    id_cliente decimal(18,0),
    canal_de_venta decimal(18,0),
    medio_de_envio decimal(18,0),
    costo_envio decimal(18,2),
    medio_de_pago decimal(18,0),
    total decimal(18,2) DEFAULT 0,
    desc_medio_de_pago decimal(18,2),
    costo_medio_de_pago decimal(18,2),
    FOREIGN KEY (medio_de_pago) REFERENCES nibble.Medio_de_pago_venta(id_medio_pago),
    FOREIGN KEY (medio_de_envio) REFERENCES nibble.Medio_envio(id_medio),
    FOREIGN KEY (canal_de_venta) REFERENCES nibble.Canal(id_canal),
    FOREIGN KEY (id_cliente) REFERENCES nibble.Cliente(id_cliente),
    CONSTRAINT Importe_total_venta_mayor_a_cero CHECK (total >= 0)
);



/* DESCUENTOS VENTA */

create table nibble.Cupon_descuento (
    codigo nvarchar(255) PRIMARY KEY,
    fecha_desde date,
    fecha_hasta date,
    valor decimal(18,2),
    tipo nvarchar(50),
    CONSTRAINT fecha_de_expiracion_antes_de_la_fecha_de_inicio CHECK (fecha_hasta >= fecha_desde),
    CONSTRAINT porcentaje_menor_a_1 CHECK (tipo = 'Tipo Descuento Monto Fijo' or valor <= 1)
);

create table nibble.Descuento_venta (
    id_descuento_venta decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    codigo_venta decimal(19,0),
    importe decimal(18,2)
    FOREIGN KEY (codigo_venta) REFERENCES nibble.Venta(codigo_venta)        
);

create table nibble.Cupon_descuento_X_venta (
    codigo nvarchar(255),
    codigo_venta decimal(19,0),
    importe decimal(18,2)
    FOREIGN KEY (codigo) REFERENCES nibble.Cupon_descuento(codigo),
    FOREIGN KEY (codigo_venta) REFERENCES nibble.Venta(codigo_venta),
    CONSTRAINT Pk_Cupon_descuento_X_venta PRIMARY KEY (codigo, codigo_venta)
);




/* PRODUCTOS */

create table nibble.Variante(
    descripcion_variante nvarchar(50),
    tipo_variante nvarchar(50),
    CONSTRAINT PK_Variante PRIMARY KEY (descripcion_variante, tipo_variante)
);

create table nibble.Producto(
    cod_producto nvarchar(50) PRIMARY KEY,
    descripcion nvarchar(50),
    nombre NVARCHAR(50),
    material decimal(18,0),
    marca decimal(18,0),
    categoria decimal(18,0),
    FOREIGN KEY (material) REFERENCES nibble.Material(id_material),
    FOREIGN KEY (marca) REFERENCES nibble.Marca(id_marca),
    FOREIGN KEY (categoria) REFERENCES nibble.Categoria(id_categoria)
);

create table nibble.Producto_X_Variante(
    cod_producto_X_variante nvarchar(50) PRIMARY KEY,
    cod_producto nvarchar(50) not null,
    descripcion_variante nvarchar(50), -- son nulleables estos dos campos porque puede haber productos sin variante
    tipo_variante nvarchar(50),
    precio_venta decimal(18,2),
    precio_compra decimal(18,2),
    stock decimal(20,0),
    FOREIGN KEY (cod_producto) REFERENCES nibble.Producto(cod_producto),
    FOREIGN KEY (descripcion_variante, tipo_variante) REFERENCES nibble.Variante(descripcion_variante, tipo_variante),
    CONSTRAINT Combinacion_unica_producto_y_variante UNIQUE (cod_producto, descripcion_variante, tipo_variante)
)

create table nibble.Venta_X_Producto (
    id_venta_x_producto decimal(20,0) IDENTITY(1,1) PRIMARY KEY,
    codigo_venta decimal(19,0),
    producto_variante nvarchar(50),
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
    total_por_producto decimal(18,2),
    FOREIGN KEY (codigo_venta) REFERENCES nibble.Venta(codigo_venta),
    FOREIGN KEY (producto_variante) REFERENCES nibble.Producto_X_Variante(cod_producto_X_variante),
);

/* COMPRAS */

create table nibble.proveedor(
    cuit nvarchar(50) PRIMARY KEY,
    razon_social nvarchar(50),
    domicilio nvarchar(50),
    localidad nvarchar(255),
    mail nvarchar(50),
    codigo_postal decimal(18),
    foreign key(codigo_postal) REFERENCES nibble.Codigo_postal(codigo_postal)
);

create table nibble.Compra(
    numero_compra decimal(19,0) PRIMARY KEY,
    fecha date,
    proveedor nvarchar(50),
    total decimal(18,2) DEFAULT 0,
    medio_de_pago decimal(18,0)
    foreign key(proveedor) REFERENCES nibble.proveedor(cuit),
    foreign key(medio_de_pago) REFERENCES nibble.Medio_de_pago_compra(id_medio_pago_compra),
    CONSTRAINT Importe_total_compra_mayor_a_cero CHECK (total >= 0)
)

create table nibble.Descuento_compra(
    codigo_descuento_compra decimal(19,0) PRIMARY KEY,
    compra decimal(19,0) not null,
    valor decimal(18,2)
    foreign key(compra) REFERENCES nibble.Compra(numero_compra),
    CONSTRAINT porcentaje_descuento_menor_a_1 CHECK (valor <= 1)
)

create table nibble.Compra_X_Producto(
    id_compra_x_producto decimal(20,0) IDENTITY(1,1) PRIMARY KEY,
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
	compra decimal(19,0) not null,
	producto nvarchar(50),
	total_por_producto decimal(18,2),
    foreign key(compra) REFERENCES nibble.Compra(numero_compra),
    foreign key(producto) REFERENCES nibble.Producto_X_Variante(cod_producto_X_variante),
);
GO
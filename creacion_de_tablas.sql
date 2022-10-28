use GD2C2022

create table Provincia (
    id_provincia decimal(3) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255) not null,
    );

create table Codigo_postal (
    codigo_postal decimal(18,0) PRIMARY KEY,
    id_provincia decimal(3) not null,              
    FOREIGN KEY (id_provincia) REFERENCES Provincia(id_provincia)
    ); 

create table Medio_envio (
    id_medio decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
);

create table Envio_X_codigo_postal (
    id_medio decimal(18,0) not null,
    codigo_postal decimal(18,0) not null,
	costo_envio decimal(18,2) not null,
    FOREIGN KEY (id_medio) REFERENCES Medio_envio(id_medio),
    FOREIGN KEY (codigo_postal) REFERENCES Codigo_postal(codigo_postal),
    CONSTRAINT PK_Envio_X_codigo_postal PRIMARY KEY (id_medio, codigo_postal)
    );


create table Canal (
    id_canal decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
    costo decimal(18,2),
);

create table Cliente (
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
    FOREIGN KEY (codigo_postal) REFERENCES Codigo_postal(codigo_postal)
);

create table Medio_de_pago_venta(
    id_medio_pago decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
    descuento decimal(18,2),
    costo decimal(18,2)
);

create table Medio_de_pago_compra(
    id_medio_pago_compra decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre nvarchar(255),
);

/* VENTA */

create table Venta (
    codigo_venta decimal(19,0) PRIMARY KEY,
    fecha date,
    id_cliente decimal(18,0),
    canal_de_venta decimal(18,0),
    medio_de_envio decimal(18,0),
    costo_envio decimal(18,2),
    medio_de_pago decimal(18,0),
    total decimal(18,2),
    desc_medio_de_pago decimal(18,2),
    FOREIGN KEY (medio_de_pago) REFERENCES Medio_de_pago(id_medio_pago),
    FOREIGN KEY (medio_de_envio) REFERENCES Medio_envio(id_medio),
    FOREIGN KEY (canal_de_venta) REFERENCES Canal(id_canal),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);



/* DESCUENTOS VENTA */

create table Cupon_descuento (
    codigo nvarchar(255) PRIMARY KEY,
    fecha_desde date,
    fecha_hasta date,
    valor decimal(18,2),
    tipo nvarchar(50),
);

create table Descuento_venta (
    id_descuento_venta decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    codigo_venta decimal(19,0),
    importe decimal(18,2)
    FOREIGN KEY (codigo_venta) REFERENCES Venta(codigo_venta)        
);

create table Cupon_descuento_X_venta (
    codigo nvarchar(255),
    codigo_venta decimal(19,0),
    importe decimal(18,2)
    FOREIGN KEY (codigo) REFERENCES Cupon_descuento(codigo),
    FOREIGN KEY (codigo_venta) REFERENCES Venta(codigo_venta),
    CONSTRAINT Pk_Cupon_descuento_X_venta PRIMARY KEY (codigo, codigo_venta)
);




/* PRODUCTOS */

create table Variante(
    descripcion_variante nvarchar(50),
    tipo_variante nvarchar(50),
    CONSTRAINT PK_Variante PRIMARY KEY (descripcion_variante, tipo_variante)
);

create table Producto(
    cod_producto nvarchar(50) PRIMARY KEY,
    descripcion nvarchar(50),
    nombre NVARCHAR(50),
    material NVARCHAR(50),
    marca nvarchar(255),
    categoria nvarchar(255),
);

create TABLE Producto_X_Variante(
    cod_producto_X_variante nvarchar(50) PRIMARY KEY,
    cod_producto nvarchar(50) not null,
    descripcion_variante nvarchar(50) not null,
    tipo_variante nvarchar(50) not null,
    precio_venta decimal(18,2),
    precio_compra decimal(18,2),
    stock decimal(20,0),
    FOREIGN KEY (cod_producto) REFERENCES Producto(cod_producto),
    FOREIGN KEY (descripcion_variante, tipo_variante) REFERENCES Variante(descripcion_variante, tipo_variante)
)

create table Venta_X_Producto (
    codigo_venta decimal(19,0),
    producto_variante nvarchar(50),
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
    total_por_producto decimal(18,2),
    FOREIGN KEY (codigo_venta) REFERENCES Venta(codigo_venta),
    FOREIGN KEY (producto_variante) REFERENCES Producto_X_Variante(cod_producto_X_variante),
    CONSTRAINT PK_Venta_X_Producto PRIMARY KEY (codigo_venta, producto_variante)
);

/* COMPRAS */

create table proveedor(
    cuit nvarchar(50) PRIMARY KEY,
    razon_social nvarchar(50),
    domicilio nvarchar(50),
    localidad nvarchar(255),
    mail nvarchar(50),
    codigo_postal decimal(18),
    foreign key(codigo_postal) references Codigo_postal(codigo_postal)
);

create table Compra(
    numero_compra decimal(19,0) PRIMARY KEY,
    fecha date,
    proveedor nvarchar(50),
    total decimal(18,2),
    medio_de_pago decimal(18,0)
    foreign key(proveedor) references proveedor(cuit),
    foreign key(medio_de_pago) references Medio_de_pago(id_medio_pago)
)

create table Descuento_compra(
    codigo_descuento_compra decimal(19,0) IDENTITY(1,1) PRIMARY KEY,
    compra decimal(19,0) not null,
    valor decimal(18,2)
    foreign key(compra) references Compra(numero_compra)
)

create table Compra_X_Producto(
    cantidad decimal(18,0),
    precio_unitario decimal(18,2),
	compra decimal(19,0) not null,
	producto nvarchar(50),
	total_por_producto decimal(18,2),
    foreign key(compra) references Compra(numero_compra),
    foreign key(producto) references Producto_X_Variante(cod_producto_X_variante),
    CONSTRAINT PK_Compra_X_Producto PRIMARY KEY (compra, producto),
);


-- pruebo commit











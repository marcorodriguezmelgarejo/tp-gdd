/*create index index_name
on table_name(column1, column2, .., columnN);*/


-- creamos estos dos porque las personas que usen el sistema van a querer buscar por nombre (el id es generado)
-- y no impacta tanto el rendimiento porque casi nunca se van a crear filas en estas tablas
create index indice_por_nombre
on nibble.Canal(nombre);

create index indice_por_nombre
on nibble.Medio_de_pago_compra(nombre);

create index indice_por_nombre
on nibble.Medio_de_pago_venta(nombre);

create index indice_por_nombre
on nibble.Provincia(nombre);   

create index indice_por_nombre
on nibble.medio_envio(nombre);   

-- medio dudoso xq capaz crean muchos productos al ser un negocio de ropa
-- pero la gente probablemente quiera buscar por nombre al comprar asi que lo ponemos
create index indice_por_nombre
on nibble.Producto(nombre);

-- creamos este porque los clientes van a saber su DNI y probablemente no sepan su codigo de cliente
create index indice_por_DNI
on nibble.Cliente(DNI);
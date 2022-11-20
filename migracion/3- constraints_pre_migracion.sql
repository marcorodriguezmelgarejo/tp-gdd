alter table nibble.Venta add
CONSTRAINT medio_de_envio_en_ese_codigo_postal CHECK 
(nibble.medioDeEnvioEnCodigoPostal(medio_de_envio, nibble.codigoPostalDeCliente(id_cliente)) = 1)
GO
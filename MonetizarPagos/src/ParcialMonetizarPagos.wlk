// -----------------------------------------------------------
// CONTENIDOS
// -----------------------------------------------------------

class Contenido {
	const property titulo
	var property vistas = 0
	var property ofensivo = false
	var property monetizacion

method monetizacion(nuevaMonetizacion){
	if(!nuevaMonetizacion.puedeAplicarseA(self))
	throw new DomainException(message="El contenido no soporta la forma de monetizacion")

	monetizacion = nuevaMonetizacion
}
override method initialize(){
	if(!monetizacion.puedeAplicarseA(self))
		throw new DomainException(message="El contenido no soporta la forma de monetizacion")
}
	method recaudacion() = monetizacion.recaudacionDe(self)
	method puedeVenderse() = self.esPopular()

	method esPopular()
	method recaudacionMaximaParaPublicidad()
	method puedeAlquilarse()
}

class Video inherits Contenido {
	override method esPopular() = vistas > 1000
	override method recaudacionMaximaParaPublicidad() = 10000

	override method puedeAlquilarse() = true
}

const tagsDeModa = ["objetos", "pdp", "serPeladoHoy"]

class Imagen inherits Contenido {
	const property tags = []

	override method esPopular() = tagsDeModa.all{tag=>tags.contains(tag)}
	override method recaudacionMaximaParaPublicidad() = 5000

	override method puedeAlquilarse() = false
}

// -----------------------------------------------------------
// MONETIZACIONES
// -----------------------------------------------------------

object publicidad {
	method recaudacionDe(contenido) = (
		0.05 * contenido.vistas() +
		if(contenido.esPopular()) 2000 else 0
		).min(contenido.recaudacionMaximaParaPublicidad())

	method puedeAplicarseA(contenido) = !contenido.esOfensivo()
}

class Donacion {
	var property donaciones = 0
	method recaudacionDe(contenido) = donaciones

	method puedeAplicarseA(contenido) = true
}

class Descarga {
	const property precio
	method recaudacionDe(contenido) = contenido.vistas() * precio

	method puedeAplicarseA(contenido) = contenido.puedeVenderse()
}

class Alquiler inherits Descarga{
	override method precio() = 1.max(super())
	override method puedeAplicarseA(contenido) = super(contenido) && contenido.puedeAlquilarse()
}

// -----------------------------------------------------------
// USUARIOS
// -----------------------------------------------------------

object usuarios{
	const todosLosUsuarios = []

	method emailsDeUsuariosRicos() = todosLosUsuarios
		.filter{usuario=>usuario.verificado()}
		.sortedBy{uno, otro => uno.saldoTotal() > otro.saldoTotal()}
		.take(100)
		.map{usuario => usuario.email()}

	method cantidadDeSuperUsuarios() = todosLosUsuarios.count{usuario => usuario.esSuperUsuario()}
}

class Usuario{
	const property nombre
	const property email
	var property verificado = false
	const contenidos = []

	method saldoTotal() = contenidos.sum{contenido=>contenido.recaudacion()}
	method esSuperUsuario() = contenidos.count{contenido=>contenido.esPopular()} >= 10

	method publicar(contenido){
		contenidos.add(contenido)
	}
}

/*
 La plataforma permite subir distintos tipos de contenidos con el fin de monetizarlos, de los cuales conocemos el título y la cantidad de vistas 
 que tuvieron. Además, cada pieza de contenido podría estar marcada como “contenido ofensivo” por su autor (o debido al pedido de otros usuarios). 
 Ahora mismo, los tipos de contenido disponibles son videos e imágenes (de las cuales también conocemos los tags con los que el autor las etiquetó) 
 pero en el futuro podrían aparecer más.

Los usuarios de la aplicación ingresan su nombre y email los cuales, pasados cierto tiempo, son verificados (hasta que eso ocurra, se los 
considera “sin verificar”).

Al subir un contenido, los usuarios eligen para el mismo una forma de monetización, la cual determina la forma en que el contenido se cotiza. 
El usuario puede cambiar en cualquier momento la forma de monetizar cada uno de sus contenidos, pero sólo puede aplicar una a cada uno. 
Cambiar la forma de monetizar hace que se pierda todo el dinero ganado por ese contenido en la forma anterior.

Las estrategias de monetización posibles son:

Publicidad: El contenido se muestra al lado de un aviso publicitario. El usuario cobra 5 centavos por cada vista que haya tenido su contenido. 
Además los contenidos populares cobran un plus de $2000.00. Consideramos que un video es popular cuando tiene más de 10000 vistas, mientras que una 
imagen es popular si está marcada con todos los tags de moda (una lista de tags arbitrarios que actualizamos a mano y puede cambiar en cualquier 
momento).
Ninguna publicación puede recaudar con publicidades más de cierto máximo que depende del tipo: $10000.00 para los videos y $4000.00 para las 
imágenes (incluyendo el plus).
Sólo las publicaciones no-ofensivas pueden monetizarse por publicidad pero si una publicidad es marcada como ofensiva luego de elegir esta 
monetización puede conservarla.


Donaciones: El contenido ofrece la posibilidad de hacer una donación al autor. El monto de cada donación depende de cada donador y puede 
acumularse cualquier cantidad. Todos los contenidos pueden ser monetizados por donaciones.


Venta de Descarga: El contenido puede ser descargado luego de que el comprador pague un precio fijo, elegido por el vendedor. El valor mínimo 
de venta es de $5.00 y se cobra por cada vista. Sólo los contenidos populares pueden acceder a esta forma de monetización.


Se pide:

1- Calcular el total recaudado por un contenido


2- Hacer que el sistema permita realizar las siguientes consultas:


a- Saldo total de un usuario, que es la suma total de lo recaudado por todos sus contenidos.


b- Email de los 100 usuarios verificados con mayor saldo total.


c- Cantidad de super-usuarios en el sistema (usuarios que tienen al menos 10 contenidos populares publicados).


3- Permitir que un usuario publique un nuevo contenido, asociándolo a una forma de monetización.


4- Aparece un nuevo tipo de estrategia de monetización: El Alquiler. Esta estrategia es muy similar a la venta de descargas, pero los archivos se 
autodestruyen después de un tiempo. Los alquileres tienen un precio mínimo de $1.00 y, además de tener todas las restricciones de las ventas, 
los alquileres sólo pueden aplicarse a videos.


5- Responder sin implementar:


a- ¿Cuáles de los siguientes requerimientos te parece que sería el más fácil y cuál el más difícil de implementar en la solución que modelaste? 
Responder relacionando cada caso con conceptos del paradigma.
i- Agregar un nuevo tipo de contenido.
ii- Permitir cambiar el tipo de un contenido (e.j.: convertir un video a imagen).
iii- Agregar un nuevo estado “verificación fallida” a los usuarios, que no les permita cargar ningún nuevo contenido.


b- ¿En qué parte de tu solución se está aprovechando más el uso de polimorfismo? ¿Porqué?
 
 */


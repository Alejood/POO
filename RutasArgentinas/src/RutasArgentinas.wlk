/////////// RUEDAS

class Rueda{
	var desgaste = 0
	method aumentar(valor) {
		desgaste += valor
		if(desgaste > 100) throw new DomainException(message = "Hay que cambiar la rueda!")
	}
}

/////////// VEHICULOS

class Vehiculo{
	const desgasteRuedas = []
	
	method velocidadBase()
	method velocidadVehiculo(ruta) = self.velocidadBase() - ruta.resistenciaViento()
	method velocidadFinal(ruta) = self.velocidadVehiculo(ruta).min(ruta.velocidadMaxima())
	method tiempoQueTardaEnRecorrer(ruta) = ruta.kilometros() / self.velocidadFinal(ruta)
	
	method tiempoCamino(camino) = camino.cuantoTarda(self)
	
	method recorrer(ruta) {
		ruta.desgastar(self)
	}
	method desgastarRuedas(valor) {
		desgasteRuedas.forEach{rueda => rueda.aumentar(valor)}
	}
}

class Particular inherits Vehiculo{
	var velocidad
	
	override method velocidadBase() = velocidad
}

class DeCarga inherits Vehiculo{
	var carga
	
	override method velocidadBase() = if (carga < 40) 80 else 60
	override method desgastarRuedas(valor) {
		super(valor*2)
	}
}

class DeTransporte inherits Vehiculo{
	var pasajeros
	
	override method velocidadBase() = 120 - pasajeros
}

/////////// RUTAS

class Ruta{
	var property resistenciaViento
	var property mmDeLluvia
	var property kilometros
	var property velocidadMaxima
	var tipo = tierra
	
	method desgaste(auto) = tipo.desgaste(auto, self)
	method desgastar(auto) {
		auto.desgastarRuedas(self.desgaste(auto))
	} 
	
	method velocidadMaxima() = tipo.velocidadMaxima(self)
	
	method mejorar() = tipo.mejorarse(self)
	
	method aumentarVelocidadMaximaAsfalto() {
		velocidadMaxima += 5
	}
	
	method cambiarTipoDeRuta(nuevoTipo){
		tipo = nuevoTipo
	}
}

object tierra{ 
	method velocidadMaxima(ruta) = (60 - ruta.mmDeLluvia()).max(10)
	method desgaste(auto, ruta) = auto.velocidadFinal(ruta) / 10
	method mejorarse(ruta) {
		ruta.cambiarTipoDeRuta(ripio)
	}
}

object ripio{
	method velocidadMaxima(ruta) = 80
	method desgaste(auto, ruta) = auto.velocidadFinal(ruta) / 10
	method mejorarse(ruta) {
		ruta.cambiarTipoDeRuta(asfalto)
	}
}

object asfalto{
	var velocidadMaxima
	
	method velocidadMaxima(ruta) = velocidadMaxima
	method desgaste(auto, ruta) = auto.tiempoQueTardaEnRecorrer(ruta)
	method mejorar(ruta) {
		ruta.aumentarVelocidadMaximaAsfalto()
	}
}

/////////// CAMINOS

class Camino{
	const rutas = []
	
	method cuantoTarda(vehiculo) = rutas.sum{ruta => vehiculo.tiempoQueTardaEnRecorrer(ruta)}
	method recorrerCamino(vehiculo) = rutas.forEach{ruta => vehiculo.recorrer(ruta)}
}
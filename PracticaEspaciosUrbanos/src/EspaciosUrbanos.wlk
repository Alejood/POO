//////////////// ESPACIOS

class EspacioUrbano{
	var property valuacion = 0
	var property metrosCuadrados
	var property nombre
	var property vallado
	const property trabajosRealizados = []
	
	method esGrande() = metrosCuadrados >= 50 && self.cumpleCondicionesEsGrande()
	
	method cumpleCondicionesEsGrande()
	
	method tieneVallado() = vallado
	
	method esEspacioVerde() = false
	
	method esLimpiable() = false
	
	method aumentarValuacion(cantidad) {
		valuacion += cantidad
	}
	
	method agregarTrabajo(trabajo) {
		trabajosRealizados.add(trabajo)
	}
	
	method trabajosHeavy() = trabajosRealizados.filter{trabajo => trabajo.esHeavy()} // CONSULTAR

	method esDeUsoIntensivo() = self.trabajosHeavy().size() > 5 // CONSULTAR
}

class Plaza inherits EspacioUrbano{
	var nroCanchas
	var property espacioDeEsparcimiento
	
	override method cumpleCondicionesEsGrande() = nroCanchas > 2
	override method esEspacioVerde() = nroCanchas == 0
	override method esLimpiable() = true
}

class Plazoletas inherits EspacioUrbano{
	var property procer = ""
	override method cumpleCondicionesEsGrande() = procer == "San Martín" && self.tieneVallado()
}

class Anfiteatro inherits EspacioUrbano{
	var capacidad
	var superficieEscenario
	
	override method cumpleCondicionesEsGrande() = capacidad > 500
	override method esLimpiable() = self.cumpleCondicionesEsGrande()
}

class Multiespacio inherits EspacioUrbano{
	const espaciosUrbanos = []
	
	override method cumpleCondicionesEsGrande() = 
		espaciosUrbanos.all{espacio => espacio.cumpleCondicionesEsGrande()}
		
	override method esEspacioVerde() = espaciosUrbanos.size() > 3
}

//////////////// TRABAJADOR

class Trabajador{
	var property profesion
	
	method trabajarEn(espacioUrbano){
		profesion.trabajarEn(espacioUrbano, self)
	}
}

class Profesion{
	var property valorHora = 100
	
	method trabajarEn(espacioUrbano, trabajador){
		self.validarPuedeTrabajarEn(espacioUrbano)
		self.producirEfecto(espacioUrbano)
		self.registrarTrabajoRealizado(espacioUrbano, trabajador)
	}
	
	method validarPuedeTrabajarEn(espacioUrbano){
		if(!self.puedeTrabajarEn(espacioUrbano)){
			throw new DomainException(message = "No puede trabajar en dicho espacio.")
		}
	}
	
	method registrarTrabajoRealizado(espacioUrbano, trabajador) {
		espacioUrbano.
		agregarTrabajo(new TrabajoRealizado(persona = trabajador, duracion = self.duracionTrabajo(espacioUrbano), costo = self.montoDeTrabajo(espacioUrbano), esHeavy = self.esTrabajoHeavy(espacioUrbano)))
	}
	
	method montoDeTrabajo(espacioUrbano) = self.duracionTrabajo(espacioUrbano) * valorHora
	
	method puedeTrabajarEn(espacioUrbano)
	method producirEfecto(espacioUrbano)
	method duracionTrabajo(espacioUrbano)
	method esTrabajoHeavy(espacioUrbano) = self.montoDeTrabajo(espacioUrbano) > 10000
}

object cerrajero inherits Profesion{
	override method puedeTrabajarEn(espacioUrbano) = not espacioUrbano.tieneVallado()
	override method producirEfecto(espacioUrbano) = espacioUrbano.vallado(true)
	override method duracionTrabajo(espacioUrbano) = if(espacioUrbano.esGrande()) 5 else 3
	override method esTrabajoHeavy(espacioUrbano) = 
		super(espacioUrbano) or self.duracionTrabajo(espacioUrbano) > 5
}

object jardinero inherits Profesion{
	var property valorTrabajo = 2500
	
	override method puedeTrabajarEn(espacioUrbano) = espacioUrbano.esEspacioVerde()
	override method producirEfecto(espacioUrbano) = 
		espacioUrbano.aumentarValuacion(espacioUrbano.valuacion() * 0.1)
	override method duracionTrabajo(espacioUrbano) = espacioUrbano.metrosCuadrados() / 10
	
	override method montoDeTrabajo(espacioUrbano) = valorTrabajo
}

object encargado inherits Profesion{
	override method puedeTrabajarEn(espacioUrbano) = espacioUrbano.esLimpiable()
	override method producirEfecto(espacioUrbano) = 
		espacioUrbano.aumentarValuacion(5000)
	override method duracionTrabajo(espacioUrbano) = 8
}

//////////////// TRABAJOS REALIZADOS

class TrabajoRealizado {
	var property fecha = new Date()
	var property persona
	var property duracion 
	var property costo
	var property esHeavy
}
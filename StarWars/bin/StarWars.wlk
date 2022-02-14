/////////////// HABITANTES

class Habitante{
	var valentia
	var inteligencia
	
	method poder() = valentia + inteligencia
	
}

class Soldado inherits Habitante{
	const equipamiento = []
	override method poder() = super() + equipamiento.potencia()
	
	method potencia(){
		equipamiento.filter{eq => eq.esUtil()}.
		sum{eq => eq.potencia()}
	}
	
	method tomar(arma){
		equipamiento.add(arma)
	}
	
	method dejar(arma){
		equipamiento.remove(arma)
	}
}

class Maestro inherits Habitante{
	const midiclorianos
	var property ladoFuerza
	var sableDeLuz
	
	override method poder() = 
	super() + 0.001 * midiclorianos + ladoFuerza.potenciaDe(sableDeLuz)
}

/////////////// EQUIPO

class Equipo{
	var property potencia
	var property estaDesgastado = true
	
	method esUtil() = potencia > 10 && estaDesgastado
	
	method usar(){
		estaDesgastado = false
	}
	
	method reparar(){
		estaDesgastado = true
	}
}

/////////////// FUERZA

class Fuerza{
	var antiguedad = 0
	
	method pasarTiempo() {
		antiguedad += 1
	}
	
	method aceptarSuceso(suceso, maestro)
	
	method vivirSuceso(suceso, maestro){
		self.pasarTiempo()
		self.aceptarSuceso(suceso, maestro)
	}
}

class LadoOscuro inherits Fuerza{
	var odio = 1000
	
	method aumentarOdio(){
		odio *= 1.1
	}
	
	method descripcion() = "Lado Oscuro"
	
	override method aceptarSuceso(suceso, maestro){
		if (suceso.cargaEmocional() > odio){
			maestro.ladoFuerza(new LadoLuminoso())
		} else { maestro.aumentarOdio() }
	}
	
	method potenciaDe(sable) = sable.potencia() + antiguedad
}

class LadoLuminoso inherits Fuerza{
	var pazInterior = 1000
	
	method sinPaz() = pazInterior <= 0
	
	method descripcion() = "Lado Luminoso"
	
	override method aceptarSuceso(suceso, maestro){
		pazInterior += suceso.cargaEmocional()
		if (maestro.sinPaz()){
			maestro.ladoFuerza(new LadoOscuro())
		}
	}
	
	method potenciaDe(sable) = 2 * sable.potencia() + antiguedad
}

/////////////// SUCESO

class Suceso{
	var property cargaEmocional
}

/////////////// PLANETA

class Planeta{
	const habitantes = []
	
	method poder() = habitantes.sum{hab => hab.poder()}
	
	method habitantesPoderosos() =
		habitantes.sortedBy{uno, otro => uno.poder() > otro.poder()}.
		take(3).
		sum{hab => hab.poder()}
	
	method tieneOrden() = self.habitantesPoderosos().poder() > self.poder() / 2
}
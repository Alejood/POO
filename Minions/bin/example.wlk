class Minion{
	var property estamina = 0
	const raza = biclopes
	const tareasRealizadas = []
	const herramientas = []
	var property rol = mucama
	
	method comerFruta(unaFruta){
		estamina = raza.estaminaQueAporta(self, unaFruta.estamina())
	}
	
	method disminuirEstamina(valor) {
		estamina -= valor
	}
	
	method tieneHerramienta(herramienta) = herramientas.contains(herramienta)
	
	method capacidadParaDefenderSector() = rol.puedeDefenderSector()
	
	method dificultadParaDefenderUnSector(gradoDeAmenaza) = raza.dificultadParaDefenderUnSector(gradoDeAmenaza)
	
	method fuerza() = raza.fuerza(rol.fuerza((estamina / 2) + 2))
	
	method tieneMasFuerzaQue(unaFuerza) = self.fuerza() >= unaFuerza
	
	method tieneMasEstaminaQue(valor) = estamina > valor 
	
	method experiencia() = 
		tareasRealizadas.size() * tareasRealizadas.sum{tarea => tarea.dificultad(self)}
		
	method realizarTarea(tarea){
		if (tarea.puedeSerRealizadaPor(self)){
			self.disminuirEstamina(tarea.estaminaRequerida(self))
			tareasRealizadas.add(tarea)
		} else {
			throw new DomainException(message = "La tarea no pudo ser realizada!")
		}
	}
}

///////// ROLES

class Soldado{
	const danioPorPractica = 2
	
	method fuerza(fuerzaBase) = fuerzaBase + danioPorPractica
	
	method puedeDefenderSector() = true
	
	method estaminaParaDefenderSector(minion) = 0
	
	method estaminaParaLimpiarSector(minion) = 1
}

object mucama{
	method fuerza(fuerzaBase) = fuerzaBase
	
	method puedeDefenderSector() = false
	
	method estaminaParaDefenderSector(minion) = minion.estamina() / 2
	
	method estaminaParaLimpiarSector(minion) = 0
}

object obrero{
	method fuerza(fuerzaBase) = fuerzaBase
	
	method puedeDefenderSector() = true
	
	method estaminaParaDefenderSector(minion) = minion.estamina() / 2
	
	method estaminaParaLimpiarSector(minion) = 1
}

class ElCapataz{
	const subordinados = []
	
	method puedeDefenderSector() = true
	
	method empleadosCapacesDeRealizar(tarea) = 
		subordinados.filter{minion => tarea.puedeSerRealizadaPor(minion)}
	
	method empleadoMasResponsable(tarea) {
		const candidatos = self.empleadosCapacesDeRealizar(tarea)
		return candidatos.max{minion => minion.experiencia()}
	}
	
	method hayEmpleadoResponsable(tarea) = [self.empleadoMasResponsable(tarea)] == 1
	
	method delegarTarea(tarea) {
		if (self.hayEmpleadoResponsable(tarea)){
		self.empleadoMasResponsable(tarea).realizarTarea(tarea)
		} else { /* FALTA QUE PUEDA HACER LA TAREA ÉL MISMO */ }
		}
	
	method estaminaParaLimpiarSector(minion) = 1
}

///////// RAZAS

object biclopes{
	method estaminaQueAporta(minion, estaminaAAgregar) = (minion.estamina() + estaminaAAgregar).min(10)
	method dificultadParaDefenderUnSector(gradoDeAmenaza) = gradoDeAmenaza
	method fuerza(unaFuerza) = unaFuerza
}

object ciclopes{
	method estaminaQueAporta(minion, estaminaAAgregar) = minion.estamina() + estaminaAAgregar
	method dificultadParaDefenderUnSector(gradoDeAmenaza) = gradoDeAmenaza * 2
	method fuerza(unaFuerza) = unaFuerza / 2
}

///////// TAREAS

class ArreglarUnaMaquina{
	const complejidadDeLaMaquina = 0
	const herramientasNecesarias = []
	
	method dificultad(minion) = complejidadDeLaMaquina * 2
	method estaminaRequerida(minion) = complejidadDeLaMaquina
	
	method puedeSerRealizadaPor(minion) = 
		minion.tieneMasEstaminaQue(self.estaminaRequerida(minion)) && 
		herramientasNecesarias.all{herramienta => minion.tieneHerramienta(herramienta)}
}

class DefenderUnSector {
	const gradoDeAmenaza = 0
	
	method dificultad(minion) = minion.dificultadParaDefenderUnSector(gradoDeAmenaza)
	
	method estaminaRequerida(minion) = minion.rol().estaminaParaDefenderSector(minion)
	
	method puedeSerRealizadaPor(minion) =
		minion.capacidadParaDefenderSector() && minion.tieneMasFuerzaQue(gradoDeAmenaza)
}

class LimpiarUnSector{
	const grande
	
	method dificultad(minion) = dificultadLimpiarUnSector.dificultad()
	
	method estaminaRequerida(minion) = 
		if (grande) 4 else 1
		* minion.rol().estaminaParaLimpiarSector(minion)
	
	method puedeSerRealizadaPor(minion) = minion.tieneMasEstaminaQue(self.estaminaRequerida(minion))	
}

object dificultadLimpiarUnSector{
	var dificultad = 10
	
	method cambiarDificultad(nuevaDif){
		dificultad = nuevaDif
	}
	
	method dificultad() = dificultad
}

///////// FRUTAS

object banana{
	method estamina() = 10
}

object manzana{
	method estamina() = 5
}

object uva{
	method estamina() = 1
}
class Pirata{
	const property items = []
	var property nivelDeEbriedad
	var property dinero = 0
	
	method esUtilPara(mision) = mision.cumpleRequisitos(self)
	
	method tieneItem(item) = items.contains(item)
	method numeroDeItems() = items.size()
	
	method seAnimaASaquearA(victima) = victima.puedeSerSaqueadoPor(self)
	method pasadoDeGrogXD() = 
		self.nivelDeEbriedad() >= 90 && self.tieneItem("botella de GrogXD")
		
	method puedePagar(precio) = dinero >= precio
	
	method gastar(precio){
 		if(self.puedePagar(precio))
 			dinero -= precio
 		else
 			self.error("No puede pagar esa cantidad de monedas")
 	}
	
	method tomarTragoDeGrogGXD(ciudad) {
		self.gastar(ciudad.cuantoCobraElGrogXD())
		nivelDeEbriedad += 5
	}
}

class EspiaDeLaCorona inherits Pirata{
	override method pasadoDeGrogXD() = false
	
	override method seAnimaASaquearA(victima) = super(victima) && items.contains("Permiso de la Corona")
}

//////////////// MISIONES

class Mision{
	method cumpleRequisitos(pirata)
	
	method puedeSerRealizadaPor(barco) = 
		barco.porcentajeDeOcupacion() >= 90 && self.cumpleCondicionParaRealizarla(barco)
		
	method cumpleCondicionParaRealizarla(barco) = true
}

class BusquedaDeTesoro inherits Mision{
	
	method tieneAlgunItemUtil(pirata) = 
	#{"brujula", "mapa", "botella de GrogXD"}.any({item => pirata.tieneItem(item)})
	override method cumpleRequisitos(pirata) = pirata.dinero() <= 5 && self.tieneAlgunItemUtil(pirata)

	override method cumpleCondicionParaRealizarla(barco) = 
		barco.tieneItem("Llave del cofre")
}

class ConvertirseEnLeyenda inherits Mision{
	var property itemObligatorio
	
	override method cumpleRequisitos(pirata) = 
		pirata.numeroDeItems() >= 10 && pirata.tieneItem(itemObligatorio)
}

class Saqueo inherits Mision{
	const property victima
	
	method maximoDeMonedas() = configuracionSaqueos.maximoDeMonedas()
	override method cumpleRequisitos(pirata) = 
		pirata.dinero() < self.maximoDeMonedas() && pirata.seAnimaASaquearA(victima)
}

object configuracionSaqueos{
	var property maximoDeMonedas = 0
}

//////////////// ZONAS

class BarcoPirata{
	const tripulantes = []
	const property capacidad
	var property mision
	
	method nroTripulantes() = tripulantes.size()
	method porcentajeDeOcupacion() = self.nroTripulantes() * 100 / capacidad
	method hayVacantes() = self.nroTripulantes() < capacidad
	
	method tieneItem(item) = tripulantes.any{pirata => pirata.tieneItem("Llave del cofre")}
	
	method puedeSerSaqueadoPor(pirata) = pirata.pasadoDeGrogXD()
	
	method tripulacionPasadaDeGrogXD() = tripulantes.all{pirata => pirata.pasadoDeGrogXD()}
	
	method esVulnerableA(barco) = 
		barco.nroTripulantes() > self.nroTripulantes() / 2

	method esAptoPara() = mision.puedeSerRealizadaPor(self)
	
	method puedeFormarParteDeTripulacion(pirata) = 
		pirata.esUtilPara(mision) && self.hayVacantes()
	
	method agregarPirata(pirata) = 
		if (self.puedeFormarParteDeTripulacion(pirata)) {tripulantes.add(pirata)}
		else { self.error("No puede formar parte de la tripulacion!") }
		
	method cambiarMision(nuevaMision){
		mision = nuevaMision
		
		const tripulantesInutiles = tripulantes.filter{tripulante => not tripulante.esUtilPara(mision)}
		
		tripulantes.removeAll(tripulantesInutiles)
	}
	
	method esTemible() = 
		self.esAptoPara() && tripulantes.count{pirata => pirata.esUtilPara(mision)} >= 5
		
	method itemsBarco() = tripulantes.flatMap {tripulante => tripulante.items()}	
	
	method cantidadDeTripulantesQueTienen(item) = tripulantes.count {tripulante =>
 		tripulante.tieneItem(item)
 	}
	
	method itemMasRaro() = self.itemsBarco().min {item => self.cantidadDeTripulantesQueTienen(item)}
	
	method tripulanteMasEbrio() = tripulantes.max{pirata => pirata.nivelDeEbriedad()}
	
	method anclarEn(ciudadCostera){
		tripulantes.
		filter{pirata => pirata.puedePagar(ciudadCostera.cuantoCobraElGrogXD())}.
		forEach{pirata => pirata.tomarTragoDeGrogGXD(ciudadCostera)}
		
		const elMasEbrio = self.tripulanteMasEbrio()
		tripulantes.remove(elMasEbrio)
		ciudadCostera.sumarHabitante()
	}
}

class CiudadCostera{
	var property habitantes
	const property cuantoCobraElGrogXD
	
	method puedeSerSaqueadoPor(pirata) = pirata.nivelDeEbriedad() >= 50
	
	method esVulnerableA(barco) = 
		barco.nroTripulantes() > self.habitantes() * 0.4 or
		barco.tripulacionPasadaDeGrogXD()
		
	method sumarHabitante(){
		habitantes += 1
	}
}

/*
 * A- pirata.esUtilPara(mision)
 * 
 * pirata = new Pirata()
 * mision = new BusquedaDelTesoro()
 * mision.esUtil(pirata)
 * 
 * busquedaDelTesoro.esUtil(pirata)
 * 
 * mision = new ConvertirseEnLeyenda(itemObligatorio = mapa)
 * 
 * mision1 = new Saqueo(victima = new CiudadCostera(cuantoCobraElGrogXD = 4))
 * mision2 = new Saqueo(victima = new CiudadCostera(cuantoCobraElGrogXD = 6))
 * 
 * configuracionSaqueos.maximoDeMonedas(7)
 * 
 * -----------
 * 
 * Punto 2:
 * barco.puedeFormarParte(pirata)
 * barco.incorporarATripulacion(pirata)
 * barco.mision(nuevaMision)
 * 
 * Punto 3:
 * barco.esTemible()
 * 
 * Punto 4:
 * barco.itemMasRaro()
 * 
 * Punto 5:
 * barco.anclarEn(ciudadCostera)
 * 
 * Punto 6:
 * espia.pasadoDeGrogXD()
 * espia.seAnimaASaquearA(victima)
 */
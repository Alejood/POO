class Mafioso{
	var salud = 4
	const armas = []
	var property rango = soldado
	
	// A) Durmiendo con los peces
	method estaMuerto() = salud <= 0
	
	method morir() { salud = 0 }
	method herir() { salud -= 1 } 
	
	method intimidacion() = rango.intimidacion(self.intimidacionBase())
	method intimidacionBase() = armas.sum{arma => arma.peligrosidadBase()}
	
	// C) Ataque sorpresa!
	method trabajar(victima){
		rango.hacerTrabajo(self,victima)
	}
	
	method atacar(familia){
		self.trabajar(familia.elMasPeligroso())
	}
	
	method desarmar(){
		armas.clear()
	}
	
	method armaEnMano() = armas.first()
	method armaEnCondiciones() = armas.findOrDefault({arma=>arma.enCondiciones()},armas.anyOne())

	// D) Luto
	
	method reorganizarse() {
		const nuevoRango = rango.nuevoRango()
		if (armas.size() > 2)
			rango = nuevoRango
		self.acondicionarArmas()
		armas.add(new Revolver())
	}	
	
	method acondicionarArmas(){
		armas.forEach{arma => arma.acondicionar()}
	}
}

object soldado{
	method intimidacion(base) = base
	
	method hacerTrabajo(atacante, victima){
		atacante.armaEnMano().usarseEn(victima)
	}
	
	method nuevoRango() = new SubJefe()
}

object don{
	method intimidacion(base) = base + 20
	
	method hacerTrabajo(atacante, victima){
		victima.desarmar()
	}
	
	method nuevoRango() = throw new DomainException(message = "Soy el don y sigo vivo.")
}

class SubJefe{
	method intimidacion(base) = base * 2
	
	method hacerTrabajo(atacante, victima){
		atacante.armaEnCondiciones().usarseEn(victima)
	}
	
	method nuevoRango() = soldado
}

///////////// FAMILIA

class Familia{
	const miembros = []

	// B) El mas peligroso!
	
	method elMasPeligroso() = self.miembrosVivos().max{miembro => miembro.intimidacion()}
	method miembrosVivos() = miembros.filter{miembro => not miembro.estaMuerto()}	
	
	// D) Luto
	method luto(){
		self.miembrosVivos().forEach{m=>m.reorganizarse()}
		self.elMasPeligroso().rango(don)
	}
}

///////////// ARMAS

class Arma{
	method peligrosidad() = 
		if (self.estaEnCondiciones()) self.peligrosidadBase() else 1
	method estaEnCondiciones()
	method peligrosidadBase()
}

class Revolver inherits Arma{
	var balas = 6
	
	override method estaEnCondiciones() = balas > 0
	method acondicionar() { balas = 6}
	method disparar(victima) {victima.morir()}
	method usarseEn(victima){
		if (self.estaEnCondiciones()){
			self.disparar(victima)
			balas -= 1
		}
	}
	override method peligrosidadBase() = balas * 2
}

class RevolverOxidado inherits Revolver{
	override method disparar(victima){
		if(self.balaMortal())
			victima.morir()
		else
			victima.herir()
	}
	method balaMortal() = [true,true,false].anyOne()
	
	override method peligrosidadBase() = super() / 2
}

class Daga inherits Arma{
	var property peligrosidadBase
	method usarseEn(victima){
		victima.herir()
	}
	override method estaEnCondiciones() = true
	method acondicionar() { }
}

class Cuerda inherits Arma{
	var property estaEnCondiciones = true
	
	method usarseEn(victima){
		if (self.estaEnCondiciones()){
			victima.morir()
		} else { victima.herir() }
	}
	method acondicionar() { 
		estaEnCondiciones = true
	}
}
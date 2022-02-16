class Programa{
	const disco
	const memoria
	
	var property ejecuciones = 0
	
	const hospedados = []
	
	method memoriaUsada() = memoria
	method discoUsado() = disco + hospedados.sum{malicioso => malicioso.discoUsado()}
	
	method instalarseEn(computadora){
		computadora.agregar(self)
	}
	
	method ejecutarseEn(computadora){
		ejecuciones += 1
		computadora.abrir(self)
		hospedados.forEach{hospedado => hospedado.ejecutarseEn(computadora)}
	}
	
	method detenerseEn(computadora){
		computadora.cerrar(self)
	}
	
	method hospedar(malicioso) {
		hospedados.add(malicioso)
	}
	
	method infectar(malicioso){
		if (! hospedados.contains(malicioso)){
			self.hospedar(malicioso)
			malicioso.registrarInfeccion()
		}
	}
	
	method esSano() = hospedados.isEmpty()
	
	method limpiarCon(antivirus, computadora){
		hospedados.forEach{hospedado => 
			if (antivirus.elimina(hospedado)){
				hospedados.remove(hospedado)
				computadora.detener(hospedado)
			} 
		}
	}
}

class SistemaOperativo inherits Programa{
	
	override method instalarseEn(computadora){
		computadora.sistemaOperativo(self)
	}
	
	override method detenerseEn(computadora) {
		super(computadora)
		computadora.detenerTodosLosProgramas()
	}
}

// Virus

class ProgramaMalisioso inherits Programa{
	method puedeEliminarlo(antivirus) = antivirus.virusQueMata().contains(self) 
}

class Troyano inherits ProgramaMalisioso{
	override method ejecutarseEn(computadora){
		super(computadora)
		computadora.hacerVulnerable()
	}
}

class Virus inherits ProgramaMalisioso{
	var potencia
	var property cantidadInfectados = 0
	
	override method ejecutarseEn(computadora){
		super(computadora)
		computadora.programasQueAtaca(self).forEach{programa => programa.infectar(self)}
	}
	
	method puedeAtacar(programa) = programa.ejecuciones() > potencia
	
	method registrarInfeccion(){
		cantidadInfectados += 1
	}
}

class Destructor inherits ProgramaMalisioso{
	const cantidadMaximaEjecuciones = 3
	
	override method ejecutarseEn(computadora){
		super(computadora)
		if (ejecuciones < cantidadMaximaEjecuciones){
			computadora.desinstalarPrimerPrograma()
		}
	}
}

class Inventado inherits Destructor { /* Hace lo mismo que un Destructor pero además infecta otro programa al azar (se reproduce)*/
	override method ejecutarseEn(computadora) {
		super(computadora)
		computadora.ataqueInventado(self)
	}
}

class Worm inherits ProgramaMalisioso{
	// Ni idea
}

class Antivirus inherits Programa {
	const virusQueElimina = []
	
	override method ejecutarseEn(computadora) {
		super(computadora)
		computadora.limpiarCon(self)
	}
	
	method elimina(virus) = virusQueElimina.contains(virus)
}

//	Lista de computadoras

object computadoras{
	const todasLasComputadoras = []

	method puedeInstalarse(programa) = todasLasComputadoras
		.filter{compu=>compu.validarInstalacionPrograma(programa)}
}

class Computadora{
	var discoTotal = 0
	var memoriaTotal
	var property sistemaOperativo
	var property vulnerable = false
	
	const property programasInstalados = []
	const property programasEnEjecucion = []
	
	method estaEnCondicionesSO() = programasEnEjecucion.contains(sistemaOperativo)
	
	method estaInstalado(programa) = programasInstalados.contains(programa) or programa == sistemaOperativo
	
	method detenerTodosLosProgramas() {
		programasEnEjecucion.forEach{programa => self.detener(programa)}
	}
	
	//Manejo de Memoria
	
	method memoriaEnUso() = 
		programasEnEjecucion.sum{programa => programa.memoriaUsada()}
	method memoriaDisponible() = memoriaTotal - self.memoriaEnUso()
	method memoriaSuficiente(programa) = 
		self.memoriaDisponible() >= programa.memoriaUsada() 
	
	//Manejo de Disco
		
	method discoEnUso() = 
		programasInstalados.sum{programa => programa.discoUsado()} + sistemaOperativo.discoUsado()
	method discoDisponible() = discoTotal - self.discoEnUso()
	method discoSuficiente(programa) = 
		self.discoDisponible() >= programa.discoUsado()
	
	//Instalar programa
		
	method instalar(programa) {
		if(!self.validarInstalacionPrograma(programa)){
			throw new DomainException(message = "No hay espacio en disco.")
		} else {
			programa.instalarseEn(self)
		}
	}
	
	method validarInstalacionPrograma(programa) = self.discoSuficiente(programa) && not self.estaInstalado(programa)
	
	method agregar(programa) { 
		programasEnEjecucion.add(programa)
	}
	
	//Ejecutar programa
	
	method ejecutar(programa){
		if (!self.validarEjecucionPrograma(programa)){
			throw new DomainException(message = "No hay memoria suficiente.")
		} else {
			programa.ejecutarseEn(self)
		}
	}
	
	method abrir(programa) {
		programasEnEjecucion.add(programa)
	}
	
	method validarEjecucionPrograma(programa) = 
		self.memoriaSuficiente(programa) && not self.estaEnEjecucion(programa) && self.estaEnCondicionesSO()
		
	method estaEnEjecucion(programa) = programasEnEjecucion.contains(programa)
	
	//Detener programa
	
	method detener(programa){
		programa.detenerseEn(self)
	}
	method cerrar(programa)	{
		programasEnEjecucion.remove(programa)
	}
	
	//Estadisticas
	
	method programaQueMasMemoriaConsume() = programasEnEjecucion.max{programa => programa.memoriaUsada()}
	
	method programaMuyPesado() = programasEnEjecucion.any{programa => programa.discoUsado() > discoTotal/2}
	
	//Desinstalar un programa.
	
	method desinstalar(programa) {
		// La consigna no lo detalla, se asume que implica primero detener el programa y luego quitarlo del disco. 
		self.detener(programa)  
		programasInstalados.remove(programa)
	}
	
	//Virus
	
	method hacerVulnerable() {
		vulnerable = true
	}
	
	method resolverVulnerabilidad() {
		vulnerable = false
	}
	
	method programasQueAtaca(malicioso) = programasInstalados.filter{programa => malicioso.puedeAtacar(programa)}
	
	method desinstalarPrimerPrograma() {
		self.desinstalar(programasInstalados.first())
	}
	
	method ataqueInventado(malicioso){
		// Invente Roman invente
	}
	
	method virusDeMayorImpacto(muchosVirus) {
		muchosVirus.sortedby{uno, otro => uno.cantidadInfectados() > otro.cantidadInfectados()}.take(3)
	}
	
	// AntiVirus
	
	method limpiarCon(antivirus) {
		programasInstalados.forEach{programa=> programa.limpiarCon(antivirus,self)}
		self.resolverVulnerabilidad()
	}
}
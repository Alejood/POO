class Zona {
	var valor
	
	constructor(valorDeZona){
		valor = valorDeZona
	}
	
	method valor() = valor
	method valor(nuevoValor){
		valor = nuevoValor
	}
}

class Inmueble {
  const tamanio
  const cantAmbientes
  const zona
  
  constructor(unTamanio, unosAmbientes, unaZona){
  	tamanio = unTamanio
  	cantAmbientes = unosAmbientes
  	zona = unaZona
  }
  
  method valor() = self.valorParticular() + zona.valor()
  method valorParticular()
  method zona() = zona
  
  method validarQuePuedeSerVendido(){}
}

class Casa inherits Inmueble {
	var valorParticular
	constructor(unTamanio, unosAmbientes, unaZona, valor) 
	  = super(unTamanio, unosAmbientes, unaZona) {
		valorParticular = valor
	}
	
	override method valorParticular() = valorParticular
}

class PH inherits Inmueble {
	override method valorParticular() = (14000 * tamanio).max(50000)
}

class Departamento inherits Inmueble {
	override method valorParticular() = 350000 * cantAmbientes
}

class Local inherits Casa {
	var tipoDeLocal
	constructor(unTamanio, unosAmbientes, unaZona,tipo) = super(unTamanio, unosAmbientes, unaZona){
		tipoDeLocal = tipo
	}
	override method valor() = tipoDeLocal.valorFinal(super())
	override method validarQuePuedeSerVendido(){
		throw new VentaInvalida("No se puede vender un local")
	}
}

object galpon {
	method valorFinal(valorBase) = valorBase / 2
}

object aLaCalle {
	var montoFijo
	method montoFijo(nuevoMonto){
		montoFijo = nuevoMonto
	}
	
	method valorFinal(valorBase) = valorBase + montoFijo
}
class VentaInvalida inherits Exception{}
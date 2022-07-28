
object inmobiliaria {
  var porcentajePorVenta
  const empleados = #{}
  
  method porcentajeDeComisionPorVenta()= porcentajePorVenta
  method porcentajeDeComisionPorVenta(porcentaje){
  	porcentajePorVenta = porcentaje
  }

  method mejorEmpleadoSegun(criterio)= empleados.max({empleado => criterio.ponderacion(empleado)})

}

object porTotalComisiones {
	method ponderacion(empleado) = empleado.totalComisiones()
}

object porCantidadDeOperacionesCerradas {
	method ponderacion(empleado) = empleado.operacionesCerradas().size()
}

object porCantidadDeReservas {
	method ponderacion(empleado) = empleado.reservas().size()
}

class Empleado {
	const operacionesCerradas = #{}
	const reservas = #{}
	
	method operacionesCerradas() = operacionesCerradas
	method reservas() = reservas
	
	method totalComisiones() = operacionesCerradas.sum({operacion => operacion.comision()})
	
	method vaATenerProblemasCon(otroEmpleado) 
		= self.operoEnMismaZonaQue(otroEmpleado) 
			&& (self.concretoOperacionReservadaPor(otroEmpleado) || 
				otroEmpleado.concretoOperacionReservadaPor(self))
		
	method operoEnMismaZonaQue(otroEmpleado) =
		self.zonasEnLasQueOpero()
			.any({zona => otroEmpleado.operoEnZona(zona)})
			
	method operoEnZona(zona)= self.zonasEnLasQueOpero().contains(zona)
			
	method zonasEnLasQueOpero() = operacionesCerradas.map({operacion => operacion.zona()}).asSet()
	
	method concretoOperacionReservadaPor(otroEmpleado) =
		operacionesCerradas.any({operacion => otroEmpleado.reservo(operacion)})
		
	method reservo(operacion) = reservas.contains(operacion)
	
	method reservar(operacion, cliente){
		operacion.reservarPara(cliente)
		reservas.add(operacion)
	}
	method concretarOperacion(operacion, cliente){
		operacion.concretarPara(cliente)
		operacionesCerradas.add(operacion)
	}
}

class Cliente {
	var nombre
	constructor(nombreCliente){
		nombre = nombreCliente
	}
}

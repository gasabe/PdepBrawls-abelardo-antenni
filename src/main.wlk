class Personaje {

	var property cantidadDeCopas

	method ganarCopas(copasEnJuego) {
		cantidadDeCopas += copasEnJuego
	}

	method perderCopas(copasEnJuego) {
		cantidadDeCopas -= copasEnJuego
	}

}

class Arquero inherits Personaje {

	var property rango
	var property agilidad

	method destrezaDelPersonaje() = agilidad * rango

	method tienenEstrategia() = rango > 100

}

class Guerrero inherits Personaje {

	const property fuerza
	const property tienenEstrategia // bool

	method destrezaDelPersonaje() = 1.5 * fuerza

}

class Ballestero inherits Arquero {

	override method destrezaDelPersonaje() = 2 * (agilidad * rango)

}

class Misiones {

	var property copasEnJuego

}

class MisionIndividual inherits Misiones {

	var property dificultadDeLaMision
	var property personaje

	method iniciarMision() {
		self.verificacionDeError()
		if (self.esSuperable()) {
			personaje.ganarCopas(self.copasEnJuego())
		} else {
			personaje.perderCopas((self.copasEnJuego().max(0)))
		}
	}

	override method copasEnJuego() {
		return dificultadDeLaMision * 2
	}

	method esSuperable() = personaje.tienenEstrategia() || (personaje.destrezaDelPersonaje() > dificultadDeLaMision)

	method verificacionDeError() {
		if (personaje.cantidadDeCopas() < 10) {
			throw new Exception(message = "No se puede tener menos de 10 copas")
		}
	}

}

class MisionIndividualBonus inherits MisionIndividual {
	
	override method copasEnJuego(){
		return super()+1
	}
	
}

class MisionIndividualBoost inherits MisionIndividual {
	const property multiplicadorDeCopas
	
	override method copasEnJuego(){
		return super()*multiplicadorDeCopas
	}
	
}

class MisionEnEquipo inherits Misiones {

	var property personajes

	method iniciarMision() {
		self.verificacionDeError()
		if (self.esSuperable()) {
			personajes.forEach({ personaje => personaje.ganarCopas(self.copasEnJuego())})
		} else {
			personajes.forEach({ personaje => personaje.perderCopas(self.copasEnJuego().max(0))})
		}
	}

	override method copasEnJuego() {
		return 50 / self.cantidadDePersonajes()
	}
	
	// (50 / 10) = 5
	// 5 + 1 = 6 

	method cantidadDePersonajes() {
		return personajes.size()
	}

	method esSuperable() = self.masDeLaMitadDelEquipoTieneEstrategia() || not self.personajesTienenMenorDestreza()

	/*Existen las misiones individuales y las misiones por equipo. 
	 * En las misiones individuales, las copas que están en juego 
	 * son el doble de la dificultad de la misión, y puede ser 
	 * superada cuando el personaje tiene estrategia o bien cuando 
	 * su destreza supera la dificultad de la misión.
	 * En las misiones por equipo las copas que están en juego son 
	 * 50 dividido la cantidad de personajes que participan, y 
	 * pueden ser superadas cuando más de la mitad de los participantes 
	 * tienen estrategia, o bien, cada uno tiene una destreza mayor a 400.
	 */
	method masDeLaMitadDelEquipoTieneEstrategia() {
		return self.cantidadDePersonajesConEstrategia() > self.mitadDelEquipo()
	}

	method personajesQueTienenEstrategia() {
		return personajes.filter({ personaje => personaje.tienenEstrategia() })
	}

	method cantidadDePersonajesConEstrategia() {
		return self.personajesQueTienenEstrategia().size()
	}

	method mitadDelEquipo() {
		return ((personajes.size()) / 2).truncate(0)
	}

	method personajesTienenMenorDestreza() {
		return personajes.any({ personaje => personaje.destrezaDelPersonaje() <= 400 })
	}

	method verificacionDeError() {
		if (self.sumatoriaDeCopas() < 60) {
			throw new Exception(message = "No se puede tener menos de 60 copas")
		}
	}

	method sumatoriaDeCopas() {
		return personajes.sum({ personaje => personaje.cantidadDeCopas() })
	}

}

class MisionEnEquipoBonus inherits MisionEnEquipo {
	override method copasEnJuego(){
		return super()+1
	}
}

class MisionEnEquipoBoost inherits MisionEnEquipo {
const property multiplicadorDeCopas
	
	override method copasEnJuego(){
		return super()*multiplicadorDeCopas
	}
}

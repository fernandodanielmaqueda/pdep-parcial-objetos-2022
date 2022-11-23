/*
* Nombre: Maqueda, Fernando Daniel
* Legajo: 173.065-4
*/

class Imperio {
	var property cantidadDeDinero
	const ciudades = #{}
	
	method estaEndeudado() = cantidadDeDinero < 0
	
	method pagar(cantidadDePepines) {
		cantidadDeDinero -= cantidadDePepines
	}
	
	// Punto 3	
	method evolucionarImperio() {
		ciudades.forEach({ciudad => 
			if(ciudad.esFeliz()) ciudad.crecerPoblacionEn(2)
			ciudad.causarEfectoAlEvolucionarImperio()
		})
	}
	
	method recibirRecaudacion(cantidadDePepines) {
		cantidadDeDinero += cantidadDePepines
	}
	
	method disconformidadDeLasCiudadesNoCapitales() = self.ciudadesNoCapitales().sum({ciudad => ciudad.disconformidadDeSusHabitantes()})
	
	method ciudadesNoCapitales() = ciudades.filter({ciudad => not ciudad.esCapital()})
	
	method estaEntreLas3CiudadesFelicesDelImperioQueMenosCulturaTotalTienen(ciudadEvaluada) = self.ciudadesFelices().sortedBy({ciudad1, ciudad2 => ciudad1.culturaTotal() < ciudad2.culturaTotal()}).take(3).contains(ciudadEvaluada)
	
	method ciudadesFelices() = ciudades.filter({ciudad => ciudad.esFeliz()})
}

class Ciudad {
	var property sistemaImpositivo
	var property cantidadDeHabitantes
	const edificios = #{}
	const property imperioAlQuePertenece
	var cantidadDeTanques
	
	
	// Punto 1
	method esFeliz() = (self.tranquilidadTotalQueGeneranSusEdificios() > self.disconformidadDeSusHabitantes()) && not self.seEncuentraEnUnImperioEndeudado()
	
	method tranquilidadTotalQueGeneranSusEdificios() = edificios.sum({edificio => edificio.tranquilidadQueOtorga()})
	
	method disconformidadDeSusHabitantes() = 1 / 10000 * cantidadDeHabitantes + 1 * 30.min(cantidadDeTanques)
	
	method seEncuentraEnUnImperioEndeudado() = imperioAlQuePertenece.estaEndeudado()
	
	// Punto 2.a.
	method costoDeConstruccionDe(edificio) = edificio.costoDeConstruccionBase() + sistemaImpositivo.costoAgregadoAl(edificio, self)
	
	// Punto 2.b.
	method construir(edificio) {
		if(not self.esPosibleConstruir(edificio)) throw new NoEsPosibleConstruirEdificioException(message = "El costo de construccion del edificio supera la cantidad de pepines del imperio en el que se encuentra la ciudad")
		imperioAlQuePertenece.pagar(self.costoDeConstruccionDe(edificio))
		edificios.add(edificio)
	}
	
	method esPosibleConstruir(edificio) = self.costoDeConstruccionDe(edificio) <= imperioAlQuePertenece.cantidadDeDinero()
	
	method crecerPoblacionEn(porcentaje) {
		cantidadDeHabitantes += cantidadDeHabitantes / 100 * porcentaje
	}
	
	method causarEfectoAlEvolucionarImperio() {
		self.evolucionarEdificios()
	}
	
	method evolucionarEdificios() {
		edificios.forEach({edificio => edificio.evolucionarEdificioDe(self)})
	}
	
	method recaudarDineroParaElImperio(cantidadDePepines) {
		imperioAlQuePertenece.recibirRecaudacion(cantidadDePepines)	
	}
	
	method incrementarTanquesEn(cantidad) {
		cantidadDeTanques += cantidad
	}
	
	method culturaTotal() = edificios.sum({edificio => edificio.cantidadDeCulturaQueIrradia()})
	
	method esCapital() = false
}

class SistemaImpositivo {
	method costoAgregadoAl(edificio, cantidadDeHabitantesDeLaCiudad)
}

class Citadino inherits SistemaImpositivo {
	const cadaCuantosHabitantesSeDaElIncremento
	
	override method costoAgregadoAl(edificio, ciudad) = (edificio.costoDeConstruccionBase() * 0.05) / (ciudad.cantidadDeHabitantes().div(cadaCuantosHabitantesSeDaElIncremento))
}

object incentivoCultural inherits SistemaImpositivo {
	override method costoAgregadoAl(edificio, ciudad) = -(edificio.cantidadDeCulturaQueIrradia() / 3)
}

object apaciguador inherits SistemaImpositivo {
	override method costoAgregadoAl(edificio, ciudad) {
		if(ciudad.esFeliz()) return 0
		else return -(edificio.tranquilidadQueOtorga())
	}
}

class Edificio {
	const property costoDeConstruccionBase
	
	method costoDeMantenimiento(ciudad) = ciudad.costoDeConstruccionDe(self) / 100
	
	method cantidadDeCulturaQueIrradia()
	
	method tranquilidadQueOtorga()
	
	method evolucionarEdificioDe(ciudad) {
		ciudad.imperioAlQuePertenece().pagar(self.costoDeMantenimiento(ciudad))
	}
}

class Economico inherits Edificio {
	const cantidadDeDineroQueGenera
	const property cantidadDeCulturaQueIrradia = 0
	
	override method tranquilidadQueOtorga() = 3
	
	override method evolucionarEdificioDe(ciudad) {
		super(ciudad)
		ciudad.recaudarDineroParaElImperio(cantidadDeDineroQueGenera)
	}
}

class Cultural inherits Edificio {
	const property cantidadDeCulturaQueIrradia
	
	override method tranquilidadQueOtorga() = 3 * cantidadDeCulturaQueIrradia
}

class Militar inherits Edificio {
	const cantidadDeTanquesQueGenera
	
	const property cantidadDeCulturaQueIrradia = 0
	
	override method tranquilidadQueOtorga() = 0
	
	override method evolucionarEdificioDe(ciudad) {
		super(ciudad)
		ciudad.incrementarTanquesEn(cantidadDeTanquesQueGenera)
	}
}

// Punto 4
class Capital inherits Ciudad {
	
	override method disconformidadDeSusHabitantes() = imperioAlQuePertenece.disconformidadDeLasCiudadesNoCapitales() / 2
	
	override method esCapital() = true
	
	override method costoDeConstruccionDe(edificio) = super(edificio) * 1.1
	
	override method recaudarDineroParaElImperio(cantidadDePepines) {
		imperioAlQuePertenece.recibirRecaudacion(3 * cantidadDePepines)	
	}
	
	override method causarEfectoAlEvolucionarImperio() {
		super()
		if(not self.esFeliz()) sistemaImpositivo = apaciguador
		else if(imperioAlQuePertenece.estaEntreLas3CiudadesFelicesDelImperioQueMenosCulturaTotalTienen(self)) sistemaImpositivo = incentivoCultural
		else sistemaImpositivo = new Citadino(cadaCuantosHabitantesSeDaElIncremento = 25000)
	}
}

class NoEsPosibleConstruirEdificioException inherits DomainException { }
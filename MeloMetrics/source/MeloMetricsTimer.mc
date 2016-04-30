using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;


//behavior extiende a inputdelegate por lo atnto tiene sus metodos
//si el compartamientode lso delegate no cambia quizas al final solo haga falta uno
class MeloMetricsTimer  {

	var timer = new Timer.Timer();
	var contadorSegundos;
	
	function reset(){
		contadorSegundos=0;
		timer.stop();
	}
	
	function aumentarSegundos(){
		contadorSegundos=contadorSegundos+1;
	}
	
	function stop(){
		timer.stop();
	}

	function start(){
		reiniciarSegundos();
	}
	
	
	function segundos(){
		return contadorSegundos;
	}
	
	function reiniciarSegundos(){
		contadorSegundos=0;
	}
	
	function tiempoTranscurridoCuentaAtras(duracion){
		return  tiempoTranscurrido(duracion-contadorSegundos);
	}
	
	function tiempoTranscurridoCuentaAlante(){
		return  tiempoTranscurrido(contadorSegundos);
	}
	
	function tiempoTranscurrido(contadorSegundosAux) {
		
		if (contadorSegundosAux==null){
			contadorSegundosAux=0;
		}
		
    	var hour = contadorSegundosAux / 3600;
		var min = (contadorSegundosAux / 60) % 60;
		var sec = contadorSegundosAux % 60;
		if(0 < hour) {
			return format("$1$:$2$:$3$",[hour.format("%01d"),min.format("%02d"),sec.format("%02d")]);
		}
		else {
			return format("$1$:$2$",[min.format("%02d"),sec.format("%02d")]);
		}
    }
}
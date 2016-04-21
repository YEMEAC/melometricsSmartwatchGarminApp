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

	var timer;
	var contadorSegundos;
	
	
	function inicializar(){
		timer= new Timer.Timer();
    	start();
	}
	
	function callBack(){
		contadorSegundos=contadorSegundos+1;
	}
	
	function stop(){
		timer.stop();
	}

	function start(){
		contadorSegundos=0;
		timer.start(method(:callBack),1000,true);
	}
	
	function reStart(){
		timer.start(method(:callBack),1000,true);
	}
	
	function segundos(){
		return contadorSegundos;
	}
	
	function tiempoTranscurrido() {
		if (contadorSegundos==null){
			contadorSegundos=0;
		}
		
    	var hour = contadorSegundos / 3600;
		var min = (contadorSegundos / 60) % 60;
		var sec = contadorSegundos % 60;
		if(0 < hour) {
			return format("$1$:$2$:$3$",[hour.format("%01d"),min.format("%02d"),sec.format("%02d")]);
		}
		else {
			return format("$1$:$2$",[min.format("%02d"),sec.format("%02d")]);
		}
    }
}
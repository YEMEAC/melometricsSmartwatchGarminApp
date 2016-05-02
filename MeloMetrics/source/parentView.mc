using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

class ParentView extends Ui.View{

	var app;

	//segundos que debe durar el test antes de tener suficientes muestras
	var tiempoDuracionTest;
	
	var meloMetricsTimer = new  MeloMetricsTimer(); 
	
	//estado del test
	var testEnEjecucion;
	var	testDetenido;
	var primeraMuestra;
	var activityrec;
	
	//estimacidor del test a mostrar en pantalla
	var media;
	

function resetVariablesParent(){
			
		meloMetricsTimer.contadorSegundos=0;
		meloMetricsTimer.timer.stop();
			
		testEnEjecucion=false;
		testDetenido=false;
		primeraMuestra=true;

		media=null;
		
		if(activityrec!= null) { //si cambio en medio de un test
			//if(activityrec.isRecording()){
				activityrec.discard();
				activityrec=null;
			//}
		}
}

    function onSnsr(sensor_info){
    	if(sensor_info.heartRate!=null){
    		app.heartRate=sensor_info.heartRate;
    	}
    	
    	if(sensor_info.speed!=null){
    		app.speed=sensor_info.speed;
    	}
    	Ui.requestUpdate();
    	return true; 
    }  
    
    
    //hacer subclase para rest de recorrido de distancia
    function distanciaFaltaRecorrerTest(){
		var aux;
		if(media == null && testEnEjecucion == true && testDetenido==false){
			//distanciaTestDenido = quiar la distancia recorrida con el test detenido 
			//distanciaInicioActivity = distancia que ya tenia recorrida antes de iniciar el test
			
			var distanciaTestDenido=distanciaContinuarActivity-distanciaDetenerActivity;
			var distanciaRecorrida= (Activity.getActivityInfo().elapsedDistance-distanciaTestDenido-distanciaInicioActivity)/1000; //km
    		aux=distanciaARecorrer - distanciaRecorrida;
    		
    		
    		if(aux<0){
    				distanciaFaltaRecorrer=0;
    		}else{
    			distanciaFaltaRecorrer = aux;
    		}
		}else if (testDetenido==true){
    		aux= distanciaFaltaRecorrer;
    	}else{
    		aux= 0.0d;
    	}
    	//System.println("distancia test denitod0 "  + (distanciaContinuarActivity-distanciaDetenerActivity)/1000);
    	return aux;
    }
}
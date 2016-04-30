using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

class ParentView extends Ui.View{

	var app;
	//variables para controlar tiempo/timer
	var tiempoInicioTest;
	var tiempoTestDetenido;
	var tiempoTestReanudado;
	var duracionPausas;
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
	
	var timer = new Timer.Timer();


function resetVariablesParent(){
		tiempoInicioTest=0;
		tiempoTestDetenido=0;
		tiempoTestReanudado=0;
		duracionPausas=0;
		//tiempoDuracionTest=720;
			
		meloMetricsTimer.contadorSegundos=0;
		meloMetricsTimer.stop();
			
		testEnEjecucion=false;
		testDetenido=false;
		primeraMuestra=true;
		tiempoTestReanudado=false;

		media=null;
		
		if(activityrec!= null) { //si cambio en medio de un test
			if(activityrec.isRecording()){
				activityrec.discard();
				activityrec=null;
			}
		}
}


	//todas estas funciones bajar a vo2ma si no se comarten por el resto en un futuro
	//si tiempoDuracionTest > 1 es una cuenta atras, test que depende de un tiempo
	function timerPantalla() {
    	if(testEnEjecucion==true && testDetenido==false){
    		if(tiempoDuracionTest>1) { 		
				return timerFormat(tiempoDuracionTest-tiempoTestEnCurso());	
			}else{ 
				return timerFormat(tiempoTestEnCurso());
			}
		 }else if(testEnEjecucion==true && testDetenido==true){
			if(tiempoDuracionTest>1) {
				return timerFormat(tiempoDuracionTest-tiempoTestEnCurso()+tiempoTestEnCursoDenido());
			}else{
				return timerFormat( tiempoTestEnCurso()+tiempoTestEnCursoDenido);
			}
		}
		return timerFormat(0);	
    }
    
    
    function tiempoTestEnCurso(){
		//duracionPausas siempre => 0 acumulador de las detenciones anteriores
    	return Time.now().value() - tiempoInicioTest-duracionPausas;
    }
    
    //return cuando tiempo lleva denido el test, detencion en curso
    function tiempoTestEnCursoDenido(){
    	return Time.now().value()-tiempoTestDetenido;
    }
    
    function timerFormat(time) {
    	var hour = time / 3600;
		var min = (time / 60) % 60;
		var sec = time % 60;
		if(0 < hour) {
			return format("$1$:$2$:$3$",[hour.format("%01d"),min.format("%02d"),sec.format("%02d")]);
		}
		else {
			return format("$1$:$2$",[min.format("%02d"),sec.format("%02d")]);
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
			//quiar la distancia recorrida con el test detenido 
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
    	System.println("distancia test denitod0 "  + (distanciaContinuarActivity-distanciaDetenerActivity)/1000);
    	return aux;
    }
}
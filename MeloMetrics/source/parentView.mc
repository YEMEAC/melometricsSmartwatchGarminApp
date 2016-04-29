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
		tiempoInicioTest=0.0d;
		tiempoTestDetenido=0.0d;
		tiempoTestReanudado=0.0d;
		tiempoDuracionTest=1.0d;
			
		meloMetricsTimer.contadorSegundos=0;
		meloMetricsTimer.stop();
		timer.stop();
		
		testEnEjecucion=false;
		testDetenido=false;
		primeraMuestra=true;
		tiempoTestReanudado=false;
		timer.start(method(:timerCallback),tiempoDuracionTest*1000,true);
		media=null;
		
		if(activityrec!= null) { //si cambio en medio de un test
			if(activityrec.isRecording()){
				activityrec.discard();
				activityrec=null;
			}
		}
}


//todas estas funciones bajar a vo2ma si no se comarten por el resto en un futuro
function timerPantalla() {
    	if(testEnEjecucion==true && testDetenido==false){
    		if(tiempoDuracionTest>1) { //cuenta atras   			
				return timerFormat(tiempoDuracionTest-tiempoTestEnCurso());	
			}else{ //cuenta hacia delante
				return timerFormat(tiempoTestEnCurso());
			}
		}else if(testEnEjecucion==true && testDetenido==true){
			if(tiempoDuracionTest>1) {
				return timerFormat(tiempoDuracionTest-tiempoTestEnCursoDenido());
			}else{
				return timerFormat( tiempoTestEnCurso()-(Time.now().value()-tiempoTestDetenido));
			}
		}
			return timerFormat(0);	
    }
    
    
    function tiempoTestEnCurso(){
    	//si el test se ha denido 
    	if(tiempoTestDetenido>0 && tiempoTestReanudado>0){
    		//el tiempo que lleva en curso es al actual - el de inicio pero sumandole el tiempo que estuvo parado
			//para que no cuente el tiempo parado como si hubiera estado en curso
    		return Time.now().value() - (tiempoInicioTest+(tiempoTestReanudado-tiempoTestDetenido));
    	}else{
    		//si nunca se pa detenido es al actual - el inicio
    		return Time.now().value() - tiempoInicioTest;
    	}
    }
    
      //return cuando tiempo lleva denido el test
    function tiempoTestEnCursoDenido(){
    	return tiempoTestDetenido-tiempoInicioTest;
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
}
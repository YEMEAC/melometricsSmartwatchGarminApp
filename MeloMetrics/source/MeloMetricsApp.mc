using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Sensor as Snsr;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

//las propiedades de este enum son accesibles desde cualquier lugar solo hace falta escrir la propiedad
enum{

	// Colors
	WHITE = 16777215,
	LT_GRAY = 11184810,
	DK_GRAY = 5592405,
	BLACK = 0,
	RED = 16711680,
	DK_RED = 11141120,
	ORANGE = 16733440,
	YELLOW = 16755200,
	GREEN = 65280,
	DK_GREEN = 43520,
	BLUE = 43775,
	DK_BLUE = 255,
	PURPLE = 11141375,
	PINK = 16711935
}

class MeloMetricsApp extends App.AppBase {
	

	var heartRate;
	var speed;
	var vo2max;
	
	var activityrec;
	
	var oneMileWalkTestView;
	var oneMileWalkTestDelegate;
	var vo2maxSpeedView;
	var vo2maxSpeedDelegate;
		
    function initialize() {
    	resetVariables();
        AppBase.initialize();
    }
    
    function resetVariables(){
		oneMileWalkTestView = new OneMileWalkTestView();
		oneMileWalkTestDelegate = new OneMileWalkTestDelegate();
		vo2maxSpeedView = new Vo2maxSpeedView();
		vo2maxSpeedDelegate = new Vo2maxSpeedDelegate();

		speed=0.0d;
		heartRate=0;
					
	}

    //! Return the initial view of your application here
    function getInitialView() {
        return [  new Vo2maxSpeedView(),  new Vo2maxSpeedDelegate() ];
    }
    
    //! onStart() is called on application start up
    function onStart() {
    
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }
       
    
    function timerPantalla() {
    	if(testEnEjecucion==true && testDetenido==false){
			return timerFormat(tiempoDuracionTest-tiempoTestEnCurso());	
		}else if(testEnEjecucion==true && testDetenido==true){
			return timerFormat(tiempoDuracionTest-tiempoTestEnCursoDenido());
		}else{
			return timerFormat(0);
		}
    }
    
    //return cuando tiempo lleva denido el test
    function tiempoTestEnCursoDenido(){
    	return tiempoTestDetenido-tiempoInicioTest;
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
    		heartRate=sensor_info.heartRate;
    	}
    	
    	if(sensor_info.speed!=null){
    		speed=sensor_info.speed;
    	}
    	Ui.requestUpdate();
    	return true;
    }

}

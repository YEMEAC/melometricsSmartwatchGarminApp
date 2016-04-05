using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Sensor as Snsr;
using Toybox.Lang as Lang;
using Toybox.System as Sys;


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

	var testEnEjecucion;
	var	testDetenido;
	var mensajeTest;
	
	//runninIndex index
	var	maxHeartRate;
	var heartRateReserve;
	var restingHeartRate;
	var acumuladorRunningIndex;
	var estimacionRuninIndex;
	var mediaRunningIndex;
	var contadorRunningIndexMuestras;

	//constantes
	var heartRate;
	var speed;
	var vo2max;
	
	//variables para controlar tiempo/timer
	var tiempoInicioTest;
	var tiempoTestDetenido;
	var tiempoTestReanudado;
	//segundos que debe durar el test antes de tener suficientes muestras
	var tiempoDuracionTest;
	//segundos para hacer la media con mas muestrasdespues de tener la primera estimacion
	var tiempoDuracionTestMedia;
	var timerTest;
	var primeraMuestraRunningIndex;
	
	function resetVariables(){
		tiempoInicioTest=0;
		tiempoTestDetenido=0;
		tiempoTestReanudado=0;
		tiempoDuracionTest=5;
		tiempoDuracionTestMedia=5;
		
		testEnEjecucion=false;
		testDetenido=false;
		
	
		//running index stuff	
		primeraMuestraRunningIndex=true;
		maxHeartRate=186.0d;
		restingHeartRate=55.0d;
		heartRateReserve=0.0d;
		acumuladorRunningIndex=0.0d;
		contadorRunningIndexMuestras=0.0d;
		//heartRateReserve=0;
		//runninIndex=0.0d;
		
		
		speed=0.0d;
		heartRate=0;
		//vo2max=0.0d;
		
		mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest1);
					
	}
	
    function initialize() {
    	resetVariables();
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
    
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new MeloMetricsView(), new MeloMetricsDelegate() ];
    }
    
    function empezarTest(){
    	testEnEjecucion=true;
    	
    	Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest2);
    	 	
    	tiempoInicioTest=Time.now().value();
    	timerTest= new Timer.Timer();
    	timerTest.start(method(:timerRunningIndexCallback),tiempoDuracionTest*1000,false);
    	 	
    	System.println("Empezando test");
    }
    
    function detenerTest(){
    	testDetenido=true;
    	timerTest.stop();
    	tiempoTestDetenido=Time.now().value();
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest3);
    	System.println("Detener test");
    }
    
    function continuarTest(){
    	testDetenido=false;
    	tiempoTestReanudado=Time.now().value();
    	
    	//se reinicia el timer que llama a la funcion callback de finalizartest, al tiempo de duracion del test
		//se le resta se le resta el tiempo que el test llevaba ejecutandose
		if(primeraMuestraRunningIndex==true){
    		timerTest.start(method(:timerRunningIndexCallback),(tiempoDuracionTest -(tiempoTestDetenido-tiempoInicioTest))*1000,false);
    	}else{
    		timerTest.start(method(:timerRunningIndexCallback),(tiempoDuracionTestMedia -(tiempoTestDetenido-tiempoInicioTest))*1000,false);
    	}
    	
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest2);
    	System.println("Continuar test");
    }
    
    function finalizarTest(){
    	resetVariables();
    	System.println("Finalizar test");
    }
    
    function timerRunningIndexCallback(){	
    	System.println("Estimacion Running Index");
    	
    	heartRateReserve=maxHeartRate-restingHeartRate;	
    	//aux=current runnig heart rate as a percentage of hr reserve
    	var aux=(heartRate-restingHeartRate)/heartRateReserve;
    	var estimacionRuninIndex=speed/aux;
    	
		acumuladorRunningIndex=acumuladorRunningIndex+estimacionRuninIndex;
		contadorRunningIndexMuestras=contadorRunningIndexMuestras+1;
		mediaRunningIndex=acumuladorRunningIndex/contadorRunningIndexMuestras;
        
    	//yield an estimate of the maxium runnin speed - will be close to your vo2max running speed
    	
		System.println("max hr "+maxHeartRate);
		System.println("resting hr "+restingHeartRate);
		System.println("reserve hr "+heartRateReserve);
		System.println("current hr "+heartRate);
		System.println("percent. of hr reserve "+ aux);
		System.println("running index "+ mediaRunningIndex);

		primeraMuestraRunningIndex=false;
    	timerTest.start(method(:timerRunningIndexCallback),tiempoDuracionTestMedia*1000,false);
    	//finalizarTest();
    	//timerTest.stop();
    	Ui.requestUpdate();
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

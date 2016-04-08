using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

class Vo2maxSpeedView extends Ui.View {

	var app;
	//Vo2maxSpeed runninIndex index
	var	maxHeartRate;
	var heartRateReserve;
	var restingHeartRate;
	var acumuladorVo2maxSpeed;
	var estimacionVo2maxSpeed;
	var mediaVo2maxSpeed;
	var contadorVo2maxSpeedMuestras;
	var primeraMuestraVo2maxSpeed;
	
	//estado del test
	var testEnEjecucion;
	var	testDetenido;

	//variables para controlar tiempo/timer
	var tiempoInicioTest;
	var tiempoTestDetenido;
	var tiempoTestReanudado;
	//segundos que debe durar el test antes de tener suficientes muestras
	var tiempoDuracionTest;
	//segundos para hacer la media con mas muestrasdespues de tener la primera estimacion
	var tiempoDuracionTestMedia;
	var timerTest;
	
	var mensajeTest;
	
	function resetVariables(){
		//Vo2maxSpeed running index stuff	
		primeraMuestraVo2maxSpeed=true;
		maxHeartRate=186.0d;
		restingHeartRate=55.0d;
		heartRateReserve=0.0d;
		acumuladorVo2maxSpeed=0.0d;
		contadorVo2maxSpeedMuestras=0.0d;
		
		tiempoInicioTest=0;
		tiempoTestDetenido=0;
		tiempoTestReanudado=0;
		tiempoDuracionTest=5;
		tiempoDuracionTestMedia=5;
		
		testEnEjecucion=false;
		testDetenido=false;
		mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest1);
	}
	
    function initialize() {
    	app = App.getApp();
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.Vo2maxSpeedLayout(dc));
		
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
		View.onUpdate( dc );	
		pintarVista(dc);
    }
    
    function pintarVista(dc){
    	var numFont = 6; 	
    	var msgFontMedium = 3;	// Gfx.FONT_MEDIUM
		var msgFontSmall = 2;	// Gfx.FONT_MEDIUM
		var just = 5;		// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    	
    	var	X1 = 160;
		var	X2 = 60;
    	var Y1 = 43;
		var	Y2 = 127;
		  	
    	
    	if(mediaVo2maxSpeed!=null){
    		dc.setColor(GREEN, -1);
    		dc.drawText(X2, Y1, numFont, mediaVo2maxSpeed.format("%.2f"), just);
    	}else{
    		dc.setColor(RED, -1);
    		dc.drawText(X2, Y1, msgFontSmall, Ui.loadResource(Rez.Strings.esperando) , just);
    	}
    	
    	dc.setColor(WHITE, -1);
    	if(testEnEjecucion){
    		//sino esta ene ejecucion el sensor esta apagado y no puede hacer getinfo
			dc.drawText(X1, Y1, numFont, Snsr.getInfo().heartRate.toString(), just);
			dc.drawText(X1, Y2, numFont, Snsr.getInfo().speed.format("%.2f") , just);
		}else{
			dc.drawText(X1, Y1, numFont, "000", just);
			dc.drawText(X1, Y2, numFont, "00.00" , just);
		}
		
		if(primeraMuestraVo2maxSpeed==true){
			dc.drawText(X2, Y2, numFont, timerPantalla(), just);
		}else{
			dc.setColor(LT_GRAY, -1);
    		dc.drawText(X2, Y2, msgFontSmall, Ui.loadResource(Rez.Strings.estimacionContinua) , just);
		}
		
		dc.setColor(WHITE, -1);
    	if(testEnEjecucion==true){
			dc.drawText(105, 74, msgFontSmall, mensajeTest, just);
		}else{
			dc.drawText(105, 74, msgFontMedium, mensajeTest, just);
		}
		
		
		System.println(app.heartRate + " - " + app.speed + " - " + Activity.getActivityInfo().currentHeartRate );
    }

    
    function empezarTest(){
    	testEnEjecucion=true;
    	
    	Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
		
		//var options = { :name => "Vo2maxSpeed"  };
		//activityrec=ActivityRecording.createSession(options);
		//activityrec.start();
		
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest2);
    	 	
    	tiempoInicioTest=Time.now().value();
    	timerTest= new Timer.Timer();
    	timerTest.start(method(:timerVo2maxSpeedCallback),tiempoDuracionTest*1000,false);
    	 	
    	System.println("Empezando test Vo2maxSpeed");
    }
    
    //no hace bien la detencion cuando esta en modo de estiamcion continua
    function detenerTest(){
    	testDetenido=true;
    	timerTest.stop();
    	tiempoTestDetenido=Time.now().value();
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest3);
		//activityrec.stop();
		//activityrec.save();
    	System.println("Detener test");
    }
    
    function continuarTest(){
    	testDetenido=false;
    	tiempoTestReanudado=Time.now().value();
    	
    	//se reinicia el timer que llama a la funcion callback de finalizartest, al tiempo de duracion del test
		//se le resta se le resta el tiempo que el test llevaba ejecutandose
		if(primeraMuestraVo2maxSpeed==true){
    		timerTest.start(method(:timerVo2maxSpeedCallback),(tiempoDuracionTest -(tiempoTestDetenido-tiempoInicioTest))*1000,false);
    	}else{
    		timerTest.start(method(:timerVo2maxSpeedCallback),(tiempoDuracionTestMedia -(tiempoTestDetenido-tiempoInicioTest))*1000,false);
    	}
    	
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest2);
    	System.println("Continuar test");
    }
    
    function finalizarTest(){
    	resetVariables();
    	System.println("Finalizar test");
    }
    
    function timerVo2maxSpeedCallback(){	
    	System.println("Estimacion VO2Max Speed");
    	
    	var heartRateReserve=maxHeartRate-restingHeartRate;	
    	//aux=current runnig heart rate as a percentage of hr reserve
    	var aux=(heartRate-restingHeartRate)/heartRateReserve;
    	var estimacionVo2maxSpeed=speed/aux;
    	
		acumuladorVo2maxSpeed=acumuladorVo2maxSpeed+estimacionVo2maxSpeed;
		contadorVo2maxSpeedMuestras=contadorVo2maxSpeedMuestras+1;
		mediaVo2maxSpeed=acumuladorVo2maxSpeed/contadorVo2maxSpeedMuestras;
            	
		System.println("max hr "+maxHeartRate);
		System.println("resting hr "+restingHeartRate);
		System.println("reserve hr "+heartRateReserve);
		System.println("current hr "+heartRate);
		System.println("percent. of hr reserve "+ aux);
		System.println("Vo2maxSpeed "+ mediaVo2maxSpeed);

		primeraMuestraVo2maxSpeed=false;
    	timerTest.start(method(:timerVo2maxSpeedCallback),tiempoDuracionTestMedia*1000,false);
    	//finalizarTest();
    	//timerTest.stop();
    	Ui.requestUpdate();
    }
    
}

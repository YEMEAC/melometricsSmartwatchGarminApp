using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;
using Toybox.UserProfile as UserProfile;

//mirar http://www.brianmac.co.uk/vo2max.htm#vo2 para la docu hay una tabla sobre velocidades
//FALTA DESAROLLAR EL IMPUT DEL MAX HEARRATE!


//intentar que siga guardando el activity durante la estiamcion continua
//descartar activity si es test no esta completo

class Vo2maxSpeedView extends ParentView {

	var	maxHeartRate;
	var heartRateReserve;
	var restingHeartRate;
	var acumuladorVo2maxSpeed;
	var contadorVo2maxSpeedMuestras;
	
	
	 function initialize() {
    	app = App.getApp();
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){

		maxHeartRate=186.0d;	
		restingHeartRate=UserProfile.getProfile().restingHeartRate;
		heartRateReserve=0.0d;
		acumuladorVo2maxSpeed=0.0d;
		contadorVo2maxSpeedMuestras=0.0d;
		//tiempoDuracionTest=60.0*12.0;  //12 minutos
		tiempoDuracionTest=10;
		
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
		var just = 5;			// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    	
    	var	X1 = 160;
		var	X2 = 60;
    	var Y1 = 43;
		var	Y2 = 127;
		  	
    	
    	if(media!=null){
    		dc.setColor(GREEN, -1);
    		dc.drawText(X2, Y1, numFont, media.format("%.2f"), just);
    	}else{
    		dc.setColor(RED, -1);
    		dc.drawText(X2, Y1, msgFontSmall, Ui.loadResource(Rez.Strings.esperando) , just);
    	}
    	
    	dc.setColor(WHITE, -1);

		dc.drawText(X1, Y1, numFont, app.heartRate.format("%.0f"), just);
		dc.drawText(X1, Y2, numFont, app.speed.format("%.2f") , just);

		if(primeraMuestra){
			dc.drawText(65, 98, msgFontSmall, Ui.loadResource(Rez.Strings.timer) , just);
			dc.drawText(X2, Y2, numFont,meloMetricsTimer.tiempoTranscurridoCuentaAtras(tiempoDuracionTest), just);
		}else{
			dc.setColor(BLUE, -1);
    		dc.drawText(65, 98, msgFontSmall, Ui.loadResource(Rez.Strings.estimacionContinua) , just);
    		dc.setColor(WHITE, -1);
    		dc.drawText(X2, Y2, numFont,meloMetricsTimer.tiempoTranscurridoCuentaAlante(), just);
		}
		
		
		dc.setColor(WHITE, -1);
		if(testEnEjecucion && !testDetenido){
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.capturandoDatos), just);
		}else if (media!=null  && !testDetenido){
			dc.drawText(155, 74, msgFontMedium, Ui.loadResource(Rez.Strings.vo2maxSpeed), just);
		}else if(testDetenido){
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.tabToContinue), just);
		}else{
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.tabToStart), just);
		}
		
    }

    
    function empezarTest(){
    	testEnEjecucion=true;
    	
    	Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
		
		var options = { :name => "Vo2maxSpeed"  };
		activityrec=ActivityRecording.createSession(options);
		activityrec.start();
			 	
    	meloMetricsTimer.timer.stop();
		meloMetricsTimer.timer.start(method(:timerCallback),1*1000,true);

    	System.println("Empezando test Vo2maxSpeed");
    }
    
    //se puede pasar arriba creo
    function detenerTest(){
    	testDetenido=true;
		meloMetricsTimer.timer.stop();
		//por ahora no guardo el calculo continuo
	    if(primeraMuestra && activityrec.isRecording()){
			activityrec.stop();
			System.println("Detenido activity recording");
		}

    	System.println("Detener test");
    }
    
    function continuarTest(){
    	testDetenido=false;
    	meloMetricsTimer.timer.start(method(:timerCallback),1*1000,true);
    	if(primeraMuestra && activityrec.isRecording()){
    		activityrec.start();
    		System.println("Continuar grabando activity");
    	}
    	System.println("Continuar test");
    }
        
    function timerCallback(){	

		if(testEnEjecucion && !testDetenido){
			meloMetricsTimer.aumentarSegundos();
		}
			
		if((meloMetricsTimer.segundos() >= tiempoDuracionTest || !primeraMuestra) && testEnEjecucion && !testDetenido){
			System.println(meloMetricsTimer.segundos() + " -- " + tiempoDuracionTest);
	    	var heartRateReserve=maxHeartRate-restingHeartRate;	
	    	//aux=current runnig heart rate as a percentage of hr reserve
	    	var aux=(app.heartRate-restingHeartRate)/heartRateReserve;
	    	
	    	System.println("velocidad "+app.speed);	
	    	var velocidad = app.speed * 2.23694;
	    	var estimacionVo2maxSpeed=velocidad/aux; 
	    	
			acumuladorVo2maxSpeed=acumuladorVo2maxSpeed+estimacionVo2maxSpeed;
			contadorVo2maxSpeedMuestras=contadorVo2maxSpeedMuestras+1;
			media=acumuladorVo2maxSpeed/contadorVo2maxSpeedMuestras;
	        
	        //por ahora no guardo el calculo continuo
	        if(primeraMuestra && activityrec.isRecording()){
				activityrec.save();
				activityrec=null;
				System.println("Activity  Guardado ");
			}
	        
	        System.println("velocidad "+app.speed);	
			System.println("max hr "+maxHeartRate);
			System.println("resting hr "+restingHeartRate);
			System.println("reserve hr "+heartRateReserve);
			System.println("current hr "+app.heartRate);
			System.println("percent. of hr reserve "+ aux);
			System.println("percent. of hr reserve "+ aux);
			System.println("Vo2maxSpeed "+ media);
	
			primeraMuestra=false;
	    }

    	Ui.requestUpdate();
    }
}





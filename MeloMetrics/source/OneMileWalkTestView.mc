using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;


class OneMileWalkTestView extends ParentView {

	var genero;
	var edad;
	var peso;
	var heartRate;
	var distanciaRecorrer; 
	
	var acumulador;
	var contadorMuestras;
	var primeraMuestra;
	var media;
	
	
	
	var mensajeTest;
	
	 function initialize() {
	 
	 	
    	app = App.getApp();
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){
		
		genero=0.0d;
		edad=24.0d;
		peso=73.0d;
		heartRate=0.0d;
		
		primeraMuestra=true;
		media=0.0d;
		acumulador=0.0d;
		contadorMuestras=0.0d;
		
		//1 milla = 1.60934 km = 1609.34 m
		//distanciaRecorrer=1609.34d;
		distanciaRecorrer=20.34d;
		tiempoDuracionTest=1; //llamar timer cada segundo para comprobar la distancia
		
		
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
		  	
    	
    	if(media!=null){
    		dc.setColor(GREEN, -1);
    		dc.drawText(X2, Y1, numFont, media.format("%.2f"), just);
    	}else{
    		dc.setColor(RED, -1);
    		dc.drawText(X2, Y1, msgFontSmall, Ui.loadResource(Rez.Strings.esperando) , just);
    	}
    	
    	dc.setColor(WHITE, -1);
    	if(testEnEjecucion){
			dc.drawText(X1, Y1, numFont, app.heartRate.toString(), just);
			dc.drawText(X1, Y2, numFont, app.speed.format("%.2f") , just);
		}else{
			dc.drawText(X1, Y1, numFont, "000", just);
			dc.drawText(X1, Y2, numFont, "00.00" , just);
		}
		

		dc.drawText(X2, Y2, numFont, timerPantalla(), just);
		
		dc.setColor(WHITE, -1);
    	if(testEnEjecucion==true){
			dc.drawText(105, 74, msgFontSmall, mensajeTest, just);
		}else{
			dc.drawText(105, 74, msgFontMedium, mensajeTest, just);
		}
		
		if(Activity.getActivityInfo().elapsedDistance!=null){
			System.println("Distancia d activity recorrida " + Activity.getActivityInfo().elapsedDistance);
		}else{
			System.println("Distance null");
		}
    }

    
    function empezarTest(){
    	testEnEjecucion=true;
    	
 		Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
		Snsr.setEnabledSensors();
				
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest2);
    	 	
    	tiempoInicioTest=Time.now().value();
    	timerTest= new Timer.Timer();
    	timerTest.start(method(:timerCallback),tiempoDuracionTest*1000,false);
    	
    	//asegurar que no cuenta distancias anteriores
		//parece que no deja modificar el activity directamente mal asunto

		var options = { :name => "OneMileWalkTest"  };
		activityrec=ActivityRecording.createSession(options);
		activityrec.start();
	
    	System.println("Empezando test onemilewalk");
    }
    
    //no hace bien la detencion cuando esta en modo de estiamcion continua
    function detenerTest(){
    	testDetenido=true;
    	timerTest.stop();
    	tiempoTestDetenido=Time.now().value();
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest3);
		if(activityrec.isRecording()){
			activityrec.stop();
		}
    	System.println("Detener test");
    }
    
    function continuarTest(){
    	testDetenido=false;
    	tiempoTestReanudado=Time.now().value();
    	
    	timerTest.start(method(:timerCallback),tiempoDuracionTest*1000,false);
    	
    	mensajeTest = Ui.loadResource(Rez.Strings.mensajeTest2);
    	activityrec.start();
    	System.println("Continuar test");
    }
    
    function timerCallback(){	
    	
    	if(Activity.getActivityInfo().elapsedDistance != null && 
    		distanciaRecorrer<= Activity.getActivityInfo().elapsedDistance){    			
	    	
	    	var estimacion=app.speed;
	    	
			acumulador=acumulador+estimacion;
			contadorMuestras=contadorMuestras+1;
			media=media/contadorMuestras;
	            	
			
			System.println("current hr "+app.heartRate);
			System.println("estimacion onemilewalktest "+ media);
	
			primeraMuestra=false;
			activityrec.stop();
			activityrec.save();
		}else{
			if(Activity.getActivityInfo().elapsedDistance != null){
				var a=Activity.getActivityInfo().elapsedDistance.toFloat();
				var aux= distanciaRecorrer-a;
				System.println("Falta " + aux  + " por recorrer");
			}else{
				System.println("Falta " +distanciaRecorrer+ " por recorrer");
			}
			timerTest.start(method(:timerCallback),tiempoDuracionTest*1000,false);
		}
			
	    	Ui.requestUpdate();
    }
     
    function finalizarTest(){
    	resetVariables();
    	System.println("Finalizar test");
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





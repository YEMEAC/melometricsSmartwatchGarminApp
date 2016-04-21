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
	var distanciaARecorrer; 
	var distanciaFaltaRecorrer;
	var distanciaInicioActivity;
	var distanciaDetenerActivity;
	var distanciaContinuarActivity;
	
	var acumulador;
	var contadorMuestras;
	var contadorSegundos;	

		
	 function initialize() {
	 
	 	
    	app = App.getApp();
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){
		meloMetricsTimer= new MeloMetricsTimer();
		genero=1.0d;
		edad=24.0d;
		peso=73.0d;
		heartRate=0.0d;
		
		testEnEjecucion=false;
		testDetenido=false;
		tiempoInicioTest=0.0d;
		tiempoTestDetenido=0.0d;
		tiempoTestReanudado=0.0d;
		tiempoDuracionTest=1; //llamar timer cada segundo para comprobar la distancia
		
		//media=0.0d;
		acumulador=0.0d;
		contadorMuestras=0.0d;
		
		//distancia al comienzo del test para no tenerla en cuenta
		distanciaInicioActivity=0.0d;
		distanciaDetenerActivity=0.0d;
		distanciaContinuarActivity=0.0d;
		//1 milla = 1.60934 km = 1609.34 m
		//distanciaARecorrer=1.61d;
		distanciaARecorrer=0.05d;
		distanciaFaltaRecorrer=distanciaARecorrer;
		//distanciaARecorrer=20.34d;
		contadorSegundos=0;
		
	}
	
    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.OneMileWalkTestLayout(dc));	
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
		View.onUpdate( dc );	
		pintarVista(dc);
    }
    
    function pintarVista(dc){
    	System.println("pintar");
    	var numFont = 6; 	
    	var msgFontMedium = 3;	// Gfx.FONT_MEDIUM
		var msgFontSmall = 2;	// Gfx.FONT_MEDIUM
		var just = 5;		// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    	
    	var	X1 = 175;
		var	X2 = 65;
		var	X3 = 50;		
    	var Y1 = 27;
    	var	Y2 = 127;
    	var	Y3 = 74;
		 	
    	if(media!=null && !testEnEjecucion){
    		dc.setColor(GREEN, -1);
    		dc.drawText(X3+10, Y3, 6, media.format("%.2f"), just);
    	}
    	
    	dc.setColor(WHITE, -1);
    	//if(testEnEjecucion){
			dc.drawText(X1, Y1, numFont, app.heartRate.toString(), just);
			dc.drawText(X1, Y2, numFont, app.speed.format("%.2f") , just);
			dc.drawText(X2+4, Y2, numFont, meloMetricsTimer.tiempoTranscurrido(), just);
			dc.drawText(X3+4, Y1, numFont, distanciaFaltaRecorrer.format("%.2f"), just);
		//}else{
			//dc.drawText(X1, Y1, numFont, "000", just);
			//dc.drawText(X1, Y2, numFont, "00.0" , just);
			//dc.drawText(X2+4, Y2, numFont, "00:00", just);
			///dc.drawText(X3+4, Y1, numFont, distanciaARecorrer.format("%.2f"), just);
		//}
		
		if(testEnEjecucion){
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.recorreUnaMilla), just);	
    	}else if(testDetenido){
			dc.drawText(105, 74, msgFontMedium, Ui.loadResource(Rez.Strings.tabToRestart), just);
		}else if (media!=null){
			dc.drawText(155, 74, msgFontMedium, Ui.loadResource(Rez.Strings.vomax), just);
		}else{
			dc.drawText(105, 74, msgFontMedium, Ui.loadResource(Rez.Strings.tabToStart), just);
		}
		
    }

    
    function empezarTest(){
    	resetVariables();  	
 		Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
		//Snsr.setEnabledSensors();
		
		testEnEjecucion=true;
    
    	meloMetricsTimer.inicializar();
    	tiempoInicioTest=Time.now().value();
    	timerTest.start(method(:timerCallback),tiempoDuracionTest*1000,true);
    		
    	//asegurar que no cuenta distancias anteriores
		//parece que no deja modificar el activity directamente mal asunto

		var options = { :name => "OneMileWalkTest"  };
		activityrec=ActivityRecording.createSession(options);
		activityrec.start();
		distanciaInicioActivity=Activity.getActivityInfo().elapsedDistance;
		
    	System.println("Empezando test onemilewalk"  + Time.now().value());
    }
    
    //no hace bien la detencion cuando esta en modo de estiamcion continua
    function detenerTest(){
    	
    	testDetenido=true;
    	timerTest.stop();  
    	meloMetricsTimer.stop();
    	tiempoTestDetenido=Time.now().value();
    		
    	distanciaDetenerActivity=Activity.getActivityInfo().elapsedDistance;
		if(activityrec.isRecording()){
			activityrec.stop();
			System.println("Detenido activity recording");
		}
    	System.println("Detener test");
    }
    
    function continuarTest(){
    
    	testDetenido=false;
    	meloMetricsTimer.reStart();
    	tiempoTestReanudado=Time.now().value();
    	timerTest.start(method(:timerCallback),tiempoDuracionTest*1000,true);
    		
    	activityrec.start();
    	distanciaContinuarActivity=Activity.getActivityInfo().elapsedDistance;

    	System.println("Continuar test");
    }
    
    function timerCallback(){	
    	
    	if(0 >= distanciaFaltaRecorrerTest()){
    		timerTest.stop();   
    		meloMetricsTimer.stop(); 
			
	    	System.println("Peso "+peso);
			System.println("Edad "+edad);
			System.println("Genero "+genero);
			System.println("tiempoTestEnCurso "+tiempoTestEnCurso());
			System.println("Current hr "+app.heartRate);
	    	
	    	var segundos = meloMetricsTimer.segundos();
	    	var aux = 132.853 - 0.0769*peso - 0.3877*edad + 6.315*genero - 3.2649*(segundos/60) - 0.1565*app.heartRate;           	
			System.println("estimacion onemilewalktest "+ aux);
	
			activityrec.stop();
			activityrec.save();
			media=aux;
			testEnEjecucion=false;
		}else{
			System.println("Falta por recorrer " + distanciaFaltaRecorrer.format("%.2f") + " de " + distanciaARecorrer);
		}
		
	    Ui.requestUpdate();
    }
    
    function distanciaFaltaRecorrerTest(){
    	//parecido al calculo del tiempo con el timer en vo2maxspeed
		// /100 porque el activity trabaja con metros
		//((distanciaInicioActivity +(distanciaContinuarActivity-distanciaDetenerActivity)));
		var aux;
		if(media == null && testEnEjecucion == true && testDetenido==false){
    		aux=distanciaARecorrer - (Activity.getActivityInfo().elapsedDistance/1000);
    		if(aux<0){
    				distanciaFaltaRecorrer=0;
    		}else{
    			distanciaFaltaRecorrer = aux;
    		}
    	}else{
    		aux= 0.0d;
    	}
    	return aux;
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





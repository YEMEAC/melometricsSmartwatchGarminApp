using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;
using Toybox.UserProfile as UserProfile;


class OneMileWalkTestView extends ParentView {

	var genero;
	var edad;
	var peso;
	var distanciaARecorrer; 
	var distanciaFaltaRecorrer;
	var distanciaInicioActivity;
	var distanciaDetenerActivity;
	var distanciaContinuarActivity;
	
	var profile;

	 function initialize() {	 	 	
    	app = App.getApp();
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){
		
		profile = UserProfile.getProfile();
		if( profile != null ) {
            genero=profile.gender;
			edad=Time.Gregorian.info(Time.now(), Time.FORMAT_LONG).year - profile.birthYear;
			peso=profile.weight*0.0022;  //g to pounds
		}   
		
		System.println(profile.weight + " " + peso);
	
		//distancia al comienzo del test para no tenerla en cuenta por el activity
		distanciaInicioActivity=0.0d;
		distanciaDetenerActivity=0.0d;
		distanciaContinuarActivity=0.0d;
		//1 milla = 1.60934 km = 1609.34 m
		distanciaARecorrer=1.61d;
		//distanciaARecorrer=0.03d;
		distanciaFaltaRecorrer=distanciaARecorrer;
		tiempoDuracionTest=1;
		
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

		dc.drawText(X1, Y1, numFont, app.heartRate.format("%.0f"), just);
		dc.drawText(X1, Y2, numFont, app.speed.format("%.2f") , just);
			
		dc.drawText(X2+4, Y2, numFont, meloMetricsTimer.tiempoTranscurridoCuentaAlante(), just);
		dc.drawText(X3+4, Y1, numFont, distanciaFaltaRecorrer.format("%.2f"), just);
		
		if(testEnEjecucion){
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.recorreUnaMilla), just);	
    	}else if(testDetenido){
			dc.drawText(105, 74, msgFontMedium, Ui.loadResource(Rez.Strings.tabToRestart), just);
		}else if (media){
			dc.drawText(155, 74, msgFontMedium, Ui.loadResource(Rez.Strings.vomax), just);
		}else{
			dc.drawText(105, 74, msgFontMedium, Ui.loadResource(Rez.Strings.tabToStart), just);
		}
    }

    //una idea podria generar los activities con diferentes laps por ejecucion de test
	//si un test se detiene acabar el lap e iniciar otro con un nombre que indetifique 
	// que es una parada de un lap empezado y cuando se continue lo mismo pero con un nombre
	//que indique que es una continuación etc etc
	//tambien de la clase Toybox » Application » AppBase los ge y save properties a ver si quizas generan un archivo
	//que se pueda encontrar en el reloj
    function empezarTest(){
    	resetVariablesParent();
    	resetVariables();
    	 	
 		Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
		//Snsr.setEnabledSensors();
		
		testEnEjecucion=true;
    	
    	//tiempoInicioTest=Time.now().value();
    	
    	meloMetricsTimer.timer.stop();
		meloMetricsTimer.timer.start(method(:timerCallback),1*1000,true);
    	  		
    
		var options = { :name => "OneMileWalkTest"  };
		activityrec=ActivityRecording.createSession(options);
		activityrec.start();

		distanciaInicioActivity=Activity.getActivityInfo().elapsedDistance;
		
    	System.println("Empezando test onemilewalk"  + Time.now().value());
    	
    }
    
    //se puede pasar arriba creo
    function detenerTest(){
    	
    	testDetenido=true;

		meloMetricsTimer.timer.stop();
    	distanciaDetenerActivity=Activity.getActivityInfo().elapsedDistance;

	    if(primeraMuestra && activityrec.isRecording()){
			activityrec.stop();
			System.println("Detenido activity recording");
		}
    	System.println("Detener test");
    }
    
    //se puede pasar arriba una parte
    function continuarTest(){
    
    	testDetenido=false;
    	meloMetricsTimer.timer.start(method(:timerCallback),1*1000,true);
    	if(primeraMuestra && activityrec.isRecording()){
    		activityrec.start();
    		System.println("Continuar grabando activity");
    	}
    	
    	distanciaContinuarActivity=Activity.getActivityInfo().elapsedDistance;

    	System.println("Continuar test");
    }
    
    function timerCallback(){
    
    	 //se puede afinar mas esto si no llama a ++segundo al estar detenido no hace
		//falta restar el tiempo parado al de ejecucion
    	if(testEnEjecucion &&  !testDetenido){	
    		meloMetricsTimer.aumentarSegundos();
    	}
    	
    	if(0 >= distanciaFaltaRecorrerTest() && testEnEjecucion && !testDetenido){
    		//app.meloMetricsTimer.stop(); 
			testEnEjecucion=false;
	    	
			var minutos=meloMetricsTimer.contadorSegundos/60.0;
			// probado con exrx.net/Calculators/Rockport.html && brianmac.co.uk/rockport.htm && www.shapesense.com/fitness-exercise/calculators/vo2max-calculator.shtml
	    	var aux = 132.853 - 0.0769*peso - 0.3877*edad + 6.315*genero - 3.2649*minutos - 0.1565*app.heartRate;           	
			
			//por ahora no guardo el calculo continuo
	        if(primeraMuestra && activityrec.isRecording()){
				activityrec.save();
				activityrec=null;
				System.println("Activity  Guardado ");
			}

			media=aux;
			primeraMuestra=false;
	
			System.println("Peso "+peso);
			System.println("Edad "+edad);
			System.println("Genero "+genero);
			System.println("tiempo "+minutos + " seg" +meloMetricsTimer.contadorSegundos);
			System.println("pusalciones " + app.heartRate*0.1565 + " hearrate "+ app.heartRate);	
		}
		
		System.println("Falta por recorrer " + distanciaFaltaRecorrer.format("%.2f") + " de " + distanciaARecorrer);
	    Ui.requestUpdate();
    }
}





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
	var pesoPounds;
	var pesoGramos;
	var distanciaARecorrer; 
	var distanciaFaltaRecorrer;
	var distanciaInicioActivity;

	 function initialize() {	 	 	
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){	
		if( UserProfile.getProfile() != null ) {
            genero=UserProfile.getProfile().gender;
			edad=Time.Gregorian.info(Time.now(), Time.FORMAT_LONG).year - UserProfile.getProfile().birthYear;
			pesoPounds=UserProfile.getProfile().weight*0.00220462;  //g to pounds
			pesoGramos= UserProfile.getProfile().weight;
		}else{
			genero=0; edad=25; pesoPounds=154.5; pesoGramos=70000;
		
		}   
				
		System.println("Peso pounds " + pesoPounds + " peso gramos" + pesoGramos);
		System.println("Edad "+edad);
		System.println("Genero "+genero);
		
		//distancia al comienzo del test para no tenerla en cuenta por el activity
		distanciaInicioActivity=0.0d;
		//1 milla = 1.60934 km = 1609.34 m 
		distanciaARecorrer=1.61d;
		//distanciaARecorrer=0.03d;
		distanciaFaltaRecorrer=distanciaARecorrer;
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
		var just = 5;			// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    	
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
			dc.drawText(101, 74, msgFontSmall, Ui.loadResource(Rez.Strings.recorreUnaMillaCaminando), just);
		}else if (media){
			dc.drawText(155, 74, msgFontMedium, Ui.loadResource(Rez.Strings.vomax), just);
		}else{
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.tabToStart), just);
		}
    }

    function empezarTest(){
    	empezarTestParent();
    	resetVariables();  		
		var options = { :name => "OneMileWalkTest"  };
		activityrec=ActivityRecording.createSession(options);
		activityrec.start();

		distanciaInicioActivity=Activity.getActivityInfo().elapsedDistance;
    	System.println("Empezando test onemilewalk"  + Time.now().value());
    }
    
    
    function timerCallback(){
    
    	meloMetricsTimer.aumentarSegundos();
    	
    	if(0 >= distanciaFaltaRecorrerTest() && testEnEjecucion){
			testEnEjecucion=false;
	    	
			var minutos=meloMetricsTimer.contadorSegundos/60.0;
			// probado con exrx.net/Calculators/Rockport.html && brianmac.co.uk/rockport.htm && www.shapesense.com/fitness-exercise/calculators/vo2max-calculator.shtml
			//recordar que para el segundo link en el campo de texto pone 10 seconds pulse entonces tengo que hacer (hearRatequesalgaAqui/60)*10
	    	var aux = 132.853 - 0.0769*pesoPounds - 0.3877*edad + 6.315*genero - 3.2649*minutos - 0.1565*app.heartRate;           	
			
	        if(activityrec.isRecording()){
				activityrec.save();
				activityrec=null;
				System.println("Activity  Guardado ");
			}

			media=aux;
			meloMetricsTimer.timer.stop();
			System.println("Peso pounds " + pesoPounds + " peso gramos" + pesoGramos);
			System.println("Edad "+edad);
			System.println("Genero "+genero);
			System.println("tiempo "+minutos + " seg" +meloMetricsTimer.contadorSegundos);
			System.println("hearrate "+ app.heartRate);	
		}
		
		System.println("Falta por recorrer " + distanciaFaltaRecorrer.format("%.2f") + " de " + distanciaARecorrer);
	    Ui.requestUpdate();
    }
}





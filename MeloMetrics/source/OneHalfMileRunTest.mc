using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

class OneHalfMileRunTest extends ParentView {

	var distanciaARecorrer; 
	var distanciaFaltaRecorrer;
	var distanciaInicioActivity;
	
	 function initialize() {	 	 	
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){	
		//distancia al comienzo del test para no tenerla en cuenta por el activity
		distanciaInicioActivity=0.0d;
		//1 milla = 1,60934 km = 1609,34 m  1,5 milla = 2,41402 km = 2414,02 m
		distanciaARecorrer=2.41d;
		//distanciaARecorrer=0.04d;
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
			dc.drawText(101, 74, msgFontSmall, Ui.loadResource(Rez.Strings.correUnaMillaYMediaCorriendo), just);	
		}else if (media){
			dc.drawText(155, 74, msgFontMedium, Ui.loadResource(Rez.Strings.vomax), just);
		}else{
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.tabToStart), just);
		}
    }


    function empezarTest(){
    	empezarTestParent();
    	resetVariables();    		  		
		var options = { :name => "OneHalfMileRunTest"  };
		activityrec=ActivityRecording.createSession(options);
		activityrec.start();

		distanciaInicioActivity=Activity.getActivityInfo().elapsedDistance;
    	System.println("Empezando test OneHalfMileRunTest"  + Time.now().value());
    }
    
    function timerCallback(){
    
    	meloMetricsTimer.aumentarSegundos();

    	if(0 >= distanciaFaltaRecorrerTest()){
			testEnEjecucion=false;
	    	
	    	//comparada con http://www.exrx.net/Calculators/OneAndHalf.html http://www.shapesense.com/fitness-exercise/calculators/vo2max-calculator.shtml da lo mismo
			var minutos=meloMetricsTimer.contadorSegundos/60.0;
			
	    	var aux = 483.0d;
	    	var auxdos = 3.5d;
	    	media = (aux/minutos) +3.5;         	
			
	        if(activityrec.isRecording()){
				activityrec.save();
				activityrec=null;
				System.println("Activity  Guardado ");
			}

			meloMetricsTimer.timer.stop();
			System.println("tiempo "+minutos + " segundos " +meloMetricsTimer.contadorSegundos);
			System.println("pusalciones " + app.heartRate*0.1565 + " hearrate "+ app.heartRate);	
		}
		System.println("Falta por recorrer " + distanciaFaltaRecorrer.format("%.2f") + " de " + distanciaARecorrer);
	    Ui.requestUpdate();
    }
}

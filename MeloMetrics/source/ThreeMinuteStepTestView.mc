using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

class ThreeMinuteStepTestView extends Ui.View {

	var app;
	
    function initialize() {
    	app = App.getApp();
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.OneMileWalkTestLayout(dc));
		
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
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
		  	
    	
    	if(app.mediaVo2maxSpeed!=null){
    		dc.setColor(GREEN, -1);
    		dc.drawText(X2, Y1, numFont, app.mediaVo2maxSpeed.format("%.2f"), just);
    	}else{
    		dc.setColor(RED, -1);
    		dc.drawText(X2, Y1, msgFontSmall, Ui.loadResource(Rez.Strings.esperando) , just);
    	}
    	
    	dc.setColor(WHITE, -1);
		dc.drawText(X1, Y1, numFont, app.heartRate.toString(), just);
		dc.drawText(X1, Y2, numFont, app.speed.format("%.2f") , just);
		
		if(app.primeraMuestraVo2maxSpeed==true){
			dc.drawText(X2, Y2, numFont, app.timerPantalla(), just);
		}else{
			dc.setColor(LT_GRAY, -1);
    		dc.drawText(X2, Y2, msgFontSmall, Ui.loadResource(Rez.Strings.estimacionContinua) , just);
		}
		
		dc.setColor(WHITE, -1);
    	if(app.testEnEjecucion==true){
			dc.drawText(105, 74, msgFontSmall, app.mensajeTest, just);
		}else{
			dc.drawText(105, 74, msgFontMedium, app.mensajeTest, just);
		}
		
		
		System.println(app.heartRate + " - " + app.speed + " - " + Activity.getActivityInfo().currentHeartRate );
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
}

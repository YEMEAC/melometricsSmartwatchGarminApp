using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

class MainView extends Ui.View   {
	var app;
    function initialize() {
    	app = App.getApp();
    	//resetVariables();
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
}

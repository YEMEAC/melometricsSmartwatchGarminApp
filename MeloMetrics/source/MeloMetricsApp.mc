using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Sensor as Snsr;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;

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
	

	var heartRate;
	var speed;
	var vo2max;
	
	var activityrec;
	
	var oneMileWalkTestView;
	var vo2maxSpeedView;
	var threeMinuteStepTestView;
	
	//var meloMetricsTimer;
	//var timerTest;
		
    function initialize() {
    	//meloMetricsTimer= new MeloMetricsTimer();
		//timerTest= new Timer.Timer();
					
    	resetVariables();
        AppBase.initialize();
    }
    
    function resetVariables(){
		oneMileWalkTestView = new OneMileWalkTestView();
		threeMinuteStepTestView = ThreeMinuteStepTestView;
		vo2maxSpeedView = new Vo2maxSpeedView();
		
		speed=0.0d;
		heartRate=0.0d;

	}

    //! Return the initial view of your application here
    function getInitialView() {
    	var index=2;
        return [   oneMileWalkTestView, new MainDelegate(index,oneMileWalkTestView) ];
    }
    
    //! onStart() is called on application start up
    function onStart() {
    
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }
       
    
    
    

}

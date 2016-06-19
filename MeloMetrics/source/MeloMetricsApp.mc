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
	
	var oneMileWalkTestView;
	var vo2maxSpeedView;
	var oneHalfMileRunTest;
	var mainDelegate;
	
	
	var keyboardDelegate;
	var keyboardView;
		
    function initialize() {
    	resetVariables();
        AppBase.initialize();
    }
    
    function resetVariables(){
    
    	vo2maxSpeedView = new Vo2maxSpeedView(); 					//vista 0
    	keyboardView = new KeyboardView();							//vista 1
		oneMileWalkTestView = new OneMileWalkTestView();			//vista 2
		oneHalfMileRunTest = new OneHalfMileRunTest();				//vista 3
		var index=2; //vista inicial

		mainDelegate = new MainDelegate(index,oneMileWalkTestView);
		keyboardDelegate = new KeyboardDelegate();
		
		speed=0.0d;
		heartRate=0.0d;
	
	}

    //! Return the initial view of your application here
    function getInitialView() {
    	
        return [   oneMileWalkTestView, mainDelegate ];
    }
    
    //! onStart() is called on application start up
    function onStart() {
    
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    	System.println("Saliendo de la aplicacion");
    	Sys.exit();
    }
       
    
    
    

}

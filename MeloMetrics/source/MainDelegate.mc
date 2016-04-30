using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;


//behavior extiende a inputdelegate por lo atnto tiene sus metodos
//si el compartamientode lso delegate no cambia quizas al final solo haga falta uno
class MainDelegate extends Ui.BehaviorDelegate {

	var app;
	var view;
	var index;

	 function initialize(Nindex, viewQueControla) {
   		//guardo un apuntadoe a al view que controla y a la aplicacion
		app = App.getApp();
   		view=viewQueControla;
   		index=Nindex;
        BehaviorDelegate.initialize();
    }


	function onSwipe(evt) {
	        if (evt.getDirection() == Ui.SWIPE_LEFT){
	            onNextPage();
	        }else if (evt.getDirection() == Ui.SWIPE_RIGHT){
	            onPreviousPage();
	        }
    	}
    	
    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new MeloMetricsMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }
    
         
        function onTap( evt ){
        
        	if(Activity.getActivityInfo().elapsedDistance!=null){
	        	if(view.testEnEjecucion==false){
	        		view.empezarTest();
	        	}else if (view.testEnEjecucion==true && view.testDetenido==false){
	        		view.detenerTest();
	        	}else if (view.testEnEjecucion==true && view.testDetenido==true){
	        		view.continuarTest();
	        	}
	        }else{
	        	System.println("El seguidor de actividad debe estar activado para ejecutar la aplicación");
	        }
        	
	        return true; 
        }

        function onHold( evt ){
        	 Ui.pushView(new Rez.Menus.MainMenu(), new MeloMetricsMenuDelegate(), Ui.SLIDE_UP);
	        return true; 
        }


        function onNextPage(){
			index=(index + 1) % 4;
			
        	Ui.switchToView(getView(), getDelegate(), Ui.SLIDE_LEFT);
    	}

    	function onPreviousPage() {
        	index = index - 1;
	        if (index < 0){
	            index = 4;
	        }
	        index = index % 4;
	        Ui.switchToView(getView(index), getDelegate(), Ui.SLIDE_RIGHT);
    	}

	   function getView(){
        
		view.resetVariablesParent();
    	view.resetVariables();
    	view.meloMetricsTimer.timer.stop();
    	
        if(0 == index)
        {
			System.println("Cambiando a visto: " + "vo2maxSpeedView" );
			view = app.vo2maxSpeedView;
			
        }
        else if(1 == index)
        {
			System.println("Cambiando a visto: " + "oneMileWalkTestView" );
            view = app.oneMileWalkTestView;
			
        }
        else if(2 == index)
        {
			
            System.println("Cambiando a visto: " + "OneHalfMileRunTest" );
            view = app.oneHalfMileRunTest;
        }
        else
        {

			app.onStop();
             
        }
		
		view.resetVariablesParent();
    	view.resetVariables();
        return view;
    }

    function getDelegate()
    {
    
       //deberia retocar esto para que use el mismo delegate todo el rato
       //var viewTransicion = getView(index);
       //var delegate = new MainDelegate(index,viewTransicion);
      // return delegate;
		//en realidad me estoy devolviendo a mi mismo pero este lengua no comprende un this
		return	app.mainDelegate;
    }

}
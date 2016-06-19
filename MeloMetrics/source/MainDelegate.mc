using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;


//behavior extiende a inputdelegate por lo atnto tiene sus metodos
class MainDelegate extends Ui.BehaviorDelegate {

	//apuntador a la applicacion
	var app;
	
	//apuntador a la view e index de la view actual
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
        return true;
    }
    
         
        function onTap( evt ){
        
        	if(Activity!=null && Activity.getActivityInfo()!= null &&
        	Activity.getActivityInfo().elapsedDistance!=null && Activity.getActivityInfo().currentSpeed!=null
        	&& Activity.getActivityInfo().currentHeartRate!=null){
	        	if(view.testEnEjecucion==false){
	        		view.empezarTest();
	        	}else if (view.testEnEjecucion==true && view.testDetenido==false && view instanceof Vo2maxSpeedView){
	        		view.detenerTest();
	        	}else if (view.testEnEjecucion==true && view.testDetenido==true && view instanceof Vo2maxSpeedView){
	        		view.continuarTest();
	        	}
	        	//elapse distance del activity no se puede parar asi que los test de distancia no tienen esa opcion
	        }else{
	        	System.println("El seguidor de actividad debe estar activado para ejecutar la aplicación");
	        }
        	
	        return true; 
        }

        function onHold( evt ){
	        return true; 
        }


        function onNextPage(){
        	if(index == 0) {
        		index=2; //para que salte el input del max hearrate a la vuelta
        	}else{
				index=(index + 1) % 5;
			}
			
        	Ui.switchToView(getView(), getDelegate(), Ui.SLIDE_LEFT);
    	}

    	function onPreviousPage() {
        	index = index - 1;
	        if (index < 0){
	            index = 5;
	        }
	        index = index % 5;
	        Ui.switchToView(getView(), getDelegate(), Ui.SLIDE_RIGHT);
    	}

	   function getView(){
        
        //reset view antes de dejarlo ai casos k falla esto probarlo MAS ATENCION
		System.println(index);
		
		if (!(view instanceof KeyboardView)){ // ABRIA QUE AÑADIR SI LA SIGUIENTE es la 3 para cuadno va del leboard hacia adelante
			//pero entonces cuando vas del ultimo test al hacia a tras no entraria
			//solo se me ocurre definir los metodos vacios en la de keyboardview
			view.resetVariablesParent();
    		view.resetVariables();
    		view.meloMetricsTimer.timer.stop();
    		System.println("paso" );
    	}
    	
        if(0 == index)
        {
			System.println("Cambiando a vista: " + "vo2maxSpeedView" );
			view = app.vo2maxSpeedView;
			
        }
        else if(1 == index)
        {
			System.println("Cambiando a vista: " + "keyboardView" );
			view = app.keyboardView;
			
        }
        else if(2 == index)
        {
			System.println("Cambiando a vista: " + "oneMileWalkTestView" );
            view = app.oneMileWalkTestView;
			
        }
        else if(3 == index)
        {	
            System.println("Cambiando a vista: " + "OneHalfMileRunTest" );
            view = app.oneHalfMileRunTest;
        }
        else
        {//index =4
			app.onStop();          
        }
		
		//reset de la view nueva
		if (!(view instanceof KeyboardView)){
			view.resetVariablesParent();
    		view.resetVariables();
    		view.meloMetricsTimer.timer.stop();
    	}
        return view;
    }

    function getDelegate()
    {
    	//app tiene un apuntar al mismo main delegate que lo esta llamando para hacerse un get asi mismo
		//una unica instancia de delegate
		if(index == 1){
			return app.keyboardDelegate;
		}
		return	app.mainDelegate;
    }

}
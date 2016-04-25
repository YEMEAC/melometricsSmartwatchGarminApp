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
	var mIndex;



	 function initialize(index, viewQueControla) {
   		//guardo un apuntadoe a al view que controla y a la aplicacion
		app = App.getApp();
   		view=viewQueControla;
   		mIndex=index;
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
        	//mIndex = (mIndex + 1) % 4;
        	//con esta implementacion de next y previous se vuelve a crear delegates siempre lo he 
			//lo he cambiado para que no pase asi con los view y podamos guardar el estado de una pantalla
			//quizas mas adelante combiene hacerlo mismo con los delegate

			//modifique lo del index para que nos e machaque el que ya tiene el delegate
			//porque daba igual ya que siempre se ira creando uno nuevo
			//pero si al final los reutilizo lo correcto es que mantengan su index
			var newIndex=(mIndex + 1) % 4;
        	Ui.switchToView(getView(newIndex), getDelegate(newIndex), Ui.SLIDE_LEFT);
    	}

    	function onPreviousPage() {
        mIndex = mIndex - 1;
	        if (mIndex < 0){
	            mIndex = 3;
	        }
	        mIndex = mIndex % 4;
	        Ui.switchToView(getView(mIndex), getDelegate(mIndex), Ui.SLIDE_RIGHT);
    	}

	   function getView(index)
    {
        
		view.resetVariablesParent();
    	view.resetVariables();
    	
        if(0 == index)
        {
            //view = new MainView(mIndex);
			System.println("Cambiando a visto: " + "mainView" );
			view = app.mainView;
			
        }
        else if(1 == index)
        {
            //view = new Vo2maxSpeedView(mIndex);
			System.println("Cambiando a visto: " + "vo2maxSpeedView" );
			view = app.vo2maxSpeedView;
			
        }
        else if(2 == index)
        {
            //view = new OneMileWalkTestView(mIndex);
			System.println("Cambiando a visto: " + "oneMileWalkTestView" );
            view = app.oneMileWalkTestView;
            
        }
        else
        {
            //view = new ThreeMinuteStepTestView(mIndex);
			System.println("Cambiando a visto: " + "threeMinuteStepTestView" );
            view = app.threeMinuteStepTestView;
             
        }
		
		view.resetVariablesParent();
    	view.resetVariables();
        return view;
    }

    function getDelegate(index)
    {
    
    	//deberia retocar esto para que use el mismo delegate todo el rato
       var viewTransicion = getView(index);
       var delegate = new MainDelegate(index,viewTransicion);
       return delegate;
    }

}
using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

//behavior extiende a inputdelegate por lo atnto tiene sus metodos
class MainDelegate2 extends Ui.BehaviorDelegate {

	var app;
	var vo2maxSpeedView;
	var mIndex;

    function initialize(index) {
   		//guardo un apuntadoe a al view que controla y a la aplicacion
		app = App.getApp();
   		MainView=app.vo2maxSpeedView;
   		mIndex=index;
        BehaviorDelegate.initialize();
    }


	 // When a menu behavior occurs, onMenu() is called.
    // @return [Boolean] true if handled, false otherwise
    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new MeloMetricsMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }
    
        function getView(mIndex)
    {
        var view;

        if(0 == mIndex)
        {
            view = new MainView(mIndex);
        }
        else if(1 == mIndex)
        {
            view = new Vo2maxSpeedView(mIndex);
        }
        else if(2 == mIndex)
        {
            view = new OneMileWalkTestView(mIndex);
        }
        else
        {
            view = new ThreeMinuteStepTestView(mIndex);
        }

        return view;
    }

    function getDelegate(mIndex)
    {
       var delegate;

        if(0 == mIndex)
        {
            delegate = new MainDelegate(mIndex);
        }
        else if(1 == mIndex)
        {
            delegate = new Vo2maxSpeedDelegate(mIndex);
        }
        else if(2 == mIndex)
        {
            delegate = new OneMileWalkTestDelegate(mIndex);
        }
        else
        {
            delegate = new ThreeMinuteStepTestDelegate(mIndex);
        }

        return delegate;
    }
      
    //Metodos de behavior

        function onNextPage(){
        	mIndex = (mIndex + 1) % 4;
        	Ui.switchToView(getView(mIndex), getDelegate(mIndex), Ui.SLIDE_LEFT);
    	}

    	function onPreviousPage() {
        mIndex = mIndex - 1;
	        if (mIndex < 0){
	            mIndex = 3;
	        }
	        mIndex = mIndex % 4;
	        Ui.switchToView(getView(mIndex), getDelegate(mIndex), Ui.SLIDE_RIGHT);
    	}

    //metodos de inputdelegate
        // Screen swipe event
        // @param evt Event
        function onSwipe(evt) {
	        if (evt.getDirection() == Ui.SWIPE_LEFT){
	            onNextPage();
	        }else if (evt.getDirection() == Ui.SWIPE_RIGHT){
	            onPreviousPage();
	        }
    	}
    	
        // Click event
        // @param evt Event object with click information
        // @return true if handled, false otherwise
        function onTap( evt ){
        	if(vo2maxSpeedView.testEnEjecucion==false){
        		vo2maxSpeedView.empezarTest();
        	}else if (vo2maxSpeedView.testEnEjecucion==true && vo2maxSpeedView.testDetenido==false){
        		vo2maxSpeedView.detenerTest();
        	}else if (vo2maxSpeedView.testEnEjecucion==true && vo2maxSpeedView.testDetenido==true){
        		vo2maxSpeedView.continuarTest();
        	}
        	
	        return true; 
        }

        // Screen hold event. Sent if user is touching
        // the screen
        // @param evt Event object with hold information
        // @return true if handled, false otherwise
        function onHold( evt ){
        	 Ui.pushView(new Rez.Menus.MainMenu(), new MeloMetricsMenuDelegate(), Ui.SLIDE_UP);
	        return true; 
        }
}
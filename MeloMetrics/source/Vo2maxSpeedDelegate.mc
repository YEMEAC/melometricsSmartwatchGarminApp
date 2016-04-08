using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

//behavior extiende a inputdelegate por lo atnto tiene sus metodos
class Vo2maxSpeedDelegate extends Ui.BehaviorDelegate {

	var app;
	var vo2maxSpeedView;

    function initialize() {
   		//guardo un apuntadoe a al view que controla y a la aplicacion
		app = App.getApp();
   		vo2maxSpeedView=app.vo2maxSpeedView;
   		
        BehaviorDelegate.initialize();
    }


	 // When a menu behavior occurs, onMenu() is called.
    // @return [Boolean] true if handled, false otherwise
    function onMenu() {
        Ui.pushView(new Rez.Menus.MainMenu(), new MeloMetricsMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }
    
    
    
    //Metodos de behavior

	// When a next page behavior occurs, onNextPage() is called.
    // @return [Boolean] true if handled, false otherwise
    function onNextPage(){}

    // When a previous page behavior occurs, onPreviousPage() is called.
    // @return [Boolean] true if handled, false otherwise
    function onPreviousPage(){}

    // When a back behavior occurs, onBack() is called.
    // @return [Boolean] true if handled, false otherwise
    function onBack(){}

    // When a next mode behavior occurs, onNextMode() is called.
    // @return [Boolean] true if handled, false otherwise
    function onNextMode(){}

    // When a previous mode behavior occurs, onPreviousMode() is called.
    // @return [Boolean] true if handled, false otherwise
    function onPreviousMode(){}
    
    
    //metodos de inputdelegate

        // Click event
        // @param evt Event object with click information
        // @return true if handled, false otherwise
        function onTap( evt ){
        	if(Vo2maxSpeedDelegateView.testEnEjecucion==false){
        		Vo2maxSpeedDelegateView.empezarTest();
        	}else if (Vo2maxSpeedDelegateView.testEnEjecucion==true && Vo2maxSpeedDelegateView.testDetenido==false){
        		app.detenerTest();
        	}else if (Vo2maxSpeedDelegateView.testEnEjecucion==true && Vo2maxSpeedDelegateView.testDetenido==true){
        		Vo2maxSpeedDelegateView.continuarTest();
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

        // Screen release. Sent after an onHold
        // @param evt Event object with hold information
        // @return true if handled, false otherwise
        function onRelease( evt ){}

        // Screen swipe event
        // @param evt Event
        function onSwipe( evt ){}
        
           	// Key event
        // @param evt KEY_XXX enum value
        // @return true if handled, false otherwise
        function onKey( evt ){
        	/*if(Ui.KEY_ENTER == event.getKey()) {

			onEnter();
		}
		else if(Ui.KEY_ESC == event.getKey()) {

			onEscape();
      	}
      	else if(Ui.KEY_MENU == event.getKey()) {

			onMenu();
      	}
		else if(Ui.KEY_UP == event.getKey()) {

			onDown();
		}
		else if(Ui.KEY_DOWN == event.getKey()) {

			onUp();
		}
      	else if(Ui.KEY_POWER == event.getKey()) {

			onPower();
		}*/
		return true;
        }

}
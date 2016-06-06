using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;



class KeyboardDelegate extends Ui.InputDelegate {

    function onKey(key) {
        if(key.getKey() == Ui.KEY_UP) {
        	
        	var testVali = 186;
        	var np = new Ui.NumberPicker( Ui.NUMBER_PICKER_CALORIES, testVali );
            Ui.pushView( np, new KeyboardListener(), Ui.SLIDE_IMMEDIATE );
        }
    }

    function onTap(evt) {
       		var hearRatePorDefecto = 186;
        	var np = new Ui.NumberPicker( Ui.NUMBER_PICKER_CALORIES, hearRatePorDefecto );
            Ui.pushView( np, new KeyboardListener(), Ui.SLIDE_IMMEDIATE );
    }
    
     function initialize(){
     	
     }
     
     function onSwipe(evt) {
	        if (evt.getDirection() == Ui.SWIPE_LEFT){
	            app.mainDelegate.onNextPage();
	        }else if (evt.getDirection() == Ui.SWIPE_RIGHT){
	             app.mainDelegate.onPreviousPage();
	        }
    	}

}

class KeyboardListener extends Ui.NumberPickerDelegate   {
    
    function onNumberPicked(value){
    	App.getApp().vo2maxSpeedView.setMaxHeartRate(value);
        App.getApp().mainDelegate.onPreviousPage();
    }
}
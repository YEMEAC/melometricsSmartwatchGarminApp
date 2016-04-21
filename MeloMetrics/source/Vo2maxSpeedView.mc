using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Snsr;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.Activity as Activity;


class ParentView extends Ui.View{

	var app;
	//variables para controlar tiempo/timer
	var tiempoInicioTest;
	var tiempoTestDetenido;
	var tiempoTestReanudado;
	//segundos que debe durar el test antes de tener suficientes muestras
	var tiempoDuracionTest;
	var timerTest;
	
	var meloMetricsTimer; 
	
	//estado del test
	var testEnEjecucion;
	var	testDetenido;
	var primeraMuestra=true;
	var activityrec;
	
	//estimacidor del test a mostrar en pantalla
	var media;


function resetVariablesParent(){
		tiempoInicioTest=0;
		tiempoTestDetenido=0;
		tiempoTestReanudado=0;
		tiempoDuracionTest=5;
		
		testEnEjecucion=false;
		testDetenido=false;
		tiempoTestReanudado=false;
	
		timerTest= new Timer.Timer();
}

function timerPantalla() {
    	if(testEnEjecucion==true && testDetenido==false){
    		if(tiempoDuracionTest>1) { //cuenta atras   			
				return timerFormat(tiempoDuracionTest-tiempoTestEnCurso());	
			}else{ //cuenta hacia delante
				return timerFormat(tiempoTestEnCurso());
			}
		}else if(testEnEjecucion==true && testDetenido==true){
			if(tiempoDuracionTest>1) {
				return timerFormat(tiempoDuracionTest-tiempoTestEnCursoDenido());
			}else{
				return timerFormat( tiempoTestEnCurso()-(Time.now().value()-tiempoTestDetenido));
			}
		}
			return timerFormat(0);	
    }
    
    
    function tiempoTestEnCurso(){
    	//si el test se ha denido 
    	if(tiempoTestDetenido>0 && tiempoTestReanudado>0){
    		//el tiempo que lleva en curso es al actual - el de inicio pero sumandole el tiempo que estuvo parado
			//para que no cuente el tiempo parado como si hubiera estado en curso
			System.println("aki111");
    		return Time.now().value() - (tiempoInicioTest+(tiempoTestReanudado-tiempoTestDetenido));
    	}else{
    		System.println("akiiii222");
    		//si nunca se pa detenido es al actual - el inicio
    		return Time.now().value() - tiempoInicioTest;
    	}
    }
    
      //return cuando tiempo lleva denido el test
    function tiempoTestEnCursoDenido(){
    	return tiempoTestDetenido-tiempoInicioTest;
    }
    
    function timerFormat(time) {
    	var hour = time / 3600;
		var min = (time / 60) % 60;
		var sec = time % 60;
		if(0 < hour) {
			return format("$1$:$2$:$3$",[hour.format("%01d"),min.format("%02d"),sec.format("%02d")]);
		}
		else {
			return format("$1$:$2$",[min.format("%02d"),sec.format("%02d")]);
		}
    }

}

class Vo2maxSpeedView extends ParentView {

	//Vo2maxSpeed runninIndex index
	var	maxHeartRate;
	var heartRateReserve;
	var restingHeartRate;
	var acumuladorVo2maxSpeed;
	var contadorVo2maxSpeedMuestras;
	
	var mensajeTest;
	
	 function initialize() {
    	app = App.getApp();
    	resetVariablesParent();
    	resetVariables();
        View.initialize();
    }
    
	function resetVariables(){
		//Vo2maxSpeed running index stuff	
		maxHeartRate=186.0d;
		restingHeartRate=55.0d;
		heartRateReserve=0.0d;
		acumuladorVo2maxSpeed=0.0d;
		contadorVo2maxSpeedMuestras=0.0d;
		
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
    
    function pintarVista(dc){
    	var numFont = 6; 	
    	var msgFontMedium = 3;	// Gfx.FONT_MEDIUM
		var msgFontSmall = 2;	// Gfx.FONT_MEDIUM
		var just = 5;		// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
    	
    	var	X1 = 160;
		var	X2 = 60;
    	var Y1 = 43;
		var	Y2 = 127;
		  	
    	
    	if(media!=null){
    		dc.setColor(GREEN, -1);
    		dc.drawText(X2, Y1, numFont, media.format("%.2f"), just);
    	}else{
    		dc.setColor(RED, -1);
    		dc.drawText(X2, Y1, msgFontSmall, Ui.loadResource(Rez.Strings.esperando) , just);
    	}
    	
    	dc.setColor(WHITE, -1);
    	if(testEnEjecucion || !primeraMuestra){
    		//sino esta ene ejecucion el sensor esta apagado y no puede hacer getinfo
			dc.drawText(X1, Y1, numFont, app.heartRate.toString(), just);

		}else{
			dc.drawText(X1, Y1, numFont, "000", just);
			dc.drawText(X1, Y2, numFont, "00.00" , just);
		}
		
		if(testEnEjecucion || !primeraMuestra){	
			dc.drawText(X1, Y2, numFont, app.speed.format("%.2f") , just);
		}else{
			dc.drawText(X1, Y2, numFont, "00.00" , just);
		}
		
		if(primeraMuestra){
			dc.drawText(X2, Y2, numFont, timerPantalla(), just);
		}else{
			dc.setColor(LT_GRAY, -1);
    		dc.drawText(X2, Y2, msgFontSmall, Ui.loadResource(Rez.Strings.estimacionContinua) , just);
		}
		
		
		dc.setColor(WHITE, -1);
		if(testEnEjecucion){
			dc.drawText(105, 74, msgFontSmall, Ui.loadResource(Rez.Strings.capturandoDatos), just);
		}else if (media!=null){
			dc.drawText(155, 74, msgFontMedium, Ui.loadResource(Rez.Strings.vo2maxSpeed), just);
		}else if(testDetenido){
			dc.drawText(105, 74, msgFontMedium, Ui.loadResource(Rez.Strings.tabToRestart), just);
		}else{
			dc.drawText(105, 74, msgFontMedium, Ui.loadResource(Rez.Strings.tabToStart), just);
		}
				
		//System.println(app.heartRate + " - " + app.speed + " - " + Activity.getActivityInfo().currentHeartRate );
    }

    
    function empezarTest(){
    	testEnEjecucion=true;
    	
    	Snsr.setEnabledSensors( [Snsr.SENSOR_HEARTRATE] );
		Snsr.enableSensorEvents( method(:onSnsr) );	
		
		//var options = { :name => "Vo2maxSpeed"  };
		//activityrec=ActivityRecording.createSession(options);
		//activityrec.start();
			 	
    	tiempoInicioTest=Time.now().value();
    	timerTest= new Timer.Timer();
    	timerTest.start(method(:timerCallback),tiempoDuracionTest*1000,false);
    	 	
    	System.println("Empezando test Vo2maxSpeed");
    }
    
    //no hace bien la detencion cuando esta en modo de estiamcion continua
    function detenerTest(){
    	testDetenido=true;
    	timerTest.stop();
    	tiempoTestDetenido=Time.now().value();
		//activityrec.stop();
		//activityrec.save();
    	System.println("Detener test");
    }
    
    function continuarTest(){
    	testDetenido=false;
    	tiempoTestReanudado=Time.now().value();
    	
    	//se reinicia el timer que llama a la funcion callback de finalizartest, al tiempo de duracion del test
		//se le resta se le resta el tiempo que el test llevaba ejecutandose
		if(primeraMuestra==true){
    		timerTest.start(method(:timerCallback),(tiempoDuracionTest -(tiempoTestDetenido-tiempoInicioTest))*1000,false);
    	}else{
    		timerTest.start(method(:timerCallback),1*1000,false);
    	}
    	
    	System.println("Continuar test");
    }
        
    function timerCallback(){	

    	var heartRateReserve=maxHeartRate-restingHeartRate;	
    	//aux=current runnig heart rate as a percentage of hr reserve
    	var aux=(app.heartRate-restingHeartRate)/heartRateReserve;
    	var estimacionVo2maxSpeed=app.speed/aux;
    	
		acumuladorVo2maxSpeed=acumuladorVo2maxSpeed+estimacionVo2maxSpeed;
		contadorVo2maxSpeedMuestras=contadorVo2maxSpeedMuestras+1;
		media=acumuladorVo2maxSpeed/contadorVo2maxSpeedMuestras;
            	
		System.println("max hr "+maxHeartRate);
		System.println("resting hr "+restingHeartRate);
		System.println("reserve hr "+heartRateReserve);
		System.println("current hr "+app.heartRate);
		System.println("percent. of hr reserve "+ aux);
		System.println("Vo2maxSpeed "+ media);

		primeraMuestra=false;
		//estimacion continua despues de la primera
    	timerTest.start(method(:timerCallback),1*1000,false);

    	Ui.requestUpdate();
    }
     
    function onSnsr(sensor_info){
    	if(sensor_info.heartRate!=null){
    		app.heartRate=sensor_info.heartRate;
    	}
    	
    	if(sensor_info.speed!=null){
    		app.speed=sensor_info.speed;
    	}
    	Ui.requestUpdate();
    	return true; 
    }  
}





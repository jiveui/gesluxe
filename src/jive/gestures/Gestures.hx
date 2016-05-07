package jive.gestures;

import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import jive.gestures.core.GesturesManager;
import jive.gestures.core.GestureState;
import jive.gestures.core.TouchesManager;
/**
 * ...
 * @author Josu Igoa
 */

class Gestures
{
	static inline var MOUSE_TOUCH_POINT_ID:UInt = 0;
	static var touchesManager(null, set):TouchesManager;
	static public function set_touchesManager(tm:TouchesManager):TouchesManager { touchesManager = tm; return tm; }

	static public var gesturesManager:GesturesManager;
	static var _touchesManager:TouchesManager;

	public function new()
	{
	}

	static public function init()
	{
		GestureState.initStates();
		gesturesManager = new GesturesManager();
		_touchesManager = new TouchesManager(gesturesManager);

		

		//#if web
		// desktop web browsers
		//Luxe.on(luxe.Ev.mousedown, onmousedown);
		// mobile web browsers
		//Luxe.on(luxe.Ev.touchdown, ontouchdown);
		//Luxe.on(luxe.Ev.touchmove, ontouchmove);
		//Luxe.on(luxe.Ev.touchup, ontouchup);
		//#elseif mobile
		//Luxe.on(luxe.Ev.touchdown, ontouchdown);
		//Luxe.on(luxe.Ev.touchmove, ontouchmove);
		//Luxe.on(luxe.Ev.touchup, ontouchup);
		//#else
		//Luxe.on(luxe.Ev.mousedown, onmousedown);
		//#end
	}

	static function ontouchdown(event:TouchEvent)
	{
		/*
		 * state : InteractState.down,
			timestamp : timestamp,
			touch_id : touch_id,
			x : x,
			y : y,
			dx : x,
			dy : y,
			pos : _touch_pos*/
		// Original: _touchesManager.onTouchBegin(event.touchPointID, event.pos.x * Luxe.screen.w, event.pos.y * Luxe.screen.h); //, event.target as InteractiveObject);
		_touchesManager.onTouchBegin(event.touchPointID, event.localX, event.localY); //, event.target as InteractiveObject);
	}

	static function ontouchmove(event:TouchEvent)
	{
		_touchesManager.onTouchMove(event.touchPointID, event.localX, event.localY);
	}

	static function ontouchup(event:TouchEvent)
	{
		_touchesManager.onTouchEnd(event.touchPointID, event.localX, event.localY);
	}

	static function onmousedown(event:MouseEvent)
	{
		var touchAccepted:Bool = _touchesManager.onTouchBegin(MOUSE_TOUCH_POINT_ID, event.localX, event.localY);

		if (touchAccepted)
			addmouselisteners();
	}

	static private function onmousemove(event:MouseEvent)
	{
		_touchesManager.onTouchMove(MOUSE_TOUCH_POINT_ID, event.localX, event.localY);
	}

	static private function onmouseup(event:MouseEvent)
	{
		_touchesManager.onTouchEnd(MOUSE_TOUCH_POINT_ID, event.localX, event.localY);

		if (_touchesManager.activeTouchesCount == 0)
			removemouselisteners();
	}

	static function addmouselisteners()
	{
		//Luxe.core.emitter.on(luxe.Ev.mousemove, onmousemove);
		//Luxe.core.emitter.on(luxe.Ev.mouseup, onmouseup);
	}

	static function removemouselisteners()
	{
		//Luxe.core.emitter.off(luxe.Ev.mousemove, onmousemove);
		//Luxe.core.emitter.off(luxe.Ev.mouseup, onmouseup);
	}

	static public function dispose()
	{
		gesturesManager.removeAllGestures();
		gesturesManager = null;
		touchesManager = null;

		//Luxe.core.emitter.off(luxe.Ev.touchdown, ontouchdown);
		//Luxe.core.emitter.off(luxe.Ev.touchmove, ontouchmove);
		//Luxe.core.emitter.off(luxe.Ev.touchup, ontouchup);

		//Luxe.core.emitter.off(luxe.Ev.mousedown, onmousedown);
		removemouselisteners();
	}
}

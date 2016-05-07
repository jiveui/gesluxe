package jive.gestures.core;

import jive.Component;
import jive.gestures.core.Gesture;
import jive.gestures.utils.GestureUtils;

/**
 * ...
 * @author Josu Igoa
 */
class GesturesManager
{
	var _gesturesMap:Map<Gesture, Bool>;
	var _gesturesForTouchMap:Map<Touch, Array<Gesture>>;
	var _dirtyGesturesCount:UInt = 0;
	var _dirtyGesturesMap:Map<Gesture, Bool>;
	public var target(default, null): Component;
	
	public function new(component:Component) 
	{
		_gesturesMap = new Map<Gesture, Bool>();
		_gesturesForTouchMap = new Map<Touch, Array<Gesture>>();
		_dirtyGesturesMap = new Map<Gesture, Bool>();
		target = component;
	}
	
	public function addGesture(gesture:Gesture)
	{
		if (gesture == null)
			throw "Argument 'gesture' must be not null.";
		
		gesture.init(this);
		_gesturesMap[gesture] = true;
	}
	
	public function removeGesture(gesture:Gesture)
	{
		if (gesture == null)
			throw "Argument 'gesture' must be not null.";
		
		_gesturesMap.remove(gesture);
		
		gesture.reset();
	}
	
	public function removeAllGestures()
	{
		for (g in _gesturesMap.keys())
			removeGesture(g);
	}
	
	public function scheduleGestureStateReset(gesture:Gesture)
	{
		if (!_dirtyGesturesMap[gesture])
		{
			_dirtyGesturesMap[gesture] = true;
			_dirtyGesturesCount++;
			// Luxe.next(resetDirtyGestures);
			// TODO: check 
			resetDirtyGestures();
		}
	}
	
	function resetDirtyGestures()
	{
		for (gesture in _dirtyGesturesMap.keys())
		{
			if (_dirtyGesturesMap[gesture])
			{
				gesture.reset();
				_dirtyGesturesMap[gesture] = false;
				_dirtyGesturesCount--;
			}
		}
	}
	
	public function onGestureRecognized(gesture:Gesture)
	{
		for (otherGesture in _gesturesMap.keys())
		{
			// conditions for otherGesture "own properties"
			if (otherGesture != gesture &&
				otherGesture.enabled &&
				otherGesture.state == GestureState.POSSIBLE)
			{
				// conditions for gestures relations
				if ((gesture.canPreventGesture == null || gesture.canPreventGesture(otherGesture)) &&
					(otherGesture.canBePreventedByGesture == null || otherGesture.canBePreventedByGesture(gesture)) &&
					(gesture.gesturesShouldRecognizeSimultaneously == null || !gesture.gesturesShouldRecognizeSimultaneously(gesture, otherGesture)) &&
					(otherGesture.gesturesShouldRecognizeSimultaneously == null || !otherGesture.gesturesShouldRecognizeSimultaneously(otherGesture, gesture)))
				{
					otherGesture.setState(GestureState.FAILED);
				}
			}
		}
	}
	
	public function onTouchBegin(touch:Touch)
	{
		var gesture:Gesture;
		
		// This vector will contain active gestures for specific touch during all touch session.
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		if (gesturesForTouch == null)
			gesturesForTouch = new Array<Gesture>();
		else
		{
			// touch object may be pooled in the future
			GestureUtils.clearArray(gesturesForTouch);
		}
		
		for (gesture in _gesturesMap.keys()) 
		{
			if (gesture.enabled &&
				(gesture.gestureShouldReceiveTouch == null ||
				 gesture.gestureShouldReceiveTouch(gesture, touch)))
			{
				//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
				gesturesForTouch.unshift(gesture);
			}
		}
		
		// Then we populate them with this touch and event.
		// They might start tracking this touch or ignore it (via Gesture#ignoreTouch())
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			// Check for state because previous (i+1) gesture may already abort current (i) one
			if (!_dirtyGesturesMap[gesture])
				gesture.touchBeginHandler(touch);
			else
				gesturesForTouch.splice(i, 1);
		}
		
		_gesturesForTouchMap.set(touch, gesturesForTouch);
	}
	
	
	public function onTouchMove(touch:Touch)
	{
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		var gesture:Gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				gesture.touchMoveHandler(touch);
			else
			{
				// gesture is no more interested in this touch (e.g. ignoreTouch was called)
				gesturesForTouch.splice(i, 1);
			}
		}
	}
	
	
	public function onTouchEnd(touch:Touch)
	{
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		var gesture:Gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				gesture.touchEndHandler(touch);
		}
		
		GestureUtils.clearArray(gesturesForTouch);
		
		_gesturesForTouchMap.remove(touch);//TODO: remove this once Touch objects are pooled
	}
	
	
	public function onTouchCancel(touch:Touch)
	{
		var gesturesForTouch:Array<Gesture> = _gesturesForTouchMap[touch];
		var gesture:Gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				gesture.touchCancelHandler(touch);
		}
		
		GestureUtils.clearArray(gesturesForTouch);
		
		_gesturesForTouchMap.remove(touch);//TODO: remove this once Touch objects are pooled
	}
}
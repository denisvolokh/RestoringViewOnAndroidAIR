package views
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.states.AddItems;
	import mx.states.State;
	
	import spark.components.RadioButtonGroup;
	import spark.components.View;
	import spark.events.ViewNavigatorEvent;
	
	use namespace mx_internal;
	
	public class RestoringView extends View
	{
		public function RestoringView()
		{
			super();
			
			addEventListener(ViewNavigatorEvent.VIEW_ACTIVATE, onActivateEventHandler);
			addEventListener(ViewNavigatorEvent.VIEW_DEACTIVATE, onDeactivateHandler);
		}
		
		public var isStoringActivated : Boolean = true;
		
		public var controlsForSaving : Array = [];
		
		private var supportedControls : Array = ["TextInput","CheckBox","ButtonBar","HSlider", "RadioButtonGroup", "RadioButton"];
		
		private var supportedControlsDefaultProperty : Array = ["text", "selected", "selectedIndex", "value", "selectedValue", "selected"];
		
		protected function saveProperty(target : *, propertyName : String = null, propertyValue : * = null):void
		{
			if (!data) data = new Object();
			
			trace(getQualifiedClassName(target));
			var name : String = getQualifiedClassName(target).split("::")[1];
			trace(name);
			trace(target.toString())
			
			if (!propertyName)
			{
				propertyName = supportedControlsDefaultProperty[supportedControls.indexOf(name)]
			}
			
			if (propertyValue)
			{
				data[target.id] = [propertyName, propertyValue];	
			}
			else
			{
				if (!("id" in target))
					data[target.name] = [propertyName, target[propertyName]];
				else
					data[target.id] = [propertyName, target[propertyName]];
			}
		}
		
		protected function readProperty(target : *, propertyName : String = null):void
		{
			if (!data)
				return;			
			
			var idName : String = (!("id" in target))? target.name:target.id;
			if (idName in data)
			{
				if (propertyName != null)
				{
					target[propertyName] = data[idName][1];	
				}
				else
				{
					target[data[idName][0]] = data[idName][1];				
				}
			}
		}
		
		protected function onActivateEventHandler(event : ViewNavigatorEvent):void
		{
			if (!data)
				return;
			
			isStoringActivated = data["_this"];
			
			if (!isStoringActivated)
				return
			
			for (var i : int = 0; i < controlsForSaving.length; i++)
			{
				var ui : * = controlsForSaving[i];
				var idName : String = (!("id" in ui))? ui.name:ui.id;
				if (idName in data)
				{
					readProperty(ui)
				}
			}
		}
		
		protected function onDeactivateHandler(event : ViewNavigatorEvent):void
		{
			if (!data) data = new Object();
			
			data["_this"] = isStoringActivated;
			if (!isStoringActivated)
			{
				return;	
			}
			
			for (var i : int = 0; i < controlsForSaving.length; i++)
			{
				var ui : * = controlsForSaving[i];
				saveProperty(ui);
			}
		}
		
		private function findControlsRecursive(current:IVisualElementContainer, controls:ArrayCollection):void
		{
			for(var idx:int = 0; idx < current.numElements; idx++)
			{
				var child:IVisualElement = current.getElementAt(idx);
				controls.addItem(child);
				var childContainer:IVisualElementContainer = child as IVisualElementContainer;
				if(childContainer)
				{
					findControlsRecursive(childContainer, controls);
				}
			} 
		}
		
		public function findControls():ArrayCollection  
		{
			var controls:ArrayCollection = new ArrayCollection();
			findControlsRecursive(this, controls);
			return controls;
		}
	}
}
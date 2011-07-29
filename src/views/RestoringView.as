package views
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
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
		
		private var supportedControls : Array = ["TextInput","CheckBox","ButtonBar","HSlider", "RadioButtonGroup", "RadioButton"];
		
		private var supportedControlsDefaultProperty : Array = ["text", "selected", "selectedIndex", "value", "selectedValue", "selected"];
		
		public var isStoringActivated : Boolean = true;
		
		private var _savedControls : Array = [];
		
		public function get savedControls():Array
		{
			return _savedControls;
		}

		public function set savedControls(value:Array):void
		{
			_savedControls = value;
			
			if (!data)
			{
				data = new Object();
			}
		}
		
		protected function saveProperty(target : *, propertyName : String = null, propertyValue : * = null):void
		{
			if (savedControls.indexOf(target) == -1)
			{
				var manuallyAdded : Array = (data.hasOwnProperty("manuallyAdded")) ? data["manuallyAdded"] : [];
				if (manuallyAdded.indexOf(target) == -1)
				{
					manuallyAdded.push(target);
					data["manuallyAdded"] = manuallyAdded;	
				}
			}
			
			var name : String = getQualifiedClassName(target).split("::")[1];
			if (!propertyName)
			{
				propertyName = supportedControlsDefaultProperty[supportedControls.indexOf(name)];
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
			var idName : String = (!("id" in target))? target.name:target.id;
			if (idName in data)
			{
				if (propertyName != null)
				{
					target[propertyName] = data[idName][1];	
				}
				else
				{
					var prop : * = data[idName][0];
					var value : * = data[idName][1];
					target[prop] = value;				
				}
			}
		}
		
		protected function onActivateEventHandler(event : ViewNavigatorEvent):void
		{
			if (data.hasOwnProperty("_this"))
			{
				isStoringActivated = data["_this"];	
			}
			
			if (!isStoringActivated)
				return;
			
			var i : int;
			for (i = 0; i < savedControls.length; i++)
			{
				var ui : * = savedControls[i];
				var idName : String = (!("id" in ui))? ui.name:ui.id;
				if (idName in data)
				{
					readProperty(ui)
				}
			}
			
			if (data.hasOwnProperty("manuallyAdded"))
			{
				var controls : ArrayCollection = findControls();
				var manuallyAddedControls : Array = data["manuallyAdded"];
				for (i = 0; i < manuallyAddedControls.length; i++)
				{
					var manControl : * = manuallyAddedControls[i];
					var manControlIdName : String = (!("id" in manControl))? manControl.name:manControl.id;
					var controlItem : * = findControlByName(manControlIdName);
					
					if (manControlIdName in data)
					{
						readProperty(controlItem);
					}
				}
				
				data["manuallyAdded"] = [];
			}
		}
		
		protected function onDeactivateHandler(event : ViewNavigatorEvent):void
		{
			data["_this"] = isStoringActivated;
			if (!isStoringActivated)
				return;	
			
			for (var i : int = 0; i < savedControls.length; i++)
			{
				var ui : * = savedControls[i];
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
		
		private function findControlByName(name : String, controls : ArrayCollection = null):*
		{
			controls = findControls();
			for each (var item : * in controls)
			{
				if (item.id == name)
				{
					return item
				}
				
				if (item.name == name)
				{
					return item
				}
			}
			
			return null;
		}
		
		public function findControls():ArrayCollection  
		{
			var controls:ArrayCollection = new ArrayCollection();
			findControlsRecursive(this, controls);
			return controls;
		}
	}
}
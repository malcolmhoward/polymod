package;
import flash.display.DisplayObject;
import flash.text.TextFieldType;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormatAlign;
import openfl.utils.AssetType;
import polymod.library.ModAssetLibrary;
import sys.FileSystem;

/**
 * ...
 * @author 
 */
class Demo extends Sprite
{
	private var widgets:Array<ModWidget>=[];
	private var callback:Array<String>->Void;
	private var stuff:Array<Dynamic> = [];
	
	public function new(callback:Array<String>->Void) 
	{
		super();
		
		this.callback = callback;
		
		makeButtons();
		drawImages();
		drawText();
	}
	
	public function destroy()
	{
		for (w in widgets)
		{
			w.destroy();
		}
		callback = null;
		removeChildren();
	}
	
	public function refresh()
	{
		for (thing in stuff)
		{
			removeChild(cast thing);
		}
		stuff.splice(0, stuff.length);
		drawImages();
		drawText();
	}
	
	private function makeButtons()
	{
		var modDir:String = "../../../mods";
		var mods = FileSystem.readDirectory(modDir);
		var xx = 10;
		var yy = 200;
		for (mod in mods)
		{
			var w = new ModWidget(mod, onWidgetMove);
			w.x = xx;
			w.y = yy;
			
			widgets.push(w);
			
			xx += Std.int(w.width) + 10;
			addChild(w);
		}
		
		updateWidgets();
	}
	
	private function updateWidgets()
	{
		if (widgets == null) return;
		for (i in 0...widgets.length)
		{
			var showLeft = i != 0;
			var showRight = i != widgets.length - 1;
			widgets[i].showButtons(showLeft, showRight);
		}
	}
	
	private function onWidgetMove(w:ModWidget, i:Int)
	{
		if (i != 0)
		{
			var temp = widgets.indexOf(w);
			var newI = temp + i;
			if (newI < 0 || newI >= widgets.length)
			{
				return;
			}
			var other = widgets[newI];
			
			var oldX = w.x;
			var oldY = w.y;
			
			widgets[newI] = w;
			widgets[temp] = other;
			
			w.x = other.x;
			w.y = other.y;
			
			other.x = oldX;
			other.y = oldY;
		}
		
		if (callback != null)
		{
			var theMods = [];
			for (w in widgets)
			{
				if (w.active)
				{
					theMods.push(w.mod);
				}
			}
			callback(theMods);
		}
		
		updateWidgets();
	}
	
	private function drawImages()
	{
		var xx = 10;
		var yy = 10;
		
		var images = Assets.list(AssetType.IMAGE);
		images.sort(function(a:String, b:String):Int{
			if (a < b) return -1;
			if (a > b) return  1;
			return 0;
		});
		
		for (image in images)
		{
			var bData = Assets.getBitmapData(image);
			var bmp = new Bitmap(bData);
			bmp.x = xx;
			bmp.y = yy;
			
			var text = getText();
			
			text.width = bmp.width;
			text.text = image;
			text.x = xx;
			text.y = bmp.y + bmp.height;
			
			addChild(bmp);
			addChild(text);
			stuff.push(bmp);
			stuff.push(text);
			
			xx += Std.int(bmp.width + 10);
		}
	}
	
	private function drawText()
	{
		var xx = 350;
		var yy = 10;
		
		var texts = Assets.list(AssetType.TEXT);
		
		for (t in texts)
		{
			var isXML:Bool = false;
			var align = TextFormatAlign.CENTER;
			if (t.indexOf("xml") != -1)
			{
				isXML = true;
				align = TextFormatAlign.LEFT;
			}
			
			var text = getText(align);
			text.x = xx;
			text.y = yy;
			text.height = 100;
			text.border = true;
			text.width = 150;
			if (isXML)
			{
				text.width = 250;
			}
			text.wordWrap = true;
			text.multiline = true;
			
			var str = Assets.getText(t);
			text.text = (str != null ? str : "null");
			
			var caption = getText();
			caption.x = xx;
			caption.y = text.y + text.height;
			caption.text = t;
			caption.width = text.width;
			
			addChild(text);
			addChild(caption);
			stuff.push(text);
			stuff.push(caption);
			
			xx += Std.int(text.width + 10);
		}
	}
	
	private function getText(align:TextFormatAlign = CENTER):TextField
	{
		var text = new TextField();
		var dtf = text.defaultTextFormat;
		dtf.align = align;
		text.setTextFormat(dtf);
		text.selectable = false;
		return text;
	}
}
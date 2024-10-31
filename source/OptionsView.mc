import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

class OptionsView extends View {

    public static var selected;

    function initialize() {
        View.initialize();
        
        selected = 0;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        drawHeader(dc, W, H, "Options");

        dc.drawText(W / 2.7, H / 4, Graphics.FONT_MEDIUM, "Stats:", Graphics.TEXT_JUSTIFY_RIGHT);
        drawValue(dc, INSTINCT_MODE ? W / 10 : W / 2.4, INSTINCT_MODE ? H / 2.5 : H / 4,
                  data.statsMode == 0 ? "Records" : data.statsMode == 1 ? "7 Day Avg" : "1 Day Avg", selected == 0, Graphics.FONT_MEDIUM);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H * 0.69, Graphics.FONT_XTINY,
                    "Memory: " + (System.getSystemStats().usedMemory / 1000) + "kB / " + (System.getSystemStats().totalMemory / 1000) + "kB",
                    Graphics.TEXT_JUSTIFY_CENTER);
        
        drawValue(dc, W / 2.65, H * 0.82, "SAVE", selected == 1, Graphics.FONT_SMALL);
    }
}
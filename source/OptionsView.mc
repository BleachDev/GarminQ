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
        var hs = H / 8;
        var XTINY_H = dc.getFontHeight(Graphics.FONT_XTINY) * 0.75;

        drawHeader(dc, W, H, "Options");

        dc.drawText(W / 2.7, H / 4, Graphics.FONT_MEDIUM, "Stats:", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W / 2.7, H / 4 + hs, Graphics.FONT_XTINY, "Trigger In", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W / 2.7, H / 4 + hs + XTINY_H, Graphics.FONT_XTINY, "Activity:", Graphics.TEXT_JUSTIFY_RIGHT);

        drawValue(dc, W / 2.4, H / 4, data.statsMode == 0 ? "Records" : data.statsMode == 1 ? "7 Day Avg" : "1 Day Avg", selected == 0, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 2.4, H / 4 + hs, data.triggerInActivity ? "Yes" : "No", selected == 1, Graphics.FONT_MEDIUM);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H * 0.69, Graphics.FONT_XTINY,
                    "Memory: " + (System.getSystemStats().usedMemory / 1000) + "kB / " + (System.getSystemStats().totalMemory / 1000) + "kB",
                    Graphics.TEXT_JUSTIFY_CENTER);
        
        drawValue(dc, W / 2.65, H * 0.82, "SAVE", selected == 2, Graphics.FONT_SMALL);
    }
}
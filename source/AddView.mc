import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class AddView extends View {

    public static var modifying; // Index we're modifing or -1 to add an experiment
    public static var selected;

    public static var title;     // 0
    public static var input;    // 1 + 2

    public static var gap;       // 4
    public static var startH;    // 5
    public static var endH;      // 6
    public static var days;      // 7

    function initialize(modifying) {
        View.initialize();
        self.modifying = modifying;
        selected = 0;
        title = modifying == -1 ? "New Exp " + (data.experiments.size() + 1) : data.experiments[modifying][EX_NAME];
        input = modifying == -1 ? EX_INPUT_V[0] : data.experiments[modifying][EX_INPUT];
        gap = modifying == -1 ? 10 : data.experiments[modifying][EX_GAP];
        startH = modifying == -1 ? 9 : data.experiments[modifying][EX_START_H];
        endH = modifying == -1 ? 21 : data.experiments[modifying][EX_END_H];
        days = modifying == -1 ? 0 : data.experiments[modifying][EX_DAYS];
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var MEDIUM_H = dc.getFontHeight(Graphics.FONT_MEDIUM) * 0.9;
        var MEDIUM_W = dc.getTextWidthInPixels("0", Graphics.FONT_MEDIUM) * 1.1;

        drawHeader(dc, W, H, "Add Exp.");
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

        if (selected <= 3) {
            // Page 1
            dc.drawText(W / 2.7, H / 4, Graphics.FONT_MEDIUM, "Title:", Graphics.TEXT_JUSTIFY_RIGHT);
            dc.drawText(W / 2.7, H / 4 + MEDIUM_H, Graphics.FONT_MEDIUM, "Input:", Graphics.TEXT_JUSTIFY_RIGHT);

            drawValue(dc, W / 2.4, H / 4, title, selected == 0, Graphics.FONT_MEDIUM);
            drawValue(dc, W / 2.4, H / 4 + MEDIUM_H, input.size() == 2 ? "Y/N" : "1-" + input.size(), selected == 1, Graphics.FONT_MEDIUM);
            drawValue(dc, W / 2.4, H / 4 + MEDIUM_H * 2, "Values..", selected == 2, Graphics.FONT_MEDIUM);
        } else {
            // Page 2
            var manual = gap == 2147483647;

            dc.drawText(W / 2.7, H / 4, Graphics.FONT_MEDIUM, "Gap:", Graphics.TEXT_JUSTIFY_RIGHT);
            drawValue(dc, W / 2.4, H / 4, manual ? "Manual" : gap + "m", selected == 4, Graphics.FONT_MEDIUM);
            
            if (!manual) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(W / 2.7, H / 4 + MEDIUM_H, Graphics.FONT_MEDIUM, "Hours:", Graphics.TEXT_JUSTIFY_RIGHT);

                if (startH > endH) {
                    dc.drawText(W / 2.4 + MEDIUM_W * 6, H / 4 + MEDIUM_H, Graphics.FONT_MEDIUM, "!!", Graphics.TEXT_JUSTIFY_LEFT);
                }

                drawValue(dc, W / 2.4, H / 4 + MEDIUM_H, startH.format("%02d"), selected == 5, Graphics.FONT_MEDIUM);
                drawValue(dc, W / 2.4 + MEDIUM_W * 2, H / 4 + MEDIUM_H, "-", false, Graphics.FONT_MEDIUM);
                drawValue(dc, W / 2.4 + MEDIUM_W * 3, H / 4 + MEDIUM_H, endH.format("%02d"), selected == 6, Graphics.FONT_MEDIUM);
                drawValue(dc, W / 2.4, H / 4 + MEDIUM_H * 2, EX_DAYS_S[days], selected == 7, Graphics.FONT_MEDIUM);
            }
        }

        drawValue(dc, W / 2.65, H * 0.82, selected <= 3 ? "1/2 >>" : "SAVE", selected == 3 || selected == 8, Graphics.FONT_SMALL);
    }
}
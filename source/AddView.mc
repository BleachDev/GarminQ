import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class AddView extends View {

    public static var modifying; // Index we're modifing or -1 to add an experiment
    public static var selected;
    public static var title;
    public static var input;
    public static var gap;
    public static var startH;
    public static var endH;
    public static var days;

    function initialize(modifying) {
        View.initialize();
        self.modifying = modifying;
        selected = 0;
        title = modifying == -1 ? "New Exp" : data.experiments[modifying][EX_NAME];
        input = modifying == -1 ? 0 : data.experiments[modifying][EX_INPUT];
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
        //var TINY_H = dc.getFontHeight(Graphics.FONT_TINY) * 0.9;

        drawHeader(dc, W, H, "Add Exp.");

        var hs = H / 8;
        dc.drawText(W / 2.7, H / 4, Graphics.FONT_MEDIUM, "Title:", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W / 2.7, H / 4 + hs, Graphics.FONT_MEDIUM, "Input:", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W / 2.7, H / 4 + hs * 2, Graphics.FONT_MEDIUM, "Gap:", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(W / 2.7, H / 4 + hs * 3, Graphics.FONT_MEDIUM, "Hours:", Graphics.TEXT_JUSTIFY_RIGHT);

        drawValue(dc, W / 2.4, H / 4, title, selected == 0, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 2.4, H / 4 + hs, EX_INPUT_S[input], selected == 1, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 2.4, H / 4 + hs * 2, gap + "m", selected == 2, Graphics.FONT_MEDIUM);

        drawValue(dc, W / 2.4, H / 4 + hs * 3, startH.format("%02d"), selected == 3, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 2.4 + dc.getTextWidthInPixels("00", Graphics.FONT_MEDIUM), H / 4 + hs * 3, "-", false, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 2.4 + dc.getTextWidthInPixels("00-", Graphics.FONT_MEDIUM), H / 4 + hs * 3, endH.format("%02d"), selected == 4, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 2.4 + dc.getTextWidthInPixels("00-00 ", Graphics.FONT_MEDIUM), H / 4 + hs * 3, EX_DAYS_S[days], selected == 5, Graphics.FONT_MEDIUM);

        drawValue(dc, W / 2.7, H * 0.82, "SAVE", selected == 6, Graphics.FONT_SMALL);
    }
}
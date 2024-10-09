import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class NotificationView extends View {

    public static var ex as Experiment;
    public static var value = 0;
    public static var modifying = -1; // Index we're modifing or -1 to add a record
    public static var done = false;

    function initialize(ex, modifying) {
        View.initialize();
        self.ex = ex;
        self.value = 0;
        self.modifying = modifying;
        self.done = false;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        drawHeader(dc, W, H, ex[EX_NAME]);

        var count = EX_INPUT_V[ex[EX_INPUT]];
        var countf = count - 1.0;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(W / 8 - W / 40, H / 2 - H / 60, W - W / 4 + W / 20, H / 30, W / 60);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(W / 8 - W / 40, H / 2 - H / 60, (W - W / 4) * (value / countf), H / 30, W / 60);
        
        for (var i = 0; i < count; i++) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 8 + (W - W / 4) * (i / countf), H / 2 + H / 30, Graphics.FONT_SMALL,
                        count == 2 ? (i == 0 ? "No" : "Yes") : i + 1, Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(INSTINCT_MODE ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(W / 8 + (W - W / 4) * (i / countf), H / 2 - H / 60, W / 60, H / 30);
        }

        dc.fillCircle(W / 8 + (W - W / 4) * (value / countf), H / 2, W / 25);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(W / 8 + (W - W / 4) * (value / countf), H / 2, W / 30);

        drawValue(dc, W / 2.65, H * 0.82, "SAVE", done, Graphics.FONT_SMALL);
    }
}
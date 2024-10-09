import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

class PurgeView extends View {

    private static var MONTHS as Array<String?> = [ null, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
    public static var selected;
    public static var day;
    public static var month;
    public static var year;
    public static var count;

    function initialize() {
        View.initialize();
        
        selected = 0;
        var today = Gregorian.info(new Time.Moment(Time.now().value() + 86400), Time.FORMAT_SHORT);
        day = today.day;
        month = today.month;
        year = today.year;
        count = countRecords(false);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        drawHeader(dc, W, H, "Purge");

        dc.drawText(W / 2, H / 3.8, Graphics.FONT_TINY, "Purge Records Before", Graphics.TEXT_JUSTIFY_CENTER);

        drawValue(dc, W / 5, H / 2.6, day.format("%02d"), selected == 0, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 5 + dc.getTextWidthInPixels("00-", Graphics.FONT_MEDIUM), H / 2.6, MONTHS[month], selected == 1, Graphics.FONT_MEDIUM);
        drawValue(dc, W / 5 + dc.getTextWidthInPixels("00--" + MONTHS[month], Graphics.FONT_MEDIUM), H / 2.6, year.toString(), selected == 2, Graphics.FONT_MEDIUM);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H * 0.68, Graphics.FONT_TINY, "(" + count + " Records)", Graphics.TEXT_JUSTIFY_CENTER);

        drawValue(dc, W / 2.65, H * 0.82, "SAVE", selected == 3, Graphics.FONT_SMALL);
    }

    public static function countRecords(remove) {
        var timeMs = Gregorian.moment({
            :year => PurgeView.year, :month => PurgeView.month, :day => PurgeView.day, :hour => 0, :minute => 0, :second => 0
        }).value();

        var count = 0;
        for (var i = 0; i < data.experiments.size(); i++) {
            var records = data.experiments[i][EX_RECORDS] as Array<Record>;
            for (var r = 0; r < records.size(); r++) {
                if (records[r][RE_TIME] < timeMs) {
                    if (remove) {
                        records.remove(records[r]);
                        r--;
                    }
                    count++;
                }
            }
        }
        return count;
    }
}
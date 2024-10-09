import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

// object oriented programming? whats that?
// surely this won't have scalability issues..
typedef Experiment as [String, Number, Number, Number, Number, Number, Array<Record>];
typedef BgExperiment as [String, Number, Number, Number, Number, Number, Number];
typedef Record as [Number, Number, String, Number, Number];

var EX_NAME = 0;
var EX_INPUT = 1;
var EX_GAP = 2;
var EX_START_H = 3;
var EX_END_H = 4;
var EX_DAYS = 5;
var EX_RECORDS = 6;
var EX_BG_LAST_TRIGGER = 6;

var EX_INPUT_S as Array<String> = [ "1-5", "1-10", "Y/N" ];
var EX_INPUT_V as Array<Number> = [ 5, 10, 2 ];
var EX_DAYS_S as Array<String> = [ "All", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "M-F", "S-S" ];

var RE_TIME = 0;
var RE_VALUE = 1;
var RE_ACTIVITY = 2;
var RE_HR = 3;
var RE_BATTERY = 4;
class Data {

    // experiments = [
    //   Experiment [
    //     Name
    //     Input
    //     Gap
    //     StartHour
    //     EndHour
    //     Days
    //     Records [
    //       Time
    //       Value
    //       Activity Type (See: https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html, Sport Enum)
    //       Heart Rate
    //       Body Battery
    //     ]
    //   ]
    // ]
    public var experiments as Array<Experiment> = [];
    // Copy of experiments but instead of Records, the last value is a timestamp of the last trigger
    (:background)
    public var bgExperiments as Array<BgExperiment> = [];

    public var statsMode as Number = 0;

    function load() {
        if (Storage.getValue("experiments") != null) {
            experiments = Storage.getValue("experiments") as Array<[String, Number, Number, Number, Number, Number, Array<[Number, Number, String, Number, Number]>]>;
        }
        if (Storage.getValue("statsMode") != null) {
            statsMode = Storage.getValue("statsMode");
        }
    }

    (:background)
    function loadBg() {
        if (Storage.getValue("bgExperiments") != null) {
            bgExperiments = Storage.getValue("bgExperiments") as Array<[String, Number, Number, Number, Number, Number, Number]>;
        }
    }

    function saveExp() {
        Storage.setValue("experiments", experiments as Array);

        bgExperiments = [];
        for (var i = 0; i < experiments.size(); i++) {
            var ex = experiments[i] as Experiment;
            var re = ex[EX_RECORDS] as Array<Record>;
            bgExperiments.add([ ex[0], ex[1], ex[2], ex[3], ex[4], ex[5], re.size() == 0 ? 0 : re[re.size() - 1][RE_TIME] ]);
        }
        Storage.setValue("bgExperiments", bgExperiments as Array);
        Background.registerForTemporalEvent(new Duration(5 * 60));
    }
}
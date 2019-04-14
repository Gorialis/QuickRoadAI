
class QuickRoadAI extends AIInfo {
    function GetAuthor()      { return "Devon (Gorialis) R"; }
    function GetName()        { return "QuickRoadAI"; }
    function GetShortName()   { return "QRAI"; }
    function GetDescription() { return "An AI that tries to build intra-city road infrastructure, fast."; }
    function GetVersion()     { return /* VERSION SPEC */ 0 /* END VERSION SPEC */; }
    function GetDate()        { return /* DATE SPEC */ "0000-00-00" /* END DATE SPEC */; }
    function CreateInstance() { return "QuickRoadAI"; }
    function GetSettings()    {}
}

RegisterAI(QuickRoadAI());

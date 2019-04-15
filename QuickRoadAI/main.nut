
class QuickRoadAI extends AIController
{
    name = null;
    ticks = 0;

    constructor() {
        require("engines.nut");
        require("finance.nut");
        require("towns.nut");
    }

    function Start();
};

function QuickRoadAI::AdvanceTicks(ticks) {
    if (ticks <= 1)
        ticks = 1;

    Sleep(ticks);
    this.ticks += ticks;
}

function QuickRoadAI::Advance() {
    this.AdvanceTicks(1);
}

function QuickRoadAI::IsTownMoneyAdequate() {
    local cargo = GetCargoType(AICargo.CC_PASSENGERS);
    if (cargo == null)
        return false;

    local engine = GetBestEngine(AIVehicle.VT_ROAD, cargo, GetAcquireableBalance());
    if (engine == null)
        return false;

    local engine_cost = AIEngine.GetPrice(engine);
    local depot_cost = AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_DEPOT);
    local station_cost = AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_BUS_STOP);

    local station_set_cost = station_cost + (2 * engine_cost);
    local town_cost = depot_cost + (8 * station_set_cost);

    return GetAcquireableBalance() > (2 * town_cost);
}

function QuickRoadAI::ScanLargestTowns() {
    // Get all towns on the map
    local all_towns = AITownList();

    // Remove towns that do not like us
    all_towns.Valuate(AITown.GetRating, AICompany.COMPANY_SELF);
    all_towns.RemoveValue(AITown.TOWN_RATING_APPALLING);
    all_towns.RemoveValue(AITown.TOWN_RATING_VERY_POOR);
    all_towns.RemoveValue(AITown.TOWN_RATING_POOR);

    // Sort by greatest population first
    all_towns.Valuate(AITown.GetPopulation);
    all_towns.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);

    local cargo = GetCargoType(AICargo.CC_PASSENGERS);

    for (local town = all_towns.Begin(); all_towns.HasNext(); town = all_towns.Next()) {
        this.Advance();
        AILog.Info("[" + AITown.GetName(town) + "] Checking..");

        while (!IsTownMoneyAdequate()) {
            AILog.Info("[" + AITown.GetName(town) + "] I am out of money and cannot start building in this town yet.");
            AILog.Info("[" + AITown.GetName(town) + "] Waiting a while until I've got some money on hand..");
            AICompany.SetLoanAmount(0);
            this.AdvanceTicks(5000);
        }

        local summary = TownPlaceabilitySummary(town, cargo, AIStation.STATION_BUS_STOP);

        if (summary.depot_ops.len() > 0 && summary.station_ops.len() > 3) {
            AILog.Info("Found useable town: " + AITown.GetName(town) + "(" + AITown.GetPopulation(town) + ")");

            local depotTile = null;
            local depotMade = false;

            AcquireBalance(AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_DEPOT));

            foreach (depot in summary.depot_ops) {
                if (AIRoad.BuildRoadDepot(depot.tile, depot.front)) {
                    depotTile = depot.tile;
                    depotMade = true;
                    break;
                }
            }

            if (depotMade) {
                AILog.Info("[" + AITown.GetName(town) + "] Made depot.");

                local engine = GetBestEngine(AIVehicle.VT_ROAD, cargo, GetAcquireableBalance());

                if (engine != null) {
                    AILog.Info("[" + AITown.GetName(town) + "] Buying vehicles..");

                    local vehicles = [];

                    for (local vi = 0; vi < summary.station_ops.len() * 2; vi++) {
                        AcquireBalance(AIEngine.GetPrice(engine));

                        local vehicle = AIVehicle.BuildVehicle(depotTile, engine);
                        if (AIVehicle.IsValidVehicle(vehicle)) {
                            AILog.Info("[" + AITown.GetName(town) + "] Bought vehicle #" + (vi + 1));
                            vehicles.append(vehicle);
                        } else {
                            AILog.Info("[" + AITown.GetName(town) + "] Failed to buy vehicle #" + (vi + 1));
                        }
                    }

                    foreach (station in summary.station_ops) {
                        AcquireBalance(AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_BUS_STOP));

                        if (AIRoad.BuildDriveThroughRoadStation(station.tile, station.front, AIRoad.ROADVEHTYPE_BUS, AIBaseStation.STATION_NEW)) {
                            AILog.Info("[" + AITown.GetName(town) + "] Built road station.");

                            foreach (vehicle in vehicles) {
                                AIOrder.AppendOrder(vehicle, station.tile, AIOrder.AIOF_NONE);
                            }
                        } else {
                            AILog.Info("[" + AITown.GetName(town) + "] Was unable to build a road station..");
                        }
                    }

                    foreach (vehicle in vehicles) {
                        AIVehicle.StartStopVehicle(vehicle);
                    }
                }
            }
        }
    }
}

function QuickRoadAI::Start() {
    /* Give this AI a temporary generic name while we still haven't built anything */
    if (!AICompany.SetName("QuickRoadAI")) {
        local i = 2;
        while (!AICompany.SetName("QuickRoadAI #" + i)) {
            i++;
        }
    }

    AICompany.SetLoanAmount(0);
    AILog.Info("QuickRoadAI is ready for business.");

    while (true) {
        this.ScanLargestTowns();
    }
}
